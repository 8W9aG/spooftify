/*
 Copyright (c) 2012 Will Sackfield
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */
#import "AppDelegate.h"
#import "SpooftifyLoginViewController.h"
#import "SpooftifyTabBarController.h"

@implementation AppDelegate

-(BOOL) application:(UIApplication*)application didFinishLaunchingWithOptions:(NSDictionary*)launchOptions
{
    // Check for defaults in NSUserDefaults
    NSUserDefaults* userDefaults = [NSUserDefaults standardUserDefaults];
    NSString* version = [userDefaults stringForKey:@"version"];
    // Have the defaults been loaded in before?
    if(version == nil)
    {
        // I hate this... surely Settings.bundle should be loaded into NSUserDefauts by... you know... default
        NSString* settingsBundlePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"bundle"];
        NSDictionary* settingsDict = [NSDictionary dictionaryWithContentsOfFile:[settingsBundlePath stringByAppendingPathComponent:@"Root.plist"]];
        NSArray* preferences = [settingsDict objectForKey:@"PreferenceSpecifiers"];
        NSMutableDictionary* defaultsDict = [NSMutableDictionary dictionaryWithCapacity:[preferences count]];
        for(NSDictionary* preferenceDict in preferences)
        {
            NSString* key = [preferenceDict objectForKey:@"Key"];
            if(key != nil)
                [defaultsDict setObject:[preferenceDict objectForKey:@"DefaultValue"] forKey:key];
        }
        [userDefaults registerDefaults:defaultsDict];
    }
    
    // Create the apps window
    [self setWindow:[[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]]];
    
    // Create the tab bar controller and make it our root view controller
    SpooftifyTabBarController* tabBarController = [[SpooftifyTabBarController alloc] init];
    [[self window] setRootViewController:tabBarController];
    
    // Make the window visible
    [[self window] makeKeyAndVisible];
    
    // Present the login view controller immediately
    SpooftifyLoginViewController* loginViewController = [[SpooftifyLoginViewController alloc] init];
    [tabBarController presentViewController:loginViewController animated:NO completion:nil];
    
    return YES;
}

@end
