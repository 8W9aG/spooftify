/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyPlaylistTableViewCell.h"
#import "SpooftifyNowPlayingNavigationController.h"

@implementation SpooftifyPlaylistTableViewCell

@synthesize playlist;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    return self;
}

-(void) setPlaylist:(SpooftifyPlaylist*)_playlist
{
    playlist = _playlist;
    [[self textLabel] setText:[playlist name]];
    [[self detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %d tracks",[playlist author],[playlist numberOfTracks]]];
    
    if(soundAccessoryImageView != nil)
        [soundAccessoryImageView removeFromSuperview];
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
        SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
        if([[[nowPlayingViewController currentPlaylist] playlistId] isEqualToString:[playlist playlistId]])
        {
            [self setAccessoryType:UITableViewCellAccessoryNone];
            soundAccessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soundAccessory"]];
            [soundAccessoryImageView setFrame:CGRectMake([self frame].size.width-10.0-[soundAccessoryImageView frame].size.width,0.0,[soundAccessoryImageView frame].size.width,[soundAccessoryImageView frame].size.height)];
            [soundAccessoryImageView setCenter:CGPointMake([soundAccessoryImageView center].x,[self frame].size.height/2.0)];
            [self addSubview:soundAccessoryImageView];
        }
    }
}

@end
