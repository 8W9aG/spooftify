/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "UITextFieldTableViewCell.h"

@implementation UITextFieldTableViewCell

@synthesize textField;
@synthesize delegate;

-(id) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    textField = [[UITextField alloc] initWithFrame:CGRectMake(20.0,0.0,[self frame].size.width-40.0,20.0)];
    [textField setCenter:CGPointMake([self frame].size.width/2.0,[self frame].size.height/2.0)];
    [textField setReturnKeyType:UIReturnKeyDone];
    [textField setDelegate:self];
    [self addSubview:textField];
    
    return self;
}

-(BOOL) textFieldShouldReturn:(UITextField*)_textField
{
    if(delegate != nil)
        [delegate textFieldTableViewCellDidEndEditing:self];
    return NO;
}

-(void) textFieldDidBeginEditing:(UITextField*)textField
{
    if(delegate != nil)
        [delegate textFieldTableViewCellDidBeginEditing:self];
}

@end
