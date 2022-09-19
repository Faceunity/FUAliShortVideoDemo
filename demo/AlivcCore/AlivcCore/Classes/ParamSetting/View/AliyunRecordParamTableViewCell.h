//
//  AliyunRecordParamTableViewCell.h
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//  视频拍摄设置界面、视频编辑设置界面公用的cell

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, AlivcRecordType) {
    AlivcRecordTypeNormal,
    AlivcRecordTypeMerge,
    AlivcRecordTypeMultiSource,
};

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
 actural value
 */
@property (nonatomic, assign) CGFloat value;

/**
 UITextField的值改变时的block回调
 */
@property (nonatomic, copy) void(^valueBlock)(int value);

//按钮可否点击 0 忽略 1：不可点 2 可点击
@property (nonatomic, assign) int btnEnable;

/**
 分辨率的block回调
 */
@property (nonatomic, copy) void(^sizeBlock)(CGFloat videoWidth);
@property (nonatomic, copy) void(^ratioBack)(CGFloat videoRatio);
@property (nonatomic, copy) void(^recodeTypeBlock)(AlivcRecordType recordType);
@property (nonatomic, copy) void(^mixAudioSourceBlock)(int type);
@property (nonatomic, copy) void(^mixAECTypeBlock)(int type);
@property (nonatomic, copy) void(^mixBgColorBlock)(int type);
@property (nonatomic, copy) void(^mixBgImgBlock)(int type);
@property (nonatomic, copy) void(^mixBgImgScaleBlock)(int type);

@property (nonatomic, copy) void(^encodeModelBlock)(NSInteger encodeMode);
@property (nonatomic, copy) void(^beautyTypeBlock)(NSInteger beautyType);


/**
 开关的block回调
 */
@property (nonatomic, copy) void(^switchBlock)(BOOL open);

/**
 按钮的名称数组
 */
@property (nonatomic,strong) NSArray *buttonTitleArray;
@end
