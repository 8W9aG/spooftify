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

@implementation SpooftifySettingsTableViewController

-(id) init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    [self setTitle:@"Settings"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:SpooftifyLoginSucceededNotification object:nil];
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,50.0)];
    
    UIGrayGradientButton* logoutBtn = [[UIGrayGradientButton alloc] initWithFrame:CGRectMake(0.0,0.0,300.0,38.0)];
    [logoutBtn setCenter:CGPointMake([footerView frame].size.width/2.0,[logoutBtn center].y)];
    [logoutBtn setTitle:@"Log Out" forState:UIControlStateNormal];
    [logoutBtn addTarget:self action:@selector(logoutButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    [footerView addSubview:logoutBtn];
    [[self tableView] setTableFooterView:footerView];
    
    return self;
}

-(void) viewWillAppear:(BOOL)animated
{
    if([SpooftifyNowPlayingNavigationController isNowPlayingActive])
    {
        UIBarButtonItem* nowPlayingBtn = [[UIBarButtonItem alloc] initWithTitle:@"Now Playing" style:UIBarButtonItemStyleBordered target:self action:@selector(nowPlayingClicked:)];
        [[self navigationItem] setRightBarButtonItem:nowPlayingBtn];
    }
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
    return 2;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    if(indexPath.row == 1)
    {
        UISwitchTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[UISwitchTableViewCell class] description]];
        if(cell == nil)
        {
            cell = [[UISwitchTableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[[UISwitchTableViewCell class] description]];
            [cell setDelegate:self];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
        [[cell textLabel] setText:@"High Bitrate"];
        [[cell boolSwitch] setOn:[[Spooftify sharedSpooftify] useHighBitrate]];
        return cell;
    }
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:[[UITableViewCell class] description]];
    [[cell textLabel] setText:@"Version"];
    
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [[cell detailTextLabel] setText:[defaults stringForKey:@"version"]];
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    return cell;
}

-(void) loginSucceeded
{
    [[self tableView] reloadData];
}

-(void) switchTableViewCell:(UISwitchTableViewCell*)cell switched:(BOOL)newValue
{
    NSIndexPath* indexPath = [[self tableView] indexPathForCell:cell];
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    if(indexPath.row == 1)
    {
        [defaults setBool:newValue forKey:@"use_cache"];
        [[Spooftify sharedSpooftify] setUseCache:newValue];
    }
    else
    {
        [defaults setBool:newValue forKey:@"high_bitrate"];
        [[Spooftify sharedSpooftify] setUseHighBitrate:newValue];
    }
    [defaults synchronize];
}

-(void) logoutButtonTouchUpInside:(UIButton*)logoutButton
{
    SpooftifyLoginViewController* loginViewController = [[SpooftifyLoginViewController alloc] init];
    [loginViewController setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
    [[self tabBarController] presentViewController:loginViewController animated:YES completion:nil];
}

@end
