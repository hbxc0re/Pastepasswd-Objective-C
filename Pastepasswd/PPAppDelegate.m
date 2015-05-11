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
#import <Crashlytics/Crashlytics.h>
#import "Flurry.h"

@implementation PPAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [Crashlytics startWithAPIKey:@"88300c2a59d5352c19153a01c6671ab3339d663e"];
     [Flurry startSession:@"2W32DPKHHCP4G5YDCN4Y"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    PPPasswordViewController *passwordViewController = [[PPPasswordViewController alloc] init];
    
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:passwordViewController];
    self.window.rootViewController = navigationController;
    
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UINavigationBar *navigationBar = [UINavigationBar appearance];
	//navigationBar.barTintColor = [UIColor colorWithRed:71.0f / 255.0f green:187.0f / 255.0f blue:201.0f / 255.0f alpha:1];
    //hue: 0.45, saturation: 0.48, brightness: 0.76, alpha: 1.00
    //success: 1 hue: 0.46, saturation: 0.70, brightness: 0.81, alpha: 1.00
    //success: 1 hue: 0.48, saturation: 0.64, brightness: 0.76, alpha: 1.00
    //navigationBar.barTintColor = [UIColor colorWithHue:0.48 saturation:0.64 brightness:0.76 alpha:1.00];
    navigationBar.barTintColor = [UIColor colorWithHue:0.52 saturation:0.65 brightness:0.79 alpha:1.00];
	navigationBar.tintColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
	navigationBar.titleTextAttributes = @{
                                          NSForegroundColorAttributeName: [UIColor whiteColor],
                                          NSFontAttributeName: [UIFont fontWithName:@"Avenir-Heavy" size:20.0f]
                                          };
    //hue: 0.49, saturation: 0.74, brightness: 0.65, alpha: 1.00
    //CGFloat hue;
    //CGFloat saturation;
    //CGFloat brightness;
    //CGFloat alpha;
    //BOOL success = [navigationBar.barTintColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha];
    //NSLog(@"success: %i hue: %0.2f, saturation: %0.2f, brightness: %0.2f, alpha: %0.2f", success, hue, saturation, brightness, alpha);
    
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {

}

- (void)applicationDidEnterBackground:(UIApplication *)application {

}

- (void)applicationWillEnterForeground:(UIApplication *)application {
   
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
   
}

- (void)applicationWillTerminate:(UIApplication *)application {// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
