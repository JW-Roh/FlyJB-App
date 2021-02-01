//
//  SettingsTableViewController.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/25.
//

#import "SettingsTableViewController.h"
#import "AppListTableViewController.h"
#import <sys/stat.h>

@interface SettingsTableViewController () {
    NSArray *enable;
    NSArray *enableDobby;
    NSArray *settings;
    NSArray *settingsDescription;
    NSArray *updateMemPatch;
    NSMutableArray *updateMemPatchDescription;
    NSArray *resetPrefs;
    NSArray *sections;
    
}

@end

@implementation SettingsTableViewController

static SettingsTableViewController* sharedInstance = nil;

+ (instancetype)sharedInstance {
    return sharedInstance;
}

+(void)createPreferenceIfNotExist {
    NSString *flyjbPath = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist";
    NSString *optimizePath = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist";
    NSString *disablerPath = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist";
    
    NSMutableDictionary *data = [[NSMutableDictionary alloc] init];
    
    if(access([flyjbPath UTF8String], F_OK) == -1)
        [data writeToFile:flyjbPath atomically:YES];
    if(access([optimizePath UTF8String], F_OK) == -1)
        [data writeToFile:optimizePath atomically:YES];
    if(access([disablerPath UTF8String], F_OK) == -1)
        [data writeToFile:disablerPath atomically:YES];
}

-(void)updateTableView {
    NSString *FJDataPath = @"/var/mobile/Library/Preferences/FJMemory";
    NSData *FJMemory = [NSData dataWithContentsOfFile:FJDataPath options:0 error:nil];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:FJMemory options:0 error:nil];
    NSString *version = [dict objectForKeyedSubscript:@"version"];
    NSString* updateDesc = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last Update Date", nil), version];
    updateMemPatchDescription[0] = updateDesc;
    [self.tableView reloadData];
}

-(void)setPermission {
    BOOL failedPermission = false;
    if(chmod("/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist", 0644) == -1) {
        failedPermission = true;
    }
    if(chmod("/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist", 0644) == -1) {
        failedPermission = true;
    }
    if(chmod("/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist", 0644) == -1) {
        failedPermission = true;
    }

    
    if(failedPermission) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Setting Permission Failed", nil)
                                                                       message:NSLocalizedString(@"Failed to set permission. Is your device jailbroken?", nil)
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        
        [alert addAction: ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSIndexPath* indexPath = [self.tableView indexPathForCell:(UITableViewCell*)sender];
    if(indexPath != nil) {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString *title = cell.textLabel.text;
        [[AppListTableViewController sharedInstance] setAppListTitle:title];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    sharedInstance = self;
    [[self class] createPreferenceIfNotExist];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self setTitle:NSLocalizedString(@"Settings", nil)];
    
    [self setPermission];
    
    enable = @[NSLocalizedString(@"Activate FlyJB", nil)];
    enableDobby = @[NSLocalizedString(@"Enable Dobby", nil)];
    settings = @[NSLocalizedString(@"Bypass List", nil), NSLocalizedString(@"Optimize List", nil), NSLocalizedString(@"Disable List", nil)];
    settingsDescription = @[NSLocalizedString(@"Selected Apps can NOT access the system.\nOther Apps can access the system.", nil), NSLocalizedString(@"Modify environment variables to block all tweak loads except FlyJB. Do not activate unless app crashes or there is a special problem.", nil), NSLocalizedString(@"All tweaks will be disabled including FlyJB.", nil)];
    
    NSString *FJDataPath = @"/var/mobile/Library/Preferences/FJMemory";
    NSData *FJMemory = [NSData dataWithContentsOfFile:FJDataPath options:0 error:nil];
    NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:FJMemory options:0 error:nil];
    NSString *version = [dict objectForKeyedSubscript:@"version"];
    
    NSString* updateDesc = [NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"Last Update Date", nil), version];
    updateMemPatch = @[NSLocalizedString(@"Update Memory Patch", nil), NSLocalizedString(@"View Patch Contents", nil)];
    updateMemPatchDescription = [[NSMutableArray alloc]
                                 initWithObjects:updateDesc, NSLocalizedString(@"Some apps require a memory patch, so check the app version.", nil),
                                 nil];
    resetPrefs = @[NSLocalizedString(@"Reset Settings", nil)];
    sections = @[@"FlyJB X", @"Dobby", NSLocalizedString(@"List", nil), NSLocalizedString(@"Update", nil), NSLocalizedString(@"Reset", nil)];
    
    [self.tableView layoutIfNeeded];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return sections.count;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return sections[section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int count = 0;
    
    if(section == 0)
        return enable.count;
    else if(section == 1)
        return enableDobby.count;
    else if(section == 2)
        return settings.count;
    else if(section == 3)
        return updateMemPatch.count;
    else if(section == 4)
        return resetPrefs.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    
    // Configure the cell...
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell" forIndexPath:indexPath];
        cell.textLabel.text = enable[indexPath.row];
    }
    
    else if(indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"dobbyCell" forIndexPath:indexPath];
    }
    
    else if(indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell3" forIndexPath:indexPath];
        cell.textLabel.text = settings[indexPath.row];
        cell.detailTextLabel.text = settingsDescription[indexPath.row];
    }
    
    else if(indexPath.section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell4" forIndexPath:indexPath];
        cell.textLabel.text = updateMemPatch[indexPath.row];
        cell.detailTextLabel.text = updateMemPatchDescription[indexPath.row];
        cell.textLabel.textColor = [UIColor systemBlueColor];
        cell.detailTextLabel.textColor = [UIColor systemBlueColor];
    }
    
    else if(indexPath.section == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"resetCell" forIndexPath:indexPath];
        cell.textLabel.text = resetPrefs[indexPath.row];
        cell.textLabel.textColor = [UIColor systemBlueColor];
    }
    
    cell.detailTextLabel.numberOfLines = 0;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 3) {
        if([updateMemPatch[indexPath.row] isEqualToString:NSLocalizedString(@"Update Memory Patch", nil)]) {
            [self UpdatePatchData];
        }
        
        if([updateMemPatch[indexPath.row] isEqualToString:NSLocalizedString(@"View Patch Contents", nil)]) {
            NSString *url = @"http://xsf1re.dothome.co.kr/flyjb/update.html";
            UIApplication *app = [UIApplication sharedApplication];
            [app openURL:[NSURL URLWithString:url]];
        }
    }
    
    else if(indexPath.section == 4) {
        if([resetPrefs[indexPath.row] isEqualToString:NSLocalizedString(@"Reset Settings", nil)]) {
            NSLog(@"resetPrefs");
            [self checkResetPrefs];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
}

-(void)checkResetPrefs {
    
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:@"FlyJB X"
                                message:NSLocalizedString(@"Are you going to reset all the settings?", nil)
                                preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Reset", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [self resetPreferences];
    }];
    
    UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction:ok];
    [alert addAction:cancel];
    
    [self presentViewController:alert animated:YES completion:nil];
}

