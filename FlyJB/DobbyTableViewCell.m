//
//  DobbyTableViewCell.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/31.
//

#import "DobbyTableViewCell.h"

@implementation DobbyTableViewCell

static DobbyTableViewCell* sharedInstance = nil;

+(instancetype)sharedInstance {
    return sharedInstance;
}

-(void)getPreference {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
    
    BOOL enabled = [prefs[@"enableDobby"] boolValue];
    
    if(enabled)
        self.dobbySwitch.on = true;
    else
        self.dobbySwitch.on = false;
}


-(void)enableDobby {
    NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist";
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    
    [prefs setValue:[NSNumber numberWithBool:YES] forKey:@"enableDobby"];
    [prefs writeToFile:path atomically:NO];

}

-(void)disableDobby {
    NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist";
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    [prefs setValue:[NSNumber numberWithBool:NO] forKey:@"enableDobby"];
    [prefs writeToFile:path atomically:NO];
}

- (void)layoutSubviews {
    
    [super layoutSubviews];
    
    sharedInstance = self;
    
    [self getPreference];

    self.dobbyEnableLabel.text = NSLocalizedString(@"Enable Dobby", nil);
    self.dobbyDescriptionLabel.text = NSLocalizedString(@"If you don't enable Dobby, bypass functionality may not work in some apps, but it can be resolved by memory patch.", nil);
    self.dobbyDescriptionLabel.numberOfLines = 0;
    
}
- (IBAction)setDobbyEnabler:(UISwitch *)sender {
    if(sender.on) {
        //Enable Dobby
        [self enableDobby];
    }
    else {
        //Disable Dobby
        [self disableDobby];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
