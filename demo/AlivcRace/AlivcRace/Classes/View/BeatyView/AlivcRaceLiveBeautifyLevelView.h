//
//  _AlivcLiveBeautifyLevelView.h
//  BeautifySettingsPanel
//
//  Created by 汪潇翔 on 2018/5/29.
//  Copyright © 2018 汪潇翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcRaceBeautySettingUIDefine.h"

@class AlivcRaceLiveBeautifyNavigationView,AlivcRaceLiveBeautifyLevelView;

@protocol AlivcRaceLiveBeautifyLevelViewDelegate <NSObject>
@required
- (void)levelView:(AlivcRaceLiveBeautifyLevelView *)levelView didChangeLevel:(NSInteger)level;
@optional
- (void)levelView:(AlivcRaceLiveBeautifyLevelView *)levelView didChangeUIStyle:(AlivcBeautySettingViewStyle)style;
- (void)levelViewDidSelectHowToGet:(AlivcRaceLiveBeautifyLevelView *)levelView;
@end

@interface AlivcRaceLiveBeautifyLevelView : UIView <UITextViewDelegate>

@property (nonatomic, readonly) AlivcRaceLiveBeautifyNavigationView *navigationView;

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, weak) id<AlivcRaceLiveBeautifyLevelViewDelegate> delegate;
@property (nonatomic, weak) UIButton *titleButton;

- (void)setUIStyle:(AlivcBeautySettingViewStyle)uiStyle;

- (AlivcBeautySettingViewStyle)currentUIStyle;

- (void)setBeautyTitle:(NSString *)title;

@end
