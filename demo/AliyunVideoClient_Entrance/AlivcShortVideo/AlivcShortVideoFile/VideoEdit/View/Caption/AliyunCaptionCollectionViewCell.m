//
//  AliyunCaptionCollectionViewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/17.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCaptionCollectionViewCell.h"

@implementation AliyunCaptionCollectionViewCell

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
    self.showImageView.frame = CGRectMake(0, 0, 50, 50);
    self.showImageView.layer.masksToBounds = YES;
    self.showImageView.layer.cornerRadius = self.showImageView.frame.size.height / 2;
    self.showImageView.layer.borderColor = RGBToColor(239, 75, 129).CGColor;
    [self.contentView addSubview:self.showImageView];
    self.showImageView.center = self.contentView.center;
}

-(void)setIsFont:(BOOL)isFont{
    _isFont = isFont;
    if (isFont) {
        self.showImageView.frame = CGRectMake(0, 0, 40, 40);
    }else{
        self.showImageView.frame = CGRectMake(0, 0, 50, 50);
    }
    self.showImageView.layer.cornerRadius = self.showImageView.frame.size.height / 2;
    self.showImageView.center = self.contentView.center;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
}

@end
