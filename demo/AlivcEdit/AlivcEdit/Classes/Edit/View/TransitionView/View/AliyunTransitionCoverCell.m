//
//  AliyunTransitionCoverCell.m
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTransitionCoverCell.h"
#import "UIColor+AlivcHelper.h"

@implementation AliyunTransitionCoverCell
{
    AliyunTransitionCover *_transitionCover;
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

-(void)selectedLayoutCover:(AliyunTransitionCover *)cover{
    UIView *borderView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 40, 40)];
    borderView.backgroundColor = [UIColor clearColor];
    borderView.layer.borderColor = [UIColor colorWithHexString:@"#00C1DE"].CGColor;
    borderView.layer.borderWidth = 1.5;
    [self.contentView addSubview:borderView];
    CGFloat width = cover.type == 0 ? 30 : 20;
    
    UIImageView *_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake((40-width)/2, (40-width)/2, width, width)];
    _coverImageView.backgroundColor = [UIColor clearColor];
    _coverImageView.image = cover.image;
    _coverImageView.tag = 1009;
    [_coverImageView setContentMode:UIViewContentModeScaleAspectFill];
    [borderView addSubview:_coverImageView];
}

-(void)selectCancelWithCover:(AliyunTransitionCover *)cover{
    if (cover.type == 0) {//无选中动画布局
        UIImageView *_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 0, 40, 40)];
        _coverImageView.backgroundColor = [UIColor clearColor];
        _coverImageView.image = cover.image_Nor;
        _coverImageView.tag = 1008;
        [_coverImageView setContentMode:UIViewContentModeScaleAspectFill];
        [self.contentView addSubview:_coverImageView];
    }else{//有选中动画布局
        UIView *bgView = [[UIView alloc]initWithFrame:CGRectMake(10, 0, 40, 40)];
        bgView.backgroundColor = AlivcOxRGBA(0xFFFFFF, 0.3);
        bgView.layer.cornerRadius = 2;
        bgView.layer.masksToBounds = YES;
        [self.contentView addSubview:bgView];
        
        UIImageView *_coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake((40-20)/2, (40-20)/2, 20, 20)];
        _coverImageView.backgroundColor = [UIColor clearColor];
        _coverImageView.image = cover.transitionImage_Nor;
        _coverImageView.tag = 1008;
        [_coverImageView setContentMode:UIViewContentModeScaleAspectFill];
        [bgView addSubview:_coverImageView];
    }

}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.backgroundColor = [UIColor clearColor];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}
-(void)clearContentView{
    for (UIView *view in self.contentView.subviews) {
        if (view) {
            [view removeFromSuperview];
        }
    }
}

- (void)setTransitionCover:(AliyunTransitionCover *)cover
{
    
    [self clearContentView];
    _transitionCover = cover;
    if (_transitionCover.isTransitionIdx) {
        if (_transitionCover.isSelect) {
            [self selectedLayoutCover:cover];//选中状态布局
        } else {
            [self selectCancelWithCover:cover];//未选中状态布局
        }
    }
}



@end
