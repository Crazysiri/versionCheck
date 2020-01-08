//
//  UBVersionCheck.m
//  LenzBusiness
//
//  Created by Zero on 2019/2/20.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import "UBVersionCheck.h"

#import <UIKit/UIKit.h>

static BOOL __version_check_request_cached = NO;

@interface UBVersionCheck ()

@property (nonatomic, strong) UBVersion *version;

@property (nonatomic,assign) BOOL requesting;

@property (nonatomic, strong) NSMutableArray *callbacks;


@end

@implementation UBVersionCheck

+ (id)shared {
    static UBVersionCheck *check;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        check = [[UBVersionCheck alloc] init];
    });
    return check;
}

- (void)checkAsync:(void(^)(BOOL hasNewVersion,UBVersion *version))completion cache:(BOOL)cache {
    
    if (cache && __version_check_request_cached) {
        if (completion) {
            completion([self.class hasNewVersion],self.version);
        }
        return;
    }
    
    __weak typeof(self) weakself = self;
    
    if (self.requesting) {
        [self.callbacks addObject:completion];
        return;
    }
    
    if (self.requestCallback) {
        
        self.requesting = YES;
        
        void (^callback)(BOOL,UBVersion *) = ^(BOOL success,UBVersion *version) {
            
            weakself.requesting = NO;
                        
            __version_check_request_cached = YES;
            
            for (void (^cb)(BOOL,UBVersion *) in weakself.callbacks) {
                cb([weakself.class isBigger:version],version);
            }
            
            [weakself.callbacks removeAllObjects];
            
            if (completion) {
                completion([weakself.class isBigger:version],version);
            }
        };
        
        self.requestCallback(callback);
    }
}

- (void)checkAndShowAlert:(BOOL)mute {

    __weak typeof(self) weakself = self;

    [self checkAsync:^(BOOL hasNewVersion, UBVersion *version) {
        if (!mute && hasNewVersion) {
            [weakself.class showAlert:version];
        }
    } cache:NO];
}

- (void)checkAndShowCustomAlert:(void(^)(UBVersion *version))customShow {
    __weak typeof(self) weakself = self;

    [self checkAsync:^(BOOL hasNewVersion, UBVersion *version) {
        if (hasNewVersion && customShow) {
            customShow(version);
        }
    } cache:NO];
}

- (void)checkAndGotoDownloadUrlDirectly {

    __weak typeof(self) weakself = self;
    [self checkAsync:^(BOOL hasNewVersion, UBVersion *version) {
        if (hasNewVersion) {
            if (version.downloadUrl) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:version.downloadUrl]];
            }
        }
    } cache:NO];
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


+ (BOOL)isBigger:(UBVersion *)version {
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setBool:NO forKey:@"has_new_version_key"];
    
    NSString *versionNumber = [[NSBundle mainBundle]infoDictionary][@"CFBundleShortVersionString"];
    [ud setObject:versionNumber forKey:@"new_version_string_key"];

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

//version 版本
+ (void)showAlert:(UBVersion *)version {
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



- (NSMutableArray *)callbacks {
    if (!_callbacks) {
        _callbacks = [NSMutableArray array];
    }
    return _callbacks;
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
