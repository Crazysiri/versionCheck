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



//以下：系统alert需要 checkAndShowAlert有效
// alert 更新消息
@property (copy,nonatomic) NSString *message;
// alert title 默认 更新提示
@property (copy,nonatomic) NSString *title;
//取消按钮文案
@property (copy,nonatomic) NSString *cancelButtonTitle;//默认 下次再说
//确定按钮文案
@property (copy,nonatomic) NSString *confirmButtonTitle; //默认 立即更新

@end

@interface UBVersionCheck : NSObject

+ (UBVersionCheck *)shared;

//1.只需要实例化后 调用一次，作用是设置请求接口
@property (nonatomic,copy) void (^requestCallback)(void (^ callback)(BOOL success,UBVersion *version));

//2.检查是否有新版本 内部会调用requestCallback
- (void)checkAsync:(void(^)(BOOL hasNewVersion,UBVersion *version))completion cache:(BOOL)cache;

//检查并且弹窗
- (void)checkAndShowAlert:(BOOL)mute;

//检查并且弹自定义窗，在customShow中实现自定义窗
- (void)checkAndShowCustomAlert:(void(^)(UBVersion *version))customShow;

//检查并且直接跳转下载
- (void)checkAndGotoDownloadUrlDirectly;

///是否有新版本
/*
 checkAsync/checkAndShowAlert/checkAndShowCustomAlert/checkAndGotoDownloadUrlDirectly  方法之后才有值
 */
+ (BOOL)hasNewVersion;

///新版本号
+ (NSString *)versionNew;

@end
