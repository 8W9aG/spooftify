/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyLoginViewController.h"

#define kSpooftifyLoginViewControllerUsernameCellIndex 0
#define kSpooftifyLoginViewControllerPasswordCellIndex 1

@implementation SpooftifyLoginViewController

#pragma mark UIViewController

-(id) init
{
    self = [super init];
    
    // Securely store user names and passwords
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"Spooftify" accessGroup:nil];
    // Allow the keychain to access information when the phone is unlocked
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    // Sign up to Spooftify's notifications regarding logins
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:SpooftifyLoginSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailedWithError:) name:SpooftifyLoginFailedNotification object:nil];
    
    // Sign up to keyboard notifications so we can change the UI based on whether the keyboard is being shown
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    
    // Show the default image to make the transition from load screen to login seamless
    UIImageView* backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    // Adjust the frame to take into account the fact that the view will not be full screen
    [backgroundImage setFrame:CGRectMake(0.0,-[[UIApplication sharedApplication] statusBarFrame].size.height,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
    [[self view] addSubview:backgroundImage];
    
    // Create the table view to hold the username, password and login items (for looks only)
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,160.0) style:UITableViewStyleGrouped];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setScrollEnabled:NO];
    [tableView setCenter:CGPointMake([[self view] frame].size.width/2.0,[[self view] frame].size.height/2.0)];
    [[self view] addSubview:tableView];
    
    // Create the tables footer view with a bit more height to give padding between the login button and the last cell
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,50.0)];
    
    // Create the login button
    loginBtn = [[UIGrayGradientButton alloc] initWithFrame:CGRectMake(0.0,0.0,300.0,38.0)];
    [loginBtn setCenter:CGPointMake([footerView frame].size.width/2.0,[loginBtn center].y)];
    [loginBtn setTitle:NSLocalizedString(@"LogInKey",@"Title of Login Button") forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create an activity indicator and hide it in the login button
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setCenter:CGPointMake([loginBtn frame].size.width/2.0,[loginBtn frame].size.height/2.0)];
    [loginBtn addSubview:activityIndicator];
    
    [footerView addSubview:loginBtn];
    [tableView setTableFooterView:footerView];
    
    // Change the modal transition to a horizontal flip
    [self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
}

#pragma mark UIButton Control Events

// Login button has been pressed
-(void) loginButtonTouchUpInside:(UIButton*)_loginButton
{
    // Find the appropriate cells in the table view
    UITextFieldTableViewCell* usernameCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kSpooftifyLoginViewControllerUsernameCellIndex inSection:0]];
    UITextFieldTableViewCell* passwordCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kSpooftifyLoginViewControllerPasswordCellIndex inSection:0]];
    
    // Make sure both cells are accounted for
    if(usernameCell != nil && passwordCell != nil)
    {
        // Login
        // The use of async prevents the UI from lagging for a bit
        // The method loginWithUsername is asynchronous, but this may be the first time Spooftify was called forcing it to create itself and the despotify session which may take some time
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0ul),^{
            [[Spooftify sharedSpooftify] loginWithUsername:[[usernameCell textField] text] password:[[passwordCell textField] text]];
        });
        
        // Remove the keyboard
        [[usernameCell textField] resignFirstResponder];
        [[passwordCell textField] resignFirstResponder];
        
        // Stop the user from being able to enter any more text
        [[usernameCell textField] setEnabled:NO];
        [[passwordCell textField] setEnabled:NO];
        
        // Start the activity indicator to show login is being processed
        [activityIndicator startAnimating];
        
        // Change the title to show the activity indicator clearly
        [loginBtn setTitle:@"" forState:UIControlStateNormal];
        
        // Stop the user from being able to press the login button again
        [loginBtn setEnabled:NO];
    }
}

#pragma mark Spooftify Notifications

// If the login succeeded
-(void) loginSucceeded
{
    // Locate the appropriate cells in the table view
    UITextFieldTableViewCell* usernameCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kSpooftifyLoginViewControllerUsernameCellIndex inSection:0]];
    UITextFieldTableViewCell* passwordCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kSpooftifyLoginViewControllerPasswordCellIndex inSection:0]];
    
    // Make sure both cells are found
    if(usernameCell != nil && passwordCell != nil)
    {
        // Store the login credentials in the keychain
        [keychain setObject:[[usernameCell textField] text] forKey:(__bridge id)kSecAttrAccount];
        [keychain setObject:[[passwordCell textField] text] forKey:(__bridge id)kSecValueData];
    }
    
    // Stop spinning the activity indicator (our activity is done)
    [activityIndicator stopAnimating];
    
    // Dismiss the login view to the root view controller
    [self dismissViewControllerAnimated:YES completion:nil];
}

