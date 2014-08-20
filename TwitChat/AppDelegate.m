//
//  AppDelegate.m
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "AppDelegate.h"
#import "FirstViewController.h"
#import "SecondViewController.h"
#import "ThirdViewController.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Remote Notification を受信するためにデバイスを登録する
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeBadge
                                                                           | UIRemoteNotificationTypeSound
                                                                           | UIRemoteNotificationTypeAlert)];
        
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    
    UITabBarController *tabController = [[UITabBarController alloc]init];
    UITabBarItem *tab1 = [[UITabBarItem alloc]initWithTitle:@"トーク" image:nil tag:1];
    UINavigationController *navigationController1 = [[UINavigationController alloc]initWithRootViewController:[[FirstViewController alloc]init]];
    [navigationController1 setTabBarItem:tab1];
    
    UITabBarItem *tab2 = [[UITabBarItem alloc]initWithTitle:@"フォロワー" image:nil tag:2];
    UINavigationController *navigationController2 = [[UINavigationController alloc]initWithRootViewController:[[SecondViewController alloc]init]];
    [navigationController2 setTabBarItem:tab2];
    
    UITabBarItem *tab3 = [[UITabBarItem alloc]initWithTitle:@"設定" image:nil tag:3];
    UINavigationController *navigationController3 = [[UINavigationController alloc]initWithRootViewController:[[ThirdViewController alloc]init]];
    [navigationController3 setTabBarItem:tab3];
    
    tabController.viewControllers = [NSArray arrayWithObjects:navigationController1, navigationController2, navigationController3, nil];
    tabController.tabBar.translucent = NO;
    
    self.window.rootViewController = tabController;
    
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

// デバイストークンを受信した際の処理
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    
    NSString *devToken = [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"withString:@""]
                                stringByReplacingOccurrencesOfString:@">" withString:@""]
                                stringByReplacingOccurrencesOfString: @" " withString: @""];
    NSLog(@"deviceToken: %@", devToken);
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:devToken forKey:@"devToken"];
}

// プッシュ通知を受信した際の処理
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"push recieved : %@", userInfo);
}

@end
