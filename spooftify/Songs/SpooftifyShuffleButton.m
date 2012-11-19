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

-(id) init
{
    self = [super initWithFrame:CGRectMake(0.0,0.0,320.0,SPOOFTIFY_SHUFFLE_BUTTON_HEIGHT)];
    
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor whiteColor] size:[self frame].size] forState:UIControlStateNormal];
    [self setBackgroundImage:[UIImage imageWithColor:[UIColor blueColor] size:[self frame].size] forState:UIControlStateHighlighted];
    
    shuffleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shuffle"]];
    [self addSubview:shuffleImageView];
    
    shuffleLbl = [[UILabel alloc] initWithFrame:CGRectMake(0.0,0.0,100.0,20.0)];
    [shuffleLbl setCenter:CGPointMake(([self frame].size.width/2.0)-(([shuffleImageView frame].size.width+[shuffleLbl frame].size.width+10.0)/2.0)+[shuffleImageView frame].size.width+10.0+([shuffleLbl frame].size.width/2.0),[self frame].size.height/2.0)];
    [shuffleLbl setText:@"Shuffle Play"];
    [shuffleLbl setFont:[UIFont boldSystemFontOfSize:17.0]];
    [shuffleLbl setBackgroundColor:[UIColor clearColor]];
    [self addSubview:shuffleLbl];
    
    [shuffleImageView setCenter:CGPointMake(([self frame].size.width/2.0)-(([shuffleImageView frame].size.width+[shuffleLbl frame].size.width+10.0)/2.0)+([shuffleImageView frame].size.width/2.0),[self frame].size.height/2.0)];
    
    CALayer* bottomBorder = [CALayer layer];
    [bottomBorder setBorderColor:[UIColor lightGrayColor].CGColor];
    [bottomBorder setBorderWidth:1.0];
    [bottomBorder setFrame:CGRectMake(-1.0,-1.0,[self frame].size.width+2.0,[self frame].size.height+1.0)];
    [[self layer] addSublayer:bottomBorder];
    
    return self;
}

-(void) setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if(highlighted)
    {
        [shuffleLbl setTextColor:[UIColor whiteColor]];
        [shuffleImageView setImage:[UIImage imageNamed:@"shuffle-highlighted"]];
    }
    else
    {
        [shuffleLbl setTextColor:[UIColor blackColor]];
        [shuffleImageView setImage:[UIImage imageNamed:@"shuffle"]];
    }
}

-(void) drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetRGBStrokeColor(context,163.0/255.0,163.0/255.0,163.0/255.0,1.0);
    CGContextSetLineWidth(context,2);
    
    CGPoint points[2] =
    {
        CGPointMake(0.0,0.0),
        CGPointMake(rect.size.width,0.0)
    };
    CGContextStrokeLineSegments(context,points,sizeof(points)/sizeof(CGPoint));
    
    points[0] = CGPointMake(0.0,SPOOFTIFY_SHUFFLE_BUTTON_HEIGHT);
    points[1] = CGPointMake(320.0,SPOOFTIFY_SHUFFLE_BUTTON_HEIGHT);
    CGContextStrokeLineSegments(context,points,sizeof(points)/sizeof(CGPoint));
}

@end
