//
//  AlivcPlayContainerView.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/8/30.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcPlayContainerView.h"

@interface AlivcPlayContainerView()

@property (nonatomic, strong) UIImage *p_image;

@end

@implementation AlivcPlayContainerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)init{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        NSAssert(false, @"Please use initWithPlayer");
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
       
    }
    return self;
    
}

- (instancetype)initWithPlayer:(AliyunVodPlayer *)vodPlayer{
    self = [super init];
    if (self) {
        self.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        _vodPlayer = vodPlayer;
        _coverImageView = [[UIImageView alloc]initWithFrame:self.bounds];
        _coverImageView.hidden = YES;
        [self addSubview:_coverImageView];
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)setCoverImage:(UIImage *)coverImage{
    _p_image = coverImage;
    _coverImageView.image = _p_image;
}

- (void)setPreCoverImageWhenStop{
    _coverImageView.image = _p_image;
    _coverImageView.hidden = NO;
}

- (void)clearData{
     _p_image = nil;
    _coverImageView.image = nil;
    _coverImageView.hidden = YES;
}

- (void)setVideoModel:(AlivcVideoPlayListModel *)model{
    _videoModel = model;
}

@end
