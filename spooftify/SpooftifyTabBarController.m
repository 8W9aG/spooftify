/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyTabBarController.h"
#import "SpooftifyPlaylistNavigationController.h"
#import "SpooftifySearchNavigationController.h"
#import "SpooftifyProfileNavigationController.h"
#import "SpooftifySettingsNavigationController.h"

@implementation SpooftifyTabBarController

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // Create the main navigation controllers and add them
    SpooftifyPlaylistNavigationController* playlistNavigationController = [[SpooftifyPlaylistNavigationController alloc] init];
    SpooftifySearchNavigationController* searchNavigationController = [[SpooftifySearchNavigationController alloc] init];
    SpooftifyProfileNavigationController* profileNavigationController = [[SpooftifyProfileNavigationController alloc] init];
    SpooftifySettingsNavigationController* settingsNavigationController = [[SpooftifySettingsNavigationController alloc] init];
    [self setViewControllers:[NSArray arrayWithObjects:playlistNavigationController,searchNavigationController,profileNavigationController,settingsNavigationController,nil] animated:NO];
    
    // Make the selected view controller the playlist navigation controller
    [self setSelectedViewController:playlistNavigationController];
}

@end
