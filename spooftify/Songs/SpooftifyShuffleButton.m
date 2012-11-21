/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <QuartzCore/QuartzCore.h>
#import "SpooftifyShuffleButton.h"
#import "UIImage+Color.h"

@implementation SpooftifyShuffleButton

#pragma mark UIButton

// Initialise
-(id) init
{
    self = [super initWithFrame:CGRectMake(0.0,0.0,320.0,SPOOFTIFY_SHUFFLE_BUTTON_HEIGHT)];
    
    // Set the background image for different states
    // We just using images created with colours, unfortunately UIButton does not support using background colours for different states
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:[self frame].size] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor blueColor] size:[self frame].size] forState:UIControlStateHighlighted];
    
    // Create the shuffle image view
    shuffleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shuffle"]];
    [self addSubview:shuffleImageView];
    
    // Create the shuffle label
    NSString* shufflePlayTitle = NSLocalizedString(@"ShufflePlayKey",@"Title of Shuffle button");
    UIFont* shufflePlayFont = [UIFont boldSystemFontOfSize:17.0];
    shuffleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,[shufflePlayTitle sizeWithFont:shufflePlayFont constrainedToSize:CGSizeMake([self frame].size.width-[shuffleImageView frame].size.width,20.0)].width,20.0)];
    [shuffleLbl setCenter:CGPointMake(([self frame].size.width/2.0)-(([shuffleImageView frame].size.width+[shuffleLbl frame].size.width+10.0)/2.0)+[shuffleImageView frame].size.width+10.0+([shuffleLbl frame].size.width/2.0),[self frame].size.height/2.0)];
    [shuffleLbl setText:shufflePlayTitle];
    [shuffleLbl setFont:shufflePlayFont];
    [shuffleLbl setBackgroundColor:[UIColor clearColor]];
    [self addSubview:shuffleLbl];
    
    // Set the shuffle images position
    [shuffleImageView setCenter:CGPointMake(([self frame].size.width/2.0)-(([shuffleImageView frame].size.width+[shuffleLbl frame].size.width+10.0)/2.0)+([shuffleImageView frame].size.width/2.0),[self frame].size.height/2.0)];
    
    // Create a border around the button on the top and bottom
    CALayer* bottomBorder = [CALayer layer];
    [bottomBorder setBorderColor:[UIColor lightGrayColor].CGColor];
    [bottomBorder setBorderWidth:1.0];
    [bottomBorder setFrame:CGRectMake(-1.0,-1.0,[self frame].size.width+2.0,[self frame].size.height+1.0)];
    [[self layer] addSublayer:bottomBorder];
    
    return self;
}

// Override setHighlighted
-(void) setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    
    // If highlighted
    if(highlighted)
    {
        // Change the text colour and set the image to the highlighted one
        [shuffleLbl setTextColor:[UIColor whiteColor]];
        [shuffleImageView setImage:[UIImage imageNamed:@"shuffle-highlighted"]];
    }
    else
    {
        // Change the text colour and set the image to the normal one
        [shuffleLbl setTextColor:[UIColor blackColor]];
        [shuffleImageView setImage:[UIImage imageNamed:@"shuffle"]];
    }
}

@end
