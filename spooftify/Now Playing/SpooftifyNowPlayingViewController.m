/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <MediaPlayer/MediaPlayer.h>
#import "SpooftifyNowPlayingViewController.h"
#import "Spooftify.h"
#import "NSMutableArray+Shuffle.h"

@implementation SpooftifyNowPlayingViewController

@synthesize track;
@synthesize currentPlaylist;
@synthesize currentAlbum;

#pragma mark UIViewController

// Initialise
-(id) init
{
    self = [super init];
    
    // Create the back button that allows the user to dismiss the now playing view controller
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"HideKey",@"Title of Hide Button") style:UIBarButtonItemStyleDone target:self action:@selector(hideButtonClicked:)];
    [[self navigationItem] setRightBarButtonItem:backButton];
    
    // Create the cover image view
    coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width,[[self view] frame].size.width)];
    [[self view] addSubview:coverImageView];
    
    // Create the bottom toolbar
    // This is just for the look rather than using it for items
    bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0,[[self view] frame].size.height-100.0-44.0,[[self view] frame].size.width,100.0)];
    [bottomToolbar setBarStyle:UIBarStyleBlack];
    [bottomToolbar setTranslucent:YES];
    [[self view] addSubview:bottomToolbar];
    
    // Create the back skip button
    backSkipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backSkipButton setImage:[UIImage imageNamed:@"prev"] forState:UIControlStateNormal];
    [backSkipButton setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [backSkipButton setCenter:CGPointMake(floorf([bottomToolbar frame].size.width/4.0),25.0)];
    [backSkipButton addTarget:self action:@selector(backSkipButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:backSkipButton];
    
    // Create the play/pause button
    playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playPauseButton setImage:[UIImage imageNamed:(([Spooftify sharedSpooftify].playState == SpooftifyPlayStatePause) ? @"play" : @"pause")] forState:UIControlStateNormal];
    [playPauseButton setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [playPauseButton setCenter:CGPointMake(floorf([bottomToolbar frame].size.width/2.0),25.0)];
    [playPauseButton addTarget:self action:@selector(playPauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:playPauseButton];
    
    // Create the forward skip button
    forwardSkipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardSkipButton setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [forwardSkipButton setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [forwardSkipButton setCenter:CGPointMake(floorf(([bottomToolbar frame].size.width/4.0)*3.0),25.0)];
    [forwardSkipButton addTarget:self action:@selector(forwardSkipButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:forwardSkipButton];
    
    // Create the slider to show the tracks progress
    timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0.0,0.0,[forwardSkipButton frame].origin.x+[forwardSkipButton frame].size.width-[backSkipButton frame].origin.x,20.0)];
    [timeSlider setCenter:CGPointMake([bottomToolbar frame].size.width/2.0,70.0)];
    [timeSlider addTarget:self action:@selector(timeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [timeSlider setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
    [timeSlider setMinimumTrackTintColor:[UIColor redColor]];
    [timeSlider setMaximumTrackTintColor:[UIColor whiteColor]];
    // No seeking support yet
    [timeSlider setUserInteractionEnabled:NO];
    [bottomToolbar addSubview:timeSlider];
    
    // Create the time passed label
    passedTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,([[self view] frame].size.width-[timeSlider frame].size.width)/2.0,16.0)];
    [passedTimeLbl setCenter:CGPointMake(floorf([passedTimeLbl frame].size.width/2.0),[timeSlider center].y)];
    [passedTimeLbl setTextAlignment:NSTextAlignmentCenter];
    [passedTimeLbl setText:@"0:00"];
    [passedTimeLbl setBackgroundColor:[UIColor clearColor]];
    [passedTimeLbl setTextColor:[UIColor whiteColor]];
    [passedTimeLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [bottomToolbar addSubview:passedTimeLbl];
    
    // Create the total time label
    totalTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,[passedTimeLbl frame].size.width,[passedTimeLbl frame].size.height)];
    [totalTimeLbl setCenter:CGPointMake([bottomToolbar frame].size.width-floorf([passedTimeLbl frame].size.width/2.0),[timeSlider center].y)];
    [totalTimeLbl setTextAlignment:NSTextAlignmentCenter];
    [totalTimeLbl setText:@"0:00"];
    [totalTimeLbl setBackgroundColor:[UIColor clearColor]];
    [totalTimeLbl setTextColor:[UIColor whiteColor]];
    [totalTimeLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [bottomToolbar addSubview:totalTimeLbl];
    
    // Set our background colour to black (just in case the album art stuffs up)
    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    // Create a queue to play our tracks off
    trackQueue = [[NSMutableArray alloc] init];
    
    // Create a dictionary to hold our media player info
    mediaPlayerInfo = [[NSMutableDictionary alloc] init];
    
    // Set ourselves as the now playing delegate
    [[Spooftify sharedSpooftify] setNowPlayingDelegate:self];
    
    // Sign up to the track ended notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackEnded:) name:SpooftifyTrackEndedNotification object:nil];
    
    // Listen for remote control events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    return self;
}

#pragma mark SpooftifyNowPlayingViewController

// Play a playlist at a certain track
-(void) playPlaylist:(SpooftifyPlaylist*)playlist atTrack:(SpooftifyTrack*)_track
{
    currentPlaylist = playlist;
    currentAlbum = nil;
    
    // Add the tracks from the playlist into the track queue
    [trackQueue removeAllObjects];
    [trackQueue addObjectsFromArray:[playlist tracks]];
    currentIndex = 0;
    
    // If the track is defined set the track to the one specified
    if(_track != nil)
        [self setTrack:_track];
    // If not shuffle the tracks
    else
    {
        [trackQueue shuffle];
        [self setTrack:[trackQueue objectAtIndex:0]];
    }
}

// Play an album at a certain track
-(void) playAlbum:(SpooftifyAlbum*)album atTrack:(SpooftifyTrack*)_track
{
    currentPlaylist = nil;
    currentAlbum = album;
    
    // Add the tracks from the album into the track queue
    [trackQueue removeAllObjects];
    [trackQueue addObjectsFromArray:[album tracks]];
    currentIndex = 0;
    
    // If the track is defined set the track to the one specified
    if(_track != nil)
        [self setTrack:_track];
    // If not shuffle the tracks
    else
    {
        [trackQueue shuffle];
        [self setTrack:[trackQueue objectAtIndex:0]];
    }
}

// Play a single track
-(void) playTrack:(SpooftifyTrack*)_track
{
    // Wipe the track queue and add our object
    [trackQueue removeAllObjects];
    [trackQueue addObject:_track];
    currentIndex = 0;
    
    // Set the current track to this track
    [self setTrack:_track];
}

// Set the current playing track
-(void) setTrack:(SpooftifyTrack*)_track
{
    track = _track;
    
    // Create our navigation items title view
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width-100.0,42.0)];
    
    // Make the label containing the artist name
    UILabel* artistLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,[titleView frame].size.width,14.0)];
    [artistLbl setTextAlignment:NSTextAlignmentCenter];
    [artistLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [artistLbl setTextColor:[UIColor lightGrayColor]];
    [artistLbl setShadowColor:[UIColor blackColor]];
    [artistLbl setShadowOffset:CGSizeMake(0.0,-1.0)];
    [artistLbl setText:[[track artist] name]];
    [artistLbl setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:artistLbl];
    
    // Make the label containing the song title
    UILabel* songLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,14.0,[titleView frame].size.width,14.0)];
    [songLbl setTextAlignment:NSTextAlignmentCenter];
    [songLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [songLbl setTextColor:[UIColor whiteColor]];
    [songLbl setShadowColor:[UIColor blackColor]];
    [songLbl setShadowOffset:CGSizeMake(0.0,-1.0)];
    [songLbl setText:[track title]];
    [songLbl setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:songLbl];
    
    // Make the label containing the album title
    UILabel* albumLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,28.0,[titleView frame].size.width,14.0)];
    [albumLbl setTextAlignment:NSTextAlignmentCenter];
    [albumLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [albumLbl setTextColor:[UIColor lightGrayColor]];
    [albumLbl setShadowColor:[UIColor blackColor]];
    [albumLbl setShadowOffset:CGSizeMake(0.0,-1.0)];
    [albumLbl setText:[track album]];
    [albumLbl setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:albumLbl];
    
    [[self navigationItem] setTitleView:titleView];
    
    // Set whether forward skipping is enabled (should be disabled if we are at the end of the queue)
    [forwardSkipButton setEnabled:([trackQueue count] == currentIndex+1) ? NO : YES];
    
    // Set the total time label
    int seconds = [track milliseconds]/1000;
    [totalTimeLbl setText:[NSString stringWithFormat:@"%d:%02d",seconds/60,seconds%60]];
    
    // Set the passed time
    currentMinutes = 0;
    currentSeconds = 0;
    [timeSlider setValue:0.0];
    [passedTimeLbl setText:@"0:00"];
    
    // Set the media player info to echo the tracks information
    [mediaPlayerInfo setObject:[track album] forKey:MPMediaItemPropertyAlbumTitle];
    [mediaPlayerInfo setObject:[NSNumber numberWithUnsignedInteger:[trackQueue count]] forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
    [mediaPlayerInfo setObject:[NSNumber numberWithUnsignedInteger:currentIndex+1] forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
    [mediaPlayerInfo setObject:[[track artist] name] forKey:MPMediaItemPropertyArtist];
    [mediaPlayerInfo setObject:[NSNumber numberWithDouble:[track milliseconds]/1000.0] forKey:MPMediaItemPropertyPlaybackDuration];
    [mediaPlayerInfo setObject:[track title] forKey:MPMediaItemPropertyTitle];
    [mediaPlayerInfo setValue:nil forKey:MPMediaItemPropertyArtwork];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaPlayerInfo];
    
    // Find the cover art
    [coverImageView setImage:[UIImage imageNamed:@"genericAlbum"]];
    [[Spooftify sharedSpooftify] findImageWithId:[track coverId] delegate:self];
    
    // Stop the current track and start playing our new one
    [[Spooftify sharedSpooftify] setPlayState:SpooftifyPlayStateStop];
    [[Spooftify sharedSpooftify] startPlay:track];
}

// Play a track
-(void) play
{
    // Check if we are already playing a track
    if([[Spooftify sharedSpooftify] playState] != SpooftifyPlayStatePlay)
        // If not press the play pause button
        [playPauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// Pause a track
-(void) pause
{
    // Check if we are already pausing the track
    if([[Spooftify sharedSpooftify] playState] != SpooftifyPlayStatePause)
        // If not press the play pause button
        [playPauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// Stop a track
-(void) stop
{
    // Reset the current track
    [self setTrack:track];
    
    // Stop the current track
    [[Spooftify sharedSpooftify] setPlayState:SpooftifyPlayStateStop];
    
    // Change the play pause button to play
    [playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
}

// Toggle a tracks play pause button
-(void) togglePlayPause
{
    // Press the play pause button
    [playPauseButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// Skip to the next track
-(void) nextTrack
{
    // If the forward button is enabled
    if([forwardSkipButton isEnabled])
        // Press it
        [forwardSkipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// Skip to the previous track
-(void) previousTrack
{
    // Press the back skip button
    [backSkipButton sendActionsForControlEvents:UIControlEventTouchUpInside];
}

// Queue another track as next in line to play
-(void) queueTrack:(SpooftifyTrack*)_track
{
    // Add the track to our queue
    [trackQueue addObject:_track];
    [trackQueue exchangeObjectAtIndex:currentIndex+1 withObjectAtIndex:[trackQueue count]-1];
    
    // Test whether to enable the forward skip button
    [forwardSkipButton setEnabled:([trackQueue count] == currentIndex+1) ? NO : YES];
}

#pragma mark UIBarButtonItem Control Event

// When the user presses the hide button
-(void) hideButtonClicked:(UIBarButtonItem*)backButton
{
    // Hide the view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark UIButton Control Event

// When the user presses the back skip button
-(void) backSkipButtonClicked:(UIButton*)backSkipButton
{
    // If the track has played for less than 2 seconds and it is not the first track
    if([timeSlider value]*([track milliseconds]/1000.0) <= 2.0 && currentIndex > 0)
        // Move back to the last track
        [self setTrack:[trackQueue objectAtIndex:--currentIndex]];
    // Else reset the track
    else
        [self setTrack:[trackQueue objectAtIndex:currentIndex]];
}

// When the user clicks the play pause button
-(void) playPauseButtonClicked:(UIButton*)_playPauseButton
{
    // If a song is currently playing
    if([Spooftify sharedSpooftify].playState == SpooftifyPlayStatePlay)
    {
        // Pause it and change the button image to play
        [[Spooftify sharedSpooftify] setPlayState:SpooftifyPlayStatePause];
        [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    // If not it must be paused
    else
    {
        // Play it and set the button image to pause
        [[Spooftify sharedSpooftify] setPlayState:SpooftifyPlayStatePlay];
        [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
    
}

// When the user presses the forward skip button
-(void) forwardSkipButtonClicked:(UIButton*)forwardSkipButton
{
    // Iterate to the next track
    [self setTrack:[trackQueue objectAtIndex:++currentIndex]];
}

#pragma mark Spooftify Notifications

// When a track finishes playing
-(void) trackEnded:(NSNotification*)notification
{
    // If the track is not at the end of the queue
    if(currentIndex < [trackQueue count]-1)
    {
        // Play the next one on the main thread
        dispatch_async(dispatch_get_main_queue(),^{
            [self setTrack:[trackQueue objectAtIndex:++currentIndex]];
        });
    }
}

#pragma mark SpooftifyImageDelegate

// When Spooftify finds our image
-(void) spooftify:(Spooftify*)spooftify foundImage:(UIImage*)image forId:(NSString*)coverId
{
    // Check if it's the one we need
    if([[track coverId] isEqualToString:coverId])
    {
        // If it is set the cover image view
        [coverImageView setImage:image];
        
        // And update the media player info artwork
        MPMediaItemArtwork* artwork = [[MPMediaItemArtwork alloc] initWithImage:image];
        [mediaPlayerInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
        [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaPlayerInfo];
    }
}

#pragma mark SpooftifyNowPlayingDelegate

// When Spooftify's playing time updates
-(void) spooftify:(Spooftify *)spooftify timeDidUpdate:(NSTimeInterval)newTime
{
    dispatch_async(dispatch_get_main_queue(),^{
        // Check whether the user is using the slider
        if(![timeSlider isTouchInside])
        {
            // If not set our new value 
            [timeSlider setValue:newTime/([track milliseconds]/1000.0)];
            [timeSlider sendActionsForControlEvents:UIControlEventValueChanged];
        }
    });
}

#pragma mark UISlider Control Event

// When the value on the time slider changes
-(void) timeSliderValueChanged:(UISlider*)_timeSlider
{
    // Work out how many seconds have passed
    int seconds = (int)([_timeSlider value]*([track milliseconds]/1000.0));
    // Convert that to minutes and seconds
    int newMinutes = seconds/60;
    int newSeconds = seconds%60;
    
    // If the minutes and seconds are not equal to the old values
    if(newMinutes != currentMinutes || newSeconds != currentSeconds)
    {
        // Set the passed time label to the new values
        [passedTimeLbl setText:[NSString stringWithFormat:@"%d:%02d",newMinutes,newSeconds]];
        currentMinutes = newMinutes;
        currentSeconds = newSeconds;
    }
}

@end
