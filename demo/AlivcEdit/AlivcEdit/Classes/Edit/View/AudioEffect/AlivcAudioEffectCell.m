//
//  AlivcEffectAudioEffectCell.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/3/4.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcAudioEffectCell.h"
#import "UIColor+AlivcHelper.h"

#define AAEC_ICON_HEIGHT_RATIO 0.75

@implementation AlivcAudioEffectModel
@end

@interface AlivcAudioEffectCell()
{
    UIButton *selectedBtn;
    UIButton *iconView;
    UILabel *titleLab;
}


@end

@implementation AlivcAudioEffectCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews{
    self.backgroundColor =[UIColor clearColor];
    CGFloat icon_H =ceilf(CGRectGetHeight(self.frame)*AAEC_ICON_HEIGHT_RATIO);
    iconView =[[UIButton alloc]initWithFrame:CGRectMake((CGRectGetWidth(self.frame) - icon_H)/2, 0, icon_H, icon_H)];
    iconView.backgroundColor =[UIColor colorWithHexString:@"#515254"];
    iconView.layer.cornerRadius = icon_H/2;
    iconView.layer.masksToBounds =YES;
    iconView.userInteractionEnabled =NO;
    [self.contentView addSubview:iconView];
    
    selectedBtn =[[UIButton alloc]initWithFrame:iconView.bounds];
    [selectedBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_affirm"] forState:UIControlStateNormal];
    selectedBtn.hidden= YES;
    selectedBtn.backgroundColor =[UIColor colorWithHexString:@"#00C1DE"];
    [iconView addSubview:selectedBtn];
    
    titleLab =[[UILabel alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(iconView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)-CGRectGetMaxY(iconView.frame))];
    titleLab.font =[UIFont systemFontOfSize:14];
    titleLab.textAlignment =NSTextAlignmentCenter;
    titleLab.textColor =[UIColor colorWithHexString:@"#C3C5C6"];
    titleLab.backgroundColor =[UIColor clearColor];
    titleLab.transform = CGAffineTransformMakeTranslation(0, 10);
    [self.contentView addSubview:titleLab];
}

-(void)cellModel:(AlivcAudioEffectModel *)model{
    [titleLab setText:model.title];
    [iconView setImage:[AlivcImage imageNamed:model.iconPath] forState:UIControlStateNormal];
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    selectedBtn.hidden = !selected;
}

@end
