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

#pragma mark SpooftifyPlaylistTableViewCell

// Override setPlaylist
-(void) setPlaylist:(SpooftifyPlaylist*)_playlist
{
    // First off, set the referenced play list to this playlist
    playlist = _playlist;
    
    // Set the text label and the detail text label with the playlist information
    [[self textLabel] setText:[playlist name]];
    [[self detailTextLabel] setText:[NSString stringWithFormat:@"%@ - %d tracks",[playlist author],[playlist numberOfTracks]]];
    
    // If we currently have a soundAccessoryImageView that is not nil, remove it from the superview
    if(soundAccessoryImageView != nil)
        [soundAccessoryImageView removeFromSuperview];
    
    // Let's assume we will use the disclosure accessory
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    // Check whether there is currently a now playing navigation controller open
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        // Get the shared now playing navigation controller
        SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
        // Get the now playing view controller from the navigation controller
        SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
        
        // Check if the playlist is currently playing
        if([[[nowPlayingViewController currentPlaylist] playlistId] isEqualToString:[playlist playlistId]])
        {
            // If it is set the tables accessory to none
            [self setAccessoryType:UITableViewCellAccessoryNone];
            
            // Add the sound accessory
            soundAccessoryImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"soundAccessory"]];
            [soundAccessoryImageView setFrame:CGRectMake([self frame].size.width-10.0-[soundAccessoryImageView frame].size.width,0.0,[soundAccessoryImageView frame].size.width,[soundAccessoryImageView frame].size.height)];
            [soundAccessoryImageView setCenter:CGPointMake([soundAccessoryImageView center].x,[self frame].size.height/2.0)];
            [self addSubview:soundAccessoryImageView];
        }
    }
}

@end
