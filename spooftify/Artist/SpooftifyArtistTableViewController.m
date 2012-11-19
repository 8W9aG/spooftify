/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyArtistTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "Spooftify.h"
#import "SpooftifyAlbumTableViewController.h"

@interface SpooftifyArtistTableViewController ()

@property (nonatomic,strong) SpooftifyArtist* artist;

@end

@implementation SpooftifyArtistTableViewController

@synthesize artist;

-(id) initWithArtist:(SpooftifyArtist*)_artist
{
    self = [super init];
    
    albumsArray = [[NSMutableArray alloc] init];
    singlesArray = [[NSMutableArray alloc] init];
    appearsOnArray = [[NSMutableArray alloc] init];
    
    [self setArtist:_artist];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(artistFound:) name:SpooftifyArtistFoundNotification object:nil];
    
    return self;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

-(void) viewWillAppear:(BOOL)animated
{
    if(![artist hasBrowseInformation])
    {
        [[self refreshControl] beginRefreshing];
        [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
        [self refresh];
    }
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        UIBarButtonItem* nowPlayingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingClicked:)];
        [[self navigationItem] setRightBarButtonItem:nowPlayingBtn];
    }
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 3;
}

-(NSString*) tableView:(UITableView*)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section == 0) return @"Albums";
    else if(section == 1) return @"Singles";
    return @"Appears On";
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0) return [albumsArray count];
    else if(section == 1) return [singlesArray count];
    return [appearsOnArray count];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[UITableViewCell class] description]];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    SpooftifyAlbum* album = nil;
    if(indexPath.section == 0)
        album = [albumsArray objectAtIndex:indexPath.row];
    else if(indexPath.section == 1)
        album = [singlesArray objectAtIndex:indexPath.row];
    else album = [appearsOnArray objectAtIndex:indexPath.row];
    [[cell textLabel] setText:[album name]];
    [[cell detailTextLabel] setText:[NSString stringWithFormat:@"by %@",[album artistName]]];
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    SpooftifyAlbum* album = nil;
    if(indexPath.section == 0)
        album = [albumsArray objectAtIndex:indexPath.row];
    else if(indexPath.section == 1)
        album = [singlesArray objectAtIndex:indexPath.row];
    else album = [appearsOnArray objectAtIndex:indexPath.row];
    
    SpooftifyAlbumTableViewController* albumTableViewController = [[SpooftifyAlbumTableViewController alloc] initWithAlbum:album];
    [[self navigationController] pushViewController:albumTableViewController animated:YES];
}

-(void) setArtist:(SpooftifyArtist*)_artist
{
    artist = _artist;
    [self setTitle:[artist name]];
    
    if([artist hasBrowseInformation])
    {
        for(SpooftifyAlbum* album in [artist albums])
        {
            if(![[album artistName] isEqualToString:[artist name]])
            {
                [appearsOnArray addObject:album];
            }
            else
            {
                if([[album tracks] count] <= 5) [singlesArray addObject:album];
                else [albumsArray addObject:album];
            }
        }
    }
}

-(void) nowPlayingClicked:(UIBarButtonItem*)nowPlayingBtn
{
    [self presentViewController:[SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController] animated:YES completion:nil];
}

-(void) artistFound:(NSNotification*)notification
{
    [[self refreshControl] endRefreshing];
    self.artist = [[notification userInfo] objectForKey:@"Artist"];
    [[self tableView] reloadData];
}

-(void) refresh
{
    [[Spooftify sharedSpooftify] findArtist:[artist artistId]];
}

@end
