//
//  AliyunPublishProgressView.h
//  qusdk
//
//  Created by Worthy on 2017/11/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AliyunPublishProgressView;
@protocol AliyunPublishProgressViewDelegate <NSObject>
- (void) onAliyunPublishProgressViewDidExport:(AliyunPublishProgressView *)view;
- (void) onAliyunPublishProgressViewDidExportAndUpload:(AliyunPublishProgressView *)view;
@end

@interface AliyunPublishProgressView : UIView
@property (nonatomic, weak) id<AliyunPublishProgressViewDelegate> delegate;
@property (nonatomic, assign) BOOL exportAndUpload;
@property (nonatomic, assign) NSUInteger uploadedSize;
@property (nonatomic, assign) NSUInteger totalSize;
- (void)setProgress:(CGFloat)progress;
- (void)markAsExportFinihed;
- (void)markAsUploadFinished;
- (void)markAsUploadFail;
- (void)markAsExportFailed;
@end
