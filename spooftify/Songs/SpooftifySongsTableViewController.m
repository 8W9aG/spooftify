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

#pragma mark SpooftifySongsTableViewController

// Initialise
-(id) initWithPlaylist:(SpooftifyPlaylist*)_playlist
{
    self = [super init];
    
    playlist = _playlist;
    
    // Set the table view controllers title to the playlists name
    [self setTitle:[playlist name]];
    
    return self;
}

#pragma mark UITableViewDataSource

// Define the number of sections in the table view
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    // Always 1
    return 1;
}

// Define the number of rows in the table view
-(NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Count the number of tracks in the playlist
    return [[playlist tracks] count];
}

// Return the cell for the row
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Find the queued Spooftify songs table view cell
    SpooftifySongsTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[SpooftifySongsTableViewCell class] description]];
    
    // If none is found, create it
    if(cell == nil)
    {
        cell = [[SpooftifySongsTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:[[SpooftifySongsTableViewCell class] description]];
        [cell setDelegate:self];
    }
    
    // Set the cells track
    [cell setTrack:[[playlist tracks] objectAtIndex:indexPath.row]];
    return cell;
}

#pragma mark UITableViewDelegate

// When the user selects the cell
-(void) tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Set the now playing controllers track and present it to the user
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    [nowPlayingViewController playPlaylist:playlist atTrack:[[playlist tracks] objectAtIndex:indexPath.row]];
    [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
}

// Returns the view for the section header
-(UIView*) tableView:(UITableView*)tableView viewForHeaderInSection:(NSInteger)section
{
    // Create the shuffle button
    SpooftifyShuffleButton* shuffleBtn = [[SpooftifyShuffleButton alloc] init];
    [shuffleBtn addTarget:self action:@selector(shuffleClicked:) forControlEvents:UIControlEventTouchUpInside];
    return shuffleBtn;
}

// Define the height for the section header
-(CGFloat) tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    return SPOOFTIFY_SHUFFLE_BUTTON_HEIGHT;
}

#pragma mark UIButton Control Event

// When the user clicks the shuffle button
-(void) shuffleClicked:(SpooftifyShuffleButton*)shuffleBtn
{
    // Set the now playing controller to shuffle and present it to the user
    SpooftifyNowPlayingNavigationController* nowPlayingNavigationController = [SpooftifyNowPlayingNavigationController sharedNowPlayingNavigationController];
    SpooftifyNowPlayingViewController* nowPlayingViewController = [nowPlayingNavigationController nowPlayingViewController];
    [nowPlayingViewController playPlaylist:playlist atTrack:nil];
    [self presentViewController:nowPlayingNavigationController animated:YES completion:nil];
}

#pragma mark SpooftifySongsTableViewCellDelegate

// When the user clicks the album button
-(void) spooftifySongsTableViewCellRequestAlbum:(SpooftifySongsTableViewCell*)cell
{
    // Create the album table view controller and present it to the user
    SpooftifyAlbumTableViewController* albumTableViewController = [[SpooftifyAlbumTableViewController alloc] initWithAlbumId:[[cell track] albumId] name:[[cell track] album]];
    [[self navigationController] pushViewController:albumTableViewController animated:YES];
}

// When the user clicks the artist button
-(void) spooftifySongsTableViewCellRequestArtist:(SpooftifySongsTableViewCell*)cell
{
    // Create the artist table view controller and present it to the user
    SpooftifyArtistTableViewController* artistTableViewController = [[SpooftifyArtistTableViewController alloc] initWithArtist:[[cell track] artist]];
    [[self navigationController] pushViewController:artistTableViewController animated:YES];
}

@end
