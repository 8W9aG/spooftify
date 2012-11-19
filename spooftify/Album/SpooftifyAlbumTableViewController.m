/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyAlbumTableViewController.h"
#import "Spooftify.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "SpooftifyShuffleButton.h"
#import "SpooftifyArtistTableViewController.h"

@interface SpooftifyAlbumTableViewController ()

@property (nonatomic,strong) SpooftifyAlbum* album;

@end

@implementation SpooftifyAlbumTableViewController

@synthesize album;

-(id) initWithAlbum:(SpooftifyAlbum*)_album
{
    self = [super init];
    
    albumLbl = [[UILabel alloc] initWithFrame:CGRectMake(102.0,8.0,[[self view] frame].size.width-102.0,15.0)];
    [albumLbl setFont:[UIFont boldSystemFontOfSize:15.0]];
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [self setAlbum:_album];
    
    return self;
}

-(id) initWithAlbumId:(NSString*)albumId name:(NSString*)name;
{
    self = [super init];
    
    albumLbl = [[UILabel alloc] initWithFrame:CGRectMake(102.0,8.0,[[self view] frame].size.width-102.0,15.0)];
    [albumLbl setFont:[UIFont boldSystemFontOfSize:15.0]];
    
    UIRefreshControl* refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [self setTitle:[album name]];
    
    [[self refreshControl] beginRefreshing];
    [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
    [[Spooftify sharedSpooftify] findAlbum:albumId];
    
    return self;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(albumFound:) name:SpooftifyAlbumFoundNotification object:nil];
}

-(void) viewWillAppear:(BOOL)animated
{
    if(![album hasBrowseInformation])
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
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[album tracks] count];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SpooftifySongsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifySongsTableViewCell class] description]];
    if(cell == nil)
    {
        cell = [[SpooftifySongsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifySongsTableViewCell class] description]];
        [[cell albumButton] setEnabled:NO];
        [cell setDelegate:self];
    }
    [cell setTrack:[[album tracks] objectAtIndex:indexPath.row]];
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    [nowPlayingViewController playAlbum:album atTrack:[[album tracks] objectAtIndex:indexPath.row]];
    [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
}

-(UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    SpooftifyShuffleButton* shuffleBtn = [[SpooftifyShuffleButton alloc] init];
    [shuffleBtn addTarget:self action:@selector(shuffleClicked:) forControlEvents:UIControlEventTouchUpInside];
    return shuffleBtn;
}

-(CGFloat) tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return SPOOFTIFY_SHUFFLE_BUTTON_HEIGHT;
}

-(void) refresh
{
    if(album != nil)
        [[Spooftify sharedSpooftify] findAlbum:[album albumId]];
}

-(void) albumFound:(NSNotification*)notification
{
    [[self refreshControl] endRefreshing];
    [self setAlbum:[[notification userInfo] objectForKey:@"Album"]];
    [albumLbl setText:[NSString stringWithFormat:@"%@ (%d)",[album name],[album year]]];
    [[self tableView] reloadData];
}

-(void) nowPlayingClicked:(UIBarButtonItem*)nowPlayingBtn
{
    [self presentViewController:[SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController] animated:YES completion:nil];
}

-(void) setAlbum:(SpooftifyAlbum*)_album
{
    album = _album;
    
    [self setTitle:[album name]];
    
    UIView* headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,[[self view] frame].size.width,100.0)];
    [headerView setBackgroundColor:[UIColor whiteColor]];
    
    albumImageView = [[UIImageView alloc] initWithFrame:CGRectMake(8.0,8.0,84.0,84.0)];
    [albumImageView setImage:[UIImage imageNamed:@"genericAlbum"]];
    [albumImageView setContentMode:UIViewContentModeScaleAspectFit];
    [headerView addSubview:albumImageView];
    
    if([album hasBrowseInformation])
        [albumLbl setText:[NSString stringWithFormat:@"%@ (%d)",[album name],[album year]]];
    else
        [albumLbl setText:[album name]];
    [albumLbl setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:albumLbl];
    
    UILabel* artistLbl = [[UILabel alloc] initWithFrame:CGRectMake(102.0,25.0,[albumLbl frame].size.width,17.0)];
    [artistLbl setFont:[UIFont systemFontOfSize:15.0]];
    [artistLbl setTextColor:[UIColor lightGrayColor]];
    [artistLbl setText:[album artistName]];
    [artistLbl setBackgroundColor:[UIColor clearColor]];
    [headerView addSubview:artistLbl];
    
    [[self tableView] setTableHeaderView:headerView];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0ul),^{
        UIImage* coverImage = [[Spooftify sharedSpooftify] imageWithId:[album coverId]];
        dispatch_sync(dispatch_get_main_queue(),^{
            [albumImageView setImage:coverImage];
        });
    });
}

-(void) shuffleClicked:(SpooftifyShuffleButton*)shuffleBtn
{
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    [nowPlayingViewController playAlbum:album atTrack:nil];
    [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
}

-(void) spooftifySongsTableViewCellRequestAlbum:(SpooftifySongsTableViewCell*)cell
{
}

-(void) spooftifySongsTableViewCellRequestArtist:(SpooftifySongsTableViewCell*)cell
{
    SpooftifyArtistTableViewController* artistTableViewController = [[SpooftifyArtistTableViewController alloc] initWithArtist:[[cell track] artist]];
    [[self navigationController] pushViewController:artistTableViewController animated:YES];
}

@end
