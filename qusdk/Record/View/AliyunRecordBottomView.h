//
//  AliyunRecordBottomView.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AliyunRecordBottomViewDelegate;
@interface AliyunRecordBottomView : UIView

@property (nonatomic, assign) CGFloat minDuration;
@property (nonatomic, assign) CGFloat maxDuration;
@property (nonatomic, weak) id<AliyunRecordBottomViewDelegate> delegate;

- (void)updateVideoDuration:(CGFloat)duration;

- (void)updateRecordStatus;

- (void)updateRecordTypeToEndRecord;

- (void)deleteLastProgress;

-(void)updateHeight:(CGFloat)height;

@end


@protocol AliyunRecordBottomViewDelegate <NSObject>

- (void)bottomViewRecordVideo;

- (void)bottomViewPauseVideo;

- (void)bottomViewFinishVideo;

- (void)bottomViewDeleteFinished;

- (void)bottomViewShowLibrary;
@end
