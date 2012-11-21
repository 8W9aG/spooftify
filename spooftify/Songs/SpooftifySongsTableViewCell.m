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

#pragma mark UITableViewCell

// Initialise
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    // Create the left and right gesture recognizers
    UISwipeGestureRecognizer* swipeGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeRight:)];
    [swipeGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionRight];
    [self addGestureRecognizer:swipeGestureRecognizer];
    
    UISwipeGestureRecognizer* swipeLeftGestureRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeLeft:)];
    [swipeLeftGestureRecognizer setDirection:UISwipeGestureRecognizerDirectionLeft];
    [self addGestureRecognizer:swipeLeftGestureRecognizer];
    
    // Create the front view of the cell
    frontView = [[UIView alloc] initWithFrame:[self bounds]];
    [frontView addSubview:[self textLabel]];
    [frontView addSubview:[self detailTextLabel]];
    [frontView setBackgroundColor:[UIColor whiteColor]];
    [self addSubview:frontView];
    
    // Set the content views features
    [[self contentView] setUserInteractionEnabled:YES];
    [[self contentView] setHidden:YES];
    
    // Create a gradient layer on the content view
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    [gradientLayer setFrame:[[self layer] bounds]];
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:113.0/255.0 alpha:1.0] CGColor],(id)[[UIColor colorWithWhite:51.0/255.0 alpha:1.0] CGColor], nil]];
    [gradientLayer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0],nil]];
    [[[self contentView] layer] addSublayer:gradientLayer];
    
    // Create the add to queue button
    addToQueueButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [addToQueueButton setImage:[UIImage imageNamed:@"add"] forState:UIControlStateNormal];
    [addToQueueButton setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [addToQueueButton setCenter:CGPointMake([[self contentView] frame].size.width/4.0,[[self contentView] frame].size.height/2.0)];
    [addToQueueButton addTarget:self action:@selector(addSong:) forControlEvents:UIControlEventTouchUpInside];
    [addToQueueButton setShowsTouchWhenHighlighted:YES];
    [[self contentView] addSubview:addToQueueButton];
    
    // Create the album button
    albumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [albumButton setImage:[UIImage imageNamed:@"album"] forState:UIControlStateNormal];
    [albumButton setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [albumButton setCenter:CGPointMake([[self contentView] frame].size.width/2.0,[[self contentView] frame].size.height/2.0)];
    [albumButton addTarget:self action:@selector(requestAlbum:) forControlEvents:UIControlEventTouchUpInside];
    [albumButton setShowsTouchWhenHighlighted:YES];
    [[self contentView] addSubview:albumButton];
    
    // Create the artist button
    UIButton* artistBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [artistBtn setImage:[UIImage imageNamed:@"artist"] forState:UIControlStateNormal];
    [artistBtn setFrame:CGRectMake(0.0,0.0,44.0,44.0)];
    [artistBtn setCenter:CGPointMake(([self frame].size.width/4.0)*3.0,[self frame].size.height/2.0)];
    [artistBtn addTarget:self action:@selector(requestArtist:) forControlEvents:UIControlEventTouchUpInside];
    [artistBtn setShowsTouchWhenHighlighted:YES];
    [[self contentView] addSubview:artistBtn];
    
    return self;
}

#pragma mark SpooftifySongsTableViewCell

// Override setTrack
-(void) setTrack:(SpooftifyTrack*)_track
{
    track = _track;
    
    // Set the text labels on the cell to the tracks values
    [[self textLabel] setText:[track title]];
    [[self detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %@",[[track artist] name],[track album]]];
    
    // Remove the sound accessory if it exists
    if(soundAccessoryImageView != nil)
        [soundAccessoryImageView removeFromSuperview];
    
    // Disable the add to the queue button
    [addToQueueButton setEnabled:NO];
    
    // Set the front view over the cells frame and hide the content view
    [frontView setFrame:CGRectMake(0.0,[frontView frame].origin.y,[frontView frame].size.width,[frontView frame].size.height)];
    [[self contentView] setHidden:YES];
    
    // If the now playing controller is now active
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        // Enable the add to queue button
        [addToQueueButton setEnabled:YES];
        
        // Find the current now playing controller
        SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
        SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
        
        // If the track playing is equal to this track
        if([[[nowPlayingViewController track] trackId] isEqualToString:[track trackId]])
        {
            // Add the sound accessory view to the cell
            soundAccessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soundAccessory"]];
            [soundAccessoryImageView setFrame:CGRectMake([self frame].size.width-10.0-[soundAccessoryImageView frame].size.width,0.0,[soundAccessoryImageView frame].size.width,[soundAccessoryImageView frame].size.height)];
            [soundAccessoryImageView setCenter:CGPointMake([soundAccessoryImageView center].x,[self frame].size.height/2.0)];
            [frontView addSubview:soundAccessoryImageView];
        }
    }
    
    // Load the album image
    albumImage = [[Spooftify sharedSpooftify] cachedThumbnailWithId:[track coverId]];
    
    // If a timer currently exists invalidate it
    if(albumImageTimer != nil)
        [albumImageTimer invalidate];
    // Create a new timer that will check if the cell is still around after 2 seconds (user has stopped scrolling fast)
    albumImageTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(albumImageDownloadTimer:) userInfo:track repeats:NO];
}

#pragma mark UISwipeGestureRecognizer Events

// When the user swipes right
-(void) swipeRight:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    // If the front view is over the cell
    if([frontView frame].origin.x == 0.0)
    {
        // Hide the content view
        [[self contentView] setHidden:NO];
        
        // Animate it off the cell
        [UIView animateWithDuration:0.4 delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            [frontView setFrame:CGRectMake([self frame].size.width,[frontView frame].origin.y,[frontView frame].size.width,[frontView frame].size.height)];
        } completion:nil];
    }
}

