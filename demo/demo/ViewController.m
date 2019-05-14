//
//  ViewController.m
//  demo
//
//  Created by Zero on 2019/5/13.
//  Copyright © 2019 Zero. All rights reserved.
//

#import "ViewController.h"

#import "UBVersionCheck.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [UBVersionCheck checkNewVersionAndShowAlertIfNeeded:^(void (^ _Nonnull callback)(UBVersion * _Nonnull)) {
            UBVersion *version = [[UBVersion alloc] init];
            version.version  = @"1.0.1";
            version.message = @"更新内容";
            version.title = @"更新标题";
            callback(version);
            
        } show:^(BOOL show) {
            
        }];
    });
    

    // Do any additional setup after loading the view.
}


@end
