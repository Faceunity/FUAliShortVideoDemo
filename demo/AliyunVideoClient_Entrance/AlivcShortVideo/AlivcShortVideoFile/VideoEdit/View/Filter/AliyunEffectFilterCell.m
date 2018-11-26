//
//  AliyunEffectFilterCell.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectFilterCell.h"
#import "UIImageView+WebCache.h"
#import "AVC_ShortVideo_Config.h"
#import "UIView+Progress.h"
#import "AliyunEffectResourceModel.h"
@interface AliyunEffectFilterCell ()

/**
 MV中的中间黑洞
 */
@property (weak, nonatomic) IBOutlet UIImageView *mvCenterImageView;

/**
 数据ID
 */
@property (nonatomic, assign) NSInteger eid;

/**
 下载进度view
 */
@property (nonatomic, strong) UIView *pieView;

/**
 数据类型
 */
@property (assign, nonatomic) NSInteger type;

@end

@implementation AliyunEffectFilterCell

- (void)awakeFromNib {
    [super awakeFromNib];
    _imageView.layer.cornerRadius = 25;
    _imageView.layer.masksToBounds = YES;
    _imageView.layer.borderColor = AlivcOxRGB(0x00c1de).CGColor;
    

    self.downloadImageView.backgroundColor = [UIColor clearColor];
    self.downloadImageView.image = [AlivcImage imageNamed:@"shortVideo_download"];
    [self addSubview:self.downloadImageView];
    self.downloadImageView.hidden = YES;
    
    _pieView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
    [self addSubview:_pieView];
    _pieView.backgroundColor = [UIColor clearColor];
    [_pieView pieProgressView].progressColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:0.8] ;
    _pieView.hidden = YES;
    
}

- (void)shouldDownload:(BOOL)flag
{
    self.downloadImageView.hidden = flag;
    if (flag == YES) {
        self.pieView.hidden = YES;
    }
}

- (void)cellModel:(AliyunEffectInfo *)effectInfo {
    self.type = effectInfo.effectType;
    _nameLabel.text = effectInfo.name;
    _eid = effectInfo.eid;
    if (effectInfo.effectType == AliyunEffectTypeFilter || effectInfo.effectType == AliyunEffectTypeSpecialFilter) {
        _mvCenterImageView.hidden = YES;
        _imageView.image = [UIImage imageWithContentsOfFile:[effectInfo localFilterIconPath]];
        if ((effectInfo.effectType == AliyunEffectTypeSpecialFilter)&&(effectInfo.eid == -1)) {
            _imageView.image = [AlivcImage imageNamed:effectInfo.icon];
        }
    } else if (effectInfo.effectType == AliyunEffectTypeMV) {
        if (effectInfo.eid == -1) {
            _mvCenterImageView.hidden = YES;
            _imageView.image = [AlivcImage imageNamed:effectInfo.icon];
        } else {
            _mvCenterImageView.hidden = NO;
            _mvCenterImageView.image  = [AlivcImage imageNamed:@"shortVideo_edit_center"];
            NSURL *url = [NSURL URLWithString:[effectInfo.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
            
            if([effectInfo.icon isEqualToString:@"shortVideo_mv_default"]){
                _imageView.image = [AlivcImage imageNamed:@"shortVideo_mv_default"];
            }else{
                [_imageView sd_setImageWithURL:url];
            }
            
            
        }
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    self.downloadImageView.frame = CGRectMake(CGRectGetWidth(self.frame) - 16, CGRectGetWidth(self.frame) - 16, 16, 16);
    
    _pieView.frame = CGRectMake(0, 0, 50, 50);
    _pieView.layer.masksToBounds = YES;
    _pieView.layer.cornerRadius = 50 / 2.0;
}

/**
 重写selected的set方法

 @param selected 是否选中
 */
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if (self.type == AliyunEffectTypeSpecialFilter) {
        return;
    }
    self.selectedButton.hidden = !selected;

}

- (void)downloadProgress:(CGFloat)progress
{
    _pieView.hidden = NO;
    [_pieView setPieProgress:progress];
    if (progress == 1) {
        _pieView.hidden = YES;
    }
}

@end
