//
//  AliyunMusicPickViewController.h
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AliyunMusicPickModel.h"
#import "AlivcBaseViewController.h"

@class AliyunMusicPickModel;
@protocol AliyunMusicPickViewControllerDelegate <NSObject>

/**
 取消
 */
- (void)didCancelPick;

/**
 选择了音乐，并点击了应用按钮响应

 @param music 选择的音乐
 @param tab 表明是本地音乐还是在线音乐
 */
- (void)didSelectMusic:(AliyunMusicPickModel *)music tab:(NSInteger)tab;

@end

@interface AliyunMusicPickViewController : AlivcBaseViewController

/**
 代理
 */
@property (nonatomic, weak) id<AliyunMusicPickViewControllerDelegate> delegate;

/**
 时长
 */
@property (nonatomic, assign) CGFloat duration;

/**
 之前应用的音乐 - 用于设置初始值
 */
@property (nonatomic, strong) AliyunMusicPickModel *selectedMusic;

/**
 之前应用的音乐的所属 - 用于设置初始值
 */
@property (nonatomic, assign) NSInteger selectedTab;
@end
