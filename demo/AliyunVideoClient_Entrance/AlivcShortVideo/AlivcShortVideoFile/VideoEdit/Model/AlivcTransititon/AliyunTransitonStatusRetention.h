//
//  AliyunTransitonStatusRetention.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/5.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
@class AliyunTransitionIcon;
@class AliyunTransitionCover;

/**
 转场效果管理类，可以通过此类获取上一次确认添加的转场效果，主要用来实现编辑态点击取消时，进行转场效果撤销功能的 */
@interface AliyunTransitonStatusRetention : NSObject

@property (nonatomic, copy) NSArray<AliyunTransitionCover*> *transitionCovers;//动画过渡效果集合

@property (nonatomic, copy) NSArray<AliyunTransitionIcon *> *transitionIcons;//已经确认渲染进视频的动画集合

@property (nonatomic, assign, readonly) BOOL isFirstEdit;//是否是第一次编辑

@property (nonatomic, strong) NSDictionary *lastTransitionInfo; //上次保存的转场信息

/**
 初始化转场动画保存Dic

 @param clipsNumber 转场片段数量
 */
-(void)initTransitionInfo:(int)clipsNumber;

@end
