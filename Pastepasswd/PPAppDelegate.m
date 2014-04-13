//
//  PPAppDelegate.m
//  Pastepasswd
//
//  Created by Spiros Gerokostas on 2/12/14.
//  Copyright (c) 2014 Spiros Gerokostas. All rights reserved.
//

#import "PPAppDelegate.h"
#import "PPMainViewController.h"
#import "PPPasswordViewController.h"

@implementation PPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PPPasswordViewController *passwordViewController = [[PPPasswordViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:passwordViewController];
    self.window.rootViewController = navigationController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UINavigationBar *navigationBar = [UINavigationBar appearance];
	//navigationBar.barTintColor = [UIColor colorWithRed:101.0f / 255.0f green:195.0f / 255.0f blue:169.0f / 255.0f alpha:1];
    //hue: 0.45, saturation: 0.48, brightness: 0.76, alpha: 1.00
    navigationBar.barTintColor = [UIColor colorWithHue:0.45 saturation:0.48 brightness:0.76 alpha:1.00];
	navigationBar.tintColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
	navigationBar.titleTextAttributes = @{
                                          NSForegroundColorAttributeName: [UIColor whiteColor],
                                          NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0f]
                                          };
    //hue: 0.49, saturation: 0.74, brightness: 0.65, alpha: 1.00
    CGFloat hue;
    CGFloat saturation;
    CGFloat brightness;
    CGFloat alpha;
    BOOL success = [navigationBar.barTintColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    NSLog(@"success: %i hue: %0.2f, saturation: %0.2f, brightness: %0.2f, alpha: %0.2f", success, hue, saturation, brightness, alpha);
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
