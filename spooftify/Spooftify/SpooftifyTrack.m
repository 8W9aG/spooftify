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

#pragma mark NSObject

// When SpooftifyTrack is first used
+(void) initialize
{
    // Check if we are executing in the right class
    if(self == [SpooftifyTrack class])
    {
        // Create the track pool
        trackPool = [[NSMutableArray alloc] init];
        
        // Sign up to receive application memory warnings
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMemoryWarning) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
    }
}

// When we are deallocated
-(void) dealloc
{
    // Free the memory we allocated for the despotify track
    free(trackPtr);
    trackPtr = NULL;
}

#pragma mark SpooftifyTrack

// Create a track from a despotify track
+(id) trackWithTrack:(struct track*)_track
{
    // Create a track string from the track ID
    NSString* trackId = [NSString stringWithUTF8String:(const char*)_track->track_id];
    
    // Loop through the tracks in the pool
    for(SpooftifyTrack* track in trackPool)
    {
        // If we find our track return it
        if([[track trackId] isEqualToString:trackId])
            return track;
    }
    
    // Create a track
    SpooftifyTrack* track = [[SpooftifyTrack alloc] initWithTrack:_track];
    return track;
}

// Initialise with a despotify track
-(id) initWithTrack:(struct track*)_track
{
    self = [super init];
    
    track = *_track;
    
    // Remove the track.next value just in case despotify tries to play the next track
    // We want to control this action ourselves
    track.next = NULL;
    
    // Allocate some memory and copy the despotify track to it
    trackPtr = (struct track*)malloc(sizeof(struct track));
    memcpy(trackPtr,&track,sizeof(struct track));
    
    // Fill in our variables
    trackId = [[NSString alloc] initWithUTF8String:(const char*)track.track_id];
    albumId = [[NSString alloc] initWithUTF8String:(const char*)track.album_id];
    coverId = [[NSString alloc] initWithUTF8String:(const char*)track.cover_id];
    title = [[NSString alloc] initWithUTF8String:track.title];
    if(track.artist != NULL)
        artist = [SpooftifyArtist artistWithArtist:track.artist];
    album = [[NSString alloc] initWithUTF8String:track.album];
    milliseconds = track.length;
    
    // Add the track to the pool
    [trackPool addObject:self];
    
    return self;
}

#pragma mark UIApplication Notification

// If the app is running low on memory
+(void) didReceiveMemoryWarning
{
    // Drain the pool
    [trackPool removeAllObjects];
}

@end
