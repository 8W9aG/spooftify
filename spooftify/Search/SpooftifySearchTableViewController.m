/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifySearchTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "SpooftifyAlbumTableViewCell.h"
#import "SpooftifyArtistTableViewCell.h"
#import "SpooftifyAlbumTableViewController.h"
#import "SpooftifyArtistTableViewController.h"

@implementation SpooftifySearchTableViewController

#pragma mark UITableViewController

// Initialise
-(id) init
{
    self = [super init];
    
    // Set the view controllers title
    [self setTitle:NSLocalizedString(@"SearchKey",@"Title of Search Navigation Bar")];
    
    // Set the title view to be a Search bar
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width,44.0)];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0,0.0,[titleView frame].size.width-10.0,[titleView frame].size.height)];
    [searchBar setDelegate:self];
    [searchBar setBarStyle:UIBarStyleBlack];
    [titleView addSubview:searchBar];
    [[self navigationItem] setTitleView:titleView];
    
    // Create a UITabBar to allow the user to switch between artists, albums and tracks
    // This probably wouldn't be done before iOS 6, Apple have opened this control up to be more versatile
    searchTabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width,[[self tableView] rowHeight])];
    [[self tableView] setTableHeaderView:searchTabBar];
    albumTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"AlbumsKey",@"Title of Albums tab bar item") image:[UIImage imageNamed:@"albumsSearch"] tag:0];
    artistTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"ArtistsKey",@"Title of Albums tab bar item") image:[UIImage imageNamed:@"artistsSearch"] tag:0];
    songTabBarItem = [[UITabBarItem alloc] initWithTitle:NSLocalizedString(@"SongsKey",@"Title of Songs tab bar item") image:[UIImage imageNamed:@"songsSearch"] tag:0];
    [searchTabBar setItems:[NSArray arrayWithObjects:albumTabBarItem,artistTabBarItem,songTabBarItem,nil]];
    [searchTabBar setDelegate:self];
    [searchTabBar setTintColor:[UIColor darkGrayColor]];
    [searchTabBar setSelectedImageTintColor:[UIColor redColor]];
    [searchTabBar setSelectedItem:albumTabBarItem];
    
    // Create a string that holds our search string, this is for refreshing purposes
    // We don't want to reference the searchBar in case the user types something else in it, but doesn't execute a search
    searchString = [[NSMutableString alloc] initWithString:@""];
    
    // Create the albums, artists and tracks arrays
    albumsArray = [[NSMutableArray alloc] init];
    artistsArray = [[NSMutableArray alloc] init];
    tracksArray = [[NSMutableArray alloc] init];
    
    // Assign ourselves to the spooftify search delegate
    [[Spooftify sharedSpooftify] setSearchDelegate:self];
    
    return self;
}

// When the view loads
-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // Create the refresh control
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

// Before the view appears
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[[self navigationItem] titleView] setFrame:CGRectMake(0.0,0.0,310.0,[[[self navigationItem] titleView] frame].size.height)];
    
    // If now playing is active, change the width of the search bar accordingly
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
        [searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-100.0,[searchBar frame].size.height)];
    else
        [searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-10.0,[searchBar frame].size.height)];
}

#pragma mark UITableViewDataSource

// Define the number of sections in the table view
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    // Always 1 section
    return 1;
}

// Define the number of rows
-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the appropriate array count depending on the tab bar selection
    if([searchTabBar selectedItem] == albumTabBarItem)
        return [albumsArray count];
    else if([searchTabBar selectedItem] == artistTabBarItem)
        return [artistsArray count];
    return [tracksArray count];
}

