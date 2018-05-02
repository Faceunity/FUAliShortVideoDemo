

//
//  AliyunEditHeaderView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/7.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEditHeaderView.h"

@implementation AliyunEditHeaderView


- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor colorWithRed:35.0/255 green:42.0/255 blue:66.0/255 alpha:1];
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        titleLabel.center = CGPointMake(CGRectGetMidX(frame), frame.size.height/2);
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.text = NSLocalizedString(@"video_title_edit", nil);
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:titleLabel];
        
        [self buttonWithRect:CGRectMake(0, 5, 34, 34) image:@"QPSDK.bundle/back" action:@selector(backButtonClicked:)];
        [self buttonWithRect:CGRectMake(ScreenWidth - 34, 5, 34, 34) image:@"QPSDK.bundle/next" action:@selector(saveButtonClicked:)];
    }
    return self;
}

- (UIButton *)buttonWithRect:(CGRect)rect image:(NSString *)imageName action:(SEL)sel
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = rect;
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:button];
    return button;
}

- (void)backButtonClicked:(id)sender
{
    if (self.backClickBlock) {
        self.backClickBlock();
    }
}

- (void)saveButtonClicked:(id)sender
{
    if (self.saveClickBlock) {
        self.saveClickBlock();
    }
}

@end
