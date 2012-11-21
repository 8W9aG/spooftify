/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifySettingsTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "Spooftify.h"
#import "UIGrayGradientButton.h"
#import "SpooftifyLoginViewController.h"

#define kSpooftifySettingsTableViewControllerVersionCellIndex 0
#define kSpooftifySettingsTableViewControllerHighBitrateCellIndex 1

@implementation SpooftifySettingsTableViewController

#pragma mark UITableViewController

// Initialise
-(id) init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    // Set the title of the table view to settings
    [self setTitle:NSLocalizedString(@"SettingsKey",@"Title of Settings Tab Bar Item")];
    
    // Listen for a successful login
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:SpooftifyLoginSucceededNotification object:nil];
    
    // Create the table footer view
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,50.0)];
    
    // Use a gray gradient button to log out of the app with
    UIGrayGradientButton* logoutBtn = [[UIGrayGradientButton alloc] initWithFrame:CGRectMake(0.0,0.0,300.0,38.0)];
    [logoutBtn setCenter:CGPointMake([footerView frame].size.width/2.0,[logoutBtn center].y)];
    [logoutBtn setTitle:NSLocalizedString(@"LogOutKey",@"Title of the Log Out Button") forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logoutButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:logoutBtn];
    [[self tableView] setTableFooterView:footerView];
    
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
-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // We only have 2 cells in this case
    return 2;
}

// Return the cell for a row
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // If the row is the high bitrate cell
    if(indexPath.row == kSpooftifySettingsTableViewControllerHighBitrateCellIndex)
    {
        // Find a queued switch table view cell
        UISwitchTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[UISwitchTableViewCell class] description]];
        
        // If there is none, create it
        if(cell == nil)
        {
            cell = [[UISwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[[UISwitchTableViewCell class] description]];
            [cell setDelegate:self];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        
        // Set the cells UI to High Bitrate
        [[cell textLabel] setText:NSLocalizedString(@"HighBitrateKey",@"Title of the High Bitrate cell")];
        [[cell boolSwitch] setOn:[[Spooftify sharedSpooftify] useHighBitrate]];
        return cell;
    }
    
    // Else it must be the version cell
    // Find a queued version cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    
    // If none exists, create it
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[[UITableViewCell class] description]];
    
    // Set the cells UI to Version
    [[cell textLabel] setText:NSLocalizedString(@"VersionKey",@"Title of the Version cell")];
    [[cell detailTextLabel] setText:[[NSUserDefaults standardUserDefaults] stringForKey:@"version"]];
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

#pragma mark Spooftify Notifications

// When the user successfully logs in
-(void) loginSucceeded
{
    // Reload the table view data
    [[self tableView] reloadData];
}

#pragma mark UISwitchTableViewCellDelegate

// When the user switches a cell
-(void) switchTableViewCell:(UISwitchTableViewCell*)cell switched:(BOOL)newValue
{
    // Set the defaults to our new value
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setBool:newValue forKey:@"high_bitrate"];
    [defaults synchronize];
    
    // Set spooftify to use our value
    [[Spooftify sharedSpooftify] setUseHighBitrate:newValue];
}

#pragma mark UIButton Control Events

// When the log out button is pressed
-(void) logoutButtonTouchUpInside:(UIButton*)logoutButton
{
    // Create a login view and present it to the user
    SpooftifyLoginViewController* loginViewController = [[SpooftifyLoginViewController alloc] init];
    [loginViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [[self tabBarController] presentViewController:loginViewController animated:YES completion:nil];
}

@end
