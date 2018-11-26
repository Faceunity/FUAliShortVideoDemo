//
//  AliyunRecordParamTableViewCell.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  视频拍摄设置界面、视频编辑设置界面公用的cell

#import <UIKit/UIKit.h>

@class AliyunRecordParamCellModel;
@interface AliyunRecordParamTableViewCell : UITableViewCell

/**
 给cell

 @param cellModel 数据模型
 */
- (void)configureCellModel:(AliyunRecordParamCellModel *)cellModel;
@end


@interface AliyunRecordParamCellModel : NSObject

/**
 名称
 */
@property (nonatomic, copy) NSString *title;

/**
 textView的placeHolder
 */
@property (nonatomic, copy) NSString *placeHolder;

/**
 cell的ID
 */
@property (nonatomic, copy) NSString *reuseId;

/**
 默认值
 */
@property (nonatomic, assign) CGFloat defaultValue;

/**
 UITextField的值改变时的block回调
 */
@property (nonatomic, copy) void(^valueBlock)(int value);

/**
 分辨率的block回调
 */
@property (nonatomic, copy) void(^sizeBlock)(CGFloat videoWidth);
@property (nonatomic, copy) void(^ratioBack)(CGFloat videoRatio);

/**
 开关的block回调
 */
@property (nonatomic, copy) void(^switchBlock)(BOOL open);

/**
 按钮的名称数组
 */
@property (nonatomic,strong) NSArray *buttonTitleArray;
@end
