//
//  AliyunCompositionPickCell.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/9.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCompositionPickCell.h"
#import "AVC_ShortVideo_Config.h"
@implementation AliyunCompositionPickCell
-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup { 
    self.imageView = [[UIImageView alloc] initWithFrame:self.bounds];
    self.imageView.contentMode = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    [self addSubview:self.imageView];
    self.labelDuration = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
    self.labelDuration.textColor = [UIColor whiteColor];
    self.labelDuration.textAlignment = NSTextAlignmentRight;
    self.labelDuration.font = [UIFont systemFontOfSize:12.0];
    [self addSubview:self.labelDuration];
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.closeButton setBackgroundImage:[AliyunImage imageNamed:@"import_delete"] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];
}

-(void)layoutSubviews {
    [super layoutSubviews];
    CGFloat border = 10;
    CGFloat width = CGRectGetWidth(self.frame);
    CGFloat height = CGRectGetHeight(self.frame);
    self.imageView.frame = CGRectMake(border, border, width-2*border, height-2*border);
    self.labelDuration.frame = CGRectMake(border, height-border-10, width-2*border, 10);
    self.closeButton.frame = CGRectMake(width-2.5*border, 0, 2.5*border, 2.5*border);
}

- (void)closeButtonClicked {
    [_delegate pickCellWillClose:self];
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    UITouch * touch = [touches anyObject];
    //返回触摸点所在视图中的坐标
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(CGRectInset(self.closeButton.frame, -15, -15),point)) {
        if ([self.delegate respondsToSelector:@selector(pickCellWillClose:)]) {
            [self.delegate pickCellWillClose:self];
        }
    }else{
        [super touchesBegan:touches withEvent:event];
    }
}

@end
