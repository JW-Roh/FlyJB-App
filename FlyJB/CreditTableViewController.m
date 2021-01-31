//
//  CreditTableViewController.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/31.
//

#import "CreditTableViewController.h"

@interface CreditTableViewController () {
    NSArray *sections;
    NSArray *developer;
    NSArray *designer;
    NSArray *translator;
}

@end

@implementation CreditTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:NSLocalizedString(@"Credit", nil)];
    self.tableView.tableFooterView = [[UIView alloc] init];
    
    //    sections = @[@"개발", @"디자인", @"번역"];
    sections = @[NSLocalizedString(@"Development", nil), NSLocalizedString(@"Design", nil)];
    developer = @[@"@XsF1re", @"@jmpews"];
    designer = @[@"emulzone"];
    //    translator = @[@"Unknown"];
    
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
        return developer.count;
    else if(section == 1)
        return designer.count;
    //    else if(section == 2)
    //        return translator.count;
    
    return count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell ;
    
    // Configure the cell...
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"developerCell" forIndexPath:indexPath];
        cell.textLabel.text = developer[indexPath.row];
    } else if(indexPath.section == 1) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"designerCell" forIndexPath:indexPath];
        cell.textLabel.text = designer[indexPath.row];
    }
    //    else if(indexPath.section == 2) {
    //        cell = [tableView dequeueReusableCellWithIdentifier:@"translatorCell" forIndexPath:indexPath];
    //        cell.textLabel.text = translator[indexPath.row];
    //    }
    cell.textLabel.textColor = [UIColor systemBlueColor];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.section == 0) {
        if([developer[indexPath.row] isEqualToString:@"@XsF1re"]) {
            [self openWebTwitter:@"XsF1re"];
        }
        
        if([developer[indexPath.row] isEqualToString:@"@jmpews"]) {
            [self openWebTwitter:@"jmpews"];
        }
    }
    
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)openWebTwitter:(NSString*)name {
    if(name != nil) {
        NSString *twitterURL = @"https://twitter.com/";
        twitterURL = [twitterURL stringByAppendingString:name];
        
        UIApplication *app = [UIApplication sharedApplication];
        [app openURL:[NSURL URLWithString:twitterURL]];
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
