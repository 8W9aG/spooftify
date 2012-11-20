/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "Spooftify.h"
#import "SpooftifyPlaylist.h"
#import "SpooftifyAlbum.h"

#ifdef DEBUG
#define SPOOFTIFY_DEBUG(...) NSLog(__VA_ARGS__)
#else
#define SPOOFTIFY_DEBUG(...)
#endif

static bool initSuccess;
static Spooftify* sharedSpooftify = nil;

void callback(struct despotify_session* ds,int signal,void* data,void* callback_data)
{
    switch(signal)
    {
        case DESPOTIFY_NEW_TRACK:
        {
            SPOOFTIFY_DEBUG(@"DESPOTIFY_NEW_TRACK");
            [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyNewTrackNotification object:nil userInfo:nil];
            break;
        }
        case DESPOTIFY_TIME_TELL:
        {
            double seconds = *((double*)data);
            double* updatedSeconds = (double*)callback_data;
            if(seconds-*updatedSeconds > 1.0/24.0) // Humans generally process at 24 frames per second
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyTimeUpdatedNotification object:nil userInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithDouble:seconds],@"Seconds",nil]];
                *updatedSeconds = seconds;
            }
            break;
        }
        case DESPOTIFY_END_OF_PLAYLIST:
        {
            // We use our own logic to know when the track is at an end
            [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyTrackEndedNotification object:nil userInfo:nil];
            break;
        }
        case DESPOTIFY_TRACK_PLAY_ERROR:
        {
            SPOOFTIFY_DEBUG(@"DESPOTIFY_TRACK_PLAY_ERROR");
            break;
        }
    }
}

OSStatus renderAudio(void* inRefCon,AudioUnitRenderActionFlags* ioActionFlags,const AudioTimeStamp* inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList* ioData)
{
    TPCircularBuffer* buffer = (TPCircularBuffer*)inRefCon;
    
    int32_t fillBytes = ioData->mBuffers[0].mDataByteSize;
    char* fillBuffer = (char*)ioData->mBuffers[0].mData;
    
    int32_t availableBytes = 0;
    char* consumeBuffer = TPCircularBufferTail(buffer,&availableBytes);
    
    memcpy(fillBuffer,consumeBuffer,MIN(fillBytes,availableBytes));
    if(availableBytes < fillBytes)
        memset(&fillBuffer[availableBytes],0,fillBytes-availableBytes);
    
    TPCircularBufferConsume(buffer,MIN(fillBytes,availableBytes));
    
    return noErr;
}

void interruptionListener(void* inClientData,UInt32 inInterruptionState)
{
    
}

@implementation Spooftify

@synthesize loggedIn;
@synthesize playState;
@synthesize ds;
@synthesize profile;
@synthesize useHighBitrate;
@synthesize useCache;

+(void) initialize
{
    if(self == [Spooftify class])
    {
        initSuccess = despotify_init();
        SPOOFTIFY_DEBUG((initSuccess) ? @"Successfully initialized Spooftify" : @"Failed to initialize Spooftify");
        
        OSStatus result = AudioSessionInitialize(NULL,NULL,interruptionListener,(__bridge void*)self);
        if(result == kAudioSessionNoError)
        {
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,sizeof(sessionCategory),&sessionCategory);
        }
        AudioSessionSetActive(true);
    }
}

+(id) sharedSpooftify
{
    if(sharedSpooftify == nil)
        sharedSpooftify = [[Spooftify alloc] init];
    return sharedSpooftify;
}

-(id) init
{
    self = [super init];
    
    if(!initSuccess)
        return nil;
    
    ds = despotify_init_client(callback,&timeSeconds,true,true);
    if(!ds)
    {
        SPOOFTIFY_DEBUG(@"despotify_init_client() failed");
        return nil;
    }
    
    sharedSpooftify = self;
    playState = SpooftifyPlayStateNone;
    
    queue = dispatch_queue_create("com.spooftify.despotify",NULL);
    
    TPCircularBufferInit(&buffer,44100);
    
    AudioComponentDescription defaultOutputDescription;
    defaultOutputDescription.componentType = kAudioUnitType_Output;
    defaultOutputDescription.componentSubType = kAudioUnitSubType_RemoteIO;
    defaultOutputDescription.componentManufacturer = kAudioUnitManufacturer_Apple;
    defaultOutputDescription.componentFlags = 0;
    defaultOutputDescription.componentFlagsMask = 0;
    AudioComponent defaultOutput = AudioComponentFindNext(NULL,&defaultOutputDescription);
    if(defaultOutput == NULL){ NSLog(@"Can't find default output"); return nil; }
    OSErr err = AudioComponentInstanceNew(defaultOutput,&audioUnit);
    if(audioUnit == NULL){ NSLog(@"Error creating unit: %hd",err); return nil; }
    AURenderCallbackStruct input;
    input.inputProc = renderAudio;
    input.inputProcRefCon = &buffer;
    err = AudioUnitSetProperty(audioUnit,kAudioUnitProperty_SetRenderCallback,kAudioUnitScope_Input,0,&input,sizeof(input));
    if(err != noErr){ NSLog(@"Error setting callback: %hd",err); return nil; }
    AudioStreamBasicDescription streamFormat;
    streamFormat.mSampleRate = 44100.0;
    streamFormat.mFormatID = kAudioFormatLinearPCM;
    streamFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    streamFormat.mBytesPerPacket = 4;
    streamFormat.mFramesPerPacket = 1;
    streamFormat.mBytesPerFrame = 4;
    streamFormat.mChannelsPerFrame = 2;
    streamFormat.mBitsPerChannel = 16;
    err = AudioUnitSetProperty(audioUnit,kAudioUnitProperty_StreamFormat,kAudioUnitScope_Input,0,&streamFormat,sizeof(AudioStreamBasicDescription));
    if(err != noErr){ NSLog(@"Error setting stream format: %hd",err); return nil; }
    
    return self;
}

