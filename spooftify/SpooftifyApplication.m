/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyApplication.h"
#import "SpooftifyNowPlayingNavigationController.h"

@implementation SpooftifyApplication

#pragma mark UIApplication

// Override sendEvent
-(void) sendEvent:(UIEvent*)event
{
    // If the event is a remote control event, capture it
    if([event type] == UIEventTypeRemoteControl)
    {
        // Find the now playing controller
        SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
        SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
        
        // If it exists
        if(nowPlayingViewController != nil)
        {
            // Send the appropriate command
            switch([event subtype])
            {
                case UIEventSubtypeRemoteControlPlay:
                {
                    [nowPlayingViewController play];
                    break;
                }
                case UIEventSubtypeRemoteControlPause:
                {
                    [nowPlayingViewController pause];
                    break;
                }
                case UIEventSubtypeRemoteControlStop:
                {
                    [nowPlayingViewController stop];
                    break;
                }
                case UIEventSubtypeRemoteControlTogglePlayPause:
                {
                    [nowPlayingViewController togglePlayPause];
                    break;
                }
                case UIEventSubtypeRemoteControlNextTrack:
                {
                    [nowPlayingViewController nextTrack];
                    break;
                }
                case UIEventSubtypeRemoteControlPreviousTrack:
                {
                    [nowPlayingViewController previousTrack];
                    break;
                }
                case UIEventSubtypeRemoteControlBeginSeekingBackward: break;
                case UIEventSubtypeRemoteControlEndSeekingBackward: break;
                case UIEventSubtypeRemoteControlBeginSeekingForward: break;
                case UIEventSubtypeRemoteControlEndSeekingForward: break;
                default: break;
            }
        }
    }
    else
        [super sendEvent:event];
}

@end
