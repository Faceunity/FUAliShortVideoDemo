//
//  AlivcRecordSlidButtonsView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/28.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordSliderButtonsView.h"
#import "AlivcButton.h"
#import "UIImage+AlivcHelper.h"
#import <SDWebImage/UIButton+WebCache.h>
#import "NSString+AlivcHelper.h"

@implementation AlivcRecordSliderButtonsView

- (instancetype)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews{
    NSArray *titles =@[[@"剪音乐" localString],[@"滤镜" localString],[@"切画幅" localString],[@"特效" localString],[@"拍照" localString]];
    NSArray *images =@[@"shortVideo_music",@"alivc_svEdit_filter",@"shortVideo_record_switchRatio",@"shortVideo_effectFilter",@"shortVideo_takePhoto"];
    NSArray *types =@[@(AlivcRecordSlidButtonTypeMusic),@(AlivcRecordSlidButtonTypeFilter),@(AlivcRecordSlidButtonTypeSwitchRatio),@(AlivcRecordSlidButtonTypeSpecialEffects),@(AlivcRecordSlidButtonTypeTakePhoto)];
    CGFloat width = CGRectGetWidth(self.frame);
    for (int i =0; i<titles.count; i++) {
        AlivcButton *btn =[[AlivcButton alloc] initWithButtonType:AlivcButtonTypeTitleBottom];
        btn.frame = CGRectMake(0, 0+i*(width+25), width, width);
        btn.backgroundColor = [UIColor clearColor];
        btn.tag = [types[i] integerValue];
        [btn addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:titles[i] forState:UIControlStateNormal];
        [btn setImage:[AlivcImage imageNamed:images[i]] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        btn.titleLabel.font =[UIFont systemFontOfSize:12];
        [self addSubview:btn];
    }
}
- (void)setMusicButtonEnabled:(BOOL)enabled{
    UIButton *finishBtn = (UIButton *)[self viewWithTag:(NSInteger)AlivcRecordSlidButtonTypeMusic];
    finishBtn.enabled= enabled;
    //由于切换画幅的可点击状态逻辑与音乐一致，所以这里跟音乐绑定；
    [self setSwitchRationButtonEnabled:enabled];
}

- (void)setSwitchRationButtonEnabled:(BOOL)enabled{
    UIButton *rationBtn = (UIButton *)[self viewWithTag:(NSInteger)AlivcRecordSlidButtonTypeSwitchRatio];
    rationBtn.enabled= enabled;
}
- (void)setPhotoButtonEnabled:(BOOL)enabled {
    UIButton *photoBtn = (UIButton *)[self viewWithTag:(NSInteger)AlivcRecordSlidButtonTypeTakePhoto];
    photoBtn.hidden= !enabled;
}
- (void)buttonAction:(UIButton *)sBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordSlidButtonAction:)]) {
        [self.delegate alivcRecordSlidButtonAction:(AlivcRecordSlidButtonType)sBtn.tag];
    }
}
- (void)updateMusicCoverWithUrl:(NSString *)url {
    if (!url) {
        url = @"";
    }
    UIButton *musicBtn = (UIButton *)[self viewWithTag:(NSInteger)AlivcRecordSlidButtonTypeMusic];
    [musicBtn sd_setImageWithURL:[NSURL URLWithString:url] forState:UIControlStateNormal placeholderImage:[AlivcImage imageNamed:@"shortVideo_music"]];
    musicBtn.imageView.layer.cornerRadius = musicBtn.imageView.bounds.size.height * 0.5;
}
@end
