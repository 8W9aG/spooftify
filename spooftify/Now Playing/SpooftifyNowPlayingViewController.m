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

-(id) init
{
    self = [super init];
    
    UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Hide" style:UIBarButtonItemStyleDone target:self action:@selector(backButtonClicked:)];
    [[self navigationItem] setRightBarButtonItem:backButton];
    
    coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width,[[self view] frame].size.width)];
    [[self view] addSubview:coverImageView];
    
    bottomToolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0,[[self view] frame].size.height-100.0-44.0,[[self view] frame].size.width,100.0)];
    [bottomToolbar setBarStyle:UIBarStyleBlack];
    [bottomToolbar setTranslucent:YES];
    [[self view] addSubview:bottomToolbar];
    
    backSkipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [backSkipButton setImage:[UIImage imageNamed:@"prev"] forState:UIControlStateNormal];
    [backSkipButton setFrame:CGRectMake(0.0,0.0,31.0,27.0)];
    [backSkipButton setCenter:CGPointMake(floorf([bottomToolbar frame].size.width/4.0),25.0)];
    [backSkipButton addTarget:self action:@selector(backSkipButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:backSkipButton];
    
    playPauseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [playPauseButton setImage:[UIImage imageNamed:(([Spooftify sharedSpooftify].playState == SpooftifyPlayStatePause) ? @"play" : @"pause")] forState:UIControlStateNormal];
    [playPauseButton setFrame:CGRectMake(0.0,0.0,31.0,27.0)];
    [playPauseButton setCenter:CGPointMake(floorf([bottomToolbar frame].size.width/2.0),25.0)];
    [playPauseButton addTarget:self action:@selector(playPauseButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:playPauseButton];
    
    forwardSkipButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [forwardSkipButton setImage:[UIImage imageNamed:@"next"] forState:UIControlStateNormal];
    [forwardSkipButton setFrame:CGRectMake(0.0,0.0,31.0,27.0)];
    [forwardSkipButton setCenter:CGPointMake(floorf(([bottomToolbar frame].size.width/4.0)*3.0),25.0)];
    [forwardSkipButton addTarget:self action:@selector(forwardSkipButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [bottomToolbar addSubview:forwardSkipButton];
    
    timeSlider = [[UISlider alloc] initWithFrame:CGRectMake(0.0,0.0,[forwardSkipButton frame].origin.x+[forwardSkipButton frame].size.width-[backSkipButton frame].origin.x,20.0)];
    [timeSlider setCenter:CGPointMake([bottomToolbar frame].size.width/2.0,70.0)];
    [timeSlider addTarget:self action:@selector(timeSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [timeSlider setThumbImage:[UIImage imageNamed:@"knob"] forState:UIControlStateNormal];
    [timeSlider setMinimumTrackTintColor:[UIColor redColor]];
    [timeSlider setMaximumTrackTintColor:[UIColor whiteColor]];
    // No seeking support yet
    [timeSlider setUserInteractionEnabled:NO];
    [bottomToolbar addSubview:timeSlider];
    
    passedTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,([[self view] frame].size.width-[timeSlider frame].size.width)/2.0,16.0)];
    [passedTimeLbl setCenter:CGPointMake(floorf([passedTimeLbl frame].size.width/2.0),[timeSlider center].y)];
    [passedTimeLbl setTextAlignment:NSTextAlignmentCenter];
    [passedTimeLbl setText:@"0:00"];
    [passedTimeLbl setBackgroundColor:[UIColor clearColor]];
    [passedTimeLbl setTextColor:[UIColor whiteColor]];
    [passedTimeLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [bottomToolbar addSubview:passedTimeLbl];
    
    totalTimeLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,[passedTimeLbl frame].size.width,[passedTimeLbl frame].size.height)];
    [totalTimeLbl setCenter:CGPointMake([bottomToolbar frame].size.width-floorf([passedTimeLbl frame].size.width/2.0),[timeSlider center].y)];
    [totalTimeLbl setTextAlignment:NSTextAlignmentCenter];
    [totalTimeLbl setText:@"0:00"];
    [totalTimeLbl setBackgroundColor:[UIColor clearColor]];
    [totalTimeLbl setTextColor:[UIColor whiteColor]];
    [totalTimeLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [bottomToolbar addSubview:totalTimeLbl];
    
    [[self view] setBackgroundColor:[UIColor blackColor]];
    
    trackQueue = [[NSMutableArray alloc] init];
    mediaPlayerInfo = [[NSMutableDictionary alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(timeUpdated:) name:SpooftifyTimeUpdatedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(trackEnded:) name:SpooftifyTrackEndedNotification object:nil];
    
    // Listen for remote control events
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    return self;
}

-(void) playPlaylist:(SpooftifyPlaylist*)playlist atTrack:(SpooftifyTrack*)_track
{
    currentPlaylist = playlist;
    currentAlbum = nil;
    [trackQueue removeAllObjects];
    [trackQueue addObjectsFromArray:[playlist tracks]];
    currentIndex = 0;
    if(_track != nil)
        [self setTrack:_track];
    else
    {
        [trackQueue shuffle];
        [self setTrack:[trackQueue objectAtIndex:0]];
    }
}

-(void) playAlbum:(SpooftifyAlbum*)album atTrack:(SpooftifyTrack*)_track
{
    currentPlaylist = nil;
    currentAlbum = album;
    [trackQueue removeAllObjects];
    [trackQueue addObjectsFromArray:[album tracks]];
    currentIndex = 0;
    if(_track != nil)
        [self setTrack:_track];
    else
    {
        [trackQueue shuffle];
        [self setTrack:[trackQueue objectAtIndex:0]];
    }
}

-(void) playTrack:(SpooftifyTrack*)_track
{
    [trackQueue removeAllObjects];
    [trackQueue addObject:_track];
    currentIndex = 0;
    
    [self setTrack:_track];
}

-(void) backButtonClicked:(UIBarButtonItem*)backButton
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) backSkipButtonClicked:(UIButton*)backSkipButton
{
    [self setTrack:[trackQueue objectAtIndex:--currentIndex]];
}

-(void) playPauseButtonClicked:(UIButton*)_playPauseButton
{
    if([Spooftify sharedSpooftify].playState == SpooftifyPlayStatePlay)
    {
        [[Spooftify sharedSpooftify] pause];
        [_playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    else
    {
        [[Spooftify sharedSpooftify] play];
        [_playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
    
}

-(void) forwardSkipButtonClicked:(UIButton*)forwardSkipButton
{
    [self setTrack:[trackQueue objectAtIndex:++currentIndex]];
}

-(void) timeUpdated:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(),^{
        if(![timeSlider isTouchInside])
        {
            NSNumber* secondsNumber = (NSNumber*)[[notification userInfo] objectForKey:@"Seconds"];
            [timeSlider setValue:[secondsNumber doubleValue]/([track milliseconds]/1000.0)];
            [timeSlider sendActionsForControlEvents:UIControlEventValueChanged];
        }
    });
}

-(void) trackEnded:(NSNotification*)notification
{
    if(currentIndex < [trackQueue count]-1)
    {
        dispatch_sync(dispatch_get_main_queue(),^{
            [self setTrack:[trackQueue objectAtIndex:++currentIndex]];
        });
    }
}

-(void) timeSliderValueChanged:(UISlider*)_timeSlider
{
    int seconds = (int)([_timeSlider value]*([track milliseconds]/1000.0));
    int newMinutes = seconds/60;
    int newSeconds = seconds%60;
    if(newMinutes != currentMinutes || newSeconds != currentSeconds)
    {
        [passedTimeLbl setText:[NSString stringWithFormat:@"%d:%02d",newMinutes,newSeconds]];
        currentMinutes = newMinutes;
        currentSeconds = newSeconds;
    }
}

-(void) setTrack:(SpooftifyTrack*)_track
{
    track = _track;
    
    [self setTitle:[track title]];
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width-100.0,42.0)];
    UILabel* artistLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,[titleView frame].size.width,14.0)];
    [artistLbl setTextAlignment:NSTextAlignmentCenter];
    [artistLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [artistLbl setTextColor:[UIColor lightGrayColor]];
    [artistLbl setShadowColor:[UIColor blackColor]];
    [artistLbl setShadowOffset:CGSizeMake(0.0,-1.0)];
    [artistLbl setText:[[track artist] name]];
    [artistLbl setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:artistLbl];
    UILabel* songLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,14.0,[titleView frame].size.width,14.0)];
    [songLbl setTextAlignment:NSTextAlignmentCenter];
    [songLbl setFont:[UIFont boldSystemFontOfSize:12.0]];
    [songLbl setTextColor:[UIColor whiteColor]];
    [songLbl setShadowColor:[UIColor blackColor]];
    [songLbl setShadowOffset:CGSizeMake(0.0,-1.0)];
    [songLbl setText:[track title]];
    [songLbl setBackgroundColor:[UIColor clearColor]];
    [titleView addSubview:songLbl];
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
    
    [backSkipButton setEnabled:(currentIndex == 0) ? NO : YES];
    NSLog(@"backSkipButton enabled %d",backSkipButton.enabled);
    [forwardSkipButton setEnabled:([trackQueue count] == currentIndex+1) ? NO : YES];
    NSLog(@"forwardSkipButton enabled %d",forwardSkipButton.enabled);
    
    int seconds = [track milliseconds]/1000;
    [totalTimeLbl setText:[NSString stringWithFormat:@"%d:%02d",seconds/60,seconds%60]];
    currentMinutes = 0;
    currentSeconds = 0;
    [coverImageView setImage:[UIImage imageNamed:@"shuffle"]];
    [timeSlider setValue:0.0];
    [passedTimeLbl setText:@"0:00"];
    
    [mediaPlayerInfo setObject:[track album] forKey:MPMediaItemPropertyAlbumTitle];
    [mediaPlayerInfo setObject:[NSNumber numberWithUnsignedInteger:[trackQueue count]] forKey:MPNowPlayingInfoPropertyPlaybackQueueCount];
    [mediaPlayerInfo setObject:[NSNumber numberWithUnsignedInteger:currentIndex+1] forKey:MPNowPlayingInfoPropertyPlaybackQueueIndex];
    [mediaPlayerInfo setObject:[[track artist] name] forKey:MPMediaItemPropertyArtist];
    [mediaPlayerInfo setObject:[NSNumber numberWithDouble:[track milliseconds]/1000.0] forKey:MPMediaItemPropertyPlaybackDuration];
    [mediaPlayerInfo setObject:[track title] forKey:MPMediaItemPropertyTitle];
    [mediaPlayerInfo setValue:nil forKey:MPMediaItemPropertyArtwork];
    [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaPlayerInfo];
    
    [coverImageView setImage:[UIImage imageNamed:@"genericAlbum"]];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0ul);
    dispatch_async(queue,^{
        [[Spooftify sharedSpooftify] pause];
        despotify_stop([Spooftify sharedSpooftify].ds);
        // If we do this too soon it just doesn't work
        sleep(1);
        [[Spooftify sharedSpooftify] startPlay:track];
        UIImage* coverImage = [[Spooftify sharedSpooftify] imageWithId:[track coverId]];
        dispatch_sync(dispatch_get_main_queue(),^{
            [coverImageView setImage:coverImage];
            MPMediaItemArtwork* artwork = [[MPMediaItemArtwork alloc] initWithImage:coverImage];
            [mediaPlayerInfo setObject:artwork forKey:MPMediaItemPropertyArtwork];
            [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:mediaPlayerInfo];
        });
    });
}

