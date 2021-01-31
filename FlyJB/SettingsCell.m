//
//  SettingsCell.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/26.
//

#import "SettingsCell.h"

@implementation SettingsCell

static SettingsCell* sharedInstance = nil;

+(instancetype)sharedInstance {
    return sharedInstance;
}

-(void)getPreference {
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist"];
    
    BOOL enabled = [prefs[@"enabled"] boolValue];
    
    if(enabled)
        self.flyjbEnabler.on = true;
    else
        self.flyjbEnabler.on = false;
}


-(void)enableFlyJB {
    NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist";
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    
    [prefs setValue:[NSNumber numberWithBool:YES] forKey:@"enabled"];
    [prefs writeToFile:path atomically:NO];

}

-(void)disableFlyJB {
    NSString* path = @"/var/mobile/Library/Preferences/kr.xsf1re.flyjb.plist";
    NSMutableDictionary *prefs = [[NSMutableDictionary alloc] initWithContentsOfFile:path];
    
    [prefs setValue:[NSNumber numberWithBool:NO] forKey:@"enabled"];
    [prefs writeToFile:path atomically:NO];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    sharedInstance = self;
    
    [self getPreference];
    
    double height = self.textLabel.frame.size.height;

    [self.textLabel sizeToFit];

    self.textLabel.frame = CGRectMake(self.textLabel.frame.origin.x, self.textLabel.frame.origin.y, self.textLabel.frame.size.width, height);

}

- (IBAction)setEnableFlyJB:(UISwitch *)sender {
    NSLog(@"FlyJB");
    if(sender.on) {
        //Enable FlyJB
        [self enableFlyJB];
    }
    else {
        //Disable FlyJB
        [self disableFlyJB];
    }
}




@end
