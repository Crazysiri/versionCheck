//
//  UBVersionCheck.m
//  LenzBusiness
//
//  Created by Zero on 2019/2/20.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import "UBVersionCheck.h"

#import <UIKit/UIKit.h>

@implementation UBVersionCheck

+ (void)checkNewVersion:(void (^)(void (^ callback)(UBVersion *version)))request completion:(void(^)(BOOL hasNewVersion))completion {
    if (request) {
        void (^callback)(UBVersion *) = ^(UBVersion *version) {
            if (completion) {
                completion([self isBigger:version]);
            }
        };
        request(callback);
    }
}

+ (void)checkNewVersionAndShowAlertIfNeeded:(void (^)(void (^ callback)(UBVersion *,BOOL mute)))request  customShow:(void(^)(void))customShow show:(void(^)(BOOL show))show {
    if (request) {
        void (^callback)(UBVersion *,BOOL) = ^(UBVersion *version,BOOL mute){
            if ([self showAlertIfNeed:version mute:mute customShow:customShow]) {
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


+ (BOOL)showAlertIfNeed:(UBVersion *)version customShow:(void(^)(void))customShow {
    [self showAlertIfNeed:version mute:NO customShow:customShow];
}


//version 版本 mute 是否需要弹窗 customShow 自定义显示UI弹窗
//如果mute = YES 即使最新比本地大 也不更新
//[self isBigger:version 放在前面因为 需要让代码执行 [ud setBool:YES forKey:@"has_new_version_key"]; 才能在后面获取到是否有新版本
+ (BOOL)showAlertIfNeed:(UBVersion *)version mute:(BOOL)mute customShow:(void(^)(void))customShow {
    if ([self isBigger:version] && !mute && version) {
        
        if (customShow) { //自定义alert
            customShow();
        } else {
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
        }
        
        return YES;
    }
    return NO;
}


+ (BOOL)isBigger:(UBVersion *)version {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:@"has_new_version_key"];
    
    NSString *versionNumber = [[NSBundle mainBundle]infoDictionary][@"CFBundleShortVersionString"];
    
    NSArray *bundleVersionComps = [versionNumber componentsSeparatedByString:@"."];
    NSArray *serverVersionComps = [version.version componentsSeparatedByString:@"."];
    
    //以最大的 做为循环 参数
    NSUInteger count = bundleVersionComps.count > serverVersionComps.count ? bundleVersionComps.count : serverVersionComps.count;
    
    BOOL serverIsBigger = NO;
    
    //左对齐进行判断
    /*
     
     1.0
     1.0.1
     
     */
    for (int i = 0; i < count; i++) {
        
        NSInteger bundleComp = 0;
        if (i < bundleVersionComps.count) {
            bundleComp = [bundleVersionComps[i] integerValue];
        }
        
        NSInteger serverComp = 0;
        if (i < serverVersionComps.count) {
            serverComp = [serverVersionComps[i] integerValue];
        }
        
        if (bundleComp > serverComp) {
            break;
        }
        
        if (serverComp > bundleComp) {
            serverIsBigger = YES;
            break;
        }
    }
    
    
    if (serverIsBigger) {
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
