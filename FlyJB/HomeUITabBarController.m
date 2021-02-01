//
//  HomeUITabBarController.m
//  FlyJB
//
//  Created by xsf1re on 2021/02/01.
//

#import "HomeUITabBarController.h"

@interface HomeUITabBarController ()

@end

@implementation HomeUITabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.tabBar.items[0] setValue:NSLocalizedString(@"Settings", nil) forKey:@"internalTitle"];
    [self.tabBar.items[1] setValue:NSLocalizedString(@"Info", nil) forKey:@"internalTitle"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
