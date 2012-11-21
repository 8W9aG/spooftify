/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyAlbumTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "SpooftifyShuffleButton.h"
#import "SpooftifyArtistTableViewController.h"

@interface SpooftifyAlbumTableViewController ()

@property (nonatomic,strong) SpooftifyAlbum* album;

@end

@implementation SpooftifyAlbumTableViewController

@synthesize album;

#pragma mark SpooftifyAlbumTableViewController

// Initialise
-(id) initWithAlbum:(SpooftifyAlbum*)_album
{
    self = [super init];
    
    // Create the UI
    albumLbl = [[UILabel alloc] initWithFrame:CGRectMake(102.0,8.0,[[self view] frame].size.width-102.0,15.0)];
    [albumLbl setFont:[UIFont boldSystemFontOfSize:15.0]];
    
    // Set the album
    [self setAlbum:_album];
    
    // Create the refresh control
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    return self;
}

// Initialise with ID and name
-(id) initWithAlbumId:(NSString*)albumId name:(NSString*)name;
{
    self = [super init];
    
    // Create the UI
    albumLbl = [[UILabel alloc] initWithFrame:CGRectMake(102.0,8.0,[[self view] frame].size.width-102.0,15.0)];
    [albumLbl setFont:[UIFont boldSystemFontOfSize:15.0]];
    
    // Temporarily set the title
    [self setTitle:name];
    
    // Refresh the album table view controller
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    [[self refreshControl] beginRefreshing];
    [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
    
    // Find the album we need
    [[Spooftify sharedSpooftify] findAlbum:albumId delegate:self];
    
    return self;
}

#pragma mark UIViewController

// Before the view appears
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // If we don't have browse information
    if(![album hasBrowseInformation])
    {
        // Refresh to load it
        [[self refreshControl] beginRefreshing];
        [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
        [self refresh];
    }
}

#pragma mark UITableViewDataSource

// Define the number of sections in the table view
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    // Always 1
    return 1;
}

// Define the number of rows in the table
-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of tracks in the album
    return [[album tracks] count];
}

// Return the cell for the row
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Find the song cell in the queue
    SpooftifySongsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifySongsTableViewCell class] description]];
    
    // If none exists create it
    if(cell == nil)
    {
        cell = [[SpooftifySongsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifySongsTableViewCell class] description]];
        [cell setDelegate:self];
        
        // Disable the album button because we are already on the album page
        [[cell albumButton] setEnabled:NO];
    }
    
    // Set the cells track
    [cell setTrack:[[album tracks] objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate

// When the user presses a cell
-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Find the now playing controller and play the track
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    [nowPlayingViewController playAlbum:album atTrack:[[album tracks] objectAtIndex:indexPath.row]];
    [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
}

// Return the view for the section header
-(UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    // Create the shuffle button
    SpooftifyShuffleButton* shuffleBtn = [[SpooftifyShuffleButton alloc] init];
    [shuffleBtn addTarget:self action:@selector(shuffleClicked:) forControlEvents:UIControlEventTouchUpInside];
    return shuffleBtn;
}

// Return the height for the section header
-(CGFloat) tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return SPOOFTIFY_SHUFFLE_BUTTON_HEIGHT;
}

#pragma mark UIRefreshControl Event

// When the user refreshes the table
-(void) refresh
{
    // If there is an album
    if(album != nil)
        // Load it again
        [[Spooftify sharedSpooftify] findAlbum:[album albumId] delegate:self];
}

#pragma mark SpooftifyAlbumTableViewController

// Override setAlbum
-(void) setAlbum:(SpooftifyAlbum*)_album
{
    album = _album;
    
    // Set the table view controllers title to the albums name
    [self setTitle:[album name]];
    
    // Create the album header view
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width,100.0)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    // Make the cover image view
    albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0,8.0,84.0,84.0)];
    [albumImageView setImage:[UIImage imageNamed:@"genericAlbum"]];
    [albumImageView setContentMode:UIViewContentModeScaleAspectFit];
    [headerView addSubview:albumImageView];
    
    // If the album has browse information
    if([album hasBrowseInformation])
        // It also contains the year
        [albumLbl setText:[NSString stringWithFormat:@"%@ (%d)",[album name],[album year]]];
    else
        [albumLbl setText:[album name]];
    [albumLbl setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:albumLbl];
    
    // Create the artist label and fill it
    UILabel* artistLbl = [[UILabel alloc] initWithFrame:CGRectMake(102.0,25.0,[albumLbl frame].size.width,17.0)];
    [artistLbl setFont:[UIFont systemFontOfSize:15.0]];
    [artistLbl setTextColor:[UIColor lightGrayColor]];
    [artistLbl setText:[album artistName]];
    [artistLbl setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:artistLbl];
    
    [[self tableView] setTableHeaderView:headerView];
    
    [[Spooftify sharedSpooftify] findImageWithId:[album coverId] delegate:self];
}

#pragma mark UIButton Control Event

// When the user presses the shuffle button
-(void) shuffleClicked:(SpooftifyShuffleButton*)shuffleBtn
{
    // Find the now playing view controller and display it to the user
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    [nowPlayingViewController playAlbum:album atTrack:nil];
    [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
}

#pragma mark SpooftifySongsTableViewCellDelegate

// When the user presses artist
-(void) spooftifySongsTableViewCellRequestArtist:(SpooftifySongsTableViewCell*)cell
{
    // Create the artist view controller and display it to the user
    SpooftifyArtistTableViewController* artistTableViewController = [[SpooftifyArtistTableViewController alloc] initWithArtist:[[cell track] artist]];
    [[self navigationController] pushViewController:artistTableViewController animated:YES];
}

#pragma mark SpooftifyAlbumDelegate

// When Spooftify finds the album
-(void) spooftify:(Spooftify*)spooftify foundAlbum:(SpooftifyAlbum*)_album
{
    // Stop refreshing
    [[self refreshControl] endRefreshing];
    
    // Set the new album
    [self setAlbum:_album];
    
    // Reload the table
    [[self tableView] reloadData];
}

#pragma mark SpooftifyImageDelegate

// When Spooftify finds the album image
-(void) spooftify:(Spooftify*)spooftify foundImage:(UIImage*)image forId:(NSString*)coverId
{
    // Check if it is the image we want
    if([[album coverId] isEqualToString:coverId])
        // If it is, set the image
        [albumImageView setImage:image];
}

@end
