//
//  MagicCameraEffectCell.m
//  AliyunVideo
//
//  Created by Vienta on 2017/1/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMagicCameraEffectCell.h"
#import "UIView+Progress.h"
#import "AVC_ShortVideo_Config.h"

@interface AliyunMagicCameraEffectCell()

@property (nonatomic , strong) UIView *pieView;

@end

@implementation AliyunMagicCameraEffectCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(frame), CGRectGetHeight(frame))];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        _imageView.layer.borderColor = AlivcOxRGB(0x00c1de).CGColor;
        
        self.backgroundColor =[UIColor clearColor];
        
        self.downloadImageView = [[UIImageView alloc] initWithFrame:CGRectMake(CGRectGetHeight(frame) - 16, CGRectGetHeight(frame) - 16, 16, 16)];
        self.downloadImageView.backgroundColor = [UIColor clearColor];
        self.downloadImageView.image = [AlivcImage imageNamed:@"shortVideo_download"];
        [self addSubview:self.downloadImageView];
        self.downloadImageView.hidden = YES;
        
        _pieView = [[UIView alloc] initWithFrame:self.imageView.bounds];
        [self addSubview:_pieView];
        _pieView.backgroundColor = [UIColor clearColor];
        [_pieView pieProgressView].progressColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:0.8] ;
        _pieView.hidden = YES;
    }
    return self;
}

- (void)borderHidden:(BOOL)isHidden
{
    if (isHidden) {
        self.imageView.layer.borderColor = [UIColor clearColor].CGColor;
    } else {
        _imageView.layer.borderColor = AlivcOxRGB(0x00c1de).CGColor;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    self.imageView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _pieView.bounds = CGRectMake(0, 0, self.bounds.size.height, self.bounds.size.height);
    _pieView.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _pieView.layer.masksToBounds = YES;
    _pieView.layer.cornerRadius = 50 / 2.0;
    self.imageView.layer.cornerRadius = 50/2;
    self.imageView.layer.masksToBounds = YES;
}

- (void)shouldDownload:(BOOL)flag
{
    self.downloadImageView.hidden = !flag;
    if (self.isLoading) {
        self.downloadImageView.hidden = YES;
    }
}

- (void)downloadProgress:(CGFloat)progress
{
    _pieView.hidden = NO;
    [_pieView setPieProgress:progress];
    if (progress > 0 && progress < 1) {
        self.isLoading = YES;
    }else{
        self.isLoading = NO;
    }
}

- (void)setIsLoading:(BOOL)isLoading{
    _isLoading = isLoading;
    if (isLoading) {
        self.downloadImageView.hidden = YES;
    }
}
/**
 重写selected的set方法
 
 @param selected 是否选中
 */
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
}

- (void)setApplyed:(BOOL)Applyed{
    _imageView.layer.borderWidth = Applyed ? 2 : 0;
}
@end
