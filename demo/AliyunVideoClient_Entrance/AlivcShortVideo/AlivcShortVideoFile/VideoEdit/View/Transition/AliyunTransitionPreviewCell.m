//
//  AliyunTransitionPreviewCell.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/8/30.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunTransitionPreviewCell.h"

@implementation AliyunTransitionPreviewCell
{
    AliyunTransitionCover *_transitionCover;
}

-(UIImageView *)preview{
    if (!_preview) {
        _preview = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 90-20, 40)];
        _preview.backgroundColor = [UIColor clearColor];
        _preview.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_preview];
    }
    return _preview;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setTransitionCover:(AliyunTransitionCover *)cover
{
    _transitionCover = cover;
    [self updateContent];
    if (_transitionCover.isTransitionIdx) {
        if (_transitionCover.isSelect) {
            _preview.layer.cornerRadius = 20;
            _preview.layer.masksToBounds = YES;
            _preview.layer.borderColor = RGBToColor(239, 75, 129).CGColor;
            _preview.layer.borderWidth = 2;
        } else {
            _preview.layer.cornerRadius = 20;
            _preview.layer.masksToBounds = YES;
            _preview.layer.borderColor = RGBToColor(239, 75, 129).CGColor;
            _preview.layer.borderWidth = 0;
        }
    }
}

- (void)updateContent {
    [self.preview setImage:_transitionCover.image];
}


@end
