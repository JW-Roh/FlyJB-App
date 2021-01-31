//
//  AppDelegate.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/25.
//

#import "AppDelegate.h"
#import "SettingsCell.h"
#import "DobbyTableViewCell.h"
#import "AppListTableViewController.h"
#import "SettingsTableViewController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationWillEnterForeground:(UIApplication *)application {
    [[SettingsCell sharedInstance] getPreference];
    [[DobbyTableViewCell sharedInstance] getPreference];
    
    if([AppListTableViewController currentTableView])
       [[AppListTableViewController currentTableView] reloadData];

    [[SettingsTableViewController sharedInstance] updateTableView];
    [SettingsTableViewController createPreferenceIfNotExist];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}


@end
