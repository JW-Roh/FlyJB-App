//
//  AppListTableViewController.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/26.
//

#import "AppListTableViewController.h"

@interface AppListTableViewController () {
    NSArray *appArray;
    NSMutableDictionary* bundleIDWithAppName;
    NSMutableDictionary* appIconWithAppName;
    
    NSMutableArray* filteredApps;
    BOOL isFiltered;
}

@end

@implementation AppListTableViewController

static NSString* appListTitle = nil;
static id currentTableView = nil;

+ (instancetype)sharedInstance {
    static AppListTableViewController* sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

-(void)setAppListTitle:(NSString*)title {
    appListTitle = title;
}

-(void)setCurrentTableView {
    currentTableView = self.tableView;
}

+(id)currentTableView {
    return currentTableView;
}

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if(searchText.length == 0) {
        isFiltered = false;
    } else {
        isFiltered = true;
        filteredApps = [[NSMutableArray alloc] init];
        
        for (NSString* app in appArray) {
            NSRange nameRange = [app rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound) {
                [filteredApps addObject:app];
            }
        }
    }
    
    [self.tableView reloadData];
}

-(void)findApps {

    NSString *appPath = @"/var/containers/Bundle/Application/";
    NSArray *appLists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appPath error:nil];
    
    NSMutableArray *apps = [[NSMutableArray alloc] init];
    bundleIDWithAppName = [[NSMutableDictionary alloc] init];
    appIconWithAppName = [[NSMutableDictionary alloc] init];
    
    //    NSLog(@"appLists: %@", appLists);
    for (NSString* appLocation in appLists) {
        NSString *tmp = [appPath stringByAppendingString:appLocation];
        NSArray *tmp2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmp error:nil];
        for(NSString *tmp3 in tmp2) {
            if([tmp3 hasSuffix:@".app"]) {
                NSString *appContentsPath = [tmp stringByAppendingString:@"/"];
                appContentsPath = [appContentsPath stringByAppendingString:tmp3];
                //              NSLog(@"appContentsPath: %@", appContentsPath);
                NSString *appContentsInfoPath = [appContentsPath stringByAppendingString:@"/Info.plist"];
                //                NSLog(@"appContentsInfoPath: %@", appContentsInfoPath);
                NSMutableDictionary *appInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:appContentsInfoPath];
                
                NSString *bundleID = appInfo[@"CFBundleIdentifier"];
                if([bundleID hasPrefix:@"com.apple"] || [bundleID isEqualToString:@"kr.xsf1re.flyjbx"])
                    continue;
            
                if([self.title isEqualToString:NSLocalizedString(@"Optimize List", nil)]) {
                    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
                    if(![prefs[bundleID] boolValue])
                        continue;
                }
                
                NSString *appName = appInfo[@"CFBundleDisplayName"];
                if(appName == nil || [appName isEqualToString:@""])
                    appName = appInfo[@"CFBundleName"];
                
                //                NSLog(@"AppName: %@, bundleID: %@", appName, bundleID);

                if(!appName)
                    continue;
                
                [apps addObject:appName];
                
                [bundleIDWithAppName setObject:bundleID forKey:appName];
                
//                NSString* appImage = [appContentsPath stringByAppendingString:@"/AppIcon60x60@2x.png"];
                NSDictionary *CFBundleIcons = [appInfo objectForKey:@"CFBundleIcons"];
                NSDictionary *CFBundlePrimaryIcon = [CFBundleIcons objectForKey:@"CFBundlePrimaryIcon"];
                NSArray *CFBundleIconFiles = [CFBundlePrimaryIcon objectForKey:@"CFBundleIconFiles"];

                NSString *appImage = [appContentsPath stringByAppendingString:@"/"];
                
                if([CFBundleIconFiles firstObject])
                    appImage = [appImage stringByAppendingString:[CFBundleIconFiles firstObject]];
                else if(appInfo[@"CFBundleIconFile"])
                    appImage = [appImage stringByAppendingString:appInfo[@"CFBundleIconFile"]];
                appImage = [appImage stringByAppendingString:@".png"];
                
                if(!appImage)
                    continue;
                [appIconWithAppName setObject:appImage forKey:appName];
            }
        }
    }
    
    [apps sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    appArray = apps;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];

    [self setCurrentTableView];
    [self setTitle:appListTitle];

    isFiltered = false;
    self.searchBar.delegate = self;
    self.searchBar.placeholder = NSLocalizedString(@"Search Apps", nil);

    [self findApps];
    
    //    NSLog(@"appArray: %@", appArray);
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isFiltered)
        return filteredApps.count;
    return appArray.count;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    //UIGraphicsBeginImageContext(newSize);
    // In next line, pass 0.0 to use the current device's pixel scaling factor (and thus account for Retina resolution).
    // Pass 1.0 to force exact pixel size.
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
//    [[UIBezierPath bezierPathWithRoundedRect:imageView.bounds cornerRadius:10.0] addClip];
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"appListCell" forIndexPath:indexPath];
    
    NSString *appName = appArray[indexPath.row];
    
    if(isFiltered) {
        appName = filteredApps[indexPath.row];
    }
    
    NSString *appImage = appIconWithAppName[appName];
    NSString *bundleID = bundleIDWithAppName[appName];
    
