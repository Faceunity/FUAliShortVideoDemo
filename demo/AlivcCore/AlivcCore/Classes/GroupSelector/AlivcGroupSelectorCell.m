//
//  AlivcGroupSelectorCell.m
//  AFNetworking
//
//  Created by lileilei on 2020/1/3.
//

#import "AlivcGroupSelectorCell.h"
#import "UIView+AlivcHelper.h"
#import "AliyunEffectInfo.h"
#import "NSString+AlivcHelper.h"

@implementation AlivcGroupSelectorCell
- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (void)setupSubViews {
    self.backgroundColor = [UIColor clearColor];
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

- (void)setGroup:(AliyunEffectInfo *)group {
    _group = group;
    self.lab.text = [group.name localString];
    NSDictionary *attribute = @{NSFontAttributeName: [UIFont systemFontOfSize:14]};
    CGSize labelSize = [self.lab.text boundingRectWithSize:CGSizeMake(self.lab.frame.size.width, self.lab.frame.size.height*3) options: NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:attribute context:nil].size;
    self.lab.frame = CGRectMake(self.lab.frame.origin.x, self.lab.frame.origin.y, self.lab.frame.size.width, labelSize.height);
    self.lab.center = self.contentView.center;
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
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
