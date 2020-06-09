//
//  AlivcRecordButton.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/22.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 录制按钮状态

 - AlivcRecordButtonStatusNormal: 未录制
 - AlivcRecordButtonStatusHighlight: 按下录制中
 - AlivcRecordButtonStatusSelected: 选中录制中
 */
typedef NS_ENUM(NSInteger,AlivcRecordButtonStatus){
    AlivcRecordButtonStatusNormal,
    AlivcRecordButtonStatusHighlight,
    AlivcRecordButtonStatusSelected
};

@interface AlivcRecordButton : UIButton


/**
 改变录制按钮状态

 @param status 录制状态
 */
- (void)changeRecordButtonStatus:(AlivcRecordButtonStatus)status;

@end

NS_ASSUME_NONNULL_END
