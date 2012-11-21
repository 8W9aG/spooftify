/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <QuartzCore/QuartzCore.h>
#import "SpooftifyAlbumTableViewCell.h"
#import "Spooftify.h"

@implementation SpooftifyAlbumTableViewCell

@synthesize album;

#pragma mark UITableViewCell

// Initialise
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    // Set the accessory type to disclosure
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return self;
}

#pragma mark SpooftifyAlbumTableViewCell

// Override setAlbum
-(void) setAlbum:(SpooftifyAlbum*)_album
{
    // Assign our album to this new album
    album = _album;
    
    // Change the cells UI to reflect the album
    [[self textLabel] setText:[album name]];
    [[self detailTextLabel] setText:[NSString stringWithFormat:@"by %@",[album artistName]]];
    
    // Load the album image
    [[self imageView] setImage:[[Spooftify sharedSpooftify] cachedThumbnailWithId:[album coverId]]];
    
    // If a timer currently exists invalidate it
    if(albumImageTimer != nil)
        [albumImageTimer invalidate];
    // Create a new timer that will check if the cell is still around after 2 seconds (user has stopped scrolling fast)
    albumImageTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(albumImageDownloadTimer:) userInfo:album repeats:NO];
    
    [[Spooftify sharedSpooftify] findThumbnailWithId:[album coverId] delegate:self];
}

#pragma mark SpooftifyImageDelegate

// When Spooftify finds our image
-(void) spooftify:(Spooftify*)spooftify foundImage:(UIImage*)image forId:(NSString*)coverId
{
    // If the cover id is what we want
    if([[album coverId] isEqualToString:coverId])
        // Set the image
        [[self imageView] setImage:image];
}

#pragma mark NSTimer

// When the timer ends
-(void) albumImageDownloadTimer:(NSTimer*)timer
{
    // If the track is still the same
    if([timer userInfo] == album)
        // Download the thumbnail
        [[Spooftify sharedSpooftify] findThumbnailWithId:[album coverId] delegate:self];
}

@end
