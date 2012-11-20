#import "SpooftifyTableViewController.h"
#import "SpooftifyNowPlayingNavigationController.h"
#import "Spooftify.h"

@implementation SpooftifyTableViewController

-(id) init
{
    self = [super init];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newTrack:) name:SpooftifyNewTrackNotification object:nil];
    
    return self;
}

// When the view appears
-(void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
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

// If a new track is found
-(void) newTrack:(NSNotification*)notification
{
    // Reload our table so any cells that contain the currently playing item are updated
    [[self tableView] reloadData];
}

@end
