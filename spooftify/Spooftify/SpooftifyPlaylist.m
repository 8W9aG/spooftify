/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyPlaylist.h"
#import "SpooftifyTrack.h"
#import "Spooftify.h"

static NSMutableArray* playlistPool = nil;

@interface SpooftifyPlaylist ()
-(id) initWithPlaylist:(struct playlist*)playlist;
@end

@implementation SpooftifyPlaylist

@synthesize playlistId;
@synthesize name;
@synthesize author;
@synthesize numberOfTracks;
@synthesize tracks;

+(void) initialize
{
    if(self == [SpooftifyPlaylist class])
    {
        playlistPool = [[NSMutableArray alloc] init];
    }
}

+(id) playlistWithId:(NSString*)playlistId
{
    for(SpooftifyPlaylist* playlist in playlistPool)
    {
        if([[playlist playlistId] isEqualToString:playlistId])
            return playlist;
    }
    
    char _playlistId[[playlistId length]+1];
    memset(_playlistId,'\0',[playlistId length]+1);
    strcpy(_playlistId,[playlistId UTF8String]);
    
    struct playlist* playlist = despotify_get_playlist([Spooftify sharedSpooftify].ds,_playlistId,true);
    if(playlist != NULL)
        return [SpooftifyPlaylist playlistWithPlaylist:playlist];
    
    return nil;
}

+(id) playlistWithPlaylist:(struct playlist*)_playlist
{
    NSString* playlistId = [NSString stringWithUTF8String:(const char*)_playlist->playlist_id];
    
    for(SpooftifyPlaylist* playlist in playlistPool)
    {
        if([[playlist playlistId] isEqualToString:playlistId])
            return playlist;
    }
    
    SpooftifyPlaylist* playlist = [[SpooftifyPlaylist alloc] initWithPlaylist:_playlist];
    return playlist;
}

-(id) initWithPlaylist:(struct playlist*)playlist
{
    self = [super init];
    
    _playlist = *playlist;
    
    name = [[NSString alloc] initWithUTF8String:_playlist.name];
    author = [[NSString alloc] initWithUTF8String:_playlist.author];
    playlistId = [[NSString alloc] initWithUTF8String:(const char*)_playlist.playlist_id];
    numberOfTracks = _playlist.num_tracks;
    tracks = [[NSMutableArray alloc] init];
    struct track* track = _playlist.tracks;
    while(track != NULL)
    {
        SpooftifyTrack* _track = [SpooftifyTrack trackWithTrack:track];
        [tracks addObject:_track];
        track = track->next;
    }
    if(_playlist.next != NULL)
        next = [SpooftifyPlaylist playlistWithPlaylist:_playlist.next];
    
    [playlistPool addObject:self];
    
    return self;
}

@end
