/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyPlaylistNavigationController.h"
#import "SpooftifyPlaylistTableViewController.h"

@implementation SpooftifyPlaylistNavigationController

#pragma mark UINavigationController

// Initialise
-(id) init
{
    self = [super init];
    
    // Set the navigation controllers default title
    [self setTitle:NSLocalizedString(@"PlaylistsKey",@"Title of Playlists Tab Bar Item")];
    
    // Create the playlist view controller and add it to the navigation controller
    SpooftifyPlaylistTableViewController* playlistTableViewController = [[SpooftifyPlaylistTableViewController alloc] init];
    [self setViewControllers:[NSArray arrayWithObject:playlistTableViewController]];
    
    // Set the playlists tab bar item
    [self setTabBarItem:[[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"PlaylistsKey",@"Title of Playlists Tab Bar Item") image:[UIImage imageNamed:@"playlistsTab"] tag:0]];
    
    // We are using black styled navigation bars
    [[self navigationBar] setBarStyle:UIBarStyleBlack];
    
    return self;
}

@end
