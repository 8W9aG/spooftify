/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyPlaylistTableViewController.h"
#import "SpooftifyPlaylistTableViewCell.h"
#import "SpooftifySongsTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"

@implementation SpooftifyPlaylistTableViewController

-(id) init
{
    self = [super init];
    
    [self setTitle:@"Playlists"];
    
    playlists = [[NSMutableArray alloc] init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:SpooftifyLoginSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(foundPlaylists:) name:SpooftifyPlaylistsFoundNotification object:nil];
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
    return [playlists count];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    static NSString* cellIdentifier = @"SPOOFTIFY_PLAYLIST_CELL";
    
    SpooftifyPlaylistTableViewCell* cell = (SpooftifyPlaylistTableViewCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if(cell == nil)
        cell = [[SpooftifyPlaylistTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    [cell setPlaylist:[playlists objectAtIndex:indexPath.row]];
    
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    SpooftifySongsTableViewController* songsTableViewController = [[SpooftifySongsTableViewController alloc] initWithPlaylist:[playlists objectAtIndex:indexPath.row]];
    [[self navigationController] pushViewController:songsTableViewController animated:YES];
}

-(void) refresh
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
    if(![[Spooftify sharedSpooftify] playlists])
        [[self refreshControl] endRefreshing];
}

-(void) loginSucceeded
{
    [[self refreshControl] beginRefreshing];
    [[self tableView] setContentOffset:CGPointMake(0.0,-44.0) animated:YES];
    [self refresh];
}

-(void) foundPlaylists:(NSNotification*)notification
{
    [[self refreshControl] endRefreshing];
    [playlists removeAllObjects];
    [playlists addObjectsFromArray:[[notification userInfo] objectForKey:@"Playlists"]];
    [[self tableView] reloadData];
}

-(void) newTrack:(NSNotification*)notification
{
    [[self tableView] reloadData];
}

@end
