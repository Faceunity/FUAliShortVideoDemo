//
//  AlivcRollCaptionFontCell.m
//  AlivcEdit
//
//  Created by aliyun on 2021/3/10.
//

#import "AlivcRollCaptionFontCell.h"

@implementation AlivcRollCaptionFontCell

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

-(void)setupSubviews{
    _fontLab = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 60, 60)];
    _fontLab.numberOfLines = 0;
    _fontLab.backgroundColor = [UIColor clearColor];
    [_fontLab setTextColor:[UIColor whiteColor]];
    [_fontLab setTextAlignment:NSTextAlignmentCenter];
    _fontLab.layer.cornerRadius = 3;
    _fontLab.layer.masksToBounds = YES;
    _fontLab.layer.borderWidth = 1;
    _fontLab.layer.borderColor = [UIColor whiteColor].CGColor;
    [self.contentView addSubview:_fontLab];
    _fontLab.center = self.contentView.center;
}

@end
