/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "Spooftify.h"

@implementation SpooftifyTableViewController

#pragma mark UITableViewController

// Initialise
-(id) init
{
    self = [super init];
    
    // Sign up to new track notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTrack:) name:SpooftifyNewTrackNotification object:nil];
    
    return self;
}

// When the view appears
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // If we have a now playing controller
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        // Add the now playing button
        UIBarButtonItem* nowPlayingBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NowPlayingKey",@"Title of Now Playing button") style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingClicked:)];
        [[self navigationItem] setRightBarButtonItem:nowPlayingBtn];
    }
    
    // Reload the table view
    [[self tableView] reloadData];
}

#pragma mark UIBarButtonItem Event

// When the user presses the now playing button
-(void) nowPlayingClicked:(UIBarButtonItem*)nowPlayingBtn
{
    // Present the now playing view controller
    [self presentViewController:[SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController] animated:YES completion:nil];
}

#pragma mark Spooftify Notification

// If a new track is found
-(void) newTrack:(NSNotification*)notification
{
    // Reload our table so any cells that contain the currently playing item are updated
    [[self tableView] reloadData];
}

@end
