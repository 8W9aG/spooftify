/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifySearchTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "Spooftify.h"
#import "SpooftifyAlbumTableViewCell.h"
#import "SpooftifyArtistTableViewCell.h"
#import "SpooftifyTrackTableViewCell.h"
#import "SpooftifyAlbumTableViewController.h"
#import "SpooftifyArtistTableViewController.h"

@implementation SpooftifySearchTableViewController

-(id) init
{
    self = [super init];
    
    [self setTitle:@"Search"];
    
    UIView* titleView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width,44.0)];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0.0,0.0,[titleView frame].size.width-10.0,[titleView frame].size.height)];
    [searchBar setDelegate:self];
    [searchBar setBarStyle:UIBarStyleBlack];
    [titleView addSubview:searchBar];
    [[self navigationItem] setTitleView:titleView];
    
    searchTabBar = [[UITabBar alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width,[[self tableView] rowHeight])];
    [[self tableView] setTableHeaderView:searchTabBar];
    albumTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Albums" image:[UIImage imageNamed:@"albumsSearch"] tag:0];
    artistTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Artists" image:[UIImage imageNamed:@"artistsSearch"] tag:0];
    songTabBarItem = [[UITabBarItem alloc] initWithTitle:@"Songs" image:[UIImage imageNamed:@"songsSearch"] tag:0];
    [searchTabBar setItems:[NSArray arrayWithObjects:albumTabBarItem,artistTabBarItem,songTabBarItem,nil]];
    [searchTabBar setDelegate:self];
    [searchTabBar setTintColor:[UIColor darkGrayColor]];
    [searchTabBar setSelectedImageTintColor:[UIColor redColor]];
    [searchTabBar setSelectedItem:albumTabBarItem];
    
    searchString = [[NSMutableString alloc] initWithString:@""];
    albumsArray = [[NSMutableArray alloc] init];
    artistsArray = [[NSMutableArray alloc] init];
    tracksArray = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFound:) name:SpooftifySearchFoundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTrack:) name:SpooftifyNewTrackNotification object:nil];
    
    return self;
}

-(void) viewDidLoad
{
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

-(void) viewWillAppear:(BOOL)animated
{
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        UIBarButtonItem* nowPlayingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingClicked:)];
        [[self navigationItem] setRightBarButtonItem:nowPlayingBtn];
        [[[self navigationItem] titleView] setFrame:CGRectMake(0.0,0.0,310.0,[[[self navigationItem] titleView] frame].size.height)];
        [searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-100.0,[searchBar frame].size.height)];
    }
    
    [[self tableView] reloadData];
}

-(void) nowPlayingClicked:(UIBarButtonItem*)nowPlayingBtn
{
    [self presentViewController:[SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController] animated:YES completion:nil];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if([searchTabBar selectedItem] == albumTabBarItem)
        return [albumsArray count];
    else if([searchTabBar selectedItem] == artistTabBarItem)
        return [artistsArray count];
    return [tracksArray count];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if([searchTabBar selectedItem] == albumTabBarItem)
    {
        SpooftifyAlbumTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifyAlbumTableViewCell class] description]];
        if(cell == nil)
            cell = [[SpooftifyAlbumTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifyAlbumTableViewCell class] description]];
        SpooftifyAlbum* album = [albumsArray objectAtIndex:indexPath.row];
        [cell setAlbum:album];
        return cell;
    }
    else if([searchTabBar selectedItem] == artistTabBarItem)
    {
        SpooftifyArtistTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifyArtistTableViewCell class] description]];
        if(cell == nil)
            cell = [[SpooftifyArtistTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[SpooftifyArtistTableViewCell class] description]];
        [cell setArtist:[artistsArray objectAtIndex:indexPath.row]];
        return cell;
    }
    
    SpooftifySongsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifySongsTableViewCell class] description]];
    if(cell == nil)
    {
        cell = [[SpooftifySongsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifySongsTableViewCell class] description]];
        [cell setDelegate:self];
    }
    [cell setTrack:[tracksArray objectAtIndex:indexPath.row]];
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    if([searchTabBar selectedItem] == albumTabBarItem)
    {
        SpooftifyAlbumTableViewController* albumTableViewController = [[SpooftifyAlbumTableViewController alloc] initWithAlbum:[albumsArray objectAtIndex:indexPath.row]];
        [[self navigationController] pushViewController:albumTableViewController animated:YES];
    }
    else if([searchTabBar selectedItem] == artistTabBarItem)
    {
        SpooftifyArtistTableViewController* artistTableViewController = [[SpooftifyArtistTableViewController alloc] initWithArtist:[artistsArray objectAtIndex:indexPath.row]];
        [[self navigationController] pushViewController:artistTableViewController animated:YES];
    }
    else
    {
        SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
        SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
        [nowPlayingViewController playTrack:[tracksArray objectAtIndex:indexPath.row]];
        [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
    }
}

