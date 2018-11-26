//
//  AliyunFontEffectViewCell.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunFontEffectViewCell.h"

#define fontEffectImageVeiwSize  25  //iconview大小
#define fontEffectBgVeiwSize  50     //圆圈背景view大小

@interface AliyunFontEffectViewCell()

@property(nonatomic, strong)UIImageView *imageView;//iconView
@property(nonatomic, strong)UIImage *imageNormal;//未被选中的icon
@property(nonatomic, strong)UIImage *imageSelected;//被选中后的icon
@property(nonatomic, strong)UILabel *textLab;//title

@property(nonatomic, strong)UIView *bgView;//圆圈背景view

@end
@implementation AliyunFontEffectViewCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.bgView];
    }
    return self;
}

-(UILabel *)textLab{
    if (!_textLab) {
        _textLab = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.bgView.frame), CGRectGetWidth(self.contentView.frame), fontEffectImageVeiwSize)];
        [self.contentView addSubview:_textLab];
        _textLab.textColor = [UIColor whiteColor];
        _textLab.font = [UIFont systemFontOfSize:14];
        _textLab.textAlignment = NSTextAlignmentCenter;
        _textLab.center = CGPointMake(self.contentView.center.x, _textLab.center.y);
    }
    return _textLab;
}

-(UIView *)bgView{
    if (!_bgView) {
        _bgView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMidX(self.contentView.bounds)-fontEffectBgVeiwSize/2, 0, fontEffectBgVeiwSize, fontEffectBgVeiwSize)];
        _bgView.backgroundColor = AlivcOxRGBA(0xFFFFFF, 0.2);
        _bgView.layer.cornerRadius = fontEffectBgVeiwSize/2;
        _bgView.layer.masksToBounds = YES;
        
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake((fontEffectBgVeiwSize-fontEffectImageVeiwSize)/2, (fontEffectBgVeiwSize-fontEffectImageVeiwSize)/2, fontEffectImageVeiwSize, fontEffectImageVeiwSize)];
        _imageView.backgroundColor = [UIColor clearColor];
        [_bgView addSubview:_imageView];
    }
    return _bgView;
    
}


- (void)setSubtitleActionItem:(AliyunSubtitleActionItem *)actionItem
{
    [self.imageView setImage:actionItem.iconImage];
    [self.textLab setText:actionItem.iconText];
    self.imageNormal = actionItem.iconImage;
    self.imageSelected = actionItem.iconSelected;
}

-(void)setSelected:(BOOL)selected{
    [super setSelected:selected];
    if (selected) {
        self.bgView.backgroundColor = AlivcOxRGB(0x00C1DE);
        [self.imageView setImage:_imageSelected];
    }else{
        self.bgView.backgroundColor = AlivcOxRGBA(0xFFFFFF, 0.2);
        [self.imageView setImage:_imageNormal];
    }
}

@end
