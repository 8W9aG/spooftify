/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "SpooftifyTrack.h"
#import "Spooftify.h"

@class SpooftifySongsTableViewCell;

@protocol SpooftifySongsTableViewCellDelegate <NSObject>
-(void) spooftifySongsTableViewCellRequestArtist:(SpooftifySongsTableViewCell*)cell;
@optional
-(void) spooftifySongsTableViewCellQueueSongForNextTrack:(SpooftifySongsTableViewCell*)cell;
-(void) spooftifySongsTableViewCellRequestAlbum:(SpooftifySongsTableViewCell*)cell;
@end

@interface SpooftifySongsTableViewCell : UITableViewCell <SpooftifyImageDelegate>
{
    __strong SpooftifyTrack* track;
    
    __weak id <SpooftifySongsTableViewCellDelegate> delegate;
    
    UIImageView* soundAccessoryImageView;
    UIView* frontView;
    UIButton* addToQueueButton;
    UIButton* albumButton;
    
    UIImage* albumImage;
    NSTimer* albumImageTimer;
}

@property (nonatomic,strong) SpooftifyTrack* track;
@property (nonatomic,weak) id <SpooftifySongsTableViewCellDelegate> delegate;
@property (nonatomic,readonly) UIButton* addToQueueButton;
@property (nonatomic,readonly) UIButton* albumButton;

@end
