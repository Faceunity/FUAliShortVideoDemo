//
//  AlivcRecordSlidButtonsView.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/28.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 侧边栏按钮类型

 - AlivcRecordSlidButtonTypeMusic: 音乐按钮
 - AlivcRecordSlidButtonTypeFilter: 滤镜按钮
 - AlivcRecordSlidButtonTypeSwitchRatio: 切换画幅
 */
typedef NS_ENUM(NSInteger, AlivcRecordSlidButtonType){
    AlivcRecordSlidButtonTypeMusic = 1,
    AlivcRecordSlidButtonTypeFilter = 2,
    AlivcRecordSlidButtonTypeSwitchRatio = 3,
    AlivcRecordSlidButtonTypeSpecialEffects = 4,
    AlivcRecordSlidButtonTypeTakePhoto = 5
    
};

@protocol AlivcRecordSliderButtonsViewDelegate <NSObject>

- (void)alivcRecordSlidButtonAction:(AlivcRecordSlidButtonType)type;

@end

@interface AlivcRecordSliderButtonsView : UIView

@property(nonatomic, weak)id<AlivcRecordSliderButtonsViewDelegate>delegate;
//@property (nonatomic, copy) NSString *imageCoverUrl;

- (void)setMusicButtonEnabled:(BOOL)enabled;

- (void)setSwitchRationButtonEnabled:(BOOL)enabled;

- (void)setPhotoButtonEnabled:(BOOL)enabled;

//更新封面
- (void)updateMusicCoverWithUrl:(NSString *)url;
@end

NS_ASSUME_NONNULL_END
