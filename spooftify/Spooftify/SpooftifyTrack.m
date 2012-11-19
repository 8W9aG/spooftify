/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyTrack.h"
#import "Spooftify.h"

static NSMutableArray* trackPool = nil;

@interface SpooftifyTrack ()
-(id) initWithTrack:(struct track*)track;
@end

@implementation SpooftifyTrack

@synthesize trackId;
@synthesize albumId;
@synthesize coverId;
@synthesize title;
@synthesize artist;
@synthesize album;
@synthesize milliseconds;
@synthesize track;
@synthesize trackPtr;

+(void) initialize
{
    if(self == [SpooftifyTrack class])
    {
        trackPool = [[NSMutableArray alloc] init];
    }
}

+(id) trackWithId:(NSString*)trackId
{
    for(SpooftifyTrack* track in trackPool)
    {
        if([[track trackId] isEqualToString:trackId])
            return track;
    }
    
    char _trackId[[trackId length]+1];
    memset(_trackId,'\0',[trackId length]+1);
    strcpy(_trackId,[trackId UTF8String]);
    
    struct track* track = despotify_get_track([Spooftify sharedSpooftify].ds,_trackId);
    if(track != NULL)
        return [SpooftifyTrack trackWithTrack:track];
    
    return nil;
}

+(id) trackWithTrack:(struct track*)_track
{
    NSString* trackId = [NSString stringWithUTF8String:(const char*)_track->track_id];
    
    for(SpooftifyTrack* track in trackPool)
    {
        if([[track trackId] isEqualToString:trackId])
            return track;
    }
    
    SpooftifyTrack* track = [[SpooftifyTrack alloc] initWithTrack:_track];
    return track;
}

-(id) initWithTrack:(struct track*)_track
{
    self = [super init];
    
    track = *_track;
    track.next = NULL;
    trackPtr = (struct track*)malloc(sizeof(struct track));
    memcpy(trackPtr,&track,sizeof(struct track));
    
    trackId = [[NSString alloc] initWithUTF8String:(const char*)track.track_id];
    albumId = [[NSString alloc] initWithUTF8String:(const char*)track.album_id];
    coverId = [[NSString alloc] initWithUTF8String:(const char*)track.cover_id];
    title = [[NSString alloc] initWithUTF8String:track.title];
    if(track.artist != NULL)
        artist = [SpooftifyArtist artistWithArtist:track.artist];
    album = [[NSString alloc] initWithUTF8String:track.album];
    milliseconds = track.length;
    
    [trackPool addObject:self];
    
    return self;
}

-(void) dealloc
{
    free(trackPtr);
    trackPtr = NULL;
}

@end
