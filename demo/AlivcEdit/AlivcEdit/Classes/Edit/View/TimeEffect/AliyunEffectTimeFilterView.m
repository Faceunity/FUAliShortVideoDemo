//
//  AliyunEffectTimeFilterView.m
//  qusdk
//
//  Created by Vienta on 2018/2/26.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectTimeFilterView.h"
#import "UIView+AlivcHelper.h"
#import "AliyunTimelineView.h"
#import "AlivcEditBottomHeaderView.h"
#import "NSString+AlivcHelper.h"
@interface AliyunEffectTimeFilterView()

/**
 下选中的按钮
 */
@property(nonatomic, weak) UIButton *selectButton;

/**
 提示语
 */
@property(nonatomic,weak) UILabel *tipLabel;


/**
 应用时间特效按钮
 */
@property(nonatomic,weak) UIButton *applyButton;

/**
 取消时间特效按钮
 */
@property(nonatomic,weak) UIButton *noApplyButton;
/**
 占位view
 */
@property (nonatomic, strong) UIView *timeLinePalletView;
/**
 首次提醒按钮
 */
@property(nonatomic,weak) UIButton *firstTipButton;

/**
 保存状态的button
 */
@property(nonatomic,strong) UIButton *storeButton;

/**
 无效果按钮
 */
@property(nonatomic,strong) UIButton *noneButton;

/**
 无效果Label
 */
@property(nonatomic,strong) UILabel  *noneLabel;

/**
 慢动作按钮
 */
@property(nonatomic,strong) UIButton *slowButton;

/**
 慢动作Label
 */
@property(nonatomic,strong) UILabel  *slowLabel;

/**
 加速按钮
 */
@property(nonatomic,strong) UIButton *fastButton;

/**
 加速Label
 */
@property(nonatomic,strong) UILabel  *fastLabel;

/**
 倒放按钮
 */
@property(nonatomic,strong) UIButton *backRunButton;

/**
 倒放Label
 */
@property(nonatomic,strong) UILabel  *backRunLabel;
/**
 反复按钮
 */
@property(nonatomic,strong) UIButton *repeatButton;
/**
 反复Label
*/
@property(nonatomic,strong) UILabel  *repeatLabel;
@end

@implementation AliyunEffectTimeFilterView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        [self addSubViews];
    }
    return self;
}

/**
 添加子控件
 */
- (void)addSubViews {
    [self addSubview:self.timeLinePalletView];
    [self addVisualEffect];
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 117, 250, 12)];
    tipLabel.text = [@"点击添加效果" localString];
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = [UIColor whiteColor];
    [self addSubview:tipLabel];
    self.tipLabel = tipLabel;
    
    AlivcEditBottomHeaderView *headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 45)];
    [headerView setTitle:[@"变速" localString] icon:[AlivcImage imageNamed:@"shortVideo_edit_timeFliter_nameButton"]];
    [self addSubview:headerView];
    __weak typeof(self)weakSelf = self;
    [headerView bindingApplyOnClick:^{
        [weakSelf apply];
    } cancelOnClick:^{
        [weakSelf noApply];
    }];
    
    _noneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _slowButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _fastButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _repeatButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _backRunButton = [UIButton buttonWithType:UIButtonTypeCustom];
    
    NSArray *buttons = @[_noneButton, _repeatButton, _slowButton, _fastButton, _backRunButton];
    NSArray *buttonNormalImages = @[@"transition_null_Nor",
                                    @"shortVideo_edit_timeFliter_repeat",
                                     @"shortVideo_edit_timeFliter_slow",
                                     @"shortVideo_edit_timeFliter_fast",
                                     @"shortVideo_edit_timeFliter_backRun"];
    
    
    NSArray *buttonActions = @[@"noneButtonClicked:",
                               @"repeatButtonClicked:",
                               @"slowButtonClicked:",
                               @"fastButtonClicked:",
                               @"backrunButtonClicked:"];
    
    float dlt = (ScreenWidth - 40 - 50 * 5) / 4;
    float centerY = 160;
    
    for (int i = 0; i < [buttons count]; i++) {
        UIButton *btn = buttons[i];
        btn.bounds = CGRectMake(0, 0, 50, 50);
        btn.center = CGPointMake(45+i*(50+dlt), centerY);
        btn.layer.masksToBounds = YES;
        [btn setExclusiveTouch:YES];
        btn.layer.cornerRadius = 25;
        [btn setExclusiveTouch:YES];
        [btn setImage:[AlivcImage imageNamed:buttonNormalImages[i]] forState:UIControlStateNormal];
        [btn setImage:[AlivcImage imageNamed:@"shortVideo_edit_affirm"] forState:UIControlStateSelected];
        btn.backgroundColor = rgba(255, 255, 255, 0.2);
        SEL action = NSSelectorFromString(buttonActions[i]);
        [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        if (i == 0) {
            btn.selected = YES;
            btn.backgroundColor = AlivcOxRGB(0x00c1de);
            self.selectButton = btn;
        }
    }
    
    _noneLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    _slowLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    _fastLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    _repeatLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    _backRunLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 60, 20)];
    float labelCenterY = centerY + 35;
    
    NSArray *labels = @[_noneLabel, _slowLabel, _fastLabel, _repeatLabel, _backRunLabel];
    NSArray *labelTitles = @[[@"无效果" localString], [@"反复" localString], [@"慢动作" localString], [@"加速" localString], [@"倒放" localString]];
    for (int i = 0; i < [labels count]; i++) {
        UILabel *label = labels[i];
        label.center = CGPointMake(45+i*(50+dlt), labelCenterY);
        [label setText:labelTitles[i]];
        [label setTextAlignment:NSTextAlignmentCenter];
        [label setTextColor:AlivcOxRGB(0xc3c5c6)];
        [label setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:label];
    }
    UIButton *firstTip = [[UIButton alloc] initWithFrame:CGRectMake(20, 96, 57.0 + (50+dlt), 35)];
    [firstTip setTitle:[@"点击可添加效果" localString]forState:UIControlStateNormal];
    firstTip.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 8, 0);
    firstTip.titleLabel.font = [UIFont systemFontOfSize:14];
    [firstTip setBackgroundImage:[self resizableImage:@"shortVideo_edit_firstTip"]  forState:UIControlStateNormal];
    firstTip.hidden = YES;
    [firstTip addTarget:self action:@selector(removeFirstTip) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:firstTip];
    self.firstTipButton = firstTip;
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"timeFilterFirst"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"timeFilterFirst"];
        self.firstTipButton.hidden = NO;
        self.tipLabel.hidden = YES;
    }else{
        self.firstTipButton.hidden = YES;
        self.tipLabel.hidden = NO;
    }
}

