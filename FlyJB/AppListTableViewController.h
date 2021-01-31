//
//  AppListTableViewController.h
//  FlyJB
//
//  Created by xsf1re on 2021/01/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AppListTableViewController : UITableViewController <UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

+(id)currentTableView;
+ (instancetype)sharedInstance;
- (void)setAppListTitle:(NSString*)title;

@end

NS_ASSUME_NONNULL_END
