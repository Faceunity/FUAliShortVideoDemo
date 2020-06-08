//
//  _AlivcLiveBeautifySliderView.h
//  BeautifySettingsPanel
//
//  Created by 汪潇翔 on 2018/5/30.
//  Copyright © 2018 汪潇翔. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AlivcRaceLiveBeautifySliderView;

@protocol AlivcRaceLiveBeautifySliderViewDelegate <NSObject>
- (void)sliderView:(AlivcRaceLiveBeautifySliderView *)sliderView valueDidChange:(float)value;
- (void)sliderViewTouchDidCancel:(AlivcRaceLiveBeautifySliderView *)sliderView ;
@end

@interface AlivcRaceLiveBeautifySliderView : UIView

@property (nonatomic) float value;
@property (nonatomic) float minimumValue;
@property (nonatomic) float maximumValue;
@property (nonatomic) float originalValue;

@property (nonatomic, weak) id<AlivcRaceLiveBeautifySliderViewDelegate> delegate;

@end
