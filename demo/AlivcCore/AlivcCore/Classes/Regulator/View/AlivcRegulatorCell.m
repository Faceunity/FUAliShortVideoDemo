//
//  AlivcRegulatorCell.m
//  AFNetworking
//
//  Created by lileilei on 2020/1/6.
//

#import "AlivcRegulatorCell.h"
#import <AliyunVideoSDKPro/AliyunEffectConfig.h>
#import "_AlivcLiveBeautifySliderView.h"

@interface AlivcRegulatorCell ()<_AlivcLiveBeautifySliderViewDelegate>

@property(nonatomic,strong) UILabel *title;
@property(nonatomic,strong) _AlivcLiveBeautifySliderView *slider;

@end

@implementation AlivcRegulatorCell

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    [self setBackgroundColor:[UIColor clearColor]];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _title = [[UILabel alloc] initWithFrame:CGRectMake(16, (CGRectGetHeight(self.frame)-21)/2, 100, 21)];
    [self.contentView addSubview:_title];
    [_title setTextColor:[UIColor whiteColor]];
    
    _slider = [[_AlivcLiveBeautifySliderView alloc] initWithFrame:CGRectMake(CGRectGetMaxX(_title.frame), (CGRectGetHeight(self.frame)-78)/2, ScreenWidth-116, 78)];
    [_slider setClipsToBounds:NO];
    [_slider setBackgroundColor:[UIColor clearColor]];
    _slider.delegate = self;
    
    [self.contentView addSubview:_slider];
    
}

-(void)setModel:(AliyunParam*)model isEnable:(BOOL)isEnable{
    [_title setText:model.name];
    [_slider setEnabled:isEnable];
    if (model.value.values.count>0) {
        NSNumber *num = [model.value.values firstObject];
        if (model.maxValue.values.count>0 && model.minValue.values.count>0) {
            NSNumber *maxNum = [model.maxValue.values firstObject];
            NSNumber *minNum = [model.minValue.values firstObject];
            [_slider setMaximumValue:[maxNum floatValue]];
            [_slider setMinimumValue:[minNum floatValue]];
        }
        [_slider setOriginalValue:[num floatValue]];
        [_slider setValue:[num floatValue]];
        [_slider setShowFloat:model.value.type==AliyunValueFLOAT];
    }
}

- (void)sliderValueChanged:(UISlider*)sender {
    if (self.didSliderChangeBlock) {
        self.didSliderChangeBlock(sender.value);
    }
}

#pragma --mark _AlivcLiveBeautifySliderViewDelegate
- (void)sliderView:(_AlivcLiveBeautifySliderView *)sliderView valueDidChange:(float)value{
    if (self.didSliderChangeBlock) {
        self.didSliderChangeBlock(value);
    }
}

- (void)sliderViewTouchDidCancel:(_AlivcLiveBeautifySliderView *)sliderView{
    if (self.didSliderChangeBlock) {
        self.didSliderChangeBlock(sliderView.value);
    }
}

@end