-(void) play
{
    if([[Spooftify sharedSpooftify] playState] != SpooftifyPlayStatePlay)
    {
        [[Spooftify sharedSpooftify] play];
        [playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

-(void) pause
{
    if([[Spooftify sharedSpooftify] playState] != SpooftifyPlayStatePause)
    {
        [[Spooftify sharedSpooftify] pause];
        [playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

-(void) stop
{
    if([[Spooftify sharedSpooftify] playState] != SpooftifyPlayStateStop)
    {
        [[Spooftify sharedSpooftify] stop];
        [playPauseButton setImage:[UIImage imageNamed:@"stop"] forState:UIControlStateNormal];
    }
}

-(void) togglePlayPause
{
    if([Spooftify sharedSpooftify].playState == SpooftifyPlayStatePlay)
    {
        [[Spooftify sharedSpooftify] pause];
        [playPauseButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
    else
    {
        [[Spooftify sharedSpooftify] play];
        [playPauseButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    }
}

-(void) nextTrack
{
    if([forwardSkipButton isEnabled])
        [self setTrack:[trackQueue objectAtIndex:++currentIndex]];
}

-(void) previousTrack
{
    if([backSkipButton isEnabled])
        [self setTrack:[trackQueue objectAtIndex:--currentIndex]];
}

-(void) queueTrack:(SpooftifyTrack*)_track
{
    [trackQueue addObject:_track];
    [trackQueue exchangeObjectAtIndex:currentIndex+1 withObjectAtIndex:[trackQueue count]-1];
    [forwardSkipButton setEnabled:([trackQueue count] == currentIndex+1) ? NO : YES];
}

@end
