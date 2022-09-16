//
//  AliyunSubtitleActionItem.h
//  qusdk
//
//  Created by Vienta on 2018/6/12.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 字体特效枚举类型

 - TextActionTypeNull: 空
 - TextActionTypeClear: 无效果
 - TextActionTypeMoveTop: 向上移动
 - TextActionTypeMoveDown: 向下移动
 - TextActionTypeMoveLeft: 向左移动
 - TextActionTypeMoveRight: 向右移动
 - TextActionTypeLinerWipe: 线性擦除
 - TextActionTypeFade: 淡入淡出
 - TextActionTypeScale: 缩放
 */
typedef NS_ENUM(NSInteger,TextActionType){
    TextActionTypeNull = -1,
    TextActionTypeClear,
    TextActionTypeMoveTop,
    TextActionTypeMoveDown,
    TextActionTypeMoveLeft,
    TextActionTypeMoveRight,
    TextActionTypeLinerWipe,
    TextActionTypeFade,
    TextActionTypeScale,
    TextActionTypePrinter,       //打字机
    TextActionTypeClock,        //钟摆
    TextActionTypeBrush,        //雨刷
    TextActionTypeSet_1,       //组合动画1
    TextActionTypeSet_2,       //钟摆
    TextActionTypeWave,        //波浪
    TextActionTypeScrewUp,     //螺旋上升
    TextActionTypeHeart,       //心跳
    TextActionTypeCircularScan,//圆形扫描
    TextActionTypeWaveIn,      //波浪弹入
    
    

};

@interface AliyunSubtitleActionItem : NSObject

/**
 当前itme特效Type
 */
@property (nonatomic, assign) TextActionType type;

/**
 特效icon
 */
@property (nonatomic, strong) UIImage *iconImage;

/**
 是否选中
 */
@property (nonatomic, strong) UIImage *iconSelected;

/**
 特效标题
 */
@property (nonatomic, copy) NSString *iconText;

@end
