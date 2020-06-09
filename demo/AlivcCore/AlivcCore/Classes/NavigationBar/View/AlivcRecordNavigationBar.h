//
//  AlivcRecordNavigationBar.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/2/22.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AlivcRecordUIConfig;

NS_ASSUME_NONNULL_BEGIN

/**
 导航条点击事件

 - AlivcRecordNavigationBarTypeGoback: 返回
 - AlivcRecordNavigationBarTypeFinish: 完成
 - AlivcRecordNavigationBarTypeCameraSwitch: 切换摄像头
 - AlivcRecordNavigationBarTypeTiming: 定时拍摄
 - AlivcRecordNavigationBarTypeFlashSwitch: 闪光灯开关
 - AlivcRecordNavigationBarTypeMusic: 音乐
 */
typedef NS_ENUM(NSInteger, AlivcRecordNavigationBarType){
    AlivcRecordNavigationBarTypeGoback = 1,
    AlivcRecordNavigationBarTypeFinish,
    AlivcRecordNavigationBarTypeCameraSwitch,
    AlivcRecordNavigationBarTypeTiming,
    AlivcRecordNavigationBarTypeFlashMode,
    AlivcRecordNavigationBarTypeMusic
};

/**
 录制灯光模式，这里对应SDK的值

 - AlivcRecordFlashModeOff: 关闭
 - AlivcRecordFlashModeOn: 开启
 - AlivcRecordFlashModeAuto: 自动（录制时自动开启，停止时自动关闭）
 */
typedef NS_ENUM(NSInteger, AlivcRecordTorchMode){
    AlivcRecordTorchModeOff     = 0,
    AlivcRecordTorchModeOn      = 1,
    AlivcRecordTorchModeAuto    = 2,
    AlivcRecordTorchModeDisabled =3
};

@protocol AlivcRecordNavigationBarDelegate <NSObject>
@optional
/**
 导航栏按钮事件

 @param type 本次触发按钮事件类型
 */
- (void)alivcRecordNavigationBarButtonActionType:(AlivcRecordNavigationBarType)type;

@end

@interface AlivcRecordNavigationBar : UIView

@property(nonatomic, weak)id<AlivcRecordNavigationBarDelegate>delegate;


/**
 指定初始化
 
 @param uiConfig 短视频拍摄界面UI配置
 @return self对象
 */
- (instancetype)initWithUIConfig:(AlivcRecordUIConfig *)uiConfig;

/**
 设置完成按钮可点击状态

 @param enabled 是否可点击
 */
- (void)setFinishButtonEnabled:(BOOL)enabled;

/**
 设置倒计时按钮可点击状态
 
 @param enabled 是否可点击
 */
- (void)setTimerButtonEnabled:(BOOL)enabled;

/**
 设置灯光模式

 @param mode 灯光模式
 */
- (void)setTorchButtonImageWithMode:(AlivcRecordTorchMode)mode;

@end

NS_ASSUME_NONNULL_END
