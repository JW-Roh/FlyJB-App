//
//  HomeUITabBar.m
//  FlyJB
//
//  Created by xsf1re on 2021/01/31.
//

#import "HomeUITabBar.h"

@implementation HomeUITabBar

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.items[0].title = NSLocalizedString(@"Settings", nil);
    self.items[1].title = NSLocalizedString(@"Info", nil);
}

@end
