//
//  UBVersionCheck.h
//  LenzBusiness
//
//  Created by Zero on 2019/2/20.
//  Copyright © 2019 LenzTech. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UBVersion : NSObject

//是否强制更新
@property (nonatomic,assign) BOOL forceUpdate;

//版本号
@property (copy,nonatomic) NSString *version;

//下载链接
@property (copy,nonatomic) NSString *downloadUrl;

// alert 更新消息
@property (copy,nonatomic) NSString *message;

// alert title 默认 更新提示
@property (copy,nonatomic) NSString *title;


//取消按钮文案
@property (copy,nonatomic) NSString *cancelButtonTitle;//默认 下次再说
//确定按钮文案
@property (copy,nonatomic) NSString *confirmButtonTitle; //默认 立即更新
@end

NS_ASSUME_NONNULL_BEGIN

@interface UBVersionCheck : NSObject

///检查版本，并弹窗显示
/*
 可根据UBVersion中 forceUpdate 字段控制是否强制更新，强制更新无取消按钮
 request:请求
 show：是否显示回调（是否有新版本）
 */
+ (void)checkNewVersionAndShowAlertIfNeeded:(void(^)(void(^callback)(UBVersion *version)))request show:(void(^)(BOOL show))show;

///检查版本，并直接跳转下载url
+ (void)checkNewVersionAndGotoDownloadIfNeeded:(void (^)(void (^ callback)(UBVersion *)))request;

+ (BOOL)showAlertIfNeed:(UBVersion *)version;

///是否有新版本
/*
 checkNewVersion... 方法之后才有值
 */
+ (BOOL)hasNewVersion;

///新版本号
+ (NSString *)versionNew;
@end

NS_ASSUME_NONNULL_END