// If the login failed
-(void) loginFailedWithError:(NSNotification*)notification
{
    // Find the appropriate table view cells
    UITextFieldTableViewCell* usernameCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kSpooftifyLoginViewControllerUsernameCellIndex inSection:0]];
    UITextFieldTableViewCell* passwordCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:kSpooftifyLoginViewControllerPasswordCellIndex inSection:0]];
    
    // Make sure both cells are found
    if(usernameCell != nil && passwordCell != nil)
    {
        // Re-enable them to allow the user to try again
        [[usernameCell textField] setEnabled:YES];
        [[passwordCell textField] setEnabled:YES];
    }
    
    // Stop the activity indicator
    [activityIndicator stopAnimating];
    
    // Reset the login button to enabled
    [loginBtn setTitle:NSLocalizedString(@"LogInKey",@"Title of Login Button") forState:UIControlStateNormal];
    [loginBtn setEnabled:YES];
    
    // Alert the user that there is a problem
    // I'd really like to give the user some more information but despotify does not currently provide this
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ErrorKey",@"Title of Error Alert View") message:NSLocalizedString(@"LogInFailedKey",@"Contents of Login Error Alert") delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark Keyboard Notifications

// Keyboard is about to show
-(void) keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    // Find the keyboards animation duration
    double duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    // Find the keyboards animation curve
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    // Animate like the keyboard
    [UIView animateWithDuration:duration delay:0.0 options:(curve << 16) animations:^{
        // Move the table view up 70 pixels
        [tableView setCenter:CGPointMake([tableView center].x,[tableView center].y-70.0)];
    } completion:nil];
}

// Keyboard is about to hide
-(void) keyboardWillHide:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    
    // Find the keyboards animation duration
    double duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    // Find the keyboards animation curve
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    
    // Animate like the keyboard
    [UIView animateWithDuration:duration delay:0.0 options:(curve << 16) animations:^{
        // Move the table down by 70 pixels
        [tableView setCenter:CGPointMake([tableView center].x,[tableView center].y+70.0)];
    } completion:nil];
}

#pragma mark UITableViewDataSource

// Define the number of sections in the table view
-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

// Define the number of rows per table view section
-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    // Always 2, we just have the username and password cells
    return 2;
}

// Format the table cell for the row
-(UITableViewCell*) tableView:(UITableView*)_tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    // Find a queued cell
    UITextFieldTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:[[UITextFieldTableViewCell class] description]];
    
    // If one doesn't exist
    if(cell == nil)
    {
        // Create it
        cell = [[UITextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[UITableViewCell class] description]];
        // Set ourselves as the delegate
        [cell setDelegate:self];
        // Disable the tables selection style (no blue background)
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    
    // If the row is the username
    if(indexPath.row == kSpooftifyLoginViewControllerUsernameCellIndex)
    {
        // Set the cell's text field in accordance with the username text field
        [[cell textField] setPlaceholder:NSLocalizedString(@"UsernameKey",@"Placeholder for the username text field")];
        [[cell textField] setSecureTextEntry:NO];
        // Set the text fields return key to next, implying that if they click it, it will go towards the password text field
        [[cell textField] setReturnKeyType:UIReturnKeyNext];
        // Obtain the username from the keychain
        [[cell textField] setText:[keychain objectForKey:(__bridge id)kSecAttrAccount]];
    }
    // If not it must be the passwords
    else
    {
        // Set the cell's text field in accordance with the password text field
        [[cell textField] setPlaceholder:@"Password"];
        // Set the text field to have secure entry for a password
        [[cell textField] setSecureTextEntry:YES];
        // Set the return key to done (because after we have pressed the done key it will log us in)
        [[cell textField] setReturnKeyType:UIReturnKeyDone];
        // Obtain the password from the keychain
        [[cell textField] setText:[keychain objectForKey:(__bridge id)kSecValueData]];
    }
    return cell;
}

#pragma mark UITextFieldTableViewCellDelegate

// Fired when the cells text field ends its editing (presses the return key)
-(void) textFieldTableViewCellDidEndEditing:(UITextFieldTableViewCell*)cell
{
    // If the row is the username
    if([tableView indexPathForCell:cell].row == kSpooftifyLoginViewControllerUsernameCellIndex)
    {
        // Obtain the password cell
        UITextFieldTableViewCell* passwordCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        // Check if we have a valid cell
        if(passwordCell != nil)
            // Change the keyboards focus to this text field
            [[passwordCell textField] becomeFirstResponder];
    }
    // If not it must be the passwords
    else
    {
        // Remove the keyboard
        [[cell textField] resignFirstResponder];
        // Fire the method responsible for logging in when the login button is pressed
        [loginBtn sendActionsForControlEvents:UIControlEventTouchUpInside];
    }
}

@end
