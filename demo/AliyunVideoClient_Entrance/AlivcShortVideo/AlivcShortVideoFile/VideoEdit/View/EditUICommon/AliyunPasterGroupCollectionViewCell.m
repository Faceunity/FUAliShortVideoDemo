//
//  QUPackageCollectionViewCell.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterGroupCollectionViewCell.h"
#import "UIView+AlivcHelper.h"
#import "AliyunEffectPasterGroup.h"
//#import "UIImageView+WebCache.h"

@interface AliyunPasterGroupCollectionViewCell ()
@property(nonatomic, strong)UILabel *lab;//分组name
@end
@implementation AliyunPasterGroupCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.backgroundColor = [UIColor clearColor];
//    self.iconImageView = [[UIImageView alloc] init];
//    self.iconImageView.frame = CGRectMake(0, 0, SizeWidth(32), SizeWidth(32));
//    self.iconImageView.layer.cornerRadius = SizeWidth(16);
//    self.iconImageView.layer.masksToBounds = YES;
//    [self.contentView addSubview:self.iconImageView];
//    self.iconImageView.center = self.contentView.center;
}
-(UILabel *)lab{
    if (!_lab) {
        _lab = [[UILabel alloc]initWithFrame:self.contentView.bounds];
        _lab.textAlignment = NSTextAlignmentCenter;
        _lab.textColor = [UIColor whiteColor];
        _lab.font = [UIFont systemFontOfSize:14];
        _lab.numberOfLines = 0;
        [self.contentView addSubview:self.lab];
        self.lab.center = self.contentView.center;
    }
    return _lab;
}
-(UIImageView *)iconImageView{
    if (!_iconImageView) {
        _iconImageView = [[UIImageView alloc] init];
        _iconImageView.frame = CGRectMake(0, 0, 30, 30);
        _iconImageView.layer.cornerRadius = 15;
        _iconImageView.layer.masksToBounds = YES;
        [self.contentView addSubview:_iconImageView];
        _iconImageView.center = self.contentView.center;
    }
    return _iconImageView;
}

- (void)setGroup:(AliyunEffectPasterGroup *)group {
    _group = group;
    self.lab.text = group.name;
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGSize labelSize = [self.lab.text boundingRectWithSize:CGSizeMake(self.lab.frame.size.width, self.lab.frame.size.height*3) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    self.lab.frame = CGRectMake(self.lab.frame.origin.x, self.lab.frame.origin.y, self.lab.frame.size.width, labelSize.height);
//    NSString *iconPath = [[[NSHomeDirectory() stringByAppendingPathComponent:[[group.pasterList firstObject] resourcePath]] stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
//    [self.iconImageView sd_setImageWithURL:[NSURL URLWithString:[group.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]] placeholderImage:[UIImage imageWithContentsOfFile:iconPath]];
    self.lab.center = self.contentView.center;
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
//    if (!_group) {
//        return;
//    }
    if (selected) {
        [self addVisualEffect];
    }else{
        self.backgroundColor = [UIColor clearColor];
        for (id view in self.subviews) {
            if ([view isKindOfClass:[UIBlurEffect class]] || [view isKindOfClass:[UIVisualEffectView class]]) {
                [view removeFromSuperview];
            }
        }
    }
}
@end
