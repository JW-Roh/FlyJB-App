//
//  SettingsTableViewController.h
//  FlyJB
//
//  Created by xsf1re on 2021/01/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsTableViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

+(void)createPreferenceIfNotExist;
-(void)updateTableView;
+ (instancetype)sharedInstance;

@end

NS_ASSUME_NONNULL_END
