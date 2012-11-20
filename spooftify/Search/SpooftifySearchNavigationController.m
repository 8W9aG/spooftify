/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifySearchNavigationController.h"
#import "SpooftifySearchTableViewController.h"

@implementation SpooftifySearchNavigationController

#pragma mark UINavigationController

// Initialise
-(id) init
{
    self = [super init];
    
    // Set the navigation bars title
    [self setTitle:NSLocalizedString(@"SearchKey",@"Title of Search Navigation Bar")];
    
    // Create the search table view controller and add it to this navigation controller
    SpooftifySearchTableViewController* searchTableViewController = [[SpooftifySearchTableViewController alloc] init];
    [self setViewControllers:[NSArray arrayWithObject:searchTableViewController]];
    
    // Set the tab bar to be the generic search
    [self setTabBarItem:[[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemSearch tag:0]];
    
    // Set the style to black in accordance with the rest of the app
    [[self navigationBar] setBarStyle:UIBarStyleBlack];
    
    return self;
}

@end