/**
 去除首次提醒，显示正常提醒
 */
- (void)removeFirstTip{
    self.tipLabel.hidden = NO;
    self.firstTipButton.hidden = YES;
}
/**
 从中间拉伸图片，不影响边缘效果
 
 @param name 图片名称
 @return 拉伸好的图片
 */
- (UIImage *)resizableImage:(NSString *)name
{
    UIImage *image = [AlivcImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}


/**
 点击应用的触发方法
 */
- (void)apply{
    self.storeButton = self.selectButton;
    if (_delegate) {
        [self removeFirstTip];
        [_delegate applyTimeFilterButtonClick];
    }
}

/**
 点击取消的触发方法
 */
- (void)noApply{
    if (_delegate) {
        if (self.storeButton) {
            [self buttonSelected:self.storeButton];
        }else{
            [self buttonSelected:_noneButton];
        }
        [_delegate noApplyTimeFilterButtonClick];
    }
}

/**
 点击无效果的触发方法

 @param sender 无效果按钮
 */
- (void)noneButtonClicked:(id)sender
{
    [_delegate didSelectNone];
    [self buttonSelected:sender];
}


/**
 点击慢动作按钮的触发方法

 @param sender 慢动作按钮
 */
- (void)slowButtonClicked:(id)sender
{
    [self buttonSelected:sender];
    [_delegate didSelectMomentSlow];
    
}


/**
 点击加速按钮的触发方法

 @param sender 加速按钮
 */
- (void)fastButtonClicked:(id)sender
{
    
    [self buttonSelected:sender];
    
    [_delegate didSelectMomentFast];
    
}


/**
 点击重复按钮的触发方法

 @param sender 重复按钮
 */
- (void)repeatButtonClicked:(id)sender
{
    [self buttonSelected:sender];
    [_delegate didSelectRepeat];
}


/**
 点击倒放按钮的触发方法

 @param sender 倒放按钮
 */
- (void)backrunButtonClicked:(id)sender
{
    if (self.selectButton == sender) {
        return;
    }
    UIButton *lastBtn = self.selectButton;
    [self buttonSelected:sender];
    [_delegate didSelectInvert:^(BOOL success) {
        if (!success) {
            [self buttonSelected:lastBtn];
        }
    }];
}

/**
 功能按钮的点击处理

 @param button 功能按钮
 */
- (void)buttonSelected:(UIButton *)button {
   
    self.selectButton.selected = NO;
    self.selectButton.backgroundColor = rgba(255, 255, 255, 0.2);
    self.selectButton = button;
    self.selectButton.selected = YES;
    self.selectButton.backgroundColor = AlivcOxRGB(0x00c1de);
    [self removeFirstTip];
}


/**
 重写timelineView的set方法

 @param timelineView 进度条
 */
-(void)setTimelineView:(AliyunTimelineView *)timelineView{
    _timelineView = timelineView;
    if (_timelineView) {
        _timelineView.frame = CGRectMake(0, 15, CGRectGetWidth(_timeLinePalletView.frame), CGRectGetHeight(_timeLinePalletView.frame)-10);
        _timelineView.backgroundColor = self.backgroundColor;
        [_timeLinePalletView addSubview:_timelineView];
    }
}


/**
 占位view的懒加载

 @return 占位view
 */
- (UIView *)timeLinePalletView{
    if (!_timeLinePalletView) {
        _timeLinePalletView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, ScreenWidth, 40)];
        _timeLinePalletView.backgroundColor = [UIColor clearColor];
        if (_timelineView) {
            _timelineView.frame = CGRectMake(0, 5, CGRectGetWidth(_timeLinePalletView.frame), CGRectGetHeight(_timeLinePalletView.frame)-10);
            _timelineView.backgroundColor = self.backgroundColor;
            [_timeLinePalletView addSubview:_timelineView];
        }
    }
    return _timeLinePalletView;
}
@end