//    NSLog(@"appImage: %@", appImage);
    UIImage *image = [UIImage imageWithContentsOfFile:appImage];
    cell.imageView.image = [self imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
    cell.imageView.layer.cornerRadius = 5.0;
    cell.imageView.layer.masksToBounds = YES;
    
    cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.imageView.layer.borderWidth = 1.0;
    
    if(isFiltered) {
        cell.textLabel.text = filteredApps[indexPath.row];
    } else {
        cell.textLabel.text = appArray[indexPath.row];
    }
    
//    NSLog(@"self.title: %@", self.title);
    if([self.title isEqualToString:NSLocalizedString(@"Bypass List", nil)]) {
        //Get Bypass List...
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
        if([prefs[bundleID] boolValue])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    } else if([self.title isEqualToString:NSLocalizedString(@"Optimize List", nil)]) {
        //Get Optimize List...
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist"];
        if([prefs[bundleID] boolValue])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    } else if([self.title isEqualToString:NSLocalizedString(@"Disable List", nil)]) {
        //Get Disabler List...
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"];
        if([prefs[bundleID] boolValue])
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
        else
            cell.accessoryType = UITableViewCellAccessoryNone;
    }


    return cell;
}

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    NSString *appName = appArray[indexPath.row];
    if(isFiltered) {
        appName = filteredApps[indexPath.row];
    }
    
    NSString *bundleID = bundleIDWithAppName[appName];
    
    if([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryNone) {
        NSLog(@"Enable an app.");
        if([self.title isEqualToString:NSLocalizedString(@"Bypass List", nil)]) {
            NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist";
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            
            [prefs setValue:[NSNumber numberWithBool:YES] forKey:bundleID];
            [prefs writeToFile:path atomically:NO];
        }
        else if([self.title isEqualToString:NSLocalizedString(@"Optimize List", nil)]) {
            NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist";
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            
            [prefs setValue:[NSNumber numberWithBool:YES] forKey:bundleID];
            [prefs writeToFile:path atomically:NO];
        }
        else if([self.title isEqualToString:NSLocalizedString(@"Disable List", nil)]) {
            NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist";
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            
            [prefs setValue:[NSNumber numberWithBool:YES] forKey:bundleID];
            [prefs writeToFile:path atomically:NO];
        }
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
    }
    
    else if ([tableView cellForRowAtIndexPath:indexPath].accessoryType == UITableViewCellAccessoryCheckmark) {
        NSLog(@"Disable an app.");
        if([self.title isEqualToString:NSLocalizedString(@"Bypass List", nil)]) {
            NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist";
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            
            [prefs setValue:[NSNumber numberWithBool:NO] forKey:bundleID];
            [prefs writeToFile:path atomically:NO];
        }
        else if([self.title isEqualToString:NSLocalizedString(@"Optimize List", nil)]) {
            NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist";
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            
            [prefs setValue:[NSNumber numberWithBool:NO] forKey:bundleID];
            [prefs writeToFile:path atomically:NO];
        }
        else if([self.title isEqualToString:NSLocalizedString(@"Disable List", nil)]) {
            NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist";
            NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
            
            [prefs setValue:[NSNumber numberWithBool:NO] forKey:bundleID];
            [prefs writeToFile:path atomically:NO];
        }
        
        [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryNone;
    }
}



/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
