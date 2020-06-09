//
//  AliyunPasterCollectionViewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterCollectionViewCell.h"

@implementation AliyunPasterCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (!self) {
        return self;
    }
    [self setupSubViews];
    return self;
}

- (void)setupSubViews {
    
    self.showImageView = [[UIImageView alloc] init];
    self.showImageView.frame = CGRectMake(SizeWidth(0), SizeWidth(0), SizeWidth(45), SizeWidth(45));
    [self.contentView addSubview:self.showImageView];
    self.showImageView.center = self.contentView.center;
}

-(void)setIsSelected:(BOOL)isSelected{
    _isSelected = isSelected;
    if (isSelected) {
        _showImageView.layer.borderWidth = 2;
        _showImageView.layer.borderColor = [UIColor redColor].CGColor;
    }else{
        _showImageView.layer.borderWidth = 0;
    }
}

@end
