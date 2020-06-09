//
//  AlivcRecordFocusView.h
//  AlivcVideoClient_Entrance
//
//  Created by wanghao on 2019/3/18.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


/**
 把focusView添加到preview上，通过改变focusView的center来使用
 
 例：
 AlivcRecordFocusView *focusView =[[AlivcRecordFocusView alloc]initWithFrame:CGRectMake(0, 0, 150, 150)];
 focusView =YES;
 [self.recorder.preview addSubview:focusView];
 focusView.center = tapGesture.point
 */
@interface AlivcRecordFocusView : UIView

/**
 聚焦动画
 */
@property(nonatomic, assign)BOOL animation;

@end

NS_ASSUME_NONNULL_END
