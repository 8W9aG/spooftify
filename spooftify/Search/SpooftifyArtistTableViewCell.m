/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyArtistTableViewCell.h"

@implementation SpooftifyArtistTableViewCell

@synthesize artist;

#pragma mark UITableViewCell

// Initialise
-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    // Set the accessory to a disclosure indicator
    [self setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    
    return self;
}

#pragma mark SpooftifyArtistTableViewCell

// Override setArtist
-(void) setArtist:(SpooftifyArtist*)_artist
{
    // Assign the new artist to the old artist
    artist = _artist;
    
    // Change the cells UI to reflect the artist
    [[self textLabel] setText:[artist name]];
    
    // Load the album image
    [[self imageView] setImage:[[Spooftify sharedSpooftify] cachedThumbnailWithId:[artist portraitId]]];
    
    // If a timer currently exists invalidate it
    if(albumImageTimer != nil)
        [albumImageTimer invalidate];
    // Create a new timer that will check if the cell is still around after 2 seconds (user has stopped scrolling fast)
    albumImageTimer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(albumImageDownloadTimer:) userInfo:artist repeats:NO];
    
    [[Spooftify sharedSpooftify] findThumbnailWithId:[artist portraitId] delegate:self];
}

#pragma mark SpooftifyImageDelegate

// When Spooftify finds an image
-(void) spooftify:(Spooftify*)spooftify foundImage:(UIImage*)image forId:(NSString*)coverId
{
    // If the image is what we need
    if([[artist portraitId] isEqualToString:coverId])
        // Set the image
        [[self imageView] setImage:image];
}

#pragma mark NSTimer

// When the timer ends
-(void) albumImageDownloadTimer:(NSTimer*)timer
{
    // If the track is still the same
    if([timer userInfo] == artist)
        // Download the thumbnail
        [[Spooftify sharedSpooftify] findThumbnailWithId:[artist portraitId] delegate:self];
}

@end
