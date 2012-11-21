/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyArtistTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "SpooftifyAlbumTableViewController.h"

#define kSpooftifyArtistTableViewControllerAlbumsSectionIndex 0
#define kSpooftifyArtistTableViewControllerSinglesSectionIndex 1
#define kSpooftifyArtistTableViewControllerAppearsOnSectionIndex 2

@interface SpooftifyArtistTableViewController ()

@property (nonatomic,strong) SpooftifyArtist* artist;

@end

@implementation SpooftifyArtistTableViewController

@synthesize artist;

#pragma mark SpooftifyArtistTableViewController

// Initialise
-(id) initWithArtist:(SpooftifyArtist*)_artist
{
    self = [super init];
    
    // Create the arrays corresponding to different table sections
    albumsArray = [[NSMutableArray alloc] init];
    singlesArray = [[NSMutableArray alloc] init];
    appearsOnArray = [[NSMutableArray alloc] init];
    
    // Create a refresh control
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    // Set the artist
    [self setArtist:_artist];
    
    return self;
}

-(void) setArtist:(SpooftifyArtist*)_artist
{
    artist = _artist;
    
    // Set the view controllers title to the artists name
    [self setTitle:[artist name]];
    
    // If we have browse information on the artist we can go through their albums
    if([artist hasBrowseInformation])
    {
        // Sort through the albums associated with the artist
        for(SpooftifyAlbum* album in [artist albums])
        {
            // If we have an album that is not the artists name, we consider it an appears on
            if(![[album artistName] isEqualToString:[artist name]])
                [appearsOnArray addObject:album];
            else
            {
                // If we have an album with 5 or less tracks we consider it a single
                if([[album tracks] count] <= 5)
                    [singlesArray addObject:album];
                else
                    // If not we consider it an album
                    [albumsArray addObject:album];
            }
        }
    }
}

#pragma mark UIViewController

// When the view appears
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Check if we have browse information
    if(![artist hasBrowseInformation])
    {
        // If we don't force a refresh to get it
        [[self refreshControl] beginRefreshing];
        [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
        [self refresh];
    }
}

#pragma mark UITableViewDataSource

// Define the number of sections in the table view
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    // Always 3
    return 3;
}

// Define the heading for each section
-(NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == kSpooftifyArtistTableViewControllerAlbumsSectionIndex) return NSLocalizedString(@"AlbumsKey",@"Title of Albums section header");
    else if(section == kSpooftifyArtistTableViewControllerSinglesSectionIndex) return NSLocalizedString(@"SinglesKey",@"Title of Singles section header");
    return NSLocalizedString(@"AppearsOnKey",@"Title of Appears On section header");
}

// Define the number of rows for each section
-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == kSpooftifyArtistTableViewControllerAlbumsSectionIndex) return [albumsArray count];
    else if(section == kSpooftifyArtistTableViewControllerSinglesSectionIndex) return [singlesArray count];
    return [appearsOnArray count];
}

// Return a cell for the row
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Find a queued cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    
    // If none are found, create one
    if(cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[UITableViewCell class] description]];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    
    // Find the appropriate album object
    SpooftifyAlbum* album = nil;
    if(indexPath.section == kSpooftifyArtistTableViewControllerAlbumsSectionIndex)
        album = [albumsArray objectAtIndex:indexPath.row];
    else if(indexPath.section == kSpooftifyArtistTableViewControllerSinglesSectionIndex)
        album = [singlesArray objectAtIndex:indexPath.row];
    else album = [appearsOnArray objectAtIndex:indexPath.row];
    
    // Set the cells UI to the albums
    [[cell textLabel] setText:[album name]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"by %@",[album artistName]]];
    return cell;
}

#pragma mark UITableViewDelegate

// When the user presses a cell
-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Find the appropriate album object based on the index path
    SpooftifyAlbum* album = nil;
    if(indexPath.section == kSpooftifyArtistTableViewControllerAlbumsSectionIndex)
        album = [albumsArray objectAtIndex:indexPath.row];
    else if(indexPath.section == kSpooftifyArtistTableViewControllerSinglesSectionIndex)
        album = [singlesArray objectAtIndex:indexPath.row];
    else album = [appearsOnArray objectAtIndex:indexPath.row];
    
    // Create the album table view controller and display it to the user
    SpooftifyAlbumTableViewController* albumTableViewController = [[SpooftifyAlbumTableViewController alloc] initWithAlbum:album];
    [[self navigationController] pushViewController:albumTableViewController animated:YES];
}

#pragma mark UIRefreshControl Event

// When the user refresh the table
-(void) refresh
{
    // Find the artist
    [[Spooftify sharedSpooftify] findArtist:[artist artistId] delegate:self];
}

#pragma mark SpooftifyArtistDelegate

// When Spooftify finds the artist
-(void) spooftify:(Spooftify*)spooftify foundArtist:(SpooftifyArtist*)_artist
{
    // End the refreshing
    [[self refreshControl] endRefreshing];
    
    // Set the new artist
    [self setArtist:_artist];
    
    // Reload the table data
    [[self tableView] reloadData];
}

@end
