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

#pragma mark despotify

// The despotify callback method
void callback(struct despotify_session* ds,int signal,void* data,void* callback_data)
{
    // Determine the signal
    switch(signal)
    {
        // If we have a new track
        case DESPOTIFY_NEW_TRACK:
        {
            SPOOFTIFY_DEBUG(@"DESPOTIFY_NEW_TRACK");
            // Notify anyone signed up
            [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyNewTrackNotification object:nil userInfo:nil];
            break;
        }
        // If we have progressed in time
        case DESPOTIFY_TIME_TELL:
        {
            // Get the seconds from the data
            double seconds = *((double*)data);
            double* updatedSeconds = (double*)callback_data;
            
            // Determine whether a significant amount of time has passed
            if(seconds-*updatedSeconds > 1.0/24.0) // Humans generally process at 24 frames per second
            {
                // If so update the now playing delegate
                [[sharedSpooftify nowPlayingDelegate] spooftify:sharedSpooftify timeDidUpdate:seconds];
                *updatedSeconds = seconds;
            }
            break;
        }
        // If we are at the end of our playlist
        case DESPOTIFY_END_OF_PLAYLIST:
        {
            // We use our own logic to know when the track is at an end
            [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyTrackEndedNotification object:nil userInfo:nil];
            break;
        }
        // If there is an error in playing the track
        case DESPOTIFY_TRACK_PLAY_ERROR:
        {
            SPOOFTIFY_DEBUG(@"DESPOTIFY_TRACK_PLAY_ERROR");
            // ... hmmmmmmm
            // I've never seen this in action, a UIAlertView might be a bit dangerous if this happens every ms
            // Can the system recover from this? Or is it the end?
            break;
        }
    }
}

#pragma mark RemoteIO

// Render audio callback
OSStatus renderAudio(void* inRefCon,AudioUnitRenderActionFlags* ioActionFlags,const AudioTimeStamp* inTimeStamp,UInt32 inBusNumber,UInt32 inNumberFrames,AudioBufferList* ioData)
{
    // Get the circular buffer
    TPCircularBuffer* buffer = (TPCircularBuffer*)inRefCon;
    
    // Determine how many bytes we need to fill
    int32_t fillBytes = ioData->mBuffers[0].mDataByteSize;
    char* fillBuffer = (char*)ioData->mBuffers[0].mData;
    
    // Determine how many bytes we have available
    int32_t availableBytes = 0;
    char* consumeBuffer = TPCircularBufferTail(buffer,&availableBytes);
    
    // Copy our available bytes to the buffer
    memcpy(fillBuffer,consumeBuffer,MIN(fillBytes,availableBytes));
    // If we have less bytes available than required
    if(availableBytes < fillBytes)
        // Fill the rest with 0's (silence)
        memset(&fillBuffer[availableBytes],0,fillBytes-availableBytes);
    
    // Consume the bytes we just ate
    TPCircularBufferConsume(buffer,MIN(fillBytes,availableBytes));
    
    return noErr;
}

// Interruption listener, probably should do something here
void interruptionListener(void* inClientData,UInt32 inInterruptionState)
{
    
}

@implementation Spooftify

@synthesize playlistsDelegate;
@synthesize searchDelegate;
@synthesize nowPlayingDelegate;
@synthesize loggedIn;
@synthesize playState;
@synthesize profile;
@synthesize useHighBitrate;

#pragma mark NSObject

// When the class is first used
+(void) initialize
{
    // Check if we are in the right class (subclassing can screw with this)
    if(self == [Spooftify class])
    {
        // Initialise the despotify environment
        initSuccess = despotify_init();
        SPOOFTIFY_DEBUG((initSuccess) ? @"Successfully initialized Spooftify" : @"Failed to initialize Spooftify");
        
        // Initialise our audio session
        OSStatus result = AudioSessionInitialize(NULL,NULL,interruptionListener,(__bridge void*)self);
        if(result == kAudioSessionNoError)
        {
            UInt32 sessionCategory = kAudioSessionCategory_MediaPlayback;
            AudioSessionSetProperty(kAudioSessionProperty_AudioCategory,sizeof(sessionCategory),&sessionCategory);
        }
        AudioSessionSetActive(true);
    }
}

