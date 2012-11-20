/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyArtistTableViewCell.h"
#import "Spooftify.h"

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
    [[self imageView] setImage:[[Spooftify sharedSpooftify] thumbnailWithId:[artist portraitId]]];
}

@end
