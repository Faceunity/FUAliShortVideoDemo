//
//  AliyunTabController.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunTabController.h"
#import "UIView+AlivcHelper.h"
#import "AliyunColorPaletteView.h"
#import "AliyunFontSelectView.h"
#import "AliyunEffectFontInfo.h"
#import "AliyunFontEffectView.h"
#import "AlivcTabbarHeaderView.h"
#import "AlivcTabbarView.h"


#define tabBar_headerView_Height 45


@interface AliyunTabController ()<AliyunColorPaletteViewDelegate,AliyunFontSelectViewDelegate,AliyunFontEffectViewDelegate,AlivcTabbarViewDelegate>

@property (nonatomic, strong) UIView *containerView;//内容view
@property (nonatomic, strong) AlivcTabbarHeaderView *headerView;//顶部headerView
@property (nonatomic, strong) AliyunColorPaletteView *colorItemView;//颜色view
@property (nonatomic, strong) AliyunFontSelectView *fontItemView;//字体view
@property (nonatomic, strong) AliyunFontEffectView *fontEffectItermView;//字体特效view
@property (nonatomic, assign) NSInteger textActionType; //默认选中字体特效
@property (nonatomic, assign) TabBarItemType selectedType;
@property (nonatomic, assign) TextActionType selectedActionType;
@end

@implementation AliyunTabController

- (void)presentTabContainerViewInSuperView:(UIView *)superView height:(CGFloat)height duration:(CGFloat)duration tabItems:(NSArray *)tabItems
{
    
    CGFloat height_s = height;
    //初始化托板view
    if (!self.containerView) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, height_s)];
        [superView addSubview:self.containerView];
        [self.containerView addSubview:self.headerView];
        self.headerView.tabbar.tabItems = tabItems;
    }
    [UIView animateWithDuration:duration delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.frame = CGRectMake(0, (ScreenHeight - height_s - CGRectGetHeight(self.headerView.bounds)), ScreenWidth, height_s + CGRectGetHeight(self.headerView.bounds));
    } completion:^(BOOL finished) {
        //防止重复添加毛玻璃效果
        [self.containerView removeVisualEffectView];
        [self.containerView addVisualEffectWithFrame:CGRectMake(0,CGRectGetMaxY(self.headerView.frame), CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame))];
    }];
}

#pragma mark - Actions -
- (void)completeButtonClicked{
    [self dismissPresentTabContainerView];
    if (self.selectedType == TabBarItemTypePasterAnimation) {
        //如果是动图添加动画
        if (self.delegate && [self.delegate respondsToSelector:@selector(pasterActionCompleteButtonClicked:)]) {
            [self.delegate pasterActionCompleteButtonClicked:self.selectedActionType];
        }
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(completeButtonClicked)]) {
            [self.delegate completeButtonClicked];
        }
    }
    
    _fontEffectItermView = nil;
}

-(void)cancelButtonClicked{
    [self dismissPresentTabContainerView];
    if (self.selectedType == TabBarItemTypePasterAnimation) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(cancelButtonClicked)]) {
        [self.delegate cancelButtonClicked];
    }
}

- (void)dismissPresentTabContainerView
{
    if (self.containerView) {
        CGRect frame = self.containerView.frame;
        frame.origin.y = ScreenHeight;
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:.2 animations:^{
            self.containerView.frame = frame;
        } completion:^(BOOL finished) {
            
            if (weakSelf.colorItemView) {
                [weakSelf.colorItemView removeFromSuperview];
                weakSelf.colorItemView = nil;
            }
            if (weakSelf.fontItemView) {
                [weakSelf.fontItemView removeFromSuperview];
                weakSelf.fontItemView = nil;
            }
            if (weakSelf.headerView) {
                [weakSelf.headerView removeFromSuperview];
                weakSelf.headerView = nil;
            }

            if (weakSelf.containerView) {
                [weakSelf.containerView removeFromSuperview];
                weakSelf.containerView = nil;
            }
            
            if (weakSelf.fontEffectItermView) {
                [weakSelf.fontEffectItermView removeFromSuperview];
                weakSelf.fontEffectItermView =nil;
            }
        }];
    } 
}

#pragma mark - AliyunColorItemViewDelegate 字幕颜色 -

- (void)textColorChanged:(AliyunColor *)color
{
    [self.delegate textColorChanged:color];
}
- (void)clearStrokeColor
{
    if (self.delegate &&[self.delegate respondsToSelector:@selector(textStrokeColorClear)]) {
        [self.delegate textStrokeColorClear];
    }
}

