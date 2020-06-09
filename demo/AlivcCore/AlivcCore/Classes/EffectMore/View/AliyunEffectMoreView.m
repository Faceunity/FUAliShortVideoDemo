//
//  AliyunEffectMoreView.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/3.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectMoreView.h"
#import "AliyunEffectMoreTableViewCell.h"
#import "AliyunEffectMorePreviewCell.h"
#import "AVC_ShortVideo_Config.h"
@interface AliyunEffectMoreView ()

@property (nonatomic, strong) UILabel *nameLabel;

@end

@implementation AliyunEffectMoreView

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubViews];
    }
    return self;
}


- (void)setupSubViews {
    self.backgroundColor = [UIColor clearColor];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[AlivcImage imageNamed:@"shortVideo_musicBackground"]];
    imageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self addSubview:imageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self addSubview:blurEffectView];
    
    [self setupTopViews];
    [self setupCenterView];
}

- (void)setupTopViews {
    self.backgroundColor = [UIColor clearColor];
    UIView *topView = [[UIView alloc] init];
    topView.frame = CGRectMake(0, SafeTop, ScreenWidth, SizeHeight(44));
    topView.backgroundColor = [UIColor clearColor];
    [self addSubview:topView];
    
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    backButton.frame = CGRectMake(0, 0, SizeWidth(28 + 12 + 12), CGRectGetHeight(topView.frame));
    [backButton setImage:[AliyunImage imageNamed:@"avcBackIcon"] forState:UIControlStateNormal];
    backButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    backButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:backButton];
    
    self.nameLabel = [[UILabel alloc] init];
    self.nameLabel.frame = CGRectMake(SizeWidth(112), SizeHeight(12), SizeWidth(100), SizeHeight(20));
    self.nameLabel.font = [UIFont systemFontOfSize:14.f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = NSLocalizedString(@"更多" , nil);
    [topView addSubview:self.nameLabel];
    
    UIButton *nextButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    nextButton.frame = CGRectMake(ScreenWidth - SizeWidth(44), 0, SizeWidth(44), CGRectGetHeight(topView.frame));
    [nextButton setImage:[AliyunImage imageNamed:@"resource_edit"] forState:(UIControlStateNormal)];
    [nextButton setTitleColor:[UIColor whiteColor] forState:(UIControlStateNormal)];
    nextButton.titleLabel.font = [UIFont systemFontOfSize:14.f];
    nextButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [nextButton addTarget:self action:@selector(nextButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [topView addSubview:nextButton];

}


- (void)setupCenterView {
    
    self.tableView = [[UITableView alloc] initWithFrame:(CGRectMake(0, SizeHeight(44)+SafeTop, ScreenWidth, ScreenHeight - SizeHeight(44)-SafeBottom-SafeTop)) style:(UITableViewStylePlain)];
    [self.tableView registerClass:[AliyunEffectMorePreviewCell class] forCellReuseIdentifier:EffectMorePreviewTableViewIndentifier];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = NO;
    [self addSubview:self.tableView];
    
}

- (void)setTableViewDelegates:(id<UITableViewDelegate, UITableViewDataSource>)delegate {
    
    self.tableView.delegate = delegate;
    self.tableView.dataSource = delegate;
}

- (void)setTitleWithEffectType:(NSInteger)type {
    
    NSString *title = NSLocalizedString(@"更多" , nil);
    switch (type) {
        case 1:
            title = NSLocalizedString(@"更多字体" , nil);
            break;
        case 2:
            title = NSLocalizedString(@"更多动图", nil);
            break;
        case 3:
            title = NSLocalizedString(@"更多MV" , nil);
            break;
        case 4:
            title = NSLocalizedString(@"更多滤镜" , nil);
            break;
        case 5:
            title = NSLocalizedString(@"更多音乐" , nil);
            break;
        case 6:
            title = NSLocalizedString(@"更多字幕", nil);
            break;
        case 7:
            title = NSLocalizedString(@"更多滤镜特效", nil);
            break;
        case 8:
            title = NSLocalizedString(@"更多转场", nil);
            break;
        default:
            break;
    }
    self.nameLabel.text = title;
}

- (void)backButtonAction {
    
    [self.delegate onClickBackButton];
}

- (void)nextButtonAction {
    
    [self.delegate onClickNextButton];
}


@end