-(void) loginWithUsername:(NSString*)username password:(NSString*)password
{
    dispatch_async(queue,^{
        loggedIn = despotify_authenticate(ds,[username UTF8String],[password UTF8String]);
        // If failed try again, sometimes works a second time
        if(!loggedIn)
        {
            sleep(1);
            loggedIn = despotify_authenticate(ds,[username UTF8String],[password UTF8String]);
        }
        dispatch_sync(dispatch_get_main_queue(),^{
            if(loggedIn)
            {
                profile = [[SpooftifyProfile alloc] initWithUserInfo:ds->user_info];
                NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
                ds->high_bitrate = [userDefaults boolForKey:@"high_bitrate"];
                [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyLoginSucceededNotification object:self userInfo:nil];
            }
            else
                [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyLoginFailedNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:@"Test",@"Error",nil]];
        });
    });
}

-(BOOL) playlists
{
    if(!loggedIn) return NO;
    
    dispatch_async(queue,^{
        struct playlist* rootlist = despotify_get_stored_playlists(ds);
        dispatch_sync(dispatch_get_main_queue(),^{
            NSMutableArray* playlistArray = [NSMutableArray array];
            struct playlist* tmpList = rootlist;
            do
            {
                SpooftifyPlaylist* playlist = [SpooftifyPlaylist playlistWithPlaylist:tmpList];
                [playlistArray addObject:playlist];
                tmpList = tmpList->next;
            }
            while(tmpList != NULL);
            [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyPlaylistsFoundNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:playlistArray,@"Playlists",nil]];
        });
        despotify_free_playlist(rootlist);
    });
    
    return YES;
}

-(void) startPlay:(SpooftifyTrack*)track
{
    if(despotifyThread == nil || [despotifyThread isFinished] || [despotifyThread isCancelled])
    {
        stateLock = [[NSLock alloc] init];
        despotifyThread = [[NSThread alloc] initWithTarget:self selector:@selector(despotifyPCMThread) object:nil];
        [despotifyThread start];
    }
    
    despotify_stop(ds);
    timeSeconds = 0.0;
    despotify_play(ds,[track trackPtr],false);
    
    [stateLock lock];
    playState = SpooftifyPlayStatePlay;
    [stateLock unlock];
    
    OSErr err = AudioUnitInitialize(audioUnit);
    if(err != noErr){ NSLog(@"Error initializing unit: %d",err); return; }
    err = AudioOutputUnitStart(audioUnit);
    if(err != noErr){ NSLog(@"Error starting unit: %hd",err); return; }
}

-(void) pause
{
    playState = SpooftifyPlayStatePause;
}

-(void) play
{
    playState = SpooftifyPlayStatePlay;
}

-(void) stop
{
    playState = SpooftifyPlayStateStop;
}

-(void) despotifyPCMThread
{
    while(true)
    {
        [stateLock lock];
        switch(playState)
        {
            case SpooftifyPlayStatePlay:
            {
                struct pcm_data pcm;
                int rc = despotify_get_pcm(ds,&pcm);
                if(rc == 0)
                {
                    // Wait for the buffer to open up enough for the new PCM data
                    while(buffer.fillCount+pcm.len > buffer.length);
                    // Input the data
                    TPCircularBufferProduceBytes(&buffer,pcm.buf,pcm.len);
                }
                else printf("despotify_get_pcm() returned error %d\n",rc);
                break;
            }
            default: break;
        }
        [stateLock unlock];
    }
}

-(UIImage*) imageWithId:(NSString*)coverId
{
    __block UIImage* coverImage = [UIImage imageNamed:@"genericAlbum"];
    dispatch_sync(queue,^{
        int coverIdLen = [coverId length];
        char _coverId[coverIdLen+1];
        memset(_coverId,'\0',coverIdLen+1);
        strcpy(_coverId,[coverId UTF8String]);
        
        int len = 0;
        void* jpeg = despotify_get_image(ds,_coverId,&len,NO);
        if(jpeg != NULL)
            coverImage = [UIImage imageWithData:[NSData dataWithBytes:jpeg length:len]];
    });
    return coverImage;
}

