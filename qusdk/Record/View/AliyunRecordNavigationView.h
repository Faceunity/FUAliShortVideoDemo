//
//  AliyunRecordNavigationView.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunRecordNavigationViewDelegate;
@interface AliyunRecordNavigationView : UIView

@property (nonatomic, weak) id<AliyunRecordNavigationViewDelegate> delegate;

- (void)setupBeautyStatus:(BOOL)isBeauty
              flashStatus:(NSInteger)flashStatus;

- (void)updateNavigationStatusWithDuration:(CGFloat)duration;

- (void)updateNavigationStatusWithRecord:(BOOL)isRecording;

- (void)updateNavigationFlashStatus:(NSInteger)status;

@end


@protocol AliyunRecordNavigationViewDelegate <NSObject>

- (void)navigationBackButtonClick;
- (void)navigationRatioDidChangedWithValue:(CGFloat)r;
- (void)navigationBeautyDidChangedStatus:(BOOL)on;
- (void)navigationCamerationPositionDidChanged:(BOOL)front;
- (NSInteger)navigationFlashModeDidChanged;

@end
