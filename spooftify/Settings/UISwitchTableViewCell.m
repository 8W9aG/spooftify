/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "UISwitchTableViewCell.h"

@implementation UISwitchTableViewCell

@synthesize boolSwitch;
@synthesize delegate;

#pragma mark UITableViewCell

// Initialise
-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    // Create the switch
    boolSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(0.0,0.0,75.0,28.0)];
    [boolSwitch setCenter:CGPointMake([self frame].size.width-([boolSwitch frame].size.width/2.0)-20.0,[self center].y)];
    [boolSwitch addTarget:self action:@selector(boolSwitchValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self addSubview:boolSwitch];
    
    return self;
}

#pragma mark UISwitch Control Event

// When the user switches the value
-(void) boolSwitchValueChanged:(UISwitch*)_boolSwitch
{
    // Call the delegate
    if(delegate != nil)
        [delegate switchTableViewCell:self switched:[_boolSwitch isOn]];
}

@end
