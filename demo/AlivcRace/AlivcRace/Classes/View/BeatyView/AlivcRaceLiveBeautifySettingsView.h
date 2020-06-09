//
//  AlivcLiveBeautifySettingsView.h
//  BeautifySettingsPanel
//
//  Created by 汪潇翔 on 2018/5/29.
//  Copyright © 2018 汪潇翔. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AlivcRaceBeautySettingUIDefine.h"

typedef void(^AlivcBeautifySettingViewButtonAction)(NSInteger tag);

@class AlivcRaceLiveBeautifySettingsView;

@protocol AlivcRaceLiveBeautifySettingsViewDataSource <NSObject>
@required
- (NSArray<NSDictionary *> *)detailItemsOfSettingsView:(AlivcRaceLiveBeautifySettingsView *)settingsView;

@end

@protocol AlivcRaceLiveBeautifySettingsViewDelegate <NSObject>
@required
- (void)settingsView:(AlivcRaceLiveBeautifySettingsView *)settingsView didChangeLevel:(NSInteger)level;

- (void)settingsView:(AlivcRaceLiveBeautifySettingsView *)settingsView didChangeValue:(NSDictionary *)info;
@optional
- (void)settingsView:(AlivcRaceLiveBeautifySettingsView *)settingsView didChangeUIStyle:(AlivcBeautySettingViewStyle)style;

- (void)settingsViewDidSelectHowToGet:(AlivcRaceLiveBeautifySettingsView *)settingsView;
@end

@interface AlivcRaceLiveBeautifySettingsView : UIView

@property (nonatomic, assign) NSInteger level;

@property (nonatomic, weak) id<AlivcRaceLiveBeautifySettingsViewDataSource> dataSource;

@property (nonatomic, weak) id<AlivcRaceLiveBeautifySettingsViewDelegate> delegate;

@property (nonatomic, strong) NSArray<NSMutableDictionary *> *detailItems;

@property (nonatomic, strong) AlivcBeautifySettingViewButtonAction beautifyViewActionBlock;

- (void)setUIStyle:(AlivcBeautySettingViewStyle)uiStyle;

- (AlivcBeautySettingViewStyle)currentUIStyle;

///**
// setUIStyle之后调用
// 
// @param action 美颜视图导航栏左，中，右有3个透明按钮，用与响应事件，对应tag为0，1，2
// @param tag 0，1，2 =》 左，中，右
// */
//- (void)setAction:(void (^)(void))action withTag:(NSInteger)tag;
@end