#pragma mark - AliyunFontItemViewDelegate 字幕字体 -

- (void)onSelectFontWithFontInfo:(AliyunEffectFontInfo *)fontInfo {
    [self.delegate textFontChanged:fontInfo.fontName];
}

#pragma mark - AliyunFontEffectViewDelegate 字幕动画 -
-(void)onSelectActionType:(TextActionType)actionType{
    self.selectedActionType = actionType;
    if (self.delegate && [self.delegate respondsToSelector:@selector(textActionType:)]) {
        [self.delegate textActionType:actionType];
    }else{
        NSLog(@"#Wrong:请实现textActionType:代理方法");
    }
}

#pragma mark - AlivcTabbarViewDelegate tabbar代理事件 -
-(void)alivcTabbarViewDidSelectedType:(TabBarItemType)type{
    self.selectedType = type;
    switch (type) {
        case TabBarItemTypeKeboard:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardShouldAppear)]) {
                [self.delegate keyboardShouldAppear];
            }
            [self.colorItemView hiddenAnimation:YES completion:nil];
            [self.fontItemView hiddenAnimation:YES completion:nil];
            [self.fontEffectItermView hiddenAnimation:YES completion:nil];
        }
            break;
        case TabBarItemTypeColor:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardShouldHidden)]) {
                [self.delegate keyboardShouldHidden];
            }
            [self.colorItemView showInView:self.containerView animation:YES completion:nil];
            [self.fontItemView hiddenAnimation:YES completion:nil];
            [self.fontEffectItermView hiddenAnimation:YES completion:nil];
        }
            break;
        case TabBarItemTypeFont:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardShouldHidden)]) {
                [self.delegate keyboardShouldHidden];
            }
            [self.fontItemView showInView:self.containerView animation:YES completion:nil];
            [self.colorItemView hiddenAnimation:YES completion:nil];
            [self.fontEffectItermView hiddenAnimation:YES completion:nil];
        }
            break;
        case TabBarItemTypeAnimation:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardShouldHidden)]) {
                [self.delegate keyboardShouldHidden];
            }
            [self.fontEffectItermView showInView:self.containerView animation:YES completion:nil];
            [self.fontItemView hiddenAnimation:YES completion:nil];
            [self.colorItemView hiddenAnimation:YES completion:nil];
        }
            break;
        case TabBarItemTypePasterAnimation:
        {
            if (self.delegate && [self.delegate respondsToSelector:@selector(keyboardShouldHidden)]) {
                [self.delegate keyboardShouldHidden];
            }
            [self.fontEffectItermView showInView:self.containerView animation:YES completion:nil];
            [self.fontItemView hiddenAnimation:YES completion:nil];
            [self.colorItemView hiddenAnimation:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - Getter -


- (AliyunColorPaletteView *)colorItemView {
    if (!_colorItemView) {
        _colorItemView = [[AliyunColorPaletteView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.bounds), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetHeight(self.headerView.bounds))];
        _colorItemView.delegate = self;
    }
    return _colorItemView;
}

- (AliyunFontSelectView *)fontItemView {
    if (!_fontItemView) {
        _fontItemView = [[AliyunFontSelectView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.bounds), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetHeight(self.headerView.bounds))];
        _fontItemView.delegate = self;
    }
    return _fontItemView;
}

- (AliyunFontEffectView *)fontEffectItermView {
    if (!_fontEffectItermView) {
        _fontEffectItermView = [[AliyunFontEffectView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.headerView.bounds), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetHeight(self.headerView.bounds))];
        _fontEffectItermView.delegate = self;
    }
     [_fontEffectItermView setDefaultSelectItem:_textActionType];
    return _fontEffectItermView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[AlivcTabbarHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, tabBar_headerView_Height)];
        _headerView.tabbar.delegate = self;
        __weak typeof(self)weakSelf = self;
        [_headerView bindingApplyOnClick:^{
            [weakSelf completeButtonClicked];
        } cancelOnClick:^{
            [weakSelf cancelButtonClicked];
        }];
        //增加毛玻璃效果
        [_headerView addVisualEffect];
    }
    return _headerView;
}

-(void)setFontEffectDefault:(NSInteger)textEffectType{
    _textActionType = textEffectType;
}

@end