// Return the cell for the row of the table view
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // If we are searching for albums
    if([searchTabBar selectedItem] == albumTabBarItem)
    {
        // Find a queued album cell
        SpooftifyAlbumTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifyAlbumTableViewCell class] description]];
        
        // If one doesn't exist, create it
        if(cell == nil)
            cell = [[SpooftifyAlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifyAlbumTableViewCell class] description]];
        
        // Set the cells album
        [cell setAlbum:[albumsArray objectAtIndex:indexPath.row]];
        return cell;
    }
    // If we are searching for artists
    else if([searchTabBar selectedItem] == artistTabBarItem)
    {
        // Find the queued artist cell
        SpooftifyArtistTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifyArtistTableViewCell class] description]];
        
        // If one doesn't exist, create it
        if(cell == nil)
            cell = [[SpooftifyArtistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[SpooftifyArtistTableViewCell class] description]];
        
        // Set the cells artist
        [cell setArtist:[artistsArray objectAtIndex:indexPath.row]];
        return cell;
    }
    
    // Else we must be searching for songs
    // Find the queued song cell
    SpooftifySongsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifySongsTableViewCell class] description]];
    
    // If the song cell doesn't exist, create it
    if(cell == nil)
    {
        cell = [[SpooftifySongsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifySongsTableViewCell class] description]];
        [cell setDelegate:self];
    }
    
    // Set the cells track
    [cell setTrack:[tracksArray objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate

// When the user selects a table row
-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // If the user is searching for albums
    if([searchTabBar selectedItem] == albumTabBarItem)
    {
        // Create a new album table view controller and show it with the selected album
        SpooftifyAlbumTableViewController* albumTableViewController = [[SpooftifyAlbumTableViewController alloc] initWithAlbum:[albumsArray objectAtIndex:indexPath.row]];
        [[self navigationController] pushViewController:albumTableViewController animated:YES];
    }
    // If the user is searching for artists
    else if([searchTabBar selectedItem] == artistTabBarItem)
    {
        // Create a new artist table view controller and show it with the selected artist
        SpooftifyArtistTableViewController* artistTableViewController = [[SpooftifyArtistTableViewController alloc] initWithArtist:[artistsArray objectAtIndex:indexPath.row]];
        [[self navigationController] pushViewController:artistTableViewController animated:YES];
    }
    // Else the user must have selected a song
    else
    {
        // Display and play the selected track
        SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
        SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
        [nowPlayingViewController playTrack:[tracksArray objectAtIndex:indexPath.row]];
        [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
    }
}

#pragma mark UISearchBarDelegate

// When the search button is clicked in the search bar
-(void) searchBarSearchButtonClicked:(UISearchBar*)_searchBar
{
    // Remove the keyboard
    [searchBar resignFirstResponder];
    
    // Reset the UINavigationBar according to whether something is now playing
    // Be sure to animate to make it look smooth
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        UIBarButtonItem* nowPlayingBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NowPlayingKey",@"Title of the Now Playing button") style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingClicked:)];
        [[self navigationItem] setRightBarButtonItem:nowPlayingBtn animated:YES];
        [[[self navigationItem] titleView] setFrame:CGRectMake(0.0,0.0,310.0,[[[self navigationItem] titleView] frame].size.height)];
        [UIView animateWithDuration:0.5 animations:^{
            [searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-100.0,[searchBar frame].size.height)];
        }];
    }
    else
    {
        [[self navigationItem] setRightBarButtonItem:nil animated:YES];
        [[[self navigationItem] titleView] setFrame:CGRectMake(0.0,0.0,310.0,[[[self navigationItem] titleView] frame].size.height)];
        [UIView animateWithDuration:0.5 animations:^{
            [searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-10.0,[searchBar frame].size.height)];
        }];
    }
    
    // Remember this search
    [searchString setString:[_searchBar text]];
    
    // Show the refresh cycle
    [[self refreshControl] beginRefreshing];
    [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
    [self refresh];
}

