/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyNowPlayingNavigationController.h"
#import "SpooftifyNowPlayingViewController.h"

static SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = nil;

@implementation SpooftifyNowPlayingNavigationController

@synthesize nowPlayingViewController;

#pragma mark SpooftifyNowPlayingNavigationController

// Find the shared navigation controller
+(id) sharedNowPlayingNavigationController
{
    // If one doesn't exist
    if(nowPlayingNavigationController == nil)
        // Create it
        nowPlayingNavigationController = [[SpooftifyNowPlayingNavigationController alloc] init];
    return nowPlayingNavigationController;
}

// Return whether there is currently a now playing navigation controller active
+(BOOL) isNowPlayingActive
{
    return (nowPlayingNavigationController != nil);
}

#pragma mark UIViewController

// Initialise
-(id) init
{
    self = [super init];
    
    // Create now playing view controller
    nowPlayingViewController = [[SpooftifyNowPlayingViewController alloc] init];
    [self setViewControllers:[NSArray arrayWithObject:nowPlayingViewController]];
    
    //Set the navigation bar style to black in accordance with the rest of the app
    [[self navigationBar] setBarStyle:UIBarStyleBlack];
    
    return self;
}

@end
