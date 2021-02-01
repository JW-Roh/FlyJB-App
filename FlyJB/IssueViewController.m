//
//  IssueViewController.m
//  FlyJB
//
//  Created by xsf1re on 2021/02/01.
//

#import "IssueViewController.h"

@interface IssueViewController () {
    NSArray *bundleIDArray;
    NSMutableDictionary* AppNameFromBundleID;
    NSMutableDictionary* AppIconFromBundleID;
    __weak IBOutlet UIBarButtonItem *shareButton;
}
@property (weak, nonatomic) IBOutlet UITextView *IssueTextView;

@end

@implementation IssueViewController
- (IBAction)share:(id)sender {
    NSString* log = self.IssueTextView.text;
    
    UIActivityViewController *vc = [[UIActivityViewController alloc] initWithActivityItems:@[log] applicationActivities:nil];
    
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [self setTitle:NSLocalizedString(@"AppList Log", nil)];
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"AppList Log", nil)
                                                                   message:NSLocalizedString(@"All of installed app will be display here.\nPlease send log if you had some problem.", nil)
                                                            preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil)
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction *action){
        [alert dismissViewControllerAnimated:YES completion:nil];
    }];
    
    [alert addAction: ok];
    [self presentViewController:alert animated:YES completion:nil];
    
    
    [self findApps];
    self.IssueTextView.text = [NSString stringWithFormat:@"bundleIDArray:%@\nAppNameFromBundleID:%@\nAppIconFromBundleID:%@", bundleIDArray, AppNameFromBundleID, AppIconFromBundleID];
    shareButton.title = NSLocalizedString(@"Share", nil);
}

-(void)findApps {
    
    NSString *appPath = @"/var/containers/Bundle/Application/";
    NSArray *appLists = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:appPath error:nil];
    
    NSMutableArray *bundleIDs = [[NSMutableArray alloc] init];
    AppNameFromBundleID = [[NSMutableDictionary alloc] init];
    AppIconFromBundleID = [[NSMutableDictionary alloc] init];
    
    for (NSString* appLocation in appLists) {
        NSString *tmp = [appPath stringByAppendingString:appLocation];
        NSArray *tmp2 = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:tmp error:nil];
        for(NSString *tmp3 in tmp2) {
            if([tmp3 hasSuffix:@".app"]) {
                NSString *appContentsPath = [tmp stringByAppendingString:@"/"];
                appContentsPath = [appContentsPath stringByAppendingString:tmp3];
                
//                앱 Info.plist 가져오기
                NSString *appContentsInfoPath = [appContentsPath stringByAppendingString:@"/Info.plist"];
                NSMutableDictionary *appInfo = [[NSMutableDictionary alloc] initWithContentsOfFile:appContentsInfoPath];
                
//                엡 번들ID를 가져옵니다. 단, FlyJB나 애플 관련 앱들은 건너뛰세요!
                NSString *bundleID = appInfo[@"CFBundleIdentifier"];
                if([bundleID hasPrefix:@"com.apple"] || [bundleID isEqualToString:@"kr.xsf1re.flyjbx"])
                    continue;
                [bundleIDs addObject:bundleID];
                
//                앱 이름을 가져옵니다. 단, 이름을 가지고 있지 않으면 건너뛰세요!
                NSString *appName = [appInfo[@"CFBundleDisplayName"] description];
                if(!appName || appName.length == 0)
                    appName = [appInfo[@"CFBundleName"] description];
                if(!appName || appName.length == 0)
                    continue;
                [AppNameFromBundleID setObject:appName forKey:bundleID];
                
//                앱 아이콘 이미지를 가져옵니다. 단, 아이콘 이미지가 없다면 건너뛰세요!
                NSDictionary *CFBundleIcons = [appInfo objectForKey:@"CFBundleIcons"];
                NSDictionary *CFBundlePrimaryIcon = [CFBundleIcons objectForKey:@"CFBundlePrimaryIcon"];
                NSArray *CFBundleIconFiles = [CFBundlePrimaryIcon objectForKey:@"CFBundleIconFiles"];
                NSString *appImage = [appContentsPath stringByAppendingString:@"/"];
                
                if([CFBundleIconFiles firstObject])
                    appImage = [appImage stringByAppendingString:[CFBundleIconFiles firstObject]];
                else if(appInfo[@"CFBundleIconFile"])
                    appImage = [appImage stringByAppendingString:appInfo[@"CFBundleIconFile"]];
                if(!appImage)
                    continue;
                appImage = [appImage stringByAppendingString:@".png"];
                [AppIconFromBundleID setObject:appImage forKey:bundleID];
            }
        }
    }
    
    NSArray *bundleIDsSortedByAppName = [bundleIDs sortedArrayUsingComparator:^NSComparisonResult(id bundleID, id bundleID2) {
        
        NSString *obj1 = AppNameFromBundleID[bundleID];
        NSString *obj2 = AppNameFromBundleID[bundleID2];
        
        NSString* left = [NSString stringWithFormat:@"%@%@",
                          [obj1 localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                          !([obj1 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                          @"1", obj1];
        
        NSString* right = [NSString stringWithFormat:@"%@%@",
                           [obj2 localizedCaseInsensitiveCompare:@"ㄱ"]+1 ? @"0" :
                           !([obj2 localizedCaseInsensitiveCompare:@"a"]+1) ? @"2" :
                           @"1", obj2];
        
        NSComparisonResult comparisonResult = [left localizedCaseInsensitiveCompare:right];
        
        return comparisonResult;
    }];
    
    bundleIDArray = bundleIDsSortedByAppName;
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
