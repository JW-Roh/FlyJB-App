//
//  SettingsCell.h
//  FlyJB
//
//  Created by xsf1re on 2021/01/26.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SettingsCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UISwitch *flyjbEnabler;

+(instancetype)sharedInstance;
-(void)getPreference;

@end

NS_ASSUME_NONNULL_END
