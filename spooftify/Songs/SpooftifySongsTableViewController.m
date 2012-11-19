/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifySongsTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "Spooftify.h"
#import "SpooftifyAlbumTableViewController.h"
#import "SpooftifyArtistTableViewController.h"
#import "SpooftifyShuffleButton.h"

@implementation SpooftifySongsTableViewController

-(id) initWithPlaylist:(SpooftifyPlaylist*)_playlist
{
    self = [super init];
    
    playlist = _playlist;
    
    [self setTitle:[playlist name]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTrack:) name:SpooftifyNewTrackNotification object:nil];
    
    return self;
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

-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[playlist tracks] count];
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    SpooftifySongsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifySongsTableViewCell class] description]];
    if(cell == nil)
    {
        cell = [[SpooftifySongsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifySongsTableViewCell class] description]];
        [cell setDelegate:self];
    }
    [cell setTrack:[[playlist tracks] objectAtIndex:indexPath.row]];
    return cell;
}

-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    [nowPlayingViewController playPlaylist:playlist atTrack:[[playlist tracks] objectAtIndex:indexPath.row]];
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

-(void) newTrack:(NSNotification*)notification
{
    [[self tableView] reloadData];
}

-(void) shuffleClicked:(SpooftifyShuffleButton*)shuffleBtn
{
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    [nowPlayingViewController playPlaylist:playlist atTrack:nil];
    [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
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
