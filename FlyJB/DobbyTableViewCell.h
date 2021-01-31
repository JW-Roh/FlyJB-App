//
//  DobbyTableViewCell.h
//  FlyJB
//
//  Created by xsf1re on 2021/01/31.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface DobbyTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *dobbyEnableLabel;
@property (weak, nonatomic) IBOutlet UILabel *dobbyDescriptionLabel;
@property (weak, nonatomic) IBOutlet UISwitch *dobbySwitch;

+(instancetype)sharedInstance;
-(void)getPreference;

@end

NS_ASSUME_NONNULL_END
