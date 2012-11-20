/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyProfileTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"

#define kSpooftifyProfileTableViewControllerUsernameCellIndex 0
#define kSpooftifyProfileTableViewControllerCountryCellIndex 1
#define kSpooftifyProfileTableViewControllerTypeCellIndex 2
#define kSpooftifyProfileTableViewControllerServerCellIndex 3

@interface SpooftifyProfileTableViewController ()

@property (nonatomic,strong) SpooftifyProfile* profile;

@end

@implementation SpooftifyProfileTableViewController

@synthesize profile;

#pragma mark UITableViewController

// Initialise
-(id) init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    // Set the title
    [self setTitle:NSLocalizedString(@"ProfileKey",@"Title of Profile Navigation Bar")];
    
    // Subscribe to login notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:SpooftifyLoginSucceededNotification object:nil];
    
    return self;
}

#pragma mark UITableViewDataSource

// Define the number of sections in the table view
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

// Define the number of rows in the table view
-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // If we have no profile we have no data
    if(profile == nil)
        return 0;
    
    // Else we will have 4 items
    return 4;
}

// Return the cell for the row
-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Find the queued cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    
    // If there is no queued cell
    if(cell == nil)
        // Create one
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:[[UITableViewCell class] description]];
    
    // Fill in the cell depending on the row
    switch(indexPath.row)
    {
        case kSpooftifyProfileTableViewControllerUsernameCellIndex:
        {
            [[cell textLabel] setText:NSLocalizedString(@"UsernameKey",@"Username cell title")];
            [[cell detailTextLabel] setText:[profile username]];
            break;
        }
        case kSpooftifyProfileTableViewControllerCountryCellIndex:
        {
            [[cell textLabel] setText:NSLocalizedString(@"CountryKey",@"Country cell title")];
            [[cell detailTextLabel] setText:[profile country]];
            break;
        }
        case kSpooftifyProfileTableViewControllerTypeCellIndex:
        {
            [[cell textLabel] setText:NSLocalizedString(@"TypeKey",@"Type cell title")];
            [[cell detailTextLabel] setText:[profile type]];
            break;
        }
        case kSpooftifyProfileTableViewControllerServerCellIndex:
        {
            [[cell textLabel] setText:NSLocalizedString(@"ServerKey",@"Server cell title")];
            [[cell detailTextLabel] setText:[profile serverHost]];
            break;
        }
    }
    
    return cell;
}

#pragma mark Spooftify Notifications

// When the user logs in
-(void) loginSucceeded
{
    // Set our profile to the users
    [self setProfile:[[Spooftify sharedSpooftify] profile]];
}

#pragma mark SpooftifyProfileTableViewController

// Override setProfile
-(void) setProfile:(SpooftifyProfile*)_profile
{
    profile = _profile;
    
    // If we have a new profile we need to reload the tables data
    [[self tableView] reloadData];
}

@end
