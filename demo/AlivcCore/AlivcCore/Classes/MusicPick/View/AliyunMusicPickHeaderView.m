//
//  AliyunMusicPickHeaderView.m
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicPickHeaderView.h"
#import "AVC_ShortVideo_Config.h"
#import "AlivcUIConfig.h"
#import "UIView+Progress.h"
#import "AliyunMusicPickModel.h"
@interface AliyunMusicPickHeaderView()
@property (nonatomic,strong) UIView *pieView;
@end
@implementation AliyunMusicPickHeaderView

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self buildSubview];
    }
    
    return self;
}
- (void)buildSubview {
//    // 白色背景
//    self.backgroundColor = [UIColor clearColor];
//    self.backgroundView.backgroundColor = [UIColor clearColor];
    UIView *contentView         = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,64)];
    contentView.backgroundColor = [UIColor clearColor];
    self.backgroundView = contentView;
    
//    self.line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
//    self.line.backgroundColor = [UIColor whiteColor];
//    [contentView addSubview:self.line];
    
    // 按钮
    self.button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0.5, ScreenWidth, 63)];
    [self.button addTarget:self
                    action:@selector(buttonEvent:)
          forControlEvents:UIControlEventTouchUpInside];
    self.button.backgroundColor = [UIColor clearColor];
    [self addSubview:self.button];
    
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 0.5, ScreenWidth, 40)];
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.font = [UIFont systemFontOfSize:17.0f];
    [contentView addSubview:self.titleLabel];
    
    self.artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 40.5, ScreenWidth, 17)];
    self.artistLabel.textColor = [UIColor whiteColor];
    self.artistLabel.font = [UIFont systemFontOfSize:12.0f];
    [contentView addSubview:self.artistLabel];
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth - 36, 24, 16, 16)];
    self.imageView.image = [AlivcImage imageNamed:@"shortVideo_musicStatus"];
    self.imageView.hidden = YES;
    [contentView addSubview:self.imageView];
    
    _pieView = [[UIView alloc] initWithFrame:self.imageView.frame];
    [contentView addSubview:_pieView];
    _pieView.backgroundColor = [UIColor clearColor];
    [_pieView pieProgressView].progressColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:0.8] ;
    _pieView.hidden = YES;
}


- (void)configWithModel:(AliyunMusicPickModel *)model{
    self.titleLabel.text = model.name;
    self.artistLabel.text = model.artist;
    [self setTextLabelFrame];
    self.pieView.hidden = YES;
    if (model.downloadProgress < 1 && model.downloadProgress > 0) {
        [self.contentView addSubview:self.pieView];
        [self downloadProgress:model.downloadProgress];
    }else{
        [self.pieView removeFromSuperview];
    }
    if ([model.name isEqualToString:NSLocalizedString(@"无音乐" , nil)]) {
        self.imageView.hidden = YES;
    }
}

- (void)updateDownloadViewWithFinish:(BOOL)finish{
    if (finish) {
        [self.pieView removeFromSuperview];
    }else{
        [self.contentView addSubview:self.pieView];
    }
    
}

- (void)downloadProgress:(CGFloat)progress
{
    _pieView.hidden = NO;
    [_pieView setPieProgress:progress];
    if (progress == 1) {
        _pieView.hidden = YES;
    }
}

- (void)buttonEvent:(UIButton *)button {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectHeader:)]) {
        [self.delegate didSelectHeader:self];
    }
}

- (void)shouldExpand:(BOOL)expand{
    if (expand) {
        self.imageView.hidden = NO;
        self.titleLabel.textColor = [AlivcUIConfig shared].kAVCThemeColor;
        self.artistLabel.textColor = [AlivcUIConfig shared].kAVCThemeColor;
    }else {
        self.imageView.hidden = YES;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.artistLabel.textColor = [UIColor whiteColor];
    }
}

- (void)setTextLabelFrame{
    [self.titleLabel sizeToFit];
    [self.artistLabel sizeToFit];
    CGFloat cy = 27;
    self.titleLabel.center = CGPointMake(self.titleLabel.frame.size.width / 2 + 8, cy);
    CGFloat acx = CGRectGetMaxX(self.titleLabel.frame) + 8 + self.artistLabel.frame.size.width / 2;
    self.artistLabel.center = CGPointMake(acx,cy);
    CGFloat amx = CGRectGetMaxX(self.artistLabel.frame);
    if (amx > [UIScreen mainScreen].bounds.size.width - 60) {
        CGRect frame = self.artistLabel.frame;
        frame.size.width = [UIScreen mainScreen].bounds.size.width - 60;
        self.artistLabel.frame = frame;
    }
}

@end