-(void)resetPreferences {
    NSError *error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist" error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_optimize.plist" error:&error];
    [[NSFileManager defaultManager] removeItemAtPath:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb_disabler.plist" error:&error];
    
    if(error) {
        UIAlertController *alert = [UIAlertController
                                              alertControllerWithTitle:@"FlyJB X"
                                              message:NSLocalizedString(@"Failed to reset all settings.", nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
        return;
    }
    
    UIAlertController *alert = [UIAlertController
                                             alertControllerWithTitle:@"FlyJB X"
                                             message:NSLocalizedString(@"All settings has been reset.", nil)
                                             preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    [[self class] createPreferenceIfNotExist];
    [self.tableView reloadData];
}



-(void)UpdatePatchData {
    UIAlertController *alert = [UIAlertController
                                alertControllerWithTitle:NSLocalizedString(@"Checking Update...", nil)
                                message:NSLocalizedString(@"Get patch data from server.", nil)
                                preferredStyle:UIAlertControllerStyleAlert];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [activity startAnimating];
    [activity setFrame:CGRectMake(0, 0, 70, 60)];
    [alert.view addSubview:activity];
    [self presentViewController:alert animated:YES completion:nil];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://xsf1re.dothome.co.kr/flyjb/last_roleset.php"]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
        NSString *returnData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
        [alert dismissViewControllerAnimated:YES completion:^{
            if (error || statusCode != 200) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Failed", nil)
                                                                               message:NSLocalizedString(@"Failed to get patch data from server. Please try again.", nil)
                                                                        preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *action){
                    [alert dismissViewControllerAnimated:YES completion:nil];
                }];
                
                [alert addAction: ok];
                [self presentViewController:alert animated:YES completion:nil];
            }
            
            if (error == nil && statusCode == 200) {
                NSString *FJDataPath = @"/var/mobile/Library/Preferences/FJMemory";
                NSData *FJMemory = [NSData dataWithContentsOfFile:FJDataPath options:0 error:nil];
                NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:FJMemory options:0 error:nil];
                NSString *version = [dict objectForKeyedSubscript:@"version"];
                
                NSData *returnData_nsd = [returnData dataUsingEncoding:NSUTF8StringEncoding];
                NSDictionary* dict_web = [NSJSONSerialization JSONObjectWithData:returnData_nsd options:0 error:nil];
                NSString *version_web = [dict_web objectForKey:@"version"];
                NSString *supportedVersion_web = [dict_web objectForKey:@"supportedVersion"];
                
                NSString *supportedVersion = @"20201223";
                if(![supportedVersion_web isEqualToString:supportedVersion])  {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Failed", nil)
                                                                                   message:NSLocalizedString(@"The current version does not support updating memory patch. Please update tweak to the latest version.", nil)
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action){
                        [alert dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [alert addAction: ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                else if([version_web isEqualToString:version]) {
                    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Successfully Updated", nil)
                                                                                   message:NSLocalizedString(@"Patch data is already up to date.", nil)
                                                                            preferredStyle:UIAlertControllerStyleAlert];
                    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                 style:UIAlertActionStyleDefault
                                                               handler:^(UIAlertAction *action){
                        [alert dismissViewControllerAnimated:YES completion:nil];
                    }];
                    
                    [alert addAction: ok];
                    [self presentViewController:alert animated:YES completion:nil];
                }
                
                else if(![returnData isEqualToString:version]) {
                    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://xsf1re.dothome.co.kr/flyjb/%@.php", version_web]]];
                    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error){
                        NSInteger statusCode = [(NSHTTPURLResponse *)response statusCode];
                        if (error || statusCode != 200) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Update Failed", nil)
                                                                                           message:NSLocalizedString(@"Failed to get patch data from server. Please try again.", nil)
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction *action){
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];
                            
                            [alert addAction: ok];
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                        
                        if (error == nil && statusCode == 200) {
                            [data writeToFile:FJDataPath atomically:YES];
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Successfully Updated", nil)
                                                                                           message:NSLocalizedString(@"The patch data was successfully received from the server.", nil)
                                                                                    preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                                         style:UIAlertActionStyleDefault
                                                                       handler:^(UIAlertAction *action){
                                [alert dismissViewControllerAnimated:YES completion:nil];
                            }];
                            
                            [alert addAction: ok];
                            
                            [self updateTableView];
                            
                            
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }];
                    [task resume];
                }
                
            }
        }];
        
        
        
    }];
    [task resume];
    //[self performSelector:@selector(respring:) withObject:nil afterDelay:3.0];
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
