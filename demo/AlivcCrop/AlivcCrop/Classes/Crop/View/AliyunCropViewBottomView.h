//
//  AliyunCropViewBottomView.h
//  AliyunVideo
//
//  Created by TripleL on 17/5/4.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunCropViewBottomViewDelegate <NSObject>

- (void)onClickBackButton;
- (void)onClickRatioButton;
- (void)onClickCropButton;

@end

@interface AliyunCropViewBottomView : UIView

/**
 裁剪模式切换按钮
 */
@property (nonatomic, strong) UIButton *ratioButton;

/**
 确定按钮
 */
@property (nonatomic, strong) UIButton *cropButton;

/**
 代理
 */
@property (nonatomic, weak) id<AliyunCropViewBottomViewDelegate> delegate;

@end
