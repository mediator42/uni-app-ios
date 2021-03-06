//
//  AppDelegate.m
//  SaarlandUniversityAppB
//
//  Created by Tobias Tykvart on 25.6.12.
//  Copyright (c) 2012 Universität des Saarlandes. All rights reserved.
//

#import "AppDelegate.h"
#import "CampusSelectionViewController.h"
#import "HomeViewController.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize QueryURL;
@synthesize detailURL;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString* dbPathString = [documentsDirectory stringByAppendingPathComponent:@"pointOfInterest.sqlite3"];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:dbPathString] == YES) {
        if (![fileManager removeItemAtPath:dbPathString error:&error]) {
            NSLog(@"%@",error);
        }
    }
    
    NSString *pathInMainBundle = [[NSBundle mainBundle] pathForResource:@"pointOfInterest" ofType:@"sqlite3"];
    if (![fileManager fileExistsAtPath:dbPathString]) {
        [fileManager copyItemAtPath:pathInMainBundle toPath:dbPathString error:nil];
    }
    
    UIStoryboard *mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                             bundle: nil];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPad"
                                                   bundle: nil];
        
    }
    else{
        mainStoryboard = [UIStoryboard storyboardWithName:@"MainStoryboard_iPhone"
                                                   bundle: nil];
    }
    
    
    
    NSUserDefaults *defaults= [NSUserDefaults standardUserDefaults];
    if([[[defaults dictionaryRepresentation] allKeys] containsObject:@"selectedCampus"]){
        
        HomeViewController *mainViewController = (HomeViewController*)[mainStoryboard
                                                                       instantiateViewControllerWithIdentifier: @"HomeViewController"];
        
        [(UINavigationController*)self.window.rootViewController pushViewController:mainViewController animated:YES];
        
    }
    else{
        
        CampusSelectionViewController *mainViewController = (CampusSelectionViewController*)[mainStoryboard
                                                                       instantiateViewControllerWithIdentifier: @"CampusSelectionViewController"];
        [(UINavigationController*)self.window.rootViewController pushViewController:mainViewController animated:YES];
    }
    
    
    
    
    // avoids black navigation bar while opeing app
    self.window.backgroundColor = [UIColor whiteColor];

    
    // Override point for customization after application launch.
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
    QueryURL = [[NSMutableString alloc] init];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
