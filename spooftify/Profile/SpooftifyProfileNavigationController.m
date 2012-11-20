/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyProfileNavigationController.h"
#import "SpooftifyProfileTableViewController.h"

@implementation SpooftifyProfileNavigationController

#pragma mark UINavigationController

// Initialise
-(id) init
{
    self = [super init];
    
    // Set the title
    [self setTitle:NSLocalizedString(@"ProfileKey",@"Title of Profile Navigation Bar")];
    
    // Create the profile table view controller and add it to the navigation controller
    SpooftifyProfileTableViewController* profileTableViewController = [[SpooftifyProfileTableViewController alloc] init];
    [self setViewControllers:[NSArray arrayWithObject:profileTableViewController]];
    
    // Set the navigation controllers tab bar item
    [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ProfileKey",@"Title of Profile Tab Bar item") image:[UIImage imageNamed:@"profileTab"] tag:0]];
    
    // Set the navigation bar to black style
    [[self navigationBar] setBarStyle:UIBarStyleBlack];
    
    return self;
}

@end