// Initialise
-(id) init
{
    self = [super init];
    
    // If we did not have success initially we will not return a good value
    if(!initSuccess)
        return nil;
    
    // Initialise the despotify client
    ds = despotify_init_client(callback,&timeSeconds,true,true);
    if(!ds)
    {
        SPOOFTIFY_DEBUG(@"despotify_init_client() failed");
        return nil;
    }
    
    // Set the shared instance to this instance
    sharedSpooftify = self;
    
    // Set our current play state to none
    playState = SpooftifyPlayStateNone;
    
    // Create the queue which will process all our despotify requests
    // This is important, we need to process each despotify request in sequence on the same thread
    // Using global queues execute requests concurrently, breaking the system
    queue = dispatch_queue_create("com.spooftify.despotify",NULL);
    
    // Create the circular buffer to feed to RemoteIO
    TPCircularBufferInit(&buffer,44100);
    
    // Initialise the RemoteIO device
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
    
    // Set the format to 16 bit signed integers (returned by vorbis)
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

// When Spooftify is being deallocated
-(void) dealloc
{
    // Logout
    [self logout];
    // Remove the reference to sharedSpooftify
    sharedSpooftify = nil;
}

#pragma mark Spooftify

// Return the shared Spooftify instance
+(id) sharedSpooftify
{
    // If one doesn't exist
    if(sharedSpooftify == nil)
        // Create it
        sharedSpooftify = [[Spooftify alloc] init];
    
    return sharedSpooftify;
}

// Logs the user in with a username and password
-(void) loginWithUsername:(NSString*)username password:(NSString*)password
{
    dispatch_async(queue,^{
        // We do this because the UTF8String method returns a const variable
        // And although we could just typecast, it's safer to have a non-const variable to feed to despotify
        // Turn username into a char array
        int usernameLen = [username length];
        char _username[usernameLen+1];
        memset(_username,'\0',usernameLen+1);
        strcpy(_username,[username UTF8String]);
        
        // Turn password into a char array
        int passwordLen = [password length];
        char _password[passwordLen+1];
        memset(_password,'\0',passwordLen+1);
        strcpy(_password,[password UTF8String]);
        
        // Authenticate
        loggedIn = despotify_authenticate(ds,[username UTF8String],[password UTF8String]);
        // If failed try again, sometimes works a second time
        // I know this looks dodgy... but it's just the way this library works
        if(!loggedIn)
            loggedIn = despotify_authenticate(ds,[username UTF8String],[password UTF8String]);
        
        dispatch_sync(dispatch_get_main_queue(),^{
            // If we have successfully logged in
            if(loggedIn)
            {
                // Fetch the user profile
                profile = [[SpooftifyProfile alloc] initWithUserInfo:ds->user_info];
                // Set whether to use high bitrate
                ds->high_bitrate = [[NSUserDefaults standardUserDefaults] boolForKey:@"high_bitrate"];
                // Notify other instances about the login success
                [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyLoginSucceededNotification object:self userInfo:nil];
            }
            // If not
            else
                // Tell people about our failure
                [[NSNotificationCenter defaultCenter] postNotificationName:SpooftifyLoginFailedNotification object:self userInfo:nil];
        });
    });
}

// Fetch a list of playlists stored by the user
-(void) playlists
{
    dispatch_async(queue,^{
        // Retrieve the users stored playlists
        struct playlist* rootlist = despotify_get_stored_playlists(ds);
        
        dispatch_sync(dispatch_get_main_queue(),^{
            // Create an array to hold our playlists
            NSMutableArray* playlistArray = [NSMutableArray array];
            
            // Loop through the playlist structures and turn them into SpooftifyPlaylists
            struct playlist* tmpList = rootlist;
            do
            {
                SpooftifyPlaylist* playlist = [SpooftifyPlaylist playlistWithPlaylist:tmpList];
                // Add the playlist to the array
                [playlistArray addObject:playlist];
                tmpList = tmpList->next;
            }
            while(tmpList != NULL);
            
            // Tell the playlist delegate we have found the playlists
            if(playlistsDelegate != nil)
                [playlistsDelegate spooftify:self foundPlaylists:playlistArray];
        });
        
        // Free the stored playlists
        despotify_free_playlist(rootlist);
    });
}

// Start playing the track
-(void) startPlay:(SpooftifyTrack*)track
{
    // If we don't have a thread or it is broken
    if(despotifyThread == nil || [despotifyThread isFinished] || [despotifyThread isCancelled])
    {
        // Start a new thread for extracting the PCM files
        despotifyThread = [[NSThread alloc] initWithTarget:self selector:@selector(despotifyPCMThread) object:nil];
        [despotifyThread start];
    }
    
    // Set our seconds back to 0
    timeSeconds = 0.0;
    
    // Set our state to play
    playState = SpooftifyPlayStatePlay;
    
    // Initialise the audio unit
    OSErr err = AudioUnitInitialize(audioUnit);
    if(err != noErr){ NSLog(@"Error initializing unit: %d",err); return; }
    err = AudioOutputUnitStart(audioUnit);
    if(err != noErr){ NSLog(@"Error starting unit: %hd",err); return; }
    
    // Play the song using despotify
    dispatch_async(queue,^{
        despotify_stop(ds);
        despotify_play(ds,[track trackPtr],false);
    });
}

// Override setPlayState
-(void) setPlayState:(SpooftifyPlayState)_playState
{
    playState = _playState;
    
    // If the play state is stopped
    if(playState == SpooftifyPlayStateStop)
    {
        // Stop despotify
        dispatch_async(queue,^{
            despotify_stop(ds);
        });
    }
}

// The despotify PCM decoding thread
-(void) despotifyPCMThread
{
    // Infinite loop
    while(true)
    {
        switch(playState)
        {
            // If the play state is play
            case SpooftifyPlayStatePlay:
            {
                // Get the PCM
                struct pcm_data pcm;
                int rc = despotify_get_pcm(ds,&pcm);
                if(rc == 0)
                {
                    // Wait for the buffer to open up enough for the new PCM data
                    while(buffer.fillCount+pcm.len > buffer.length)
                        usleep(10000);
                    // Input the data
                    TPCircularBufferProduceBytes(&buffer,pcm.buf,pcm.len);
                }
                else printf("despotify_get_pcm() returned error %d\n",rc);
                break;
            }
            default: break;
        }
    }
}

// Find image with an id
-(void) findImageWithId:(NSString*)coverId delegate:(id<SpooftifyImageDelegate>)delegate
{
    dispatch_async(queue,^{
        // Create a cover id char array
        int coverIdLen = [coverId length];
        char _coverId[coverIdLen+1];
        memset(_coverId,'\0',coverIdLen+1);
        strcpy(_coverId,[coverId UTF8String]);
        
        // Use despotify to get the image
        int len = 0;
        void* jpeg = despotify_get_image(ds,_coverId,&len,NO);
        
        // Convert the jpeg to the UIImage
        UIImage* coverImage = [UIImage imageNamed:@"genericAlbum"];
        if(jpeg != NULL)
            coverImage = [UIImage imageWithData:[NSData dataWithBytes:jpeg length:len]];
        dispatch_sync(dispatch_get_main_queue(),^{
            // Call the delegate
           if(delegate != nil)
               [delegate spooftify:self foundImage:coverImage forId:coverId];
        });
    });
}

// Find thumbnail with an id
-(void) findThumbnailWithId:(NSString*)coverId delegate:(id<SpooftifyImageDelegate>)delegate
{
    dispatch_async(queue,^{
        // Create a cover id char array
        int coverIdLen = [coverId length];
        char _coverId[coverIdLen+1];
        memset(_coverId,'\0',coverIdLen+1);
        strcpy(_coverId,[coverId UTF8String]);
        
        // Use despotify to get the image
        int len = 0;
        void* jpeg = despotify_get_image(ds,_coverId,&len,NO);
        
        // Convert the jpeg to the UIImage
        UIImage* bigImage = [UIImage imageNamed:@"genericAlbum"];
        if(jpeg != NULL)
            bigImage = [UIImage imageWithData:[NSData dataWithBytes:jpeg length:len]];
        
        // Rescale the image to 44 pixels
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
        
        dispatch_sync(dispatch_get_main_queue(),^{
            // Call the delegate
            if(delegate != nil)
                [delegate spooftify:self foundImage:smallImage forId:coverId];
        });
    });
}

// Find thumbnail in the cache
-(UIImage*) cachedThumbnailWithId:(NSString*)coverId
{
    // Create a cover id char array
    int coverIdLen = [coverId length];
    char _coverId[coverIdLen+1];
    memset(_coverId,'\0',coverIdLen+1);
    strcpy(_coverId,[coverId UTF8String]);
    
    // Use despotify to get the image from the cache only (no networking blocking calls)
    int len = 0;
    void* jpeg = despotify_get_image(ds,_coverId,&len,YES);
    
    // Convert the jpeg to the UIImage
    UIImage* bigImage = [UIImage imageNamed:@"genericAlbum"];
    if(jpeg != NULL)
        bigImage = [UIImage imageWithData:[NSData dataWithBytes:jpeg length:len]];
    
    // Rescale the image to 44 pixels
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

// Perform a generic search
-(void) search:(NSString*)query
{
    // This is just a search at offset 0
    [self search:query atOffset:0];
}

// Perform a search at a specified offset
-(void) search:(NSString*)query atOffset:(int)offset
{
    dispatch_async(queue,^{
        // Create a query char array
        int queryLen = [query length];
        char _query[queryLen+1];
        memset(_query,'\0',queryLen+1);
        strcpy(_query,[query UTF8String]);
        
        // Perform the search on despotify
        struct search_result* result = despotify_search(ds,_query,50);
        
        dispatch_sync(dispatch_get_main_queue(),^{
            // Create an artist array
            NSMutableArray* artistArray = [NSMutableArray array];
            // Loop through the despotify artists
            struct artist* artist = result->artists;
            do
            {
                // Convert the despotify artist into SpooftifyArtist
                SpooftifyArtist* spooftifyArtist = [SpooftifyArtist artistWithArtist:artist];
                // Add it into the artist array
                [artistArray addObject:spooftifyArtist];
                artist = artist->next;
            }
            while(artist != NULL);
            
            // Create an album array
            NSMutableArray* albumArray = [NSMutableArray array];
            // Loop through the despotify albums
            struct album* album = result->albums;
            do
            {
                // Convert the despotify album into SpooftifyAlbum
                SpooftifyAlbum* spooftifyAlbum = [SpooftifyAlbum albumWithAlbum:album];
                // Add it into the album array
                [albumArray addObject:spooftifyAlbum];
                album = album->next;
            }
            while(album != NULL);
            
            // Create a track array
            NSMutableArray* trackArray = [NSMutableArray array];
            // Loop through the despotify tracks
            struct track* track = result->tracks;
            do
            {
                // Convert the despotify track into SpooftifyTrack
                SpooftifyTrack* spooftifyTrack = [SpooftifyTrack trackWithTrack:track];
                // Add it into the track array
                [trackArray addObject:spooftifyTrack];
                track = track->next;
            }
            while(track != NULL);
            
            // Information the delegate that the search has finished
            if(searchDelegate != nil)
                [searchDelegate spooftify:self foundArtists:artistArray albums:albumArray tracks:trackArray];
        });
        
        // Free the despotify search results
        despotify_free_search(result);
    });
}

// Find an album with an ID
-(void) findAlbum:(NSString*)albumId delegate:(id<SpooftifyAlbumDelegate>)delegate
{
    dispatch_async(queue,^{
        // Create an album ID char array
        int albumIdLen = [albumId length];
        char _albumId[albumIdLen+1];
        memset(_albumId,'\0',albumIdLen+1);
        strcpy(_albumId,[albumId UTF8String]);
        
        // Find the album with despotify
        struct album_browse* album = despotify_get_album(ds,_albumId);
        
        dispatch_sync(dispatch_get_main_queue(),^{
            // Inform the album delegate
            if(delegate != nil)
                [delegate spooftify:self foundAlbum:[SpooftifyAlbum albumWithAlbumBrowse:album]];
        });
        
        // Free the album
        despotify_free_album_browse(album);
    });
}

// Find an artist with an ID
-(void) findArtist:(NSString*)artistId delegate:(id<SpooftifyArtistDelegate>)delegate
{
    dispatch_async(queue,^{
        // Create an artist ID char array
        int artistIdLen = [artistId length];
        char _artistId[artistIdLen+1];
        memset(_artistId,'\0',artistIdLen+1);
        strcpy(_artistId,[artistId UTF8String]);
        
        // Find the artist with despotify
        struct artist_browse* artist = despotify_get_artist(ds,_artistId);
        
        dispatch_sync(dispatch_get_main_queue(),^{
            // Inform the artist delegate
            if(delegate != nil)
                [delegate spooftify:self foundArtist:[SpooftifyArtist artistWithArtistBrowse:artist]];
        });
        
        // Free the artist
        despotify_free_artist_browse(artist);
    });
}

// Override useHighBitrate
-(BOOL) useHighBitrate
{
    return ds->high_bitrate;
}

// Override setUseHighBitrate
-(void) setUseHighBitrate:(BOOL)_useHighBitrate
{
    ds->high_bitrate = _useHighBitrate;
}

// Logout of spotify
-(void) logout
{
    // Exit despotify
    dispatch_sync(queue,^{
        despotify_exit(ds);
    });
    
    // Disable the audio session
    AudioSessionSetActive(false);
    
    // Cancel the thread
    if(despotifyThread != nil)
    {
        [despotifyThread cancel];
        despotifyThread = nil;
    }
    
    // Cleanup the buffer
    TPCircularBufferCleanup(&buffer);
}

@end
