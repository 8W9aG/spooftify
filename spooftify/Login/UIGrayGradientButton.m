/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import <QuartzCore/QuartzCore.h>
#import "UIGrayGradientButton.h"

@implementation UIGrayGradientButton

-(id) initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    [[self layer] setCornerRadius:7.0];
    
    CAGradientLayer* gradientLayer = [CAGradientLayer layer];
    [gradientLayer setFrame:[[self layer] bounds]];
    [gradientLayer setColors:[NSArray arrayWithObjects:(id)[[UIColor colorWithWhite:236.0/255.0 alpha:1.0] CGColor],(id)[[UIColor colorWithRed:185.0/255.0 green:192.0/255.0 blue:201.0/255.0 alpha:1.0] CGColor], nil]];
    [gradientLayer setLocations:[NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0],[NSNumber numberWithFloat:1.0],nil]];
    [gradientLayer setCornerRadius:[[self layer] cornerRadius]];
    [[self layer] addSublayer:gradientLayer];
    
    [[self layer] setShadowColor:[UIColor darkGrayColor].CGColor];
    [[self layer] setShadowOpacity:1.0];
    [[self layer] setShadowOffset:CGSizeMake(0.0,2.0)];
    
    [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:13.0]];
    [self setTitleColor:[UIColor colorWithWhite:90.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [self setTitleShadowColor:[UIColor colorWithWhite:213.0/255.0 alpha:1.0] forState:UIControlStateNormal];
    [[self titleLabel] setShadowOffset:CGSizeMake(0.0,1.0)];
    
    [self setShowsTouchWhenHighlighted:YES];
    
    return self;
}

@end
