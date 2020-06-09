//
//  AlivcPasterManager.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/26.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AliyunPasterManager;

/**
 动图相关逻辑处理类
 */
@interface AlivcPasterManager : NSObject


/**
 检查动图资源是否存在

 @param path 动图资源路径
 @return 是否存在
 */
-(BOOL)checkResourceIsExistence:(NSString *)path;


/**
 预览状态下修正动图位置
 
 @param pasterManager 需要修正位置的pasterManager
 */

-(void)correctedPasterFrameAtPreviewStatusWithPasterManager:(AliyunPasterManager *)pasterManager;


/**
 编辑状态下修正动图位置

 @param pasterManager 需要修正位置的pasterManager
 @param editFrame 编辑状态下的预览view大小
 */
-(void)correctedPasterFrameAtEditStatusWithPasterManager:(AliyunPasterManager *)pasterManager withEditFrame:(CGRect)editFrame;


/**
 获取字幕动画类型

 @param pasterController 字幕动画controller
 */
-(NSInteger)getAlivcSubtitleAnimateTypeWithPasterController:(NSObject *)pasterController;

@end
