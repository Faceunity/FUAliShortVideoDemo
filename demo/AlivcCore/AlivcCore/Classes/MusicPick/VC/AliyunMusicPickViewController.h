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

@optional
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
 设置默认选中的音乐

 @param selectedMusic 选中的音乐
 @param type 0 远程音乐 1本地音乐
 */
- (void)setSelectedMusic:(AliyunMusicPickModel *)selectedMusic type:(NSInteger)type;

@end
