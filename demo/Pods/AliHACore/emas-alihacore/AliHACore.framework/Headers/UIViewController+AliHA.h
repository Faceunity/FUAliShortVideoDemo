//
//  UIViewController+AliPerformance.h
//  AliPerformanceMonitor
//
//  Created by lv on 16/5/25.
//  Copyright © 2016年 Taobao lnc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (AliHA)

//判断controller是否是从rootController的核心链路上的controller
- (BOOL)aliha_isMainLinkController;

//设置是否是主链路上的controller
- (void)aliha_setMainLinkController:(BOOL)yesOrNo;


- (BOOL)aliha_isControllerWillExited;

- (void)aliha_setControllerWillExited:(BOOL)yesOrNo;

- (void)aliha_willExitController;

- (size_t)aliha_currentMemoryUsage;

- (void)aliha_setCurrentMemoryUsage:(size_t)usage;

- (size_t)aliha_forecastMemoryUsage;

- (void)aliha_setForecastMemoryUsage:(size_t)usage;

- (int)aliha_forecastMemoryWarnLevel;

- (void)aliha_setForecastMemoryWarnLevel:(int)level;

@end
