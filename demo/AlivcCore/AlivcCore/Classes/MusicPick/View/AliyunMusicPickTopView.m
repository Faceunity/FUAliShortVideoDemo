//
//  AliyunMusicPickTopView.m
//  qusdk
//
//  Created by Worthy on 2017/6/8.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunMusicPickTopView.h"

@implementation AliyunMusicPickTopView

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setupTopViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupTopViews];
    }
    return self;
}



- (void)setupTopViews {
    self.backgroundColor = [UIColor clearColor];
    
    UIView *topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, 0, ScreenWidth, 44);
    [self addSubview:topView];
    
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backButton.frame = CGRectMake(0, 0, SizeWidth(28 + 12 + 12), CGRectGetHeight(topView.frame));
    [backButton setImage:[AlivcImage imageNamed:@"avcBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:backButton];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.frame = CGRectMake(SizeWidth(132), 0, SizeWidth(56), 44);
    self.nameLabel.font = [UIFont systemFontOfSize:15.f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = NSLocalizedString(@"音乐", nil);
    [topView addSubview:self.nameLabel];
    
    UIButton *nextButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    nextButton.frame = CGRectMake(ScreenWidth - SizeWidth(44), 0, SizeWidth(44), CGRectGetHeight(topView.frame));
    [nextButton setImage:[AlivcImage imageNamed:@"shortVideo_edit_affirm"] forState:UIControlStateNormal];
    [nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:nextButton];
    
}

- (void)backButtonAction {
    [self.delegate cancelButtonClicked];
}

- (void)nextButtonAction {
    [self.delegate finishButtonClicked];
}
@end
