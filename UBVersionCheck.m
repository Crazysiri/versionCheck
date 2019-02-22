//
//  UBVersionCheck.m
//  LenzBusiness
//
//  Created by Zero on 2019/2/20.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import "UBVersionCheck.h"

@implementation UBVersionCheck
+ (void)checkNewVersionAndShowAlertIfNeeded:(void (^)(void (^ callback)(UBVersion *)))request  show:(void(^)(BOOL show))show {
    if (request) {
        void (^callback)(UBVersion *) = ^(UBVersion *version){
            if ([self showAlertIfNeed:version]) {
                if (show) {
                    show (YES);
                }
            } else {
                if (show) {
                    show (NO);
                }
            }
        };
        request(callback);
    }
}

+ (void)checkNewVersionAndGotoDownloadIfNeeded:(void (^)(void (^ callback)(UBVersion *)))request {
    if (request) {
        void (^callback)(UBVersion *) = ^(UBVersion *version){
            if (version && [self isBigger:version]) {
                if (version.downloadUrl) {
                    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:version.downloadUrl]];
                }
            }
        };
        request(callback);
    }
}

+ (BOOL)showAlertIfNeed:(UBVersion *)version {
    if (version && [self isBigger:version]) {
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:version.cancelButtonTitle style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *confirm = [UIAlertAction actionWithTitle:version.confirmButtonTitle style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            if (version.downloadUrl) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:version.downloadUrl]];
            }
        }];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:version.title message:version.message preferredStyle:UIAlertControllerStyleAlert];
        
        [alert addAction:confirm];
        
        //如果是非强制更新 可取消
        if (!version.forceUpdate) {
            [alert addAction:cancel];
        }
        
        [UIApplication.sharedApplication.delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
        
        return YES;
    }
    return NO;
}


+ (BOOL)isBigger:(UBVersion *)version {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:@"has_new_version_key"];
    
    NSString *versionNumber = [[NSBundle mainBundle]infoDictionary][@"CFBundleShortVersionString"];
    NSString *bundleVersionJoin = [versionNumber stringByReplacingOccurrencesOfString:@"." withString:@""];
    NSString *serverVersionJoin = [version.version stringByReplacingOccurrencesOfString:@"." withString:@""];
    
    NSInteger bundleLength = bundleVersionJoin.length;
    NSInteger serverLength = serverVersionJoin.length;
    
    if (bundleLength < serverLength) {
        for (int i = 0; i < serverLength - bundleLength; i++ ) {
            bundleVersionJoin = [bundleVersionJoin stringByAppendingString:@"0"];
        }
    } else {
        for (int i = 0; i < bundleLength - serverLength; i++ ) {
            serverVersionJoin = [serverVersionJoin stringByAppendingString:@"0"];
        }
    }
    
    if (serverVersionJoin.integerValue > bundleVersionJoin.integerValue) {
        [ud setBool:YES forKey:@"has_new_version_key"];
        [ud setObject:version.version forKey:@"new_version_string_key"];
        [ud synchronize];
        return YES;
    }
    [ud synchronize];

    return NO;
    
}


///是否有新版本
/*
 checkNewVersion... 方法之后才有值
 */
+ (BOOL)hasNewVersion {
    return [NSUserDefaults.standardUserDefaults boolForKey:@"has_new_version_key"];
}

///新版本号
+ (NSString *)versionNew {
    return [NSUserDefaults.standardUserDefaults objectForKey:@"new_version_string_key"];
}


@end


@implementation UBVersion
- (instancetype)init
{
    self = [super init];
    if (self) {
        self.cancelButtonTitle = @"下次再说";
        self.confirmButtonTitle = @"立即更新";
        self.title = @"更新提示";
    }
    return self;
}
@end