// When the user taps the search bar to begin typing
-(void) searchBarTextDidBeginEditing:(UISearchBar*)_searchBar
{
    // Make the search bar take up the entire navigation bar
    [[[self navigationItem] titleView] setFrame:CGRectMake(0.0,0.0,310.0,[[[self navigationItem] titleView] frame].size.height)];
    [UIView animateWithDuration:0.5 animations:^{
        [_searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-60.0,[_searchBar frame].size.height)];
    }];
    
    // Add a cancel button for the search bar
    UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"CancelKey",@"Title of the cancel button") style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked:)];
    [[self navigationItem] setRightBarButtonItem:cancelBtn animated:YES];
}

#pragma mark UIBarButtonItem

// If the user clicks the cancel button next to the search bar
-(void) cancelClicked:(UIBarButtonItem*)cancelBtn
{
    // Remove the keyboard
    [searchBar resignFirstResponder];
    
    // Reset the UINavigationBar according to whether something is now playing
    // Be sure to animate to make it look smooth
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        UIBarButtonItem* nowPlayingBtn = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"NowPlayingKey",@"Title of the Now Playing button") style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingClicked:)];
        [[self navigationItem] setRightBarButtonItem:nowPlayingBtn animated:YES];
        [[[self navigationItem] titleView] setFrame:CGRectMake(0.0,0.0,310.0,[[[self navigationItem] titleView] frame].size.height)];
        [UIView animateWithDuration:0.5 animations:^{
            [searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-100.0,[searchBar frame].size.height)];
        }];
    }
    else
    {
        [[self navigationItem] setRightBarButtonItem:nil animated:YES];
        [[[self navigationItem] titleView] setFrame:CGRectMake(0.0,0.0,310.0,[[[self navigationItem] titleView] frame].size.height)];
        [UIView animateWithDuration:0.5 animations:^{
            [searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-10.0,[searchBar frame].size.height)];
        }];
    }
}

#pragma mark UIRefreshControl Control Events

// When the user commands a refresh
-(void) refresh
{
    // If there is a previous valid search string, search
    if([searchString length] > 0)
        [[Spooftify sharedSpooftify] search:searchString];
    // Else end the refreshing
    else [[self refreshControl] endRefreshing];
}

#pragma mark UITabBarDelegate

// When the user selects a tab bar item
-(void) tabBar:(UITabBar*)tabBar didSelectItem:(UITabBarItem*)item
{
    // Reload the table
    [[self tableView] reloadData];
}

#pragma mark SpooftifySongsTableViewCellDelegate

// When the user clicks on the album button in the cell
-(void) spooftifySongsTableViewCellRequestAlbum:(SpooftifySongsTableViewCell*)cell
{
    // Create the album table view controller and show it to the user
    SpooftifyAlbumTableViewController* albumTableViewController = [[SpooftifyAlbumTableViewController alloc] initWithAlbumId:[[cell track] albumId] name:[[cell track] album]];
    [[self navigationController] pushViewController:albumTableViewController animated:YES];
}

// When the user clicks on the artist button in the cell
-(void) spooftifySongsTableViewCellRequestArtist:(SpooftifySongsTableViewCell*)cell
{
    // Create the artist table view controller and show it to the user
    SpooftifyArtistTableViewController* artistTableViewController = [[SpooftifyArtistTableViewController alloc] initWithArtist:[[cell track] artist]];
    [[self navigationController] pushViewController:artistTableViewController animated:YES];
}

#pragma mark SpooftifySearchDelegate

// When Spooftify has found the results for our search
-(void) spooftify:(Spooftify*)spooftify foundArtists:(NSArray*)artists albums:(NSArray*)albums tracks:(NSArray*)tracks
{
    // End the refreshing
    [[self refreshControl] endRefreshing];
    
    // Clear the arrays and add the new information to them
    [albumsArray removeAllObjects];
    [albumsArray addObjectsFromArray:albums];
    [artistsArray removeAllObjects];
    [artistsArray addObjectsFromArray:artists];
    [tracksArray removeAllObjects];
    [tracksArray addObjectsFromArray:tracks];
    
    // Reload the table view
    [[self tableView] reloadData];
}

@end
