/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <Foundation/Foundation.h>
#import <AudioUnit/AudioUnit.h>
#import <AudioToolbox/AudioToolbox.h>
#import "SpooftifyTrack.h"
#import "SpooftifyProfile.h"
#import "TPCircularBuffer.h"
#include "despotify.h"

#define SpooftifyLoginSucceededNotification @"SpooftifyLoginSucceededNotification"
#define SpooftifyLoginFailedNotification @"SpooftifyLoginFailedNotification"
#define SpooftifyPlaylistsFoundNotification @"SpooftifyPlaylistsFoundNotification"
#define SpooftifyTimeUpdatedNotification @"SpooftifyTimeUpdatedNotification"
#define SpooftifyTrackEndedNotification @"SpooftifyTrackEndedNotification"
#define SpooftifySearchFoundNotification @"SpooftifySearchFoundNotification"
#define SpooftifyAlbumFoundNotification @"SpooftifyAlbumFoundNotification"
#define SpooftifyArtistFoundNotification @"SpooftifyArtistFoundNotification"
#define SpooftifyNewTrackNotification @"SpooftifyNewTrackNotification"

typedef enum SpooftifyPlayStateEnum {
    SpooftifyPlayStateNone,
    SpooftifyPlayStatePlay,
    SpooftifyPlayStatePause,
    SpooftifyPlayStateStop,
    SpooftifyPlayStateScratch
} SpooftifyPlayState;

@class SpooftifyProfile;

@interface Spooftify : NSObject
{
    struct despotify_session* ds;
    BOOL loggedIn;
    SpooftifyPlayState playState;
    TPCircularBuffer buffer;
    NSThread* despotifyThread;
    NSLock* stateLock;
    
    AudioComponentInstance audioUnit;
    double timeSeconds;
    
    SpooftifyProfile* profile;
    
    dispatch_queue_t queue;
}

@property (nonatomic,readonly) BOOL loggedIn;
@property (nonatomic,readonly) SpooftifyPlayState playState;
@property (nonatomic,readonly) struct despotify_session* ds;
@property (nonatomic,readonly) SpooftifyProfile* profile;
@property (nonatomic,assign) BOOL useHighBitrate;
@property (nonatomic,assign) BOOL useCache;

+(Spooftify*) sharedSpooftify;

-(void) loginWithUsername:(NSString*)username password:(NSString*)password;
-(BOOL) playlists;

-(void) startPlay:(SpooftifyTrack*)track;

-(void) play;
-(void) pause;
-(void) stop;

-(UIImage*) imageWithId:(NSString*)coverId;
-(UIImage*) thumbnailWithId:(NSString*)coverId;

-(void) search:(NSString*)query;
-(void) search:(NSString*)query atOffset:(int)offset;

-(void) findAlbum:(NSString*)albumId;
-(void) findArtist:(NSString*)artistId;

-(void) logout;

@end