-(UIImage*) thumbnailWithId:(NSString*)coverId
{
    int coverIdLen = [coverId length];
    char _coverId[coverIdLen+1];
    memset(_coverId,'\0',coverIdLen+1);
    strcpy(_coverId,[coverId UTF8String]);
    
    int len = 0;
    void* jpeg = despotify_get_image(ds,_coverId,&len,YES);
    
    NSLog(@"jpeg = %p",jpeg);
    
    UIImage* bigImage = [UIImage imageWithData:[NSData dataWithBytes:jpeg length:len]];
    if(bigImage == nil)
        bigImage = [UIImage imageNamed:@"genericAlbum"];
    
    CGImageRef bigImageRef = [bigImage CGImage];
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(44.0,44.0),NO,0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetInterpolationQuality(context,kCGInterpolationHigh);
    CGAffineTransform flipVertical = CGAffineTransformMake(1,0,0,-1,0,44.0);
    CGContextConcatCTM(context,flipVertical);
    CGContextDrawImage(context,CGRectMake(0.0,0.0,44.0,44.0),bigImageRef);
    CGImageRef smallImageRef = CGBitmapContextCreateImage(context);
    UIImage* smallImage = [UIImage imageWithCGImage:smallImageRef];
    CGImageRelease(smallImageRef);
    UIGraphicsEndImageContext();
    
    return smallImage;
}

-(void) search:(NSString*)query
{
    [self search:query atOffset:0];
}

-(void) search:(NSString*)query atOffset:(int)offset
{
    dispatch_async(queue,^{
        int queryLen = [query length];
        char _query[queryLen+1];
        memset(_query,'\0',queryLen+1);
        strcpy(_query,[query UTF8String]);
        
        struct search_result* result = despotify_search(ds,_query,50);
        
        dispatch_sync(dispatch_get_main_queue(),^{
            NSMutableArray* artistArray = [NSMutableArray array];
            struct artist* artist = result->artists;
            do
            {
                SpooftifyArtist* spooftifyArtist = [SpooftifyArtist artistWithArtist:artist];
                [artistArray addObject:spooftifyArtist];
                artist = artist->next;
            }
            while(artist != NULL);
            
            NSMutableArray* albumArray = [NSMutableArray array];
            struct album* album = result->albums;
            do
            {
                SpooftifyAlbum* spooftifyAlbum = [SpooftifyAlbum albumWithAlbum:album];
                [albumArray addObject:spooftifyAlbum];
                album = album->next;
            }
            while(album != NULL);
            
            NSMutableArray* trackArray = [NSMutableArray array];
            struct track* track = result->tracks;
            do
            {
                SpooftifyTrack* spooftifyTrack = [SpooftifyTrack trackWithTrack:track];
                [trackArray addObject:spooftifyTrack];
                track = track->next;
            }
            while(track != NULL);
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifySearchFoundNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:artistArray,@"Artists",albumArray,@"Albums",trackArray,@"Tracks",nil]];
            
            despotify_free_search(result);
        });
    });
}

-(void) findAlbum:(NSString*)albumId
{
    dispatch_async(queue,^{
        int albumIdLen = [albumId length];
        char _albumId[albumIdLen+1];
        memset(_albumId,'\0',albumIdLen+1);
        strcpy(_albumId,[albumId UTF8String]);
        
        struct album_browse* album = despotify_get_album(ds,_albumId);
        
        dispatch_sync(dispatch_get_main_queue(),^{
            SpooftifyAlbum* albumSpooftify = [SpooftifyAlbum albumWithAlbumBrowse:album];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyAlbumFoundNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:albumSpooftify,@"Album",nil]];
            
            despotify_free_album_browse(album);
        });
    });
}

-(void) findArtist:(NSString*)artistId
{
    dispatch_async(queue,^{
        int artistIdLen = [artistId length];
        char _artistId[artistIdLen+1];
        memset(_artistId,'\0',artistIdLen+1);
        strcpy(_artistId,[artistId UTF8String]);
        
        struct artist_browse* artist = despotify_get_artist(ds,_artistId);
        
        dispatch_sync(dispatch_get_main_queue(),^{
            SpooftifyArtist* artistSpooftify = [SpooftifyArtist artistWithArtistBrowse:artist];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyArtistFoundNotification object:self userInfo:[NSDictionary dictionaryWithObjectsAndKeys:artistSpooftify,@"Artist",nil]];
            
            if(artist != NULL)
                despotify_free_artist_browse(artist);
        });
    });
}

-(BOOL) useHighBitrate
{
    return ds->high_bitrate;
}

-(void) setUseHighBitrate:(BOOL)_useHighBitrate
{
    ds->high_bitrate = _useHighBitrate;
}

-(void) logout
{
    despotify_exit(ds);
    despotify_cleanup();
    AudioSessionSetActive(false);
    TPCircularBufferCleanup(&buffer);
    if(despotifyThread != nil)
    {
        [despotifyThread cancel];
        despotifyThread = nil;
    }
    sharedSpooftify = nil;
}

-(void) dealloc
{
    [self logout];
}

@end
