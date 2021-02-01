//
//  InfoTableViewController.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/27.
//

#import "InfoTableViewController.h"
#include <sys/utsname.h>

@interface InfoTableViewController () {
    NSArray *version;
    NSArray *versionDetails;
    NSArray *info;
    NSArray *issue;
    NSArray *credit;
    NSArray *easteregg;
}

@end

@implementation InfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self setTitle:NSLocalizedString(@"Info", nil)];

    version = @[NSLocalizedString(@"Version", nil)];
    versionDetails = @[@"1.1.5"];
    info = @[NSLocalizedString(@"View Source Code", nil), NSLocalizedString(@"Send Feedback", nil), NSLocalizedString(@"Recommend FlyJB", nil)];
    issue = @[NSLocalizedString(@"Have issue on app list?", nil)];
    credit = @[NSLocalizedString(@"Credit", nil)];
    easteregg = @[NSLocalizedString(@"I think it's you when the wind blows.", nil)];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 6;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    int count = 0;
    
    if(section == 0)
        return 1;   //bannerImage;
    else if(section == 1)
        return version.count;
    else if(section == 2)
        return credit.count;
    else if(section == 3)
        return info.count;
    else if(section == 4)
        return issue.count;
    else if(section == 5)
        return easteregg.count;
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell;
    
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"bannerCell" forIndexPath:indexPath];
    } else if(indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"versionCell" forIndexPath:indexPath];
        cell.textLabel.text = version[indexPath.row];
        cell.detailTextLabel.text = versionDetails[indexPath.row];
    } else if(indexPath.section == 2) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"creditCell" forIndexPath:indexPath];
        cell.textLabel.text = credit[indexPath.row];
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if(indexPath.section == 3) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell" forIndexPath:indexPath];
        cell.textLabel.text = info[indexPath.row];
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if(indexPath.section == 4) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"issueCell" forIndexPath:indexPath];
        cell.textLabel.text = issue[indexPath.row];
        cell.textLabel.textColor = [UIColor systemBlueColor];
    } else if(indexPath.section == 5) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"eastereggCell" forIndexPath:indexPath];
        cell.textLabel.text = easteregg[indexPath.row];
        cell.separatorInset = UIEdgeInsetsMake(0.0f, 0.0f, 0.0f, CGFLOAT_MAX);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 3) {
        if([info[indexPath.row] isEqualToString:NSLocalizedString(@"Send Feedback", nil)]) {
            [self sendFeedback];
        }
        else if([info[indexPath.row] isEqualToString:NSLocalizedString(@"Recommend FlyJB", nil)]) {
            [self Like];
        }
        else if([info[indexPath.row] isEqualToString:NSLocalizedString(@"View Source Code", nil)]) {
            [self showSourceCode];
        }
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)sendFeedback
{
    if([MFMailComposeViewController canSendMail]) {
    MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
    
    NSString *deviceType = nil, *iOSVersion = nil, *buildNumber = nil, *JBSubstitutor = nil;
    
    BOOL isLibHooker = [[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libhooker.dylib"];
    BOOL isSubstitute = ([[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/libsubstitute.dylib"] && ![[NSFileManager defaultManager] fileExistsAtPath:@"/usr/lib/substrate"]);
    
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    deviceType = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    iOSVersion = [[UIDevice currentDevice] systemVersion];
    
    NSDictionary *systemVersionPlist = [[NSDictionary alloc] initWithContentsOfFile:@"/System/Library/CoreServices/SystemVersion.plist"];
    
    
    buildNumber = systemVersionPlist[@"ProductBuildVersion"];
    
    
    if(isLibHooker)
        JBSubstitutor = @"libhooker";
    else if(isSubstitute)
        JBSubstitutor = @"Substitute";
    else
        JBSubstitutor = @"Substrate";
    
    NSString *subject = NSLocalizedString(@"FlyJB X Feedback Request", nil);
        NSString *version = versionDetails.firstObject;
    
    NSString *subjectVers = [NSString stringWithFormat:@"%@%@%@%@",subject,@" (",version,@")"];
    
    [mailer setSubject:subjectVers];
    [mailer setMessageBody:[NSString stringWithFormat:@"\n\n\n\n\n%@\n\n%@: %@\niOS %@: %@ (%@/%@)\n", NSLocalizedString(@"If crash happen, explain in detail what happens in some cases or send a crash log to help developers solve it.", nil), NSLocalizedString(@"Device", nil), deviceType, NSLocalizedString(@"Version", nil), iOSVersion, buildNumber, JBSubstitutor] isHTML:NO];
    [mailer setToRecipients:@[@"shg1725x@yahoo.com"]];
    NSLog(@"mailer: %@", mailer);
    [self.navigationController presentViewController:mailer animated:YES completion:nil];
    mailer.mailComposeDelegate = self;
    }
    else {
        UIAlertController *alert = [UIAlertController
                                              alertControllerWithTitle:NSLocalizedString(@"Failed to request feedback", nil)
                                              message:NSLocalizedString(@"Your registered email could not be found. Please add at least one e-mail in the mail app.", nil)
                                              preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }];
        [alert addAction:ok];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    [self dismissViewControllerAnimated: YES completion: nil];
}

- (void)Like
{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter://"]]) {
        SLComposeViewController *twitter = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        [twitter setInitialText:NSLocalizedString(@"Did you jailbreak your iPhone?\n\nThen FlyJB Tweak is a MUST!\n\nFeel free to use apps that detect jailbreak!\n\n#FlyJB By @XsF1re", nil)];
        if (twitter != nil) {
            [[self navigationController] presentViewController:twitter animated:YES completion:nil];
        }
    }
    else {
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"Recommend FlyJB", nil)
                                    message:NSLocalizedString(@"You must install Twitter and log in to recommend FlyJB.", nil)
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"Install Twitter", nil) style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction * action){
            NSString *url = @"https://apps.apple.com/kr/app/twitter/id333903271";
            UIApplication *app = [UIApplication sharedApplication];
            [app openURL:[NSURL URLWithString:url]];
        }];
        
        UIAlertAction* cancel = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) style:UIAlertActionStyleDefault
                                                       handler:^(UIAlertAction * action) {
            [alert dismissViewControllerAnimated:YES completion:nil];
        }
                                 ];
        
        [alert addAction:ok];
        [alert addAction:cancel];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    }
}

-(void)showSourceCode {
    NSString *url = @"https://github.com/XsF1re/FlyJB-X";
    
    UIApplication *app = [UIApplication sharedApplication];
    [app openURL:[NSURL URLWithString:url]];
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
