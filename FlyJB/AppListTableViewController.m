//
//  AppListTableViewController.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/26.
//

#import "AppListTableViewController.h"

@interface AppListTableViewController () {
    NSArray *bundleIDArray;
    NSMutableDictionary* AppNameFromBundleID;
    NSMutableDictionary* AppIconFromBundleID;
    
    NSMutableArray* filteredBundleID;
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
        filteredBundleID = [[NSMutableArray alloc] init];
        
        for (NSString* bundleID in bundleIDArray) {
            NSRange nameRange = [AppNameFromBundleID[bundleID] rangeOfString:searchText options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound) {
                [filteredBundleID addObject:bundleID];
            }
        }
    }
    
    [self.tableView reloadData];
}

-(void)findApps {
    
    NSString *appPath = @"/var/containers/Bundle/Application/";
    NSArray *appLists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appPath error:nil];
    
    NSMutableArray *bundleIDs = [[NSMutableArray alloc] init];
    AppNameFromBundleID = [[NSMutableDictionary alloc] init];
    AppIconFromBundleID = [[NSMutableDictionary alloc] init];
    
    for (NSString* appLocation in appLists) {
        NSString *tmp = [appPath stringByAppendingString:appLocation];
        NSArray *tmp2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmp error:nil];
        for(NSString *tmp3 in tmp2) {
            if([tmp3 hasSuffix:@".app"]) {
                NSString *appContentsPath = [tmp stringByAppendingString:@"/"];
                appContentsPath = [appContentsPath stringByAppendingString:tmp3];
                
//                앱 Info.plist 가져오기
                NSString *appContentsInfoPath = [appContentsPath stringByAppendingString:@"/Info.plist"];
                NSMutableDictionary *appInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:appContentsInfoPath];
                
//                엡 번들ID를 가져옵니다. 단, FlyJB나 애플 관련 앱들은 건너뛰세요!
                NSString *bundleID = appInfo[@"CFBundleIdentifier"];
                if([bundleID hasPrefix:@"com.apple"] || [bundleID isEqualToString:@"kr.xsf1re.flyjbx"])
                    continue;
//                최적화 리스트의 경우 우회 리스트가 활성화된 앱이 아니라면 건너뛰세요!
                if([self.title isEqualToString:NSLocalizedString(@"Optimize List", nil)]) {
                    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
                    if(![prefs[bundleID] boolValue])
                        continue;
                }
                [bundleIDs addObject:bundleID];
                
//                앱 이름을 가져옵니다. 단, 이름을 가지고 있지 않으면 건너뛰세요!
                NSString *appName = [appInfo[@"CFBundleDisplayName"] description];
                if(!appName || appName.length == 0)
                    appName = [appInfo[@"CFBundleName"] description];
                if(!appName || appName.length == 0)
                    continue;
                [AppNameFromBundleID setObject:appName forKey:bundleID];
                
//                앱 아이콘 이미지를 가져옵니다. 단, 아이콘 이미지가 없다면 건너뛰세요!
                NSDictionary *CFBundleIcons = [appInfo objectForKey:@"CFBundleIcons"];
                NSDictionary *CFBundlePrimaryIcon = [CFBundleIcons objectForKey:@"CFBundlePrimaryIcon"];
                NSArray *CFBundleIconFiles = [CFBundlePrimaryIcon objectForKey:@"CFBundleIconFiles"];
                NSString *appImage = [appContentsPath stringByAppendingString:@"/"];
                
                if([CFBundleIconFiles firstObject])
                    appImage = [appImage stringByAppendingString:[CFBundleIconFiles firstObject]];
                else if(appInfo[@"CFBundleIconFile"])
                    appImage = [appImage stringByAppendingString:appInfo[@"CFBundleIconFile"]];
                if(!appImage)
                    continue;
                appImage = [appImage stringByAppendingString:@".png"];
                [AppIconFromBundleID setObject:appImage forKey:bundleID];
            }
        }
    }
    
    NSArray *bundleIDsSortedByAppName = [bundleIDs sortedArrayUsingComparator:^NSComparisonResult(id bundleID, id bundleID2) {
        
        NSString *obj1 = AppNameFromBundleID[bundleID];
        NSString *obj2 = AppNameFromBundleID[bundleID2];
        
        NSString* left = [NSString stringWithFormat:@"%@%@",
                          [obj1 localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                          !([obj1 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                          @"1", obj1];
        
        NSString* right = [NSString stringWithFormat:@"%@%@",
                           [obj2 localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                           !([obj2 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                           @"1", obj2];
        
        NSComparisonResult comparisonResult = [left localizedCaseInsensitiveCompare:right];
        
        return comparisonResult;
    }];
    
    bundleIDArray = bundleIDsSortedByAppName;
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
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(isFiltered)
        return filteredBundleID.count;
    return bundleIDArray.count;
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize {
    UIGraphicsBeginImageContextWithOptions(newSize, NO, 0.0);
    [image drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"appListCell" forIndexPath:indexPath];
    
    NSString *bundleID = bundleIDArray[indexPath.row];
    NSString *appImage = AppIconFromBundleID[bundleID];
    NSString *appName = AppNameFromBundleID[bundleID];
    
    //    NSLog(@"appImage: %@", appImage);
    
    
    if(isFiltered) {
        bundleID = filteredBundleID[indexPath.row];
        appName = AppNameFromBundleID[bundleID];
        appImage = AppIconFromBundleID[bundleID];
    }
    
    UIImage *image = [UIImage imageWithContentsOfFile:appImage];
    cell.imageView.image = [self imageWithImage:image scaledToSize:CGSizeMake(30, 30)];
    cell.imageView.layer.cornerRadius = 5.0;
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    cell.imageView.layer.borderWidth = 1.0;
    
    cell.textLabel.text = appName;
    
    UISwitch *theSwitch = [[UISwitch alloc] initWithFrame:CGRectZero];
    
    
    //    NSLog(@"self.title: %@", self.title);
    if([self.title isEqualToString:NSLocalizedString(@"Bypass List", nil)]) {
        //Get Bypass List...
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
        if([prefs[bundleID] boolValue])
            theSwitch.on = true;
        else
            theSwitch.on = false;
    } else if([self.title isEqualToString:NSLocalizedString(@"Optimize List", nil)]) {
        //Get Optimize List...
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist"];
        if([prefs[bundleID] boolValue])
            theSwitch.on = true;
        else
            theSwitch.on = false;
    } else if([self.title isEqualToString:NSLocalizedString(@"Disable List", nil)]) {
        //Get Disabler List...
        NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist"];
        if([prefs[bundleID] boolValue])
            theSwitch.on = true;
        else
            theSwitch.on = false;
    }
    cell.accessoryView = theSwitch;
    [theSwitch addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    return cell;
}

- (void)switchChanged:(id)sender {
    
//    https://stackoverflow.com/questions/31063571/getting-indexpath-from-switch-on-uitableview
    UISwitch *switchInCell = (UISwitch *)sender;
    CGPoint pos = [switchInCell convertPoint:switchInCell.bounds.origin toView:self.tableView];
    NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint:pos];
    
    NSString *bundleID = bundleIDArray[indexPath.row];
    
    if(isFiltered) {
        bundleID = filteredBundleID[indexPath.row];
    }
    
    if(switchInCell.on == true) {
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
        
    }
    
    else if (switchInCell.on == false) {
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
