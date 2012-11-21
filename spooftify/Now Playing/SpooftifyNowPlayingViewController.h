/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <UIKit/UIKit.h>
#import "SpooftifyPlaylist.h"
#import "SpooftifyTrack.h"
#import "SpooftifyAlbum.h"
#import "Spooftify.h"

@interface SpooftifyNowPlayingViewController : UIViewController <SpooftifyImageDelegate>
{
    SpooftifyTrack* track;
    SpooftifyPlaylist* currentPlaylist;
    SpooftifyAlbum* currentAlbum;
    
    UIImageView* coverImageView;
    UIToolbar* bottomToolbar;
    UIButton* backSkipButton;
    UIButton* playPauseButton;
    UIButton* forwardSkipButton;
    UISlider* timeSlider;
    UILabel* passedTimeLbl;
    UILabel* totalTimeLbl;
    
    int currentMinutes;
    int currentSeconds;
    
    NSMutableArray* trackQueue;
    NSInteger currentIndex;
    
    NSMutableDictionary* mediaPlayerInfo;
}

@property (nonatomic,readonly) SpooftifyTrack* track;
@property (nonatomic,readonly) SpooftifyPlaylist* currentPlaylist;
@property (nonatomic,readonly) SpooftifyAlbum* currentAlbum;

-(void) playPlaylist:(SpooftifyPlaylist*)playlist atTrack:(SpooftifyTrack*)track;
-(void) playAlbum:(SpooftifyAlbum*)album atTrack:(SpooftifyTrack*)track;
-(void) playTrack:(SpooftifyTrack*)track;

-(void) play;
-(void) pause;
-(void) stop;
-(void) togglePlayPause;
-(void) nextTrack;
-(void) previousTrack;

-(void) queueTrack:(SpooftifyTrack*)track;

@end