-(void) searchBarSearchButtonClicked:(UISearchBar*)_searchBar
{
    [searchBar resignFirstResponder];
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        UIBarButtonItem* nowPlayingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingClicked:)];
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
    
    [searchString setString:[_searchBar text]];
    [[self refreshControl] beginRefreshing];
    [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
    [self refresh];
}

-(void) searchBarTextDidBeginEditing:(UISearchBar*)_searchBar
{
    [[[self navigationItem] titleView] setFrame:CGRectMake(0.0,0.0,310.0,[[[self navigationItem] titleView] frame].size.height)];
    [UIView animateWithDuration:0.5 animations:^{
        [_searchBar setFrame:CGRectMake(0.0,0.0,[[[self navigationItem] titleView] frame].size.width-60.0,[_searchBar frame].size.height)];
    }];
    UIBarButtonItem* cancelBtn = [[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancelClicked:)];
    [[self navigationItem] setRightBarButtonItem:cancelBtn animated:YES];
}

-(void) cancelClicked:(UIBarButtonItem*)cancelBtn
{
    [searchBar resignFirstResponder];
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        UIBarButtonItem* nowPlayingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingClicked:)];
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

-(void) refresh
{
    if([searchString length] > 0)
        [[Spooftify sharedSpooftify] search:searchString];
    else [[self refreshControl] endRefreshing];
}

-(void) searchFound:(NSNotification*)notification
{
    [[self refreshControl] endRefreshing];
    [albumsArray removeAllObjects];
    [albumsArray addObjectsFromArray:[[notification userInfo] objectForKey:@"Albums"]];
    [artistsArray removeAllObjects];
    [artistsArray addObjectsFromArray:[[notification userInfo] objectForKey:@"Artists"]];
    [tracksArray removeAllObjects];
    [tracksArray addObjectsFromArray:[[notification userInfo] objectForKey:@"Tracks"]];
    [[self tableView] reloadData];
}

-(void) tabBar:(UITabBar*)tabBar didSelectItem:(UITabBarItem*)item
{
    [[self tableView] reloadData];
}

-(void) newTrack:(NSNotification*)notification
{
    [[self tableView] reloadData];
}

-(void) spooftifySongsTableViewCellRequestAlbum:(SpooftifySongsTableViewCell*)cell
{
    SpooftifyAlbumTableViewController* albumTableViewController = [[SpooftifyAlbumTableViewController alloc] initWithAlbumId:[[cell track] albumId] name:[[cell track] album]];
    [[self navigationController] pushViewController:albumTableViewController animated:YES];
}

-(void) spooftifySongsTableViewCellRequestArtist:(SpooftifySongsTableViewCell*)cell
{
    SpooftifyArtistTableViewController* artistTableViewController = [[SpooftifyArtistTableViewController alloc] initWithArtist:[[cell track] artist]];
    [[self navigationController] pushViewController:artistTableViewController animated:YES];
}

@end
