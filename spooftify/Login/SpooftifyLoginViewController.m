/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "SpooftifyLoginViewController.h"

@implementation SpooftifyLoginViewController

-(id) init
{
    self = [super init];
    
    keychain = [[KeychainItemWrapper alloc] initWithIdentifier:@"Spooftify" accessGroup:nil];
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginSucceeded) name:SpooftifyLoginSucceededNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loginFailedWithError:) name:SpooftifyLoginFailedNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    return self;
}

-(void) viewDidLoad
{
    [[self view] setBackgroundColor:[UIColor grayColor]];
    
    UIImageView* backgroundImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Default"]];
    [backgroundImage setFrame:CGRectMake(0.0,-[[UIApplication sharedApplication] statusBarFrame].size.height,[[UIScreen mainScreen] bounds].size.width,[[UIScreen mainScreen] bounds].size.height)];
    [[self view] addSubview:backgroundImage];
    
    tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,160.0) style:UITableViewStyleGrouped];
    [tableView setDataSource:self];
    [tableView setBackgroundColor:[UIColor clearColor]];
    [tableView setBackgroundView:nil];
    [tableView setScrollEnabled:NO];
    [tableView setCenter:CGPointMake([[self view] frame].size.width/2.0,[[self view] frame].size.height/2.0)];
    [[self view] addSubview:tableView];
    
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectMake(0.0,0.0,320.0,50.0)];
    
    loginBtn = [[UIGrayGradientButton alloc] initWithFrame:CGRectMake(0.0,0.0,300.0,38.0)];
    [loginBtn setCenter:CGPointMake([footerView frame].size.width/2.0,[loginBtn center].y)];
    [loginBtn setTitle:@"Log In" forState:UIControlStateNormal];
    [loginBtn addTarget:self action:@selector(loginButtonTouchUpInside:) forControlEvents:UIControlEventTouchUpInside];
    
    activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activityIndicator setHidesWhenStopped:YES];
    [activityIndicator setCenter:CGPointMake([loginBtn frame].size.width/2.0,[loginBtn frame].size.height/2.0)];
    [loginBtn addSubview:activityIndicator];
    
    [footerView addSubview:loginBtn];
    [tableView setTableFooterView:footerView];
    
    [self setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
}

-(void) loginButtonTouchUpInside:(UIButton*)_loginButton
{
    UITextFieldTableViewCell* usernameCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextFieldTableViewCell* passwordCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if(usernameCell != nil && passwordCell != nil)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0ul),^{
            [[Spooftify sharedSpooftify] loginWithUsername:[[usernameCell textField] text] password:[[passwordCell textField] text]];
        });
        [[usernameCell textField] resignFirstResponder];
        [[passwordCell textField] resignFirstResponder];
        [[usernameCell textField] setEnabled:NO];
        [[passwordCell textField] setEnabled:NO];
        [activityIndicator startAnimating];
        [loginBtn setTitle:@"" forState:UIControlStateNormal];
        [loginBtn setEnabled:NO];
    }
}

-(void) loginSucceeded
{
    [keychain setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    UITextFieldTableViewCell* usernameCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextFieldTableViewCell* passwordCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if(usernameCell != nil && passwordCell != nil)
    {
        [[usernameCell textField] setEnabled:YES];
        [[passwordCell textField] setEnabled:YES];
        [keychain setObject:[[usernameCell textField] text] forKey:(__bridge id)kSecAttrAccount];
        [keychain setObject:[[passwordCell textField] text] forKey:(__bridge id)kSecValueData];
    }
    [activityIndicator stopAnimating];
    [loginBtn setTitle:@"Log In" forState:UIControlStateNormal];
    [loginBtn setEnabled:YES];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) loginFailedWithError:(NSNotification*)notification
{
    UITextFieldTableViewCell* usernameCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UITextFieldTableViewCell* passwordCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if(usernameCell != nil && passwordCell != nil)
    {
        [[usernameCell textField] setEnabled:YES];
        [[passwordCell textField] setEnabled:YES];
    }
    [activityIndicator stopAnimating];
    [loginBtn setTitle:@"Log In" forState:UIControlStateNormal];
    [loginBtn setEnabled:YES];
    
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Log In, Please check your credentials" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

-(void) keyboardWillShow:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    double duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    [UIView animateWithDuration:duration delay:0.0 options:(curve << 16) animations:^{
        [tableView setCenter:CGPointMake([tableView center].x,[tableView center].y-70.0)];
    } completion:nil];
}

-(void) keyboardWillHide:(NSNotification*)notification
{
    NSDictionary* userInfo = [notification userInfo];
    double duration = [[userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    UIViewAnimationCurve curve;
    [[userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&curve];
    [UIView animateWithDuration:duration delay:0.0 options:(curve << 16) animations:^{
        [tableView setCenter:CGPointMake([tableView center].x,[tableView center].y+70.0)];
    } completion:nil];
}

-(NSInteger) numberOfSectionsInTableView:(UITableView*)tableView
{
    return 1;
}

-(NSInteger) tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

-(UITableViewCell*) tableView:(UITableView*)_tableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
    UITextFieldTableViewCell* cell = [_tableView dequeueReusableCellWithIdentifier:[[UITableViewCell class] description]];
    if(cell == nil)
    {
        cell = [[UITextFieldTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:[[UITableViewCell class] description]];
        [cell setDelegate:self];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
    if(indexPath.row == 0)
    {
        [[cell textField] setPlaceholder:@"Username"];
        [[cell textField] setSecureTextEntry:NO];
        [[cell textField] setReturnKeyType:UIReturnKeyNext];
        [[cell textField] setText:[keychain objectForKey:(__bridge id)kSecAttrAccount]];
    }
    else
    {
        [[cell textField] setPlaceholder:@"Password"];
        [[cell textField] setSecureTextEntry:YES];
        [[cell textField] setText:[keychain objectForKey:(__bridge id)kSecValueData]];
    }
    return cell;
}

-(void) textFieldTableViewCellDidBeginEditing:(UITextFieldTableViewCell*)cell
{
}

-(void) textFieldTableViewCellDidEndEditing:(UITextFieldTableViewCell*)cell
{
    if([tableView indexPathForCell:cell].row == 0)
    {
        UITextFieldTableViewCell* passwordCell = (UITextFieldTableViewCell*)[tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
        [[passwordCell textField] becomeFirstResponder];
    }
    else
    {
        [[cell textField] resignFirstResponder];
    }
}

@end
