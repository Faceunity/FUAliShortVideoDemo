//
//  AliyunFontEffectView.h
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcTabbarBaseView.h"
#import "AliyunSubtitleActionItem.h"

@protocol AliyunFontEffectViewDelegate <NSObject>

/**
 选择一个特效的代理方法

 @param actionType 选中的字体特效
 */
- (void)onSelectActionType:(TextActionType )actionType;

@end

/**
 字体特效view
 */
@interface AliyunFontEffectView : AlivcTabbarBaseView;

@property(nonatomic, weak)id<AliyunFontEffectViewDelegate> delegate;

-(void)setDefaultSelectItem:(TextActionType )actionType;

@end
