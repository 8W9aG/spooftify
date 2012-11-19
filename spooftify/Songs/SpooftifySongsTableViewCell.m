/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifySongsTableViewCell.h"
#import "Spooftify.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "UIImage+Color.h"

@implementation SpooftifySongsTableViewCell

@synthesize track;
@synthesize delegate;
@synthesize addToQueueButton;
@synthesize albumButton;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:swipeGestureRecognizer];
    
    UISwipeGestureRecognizer* swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeLeftGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    
    frontView = [[UIView alloc] initWithFrame:[self bounds]];
    [frontView addSubview:[self textLabel]];
    [frontView addSubview:[self detailTextLabel]];
    [frontView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:frontView];
    
    [[self contentView] setUserInteractionEnabled:YES];
    [[self contentView] setHidden:YES];
    
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    [gradientLayer setFrame:[[self layer] bounds]];
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:113.0/255.0 alpha:1.0] CGColor],(id)[[UIColor colorWithWhite:51.0/255.0 alpha:1.0] CGColor], nil]];
    [gradientLayer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0],nil]];
    [[[self contentView] layer] addSublayer:gradientLayer];
    
    addToQueueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addToQueueButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addToQueueButton setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [addToQueueButton setCenter:CGPointMake([[self contentView] frame].size.width/4.0,[[self contentView] frame].size.height/2.0)];
    [addToQueueButton addTarget:self action:@selector(addSong:) forControlEvents:UIControlEventTouchUpInside];
    [addToQueueButton setShowsTouchWhenHighlighted:YES];
    [[self contentView] addSubview:addToQueueButton];
    
    albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumButton setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
    [albumButton setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [albumButton setCenter:CGPointMake([[self contentView] frame].size.width/2.0,[[self contentView] frame].size.height/2.0)];
    [albumButton addTarget:self action:@selector(requestAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [albumButton setShowsTouchWhenHighlighted:YES];
    [[self contentView] addSubview:albumButton];
    
    UIButton* artistBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [artistBtn setImage:[UIImage imageNamed:@"artist"] forState:UIControlStateNormal];
    [artistBtn setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [artistBtn setCenter:CGPointMake(([self frame].size.width/4.0)*3.0,[self frame].size.height/2.0)];
    [artistBtn addTarget:self action:@selector(requestArtist:) forControlEvents:UIControlEventTouchUpInside];
    [artistBtn setShowsTouchWhenHighlighted:YES];
    [[self contentView] addSubview:artistBtn];
    
    return self;
}

-(void) setTrack:(SpooftifyTrack*)_track
{
    track = _track;
    [[self textLabel] setText:[track title]];
    [[self detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %@",[[track artist] name],[track album]]];
    
    if(soundAccessoryImageView != nil)
        [soundAccessoryImageView removeFromSuperview];
    [addToQueueButton setEnabled:NO];
    
    [frontView setFrame:CGRectMake(0.0,[frontView frame].origin.y,[frontView frame].size.width,[frontView frame].size.height)];
    [[self contentView] setHidden:YES];
    
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        [addToQueueButton setEnabled:YES];
        SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
        SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
        if([[[nowPlayingViewController track] trackId] isEqualToString:[track trackId]])
        {
            soundAccessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soundAccessory"]];
            [soundAccessoryImageView setFrame:CGRectMake([self frame].size.width-10.0-[soundAccessoryImageView frame].size.width,0.0,[soundAccessoryImageView frame].size.width,[soundAccessoryImageView frame].size.height)];
            [soundAccessoryImageView setCenter:CGPointMake([soundAccessoryImageView center].x,[self frame].size.height/2.0)];
            [frontView addSubview:soundAccessoryImageView];
        }
    }
}

-(void) swipeRight:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    if([frontView frame].origin.x != 0.0)
        return;
    [[self contentView] setHidden:NO];
    
    [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        [frontView setFrame:CGRectMake([self frame].size.width,[frontView frame].origin.y,[frontView frame].size.width,[frontView frame].size.height)];
    } completion:nil];
}

-(void) swipeLeft:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    if([frontView frame].origin.x == 0.0)
        return;
    
    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        [frontView setFrame:CGRectMake(0.0,[frontView frame].origin.y,[frontView frame].size.width,[frontView frame].size.height)];
    } completion:^(BOOL finished){
        // Bounce
        if(finished)
            [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationCurveEaseInOut animations:^{
                [frontView setFrame:CGRectMake(20.0,[frontView frame].origin.y,[frontView frame].size.width,[frontView frame].size.height)];
            } completion:^(BOOL finished){
                if(finished)
                    [UIView animateWithDuration:0.1 delay:0.0 options:UIViewAnimationCurveEaseIn animations:^{
                        [frontView setFrame:CGRectMake(0.0,[frontView frame].origin.y,[frontView frame].size.width,[frontView frame].size.height)];
                    } completion:^(BOOL finished){
                        [[self contentView] setHidden:YES];
                    }];
            }];
    }];
}

-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if([[self contentView] isHidden])
        [super touchesBegan:touches withEvent:event];
}

-(void) addSong:(UIButton*)addBtn
{
    if(delegate != nil && [delegate respondsToSelector:@selector(spooftifySongsTableViewCellQueueSongForNextTrack:)])
        [delegate spooftifySongsTableViewCellQueueSongForNextTrack:self];

    UIImage* albumImage = [[Spooftify sharedSpooftify] thumbnailWithId:[track trackId]];
    
    UIWindow* window = [[[UIApplication sharedApplication] windows] lastObject];
    CGPoint targetPoint = CGPointMake(285.0,43.0);
    CALayer* imageLayer = [CALayer layer];
    [imageLayer setContents:(id)albumImage.CGImage];
    [imageLayer setOpaque:NO];
    [imageLayer setOpacity:0.0];
    [imageLayer setFrame:[window convertRect:[addToQueueButton frame] fromView:addToQueueButton]];
    [[window layer] insertSublayer:imageLayer above:[[[window rootViewController] view] layer]];
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint startPoint = [imageLayer position];
    CGPathMoveToPoint(path,NULL,startPoint.x,startPoint.y);
    CGPathAddCurveToPoint(path, NULL, startPoint.x+100.0, startPoint.y, targetPoint.x, targetPoint.y-100, targetPoint.x, targetPoint.y);
    CAKeyframeAnimation* positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [positionAnimation setPath:path];
    CGPathRelease(path);
    
    CABasicAnimation* sizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    [sizeAnimation setFromValue:[NSValue valueWithCGSize:[imageLayer frame].size]];
    [sizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(50.0,50.0)]];
    
    CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacityAnimation setFromValue:[NSNumber numberWithFloat:0.75]];
    [opacityAnimation setToValue:[NSNumber numberWithFloat:0.0]];
    
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:[NSArray arrayWithObjects:positionAnimation,sizeAnimation,opacityAnimation,nil]];
    [animationGroup setDuration:1.0];
    [animationGroup setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animationGroup setValue:imageLayer forKey:@"animatedImageLayer"];
    [imageLayer addAnimation:animationGroup forKey:@"animateToBar"];
    
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    if(nowPlayingViewController != nil)
        [nowPlayingViewController queueTrack:track];
}

-(void) requestAlbum:(UIButton*)albumBtn
{
    if(delegate != nil)
        [delegate spooftifySongsTableViewCellRequestAlbum:self];
}

-(void) requestArtist:(UIButton*)artistBtn
{
    if(delegate != nil)
        [delegate spooftifySongsTableViewCellRequestArtist:self];
}

@end
