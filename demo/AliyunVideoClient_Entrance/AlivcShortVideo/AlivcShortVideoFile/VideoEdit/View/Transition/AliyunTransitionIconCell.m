//
//  AliyunTransitionIconCell.m
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTransitionIconCell.h"
#import "UIImage+AlivcHelper.h"


#define transitionBGViewSize 46
#define transitionCellWidth   70
#define transitionIconViewSize  20

@interface AliyunTransitionIconCell()

@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation AliyunTransitionIconCell
{
    AliyunTransitionIcon *_transitionIcon;
    UIImageView *bgView;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

    [self updateContent];
}

- (UIImageView *)iconImage {
    if (!_iconImage) {
        bgView = [[UIImageView alloc]initWithFrame:CGRectMake((transitionCellWidth-transitionBGViewSize)/2, 0, transitionBGViewSize, transitionBGViewSize)];
        bgView.image = [UIImage avc_imageWithColor: AlivcOxRGBA(0xFFFFFF, 0.2) size:CGSizeMake(transitionBGViewSize, transitionBGViewSize)];
        bgView.layer.cornerRadius = transitionBGViewSize/2;
        bgView.layer.masksToBounds = YES;
        bgView.layer.borderWidth = 1;
        bgView.layer.borderColor = [UIColor clearColor].CGColor;
        [self.contentView addSubview:bgView];
        
        _iconImage = [[UIImageView alloc] initWithFrame:CGRectMake((transitionBGViewSize-transitionIconViewSize)/2, (transitionBGViewSize-transitionIconViewSize)/2, transitionIconViewSize, transitionIconViewSize)];
        _iconImage.backgroundColor = [UIColor clearColor];
//        _iconImage.layer.borderColor = RGBToColor(239, 75, 129).CGColor;
        [bgView addSubview:_iconImage];
    }
    return _iconImage;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, transitionBGViewSize, 70, 20)];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.font = [UIFont systemFontOfSize:10];
        [self.contentView addSubview:_titleLabel];
    }
    return _titleLabel;
}

- (void)updateContent
{
    self.titleLabel.text = _transitionIcon.text;
    if (_transitionIcon.isSelect) {
        [self.iconImage setImage:_transitionIcon.imageSel];
        [bgView setImage:[UIImage avc_imageWithColor:AlivcOxRGB(0x00C1DE) size:CGSizeMake(transitionBGViewSize, transitionBGViewSize)]];
    } else {
        [self.iconImage setImage:_transitionIcon.image];
        [bgView setImage:[UIImage avc_imageWithColor:AlivcOxRGBA(0xFFFFFF, 0.2) size:CGSizeMake(transitionBGViewSize, transitionBGViewSize)]];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)setTransitionIcon:(AliyunTransitionIcon *)icon
{
    _transitionIcon = icon;
    [self updateContent];
}

@end