// When the user swipes left
-(void) swipeLeft:(UISwipeGestureRecognizer*)swipeGestureRecognizer
{
    // If the front view is off the cell
    if([frontView frame].origin.x != 0.0)
    {
        // Animate it onto the cell
        [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            [frontView setFrame:CGRectMake(0.0,[frontView frame].origin.y,[frontView frame].size.width,[frontView frame].size.height)];
        } completion:^(BOOL finished){
            // Little bounce animation at the end
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
}

#pragma mark UIResponder

// Override touchesBegan
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    // If the content view is hidden
    if([[self contentView] isHidden])
        // Parse the touches up the chain
        [super touchesBegan:touches withEvent:event];
}

#pragma mark UIButton Control Events

// When the user clicks the add song button
-(void) addSong:(UIButton*)addBtn
{
    // Call the delegate
    if(delegate != nil && [delegate respondsToSelector:@selector(spooftifySongsTableViewCellQueueSongForNextTrack:)])
        [delegate spooftifySongsTableViewCellQueueSongForNextTrack:self];
    
    // Get the window
    UIWindow* window = [[[UIApplication sharedApplication] windows] lastObject];
    
    // Define our target point
    CGPoint targetPoint = CGPointMake(285.0,43.0);
    
    // Create the image layer and put it onto the window
    CALayer* imageLayer = [CALayer layer];
    [imageLayer setContents:(id)albumImage.CGImage];
    [imageLayer setOpaque:NO];
    [imageLayer setOpacity:0.0];
    [imageLayer setFrame:[window convertRect:[addToQueueButton frame] fromView:addToQueueButton]];
    [[window layer] insertSublayer:imageLayer above:[[[window rootViewController] view] layer]];
    
    // Create an animation path
    CGMutablePathRef path = CGPathCreateMutable();
    CGPoint startPoint = [imageLayer position];
    CGPathMoveToPoint(path,NULL,startPoint.x,startPoint.y);
    CGPathAddCurveToPoint(path, NULL, startPoint.x+100.0, startPoint.y, targetPoint.x, targetPoint.y-100, targetPoint.x, targetPoint.y);
    CAKeyframeAnimation* positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    [positionAnimation setPath:path];
    CGPathRelease(path);
    
    // Define the size animation
    CABasicAnimation* sizeAnimation = [CABasicAnimation animationWithKeyPath:@"bounds.size"];
    [sizeAnimation setFromValue:[NSValue valueWithCGSize:[imageLayer frame].size]];
    [sizeAnimation setToValue:[NSValue valueWithCGSize:CGSizeMake(50.0,50.0)]];
    
    // Define the opacity animation
    CABasicAnimation* opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [opacityAnimation setFromValue:[NSNumber numberWithFloat:0.75]];
    [opacityAnimation setToValue:[NSNumber numberWithFloat:0.0]];
    
    // Group the animations
    CAAnimationGroup* animationGroup = [CAAnimationGroup animation];
    [animationGroup setAnimations:[NSArray arrayWithObjects:positionAnimation,sizeAnimation,opacityAnimation,nil]];
    [animationGroup setDuration:1.0];
    [animationGroup setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    [animationGroup setValue:imageLayer forKey:@"animatedImageLayer"];
    [animationGroup setDelegate:self];
    [imageLayer addAnimation:animationGroup forKey:@"animateToBar"];
}

// When the user clicks the album button
-(void) requestAlbum:(UIButton*)albumBtn
{
    // Call the delegate
    if(delegate != nil)
        [delegate spooftifySongsTableViewCellRequestAlbum:self];
}

// When the user clicks the artist button
-(void) requestArtist:(UIButton*)artistBtn
{
    // Call the delegate
    if(delegate != nil)
        [delegate spooftifySongsTableViewCellRequestArtist:self];
}

#pragma mark CAAnimation Delegate

// When the add to queue animation has completed
-(void) animationDidStop:(CAAnimation*)theAnimation finished:(BOOL)flag
{
    // Find now playing controller and queue the track
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    if(nowPlayingViewController != nil)
        [nowPlayingViewController queueTrack:track];
}

#pragma mark SpooftifyImageDelegate

// When Spooftify has found our image
-(void) spooftify:(Spooftify*)spooftify foundImage:(UIImage*)image forId:(NSString*)coverId
{
    // Check if it is the image we need
    if([[track coverId] isEqualToString:coverId])
        // Set it
        albumImage = image;
}

#pragma mark NSTimer

// When the timer ends
-(void) albumImageDownloadTimer:(NSTimer*)timer
{
    // If the track is still the same
    if([timer userInfo] == track)
        // Download the thumbnail
        [[Spooftify sharedSpooftify] findThumbnailWithId:[track coverId] delegate:self];
}

@end
