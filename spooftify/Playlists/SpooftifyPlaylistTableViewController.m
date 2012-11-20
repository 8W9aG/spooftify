/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyPlaylistTableViewController.h"
#import "SpooftifyPlaylistTableViewCell.h"
#import "SpooftifySongsTableViewController.h"

@implementation SpooftifyPlaylistTableViewController

#pragma mark UITableViewController

// Initialise
-(id) init
{
    self = [super init];
    
    // Set the table view controllers title
    [self setTitle:NSLocalizedString(@"PlaylistsKey",@"Title of Playlists Tab Bar Item")];
    
    // Create an array to hold the playlists
    playlists = [[NSMutableArray alloc] init];
    
    // Sign up to the login notification
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:SpooftifyLoginSucceededNotification object:nil];
    
    // Assign us to the Spooftify playlists delegate
    [[Spooftify sharedSpooftify] setPlaylistsDelegate:self];
    
    return self;
}

// When the view for the view controller loads
-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // Create a refresh control to let the user refresh the table on command
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

#pragma mark UITableViewDataSource

// Define the number of sections in the table view
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

// Define the number of rows per table view section
-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // The number of rows is the number of playlists in our array
    return [playlists count];
}

// Format the table cell for the row
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Find a queued cell
    SpooftifyPlaylistTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifyPlaylistTableViewCell class] description]];
    
    // If one is not found
    if(cell == nil)
        // Create a cell
        cell = [[SpooftifyPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifyPlaylistTableViewCell class] description]];
    
    // Set the cell's playlist
    [cell setPlaylist:[playlists objectAtIndex:indexPath.row]];
    
    return cell;
}

#pragma mark UITableViewDelegate

// Fired when the user selects a cell
-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Create a Songs table view controller with the selected playlist
    SpooftifySongsTableViewController* songsTableViewController = [[SpooftifySongsTableViewController alloc] initWithPlaylist:[playlists objectAtIndex:indexPath.row]];
    // Forward the user to this songs table view controller
    [[self navigationController] pushViewController:songsTableViewController animated:YES];
}

#pragma mark UIRefreshControl Control Event

// When the user refreshes
-(void) refresh
{
    // Reload the playlists
    [[Spooftify sharedSpooftify] playlists];
}

#pragma mark Spooftify Notifications

// If the user logs in
-(void) loginSucceeded
{
    // Begin the refreshing animation
    [[self refreshControl] beginRefreshing];
    
    // The code below should be done by the code above logically... but beginRefreshing just starts the activity indicator animation... that's all
    // Pull the table down to show the UIRefreshControl
    [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
    // Simulate a refresh
    [self refresh];
}

#pragma mark SpooftifyPlaylistsDelegate

// When the playlists are found
-(void) spooftify:(Spooftify*)spooftify foundPlaylists:(NSArray*)_playlists
{
    // Stop the refreshing process
    [[self refreshControl] endRefreshing];
    
    // Remove the playlists in our array
    [playlists removeAllObjects];
    // Add them into our array
    if(_playlists != nil)
        [playlists addObjectsFromArray:_playlists];
    
    // Reload the table with our new playlists
    [[self tableView] reloadData];
}

@end
