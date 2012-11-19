/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyProfileTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"

@interface SpooftifyProfileTableViewController ()

@property (nonatomic,strong) SpooftifyProfile* profile;

@end

@implementation SpooftifyProfileTableViewController

@synthesize profile;

-(id) init
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    [self setTitle:@"Profile"];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:SpooftifyLoginSucceededNotification object:nil];
    
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
    if(profile == nil)
        return 0;
    return 4;
}

-(UITableViewCell*) tableView:(UITableView*)tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:[[UITableViewCell class] description]];
    switch(indexPath.row)
    {
        case 0:
        {
            [[cell textLabel] setText:@"Username:"];
            [[cell detailTextLabel] setText:[profile username]];
            break;
        }
        case 1:
        {
            [[cell textLabel] setText:@"Country:"];
            [[cell detailTextLabel] setText:[profile country]];
            break;
        }
        case 2:
        {
            [[cell textLabel] setText:@"Type:"];
            [[cell detailTextLabel] setText:[profile type]];
            break;
        }
        case 3:
        {
            [[cell textLabel] setText:@"Server:"];
            [[cell detailTextLabel] setText:[profile serverHost]];
            break;
        }
    }
    return cell;
}

-(void) loginSucceeded
{
    [self setProfile:[[Spooftify sharedSpooftify] profile]];
}

@end
