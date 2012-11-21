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

#pragma mark NSObject

// When the class is first used
+(void) initialize
{
    if(self == [SpooftifyPlaylist class])
    {
        // Initialise the pool
        playlistPool = [[NSMutableArray alloc] init];
        
        // Sign up to receive application memory warnings
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
}

#pragma mark SpooftifyPlaylist

// Create a playlist with a despotify playlist
+(id) playlistWithPlaylist:(struct playlist*)_playlist
{
    // Create an NSString with the playlist id
    NSString* playlistId = [NSString stringWithUTF8String:(const char*)_playlist->playlist_id];
    
    // Loop through the playlists in the pool
    for(SpooftifyPlaylist* playlist in playlistPool)
    {
        // If we find one that has our ID return it
        if([[playlist playlistId] isEqualToString:playlistId])
            return playlist;
    }
    
    // Else just create a playlist object from the despotify playlist
    SpooftifyPlaylist* playlist = [[SpooftifyPlaylist alloc] initWithPlaylist:_playlist];
    return playlist;
}

// Initialise with a despotify playlist
-(id) initWithPlaylist:(struct playlist*)playlist
{
    self = [super init];
    
    _playlist = *playlist;
    
    // Fill in the playlist variables
    name = [[NSString alloc] initWithUTF8String:_playlist.name];
    author = [[NSString alloc] initWithUTF8String:_playlist.author];
    playlistId = [[NSString alloc] initWithUTF8String:(const char*)_playlist.playlist_id];
    numberOfTracks = _playlist.num_tracks;
    
    // Create the tracks in the playlists
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
    
    // Add this playlist to the pool
    [playlistPool addObject:self];
    
    return self;
}

#pragma mark UIApplication Notification

// If the app is running low on memory
+(void) didReceiveMemoryWarning
{
    // Drain the pool
    [playlistPool removeAllObjects];
}

@end
