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

#import "AliyunCaptionFlowerView.h"
#import "AliyunCaptionBubbleView.h"
#import  "AliyunCaptionStyleView.h"
#import "AliyunCaptionTextAlignmentView.h"

#import "UIView+OPLayout.h"



#define tabBar_headerView_Height 45


@interface AliyunTabController ()<AliyunColorPaletteViewDelegate,AliyunFontSelectViewDelegate,AliyunFontEffectViewDelegate,AlivcTabbarViewDelegate,AliyunCaptionStyleViewDelegate,AliyunCaptionFlowerViewDelegate>


@property (nonatomic, strong) UIView *containerView;//内容view
@property (nonatomic, strong) AlivcTabbarHeaderView *headerView;//顶部headerView
@property (nonatomic, strong) AliyunColorPaletteView *colorItemView;//颜色view
@property (nonatomic, strong) AliyunFontSelectView *fontItemView;//字体view
@property (nonatomic, strong) AliyunFontEffectView *fontEffectItermView;//字体特效view

@property (nonatomic, strong) AliyunCaptionFlowerView *flowerView;//字体view
@property (nonatomic, strong) AliyunCaptionStyleView *styleView;//字体特效view
@property (nonatomic, strong) AliyunCaptionBubbleView *bubleView;//字体特效view




@property (nonatomic, assign) NSInteger textActionType; //默认选中字体特效
@property (nonatomic, assign) TabBarItemType selectedType;
@property (nonatomic, assign) TextActionType selectedActionType;

@property (nonatomic, weak)  AlivcTabbarBaseView *currentSeletedView;

@end

@implementation AliyunTabController


-(instancetype)initWithSuperView:(UIView *)superView needInputView:(BOOL)needInputView
{
    self = [super init];
    if (self) {
        self.containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        [self.containerView addSubview:self.textInputView];
        if (!needInputView) {
            self.textInputView.op_height = 0.f;
            self.textInputView.hidden = YES;
        }
        [self.containerView addSubview:self.headerView];
        
        [superView addSubview:self.containerView];
        
        
    }
    return self;
}


- (void)presentTabContainerViewInSuperView:(UIView *)superView height:(CGFloat)height duration:(CGFloat)duration tabItems:(NSArray *)tabItems
{
    self.headerView.tabbar.tabItems = tabItems;
    CGFloat contentHegiht = height + CGRectGetHeight(self.headerView.bounds) + CGRectGetHeight(self.textInputView.bounds);
    
    if (@available(iOS 11.0, *)) {
        self.containerView.insetsLayoutMarginsFromSafeArea = false;
    }
    
    [superView addSubview:self.containerView];

    [UIView animateWithDuration:duration delay:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.containerView.frame = CGRectMake(0, (ScreenHeight - contentHegiht), ScreenWidth, contentHegiht);
    } completion:^(BOOL finished) {
        
        [self.containerView removeVisualEffectView];
        [self.containerView addVisualEffectWithFrame:CGRectMake(0,CGRectGetMaxY(self.headerView.frame), CGRectGetWidth(self.containerView.frame), CGRectGetHeight(self.containerView.frame))];
        
    }];
}

- (AliyunPasterTextInputView *)textInputView
{
    if (!_textInputView) {
        CGFloat height = 44;
        _textInputView = [[AliyunPasterTextInputView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, height)];
        _textInputView.textView.textAlignment = NSTextAlignmentLeft;
    }
    
    return _textInputView;
}

#pragma mark - Actions -
- (void)completeButtonClicked{
    [self dismissPresentTabContainerView];

    if (self.delegate && [self.delegate respondsToSelector:@selector(tabControllerCompleteButtonClicked)]) {
        [self.delegate tabControllerCompleteButtonClicked];
    }
}

-(void)cancelButtonClicked{
    [self dismissPresentTabContainerView];
    if (self.selectedType == TabBarItemTypePasterAnimation) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(tabControllerCancelButtonClicked)]) {
        [self.delegate tabControllerCancelButtonClicked];
    }
}

- (void)dismissPresentTabContainerView
{
    [self.textInputView shouldHiddenKeyboard];
    if (self.containerView) {
        CGRect frame = self.containerView.frame;
        frame.origin.y = ScreenHeight;
        __weak typeof(self)weakSelf = self;
        [UIView animateWithDuration:.2 animations:^{
            self.containerView.frame = frame;
        } completion:^(BOOL finished) {
        }];
    }
}

#pragma mark - AliyunFontEffectViewDelegate 字幕动画 -
-(void)onSelectActionType:(TextActionType)actionType{
    self.selectedActionType = actionType;
}

#pragma mark - AlivcTabbarViewDelegate tabbar代理事件 -
-(void)alivcTabbarViewDidSelectedType:(TabBarItemType)type{
    
    if (self.selectedType == type) {
        return;
    }
    
    self.selectedType = type;
    
    if (self.selectedType != TabBarItemTypePasterAnimation && [self.delegate respondsToSelector:@selector(tabControllerCaptionSeletedTabChanged:)]) {
        [self.delegate tabControllerCaptionSeletedTabChanged:self.selectedType];
    }

    switch (type) {
        case TabBarItemTypeKeboard:
        {
            [self.textInputView shouldAppearKeyboard];
            [self.currentSeletedView hiddenAnimation:YES completion:nil];
            self.currentSeletedView = nil;
        }
            break;
            
        case TabBarItemTypeFlower:
        {
            [self.textInputView shouldHiddenKeyboard];
            [self.currentSeletedView hiddenAnimation:YES completion:nil];
            self.currentSeletedView = self.flowerView;
            [self.currentSeletedView showInView:self.containerView animation:YES completion:nil];

        }
            break;
        case TabBarItemTypeBubble:
        {
        
            [self.textInputView shouldHiddenKeyboard];
            [self.currentSeletedView hiddenAnimation:YES completion:nil];
            self.currentSeletedView = self.bubleView;
            [self.currentSeletedView showInView:self.containerView animation:YES completion:nil];
            
        }
            break;
            
        case TabBarItemTypeStyle:
        {
            [self.textInputView shouldHiddenKeyboard];

            [self.currentSeletedView hiddenAnimation:YES completion:nil];
            self.currentSeletedView = self.styleView;
            [self.currentSeletedView showInView:self.containerView animation:YES completion:nil];

            
        }
            break;

        case TabBarItemTypeColor:
        {
            [self.textInputView shouldHiddenKeyboard];

            
            [self.currentSeletedView hiddenAnimation:YES completion:nil];
            self.currentSeletedView = self.colorItemView;
            [self.currentSeletedView showInView:self.containerView animation:YES completion:nil];
        }
            break;
        case TabBarItemTypeFont:
        {
            [self.textInputView shouldHiddenKeyboard];

            
            [self.currentSeletedView hiddenAnimation:YES completion:nil];
            self.currentSeletedView = self.fontItemView;
            [self.currentSeletedView showInView:self.containerView animation:YES completion:nil];
        }
            break;
        case TabBarItemTypeAnimation:
        {
            [self.textInputView shouldHiddenKeyboard];

            
            [self.currentSeletedView hiddenAnimation:YES completion:nil];
            self.currentSeletedView = self.fontEffectItermView;
            [self.fontEffectItermView setDefaultSelectItem:self.selectedActionType];
            [self.currentSeletedView showInView:self.containerView animation:YES completion:nil];
        }
            break;
        case TabBarItemTypePasterAnimation:
        {
            [self.textInputView shouldHiddenKeyboard];

            
            [self.currentSeletedView hiddenAnimation:YES completion:nil];
            self.currentSeletedView = self.fontEffectItermView;
            [self.currentSeletedView showInView:self.containerView animation:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}


#pragma mark - AliyunCaptionBubbleViewDelegate -

- (void)captionBubbleViewDidSeleted:(AliyunEffectPasterInfo *)info
{
    if ([self.delegate respondsToSelector:@selector(tabControllerCaptionBubbleViewDidSeleted:fontId:)]) {
        [self.delegate tabControllerCaptionBubbleViewDidSeleted:info.resourcePath fontId:[info.fontId integerValue]];
    }
}

#pragma mark - Getter -

- (AliyunCaptionBubbleView *)bubleView
{
    if (!_bubleView) {
        _bubleView = [[AliyunCaptionBubbleView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetMaxY(self.headerView.frame))];
        _bubleView.delegate = self;
    }
    return _bubleView;
}


- (AliyunCaptionFlowerView *)flowerView
{
    if (!_flowerView) {
        _flowerView = [[AliyunCaptionFlowerView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetMaxY(self.headerView.frame))];
        _flowerView.delegate = self;
    }
    return _flowerView;
}

- (AliyunCaptionStyleView *)styleView
{
    if (!_styleView) {
        _styleView = [[AliyunCaptionStyleView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetMaxY(self.headerView.frame))];
        _styleView.delegate = self;
    }
    return _styleView;
}

- (AliyunColorPaletteView *)colorItemView {
    if (!_colorItemView) {
        _colorItemView = [[AliyunColorPaletteView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetMaxY(self.headerView.frame))];
        _colorItemView.delegate = self;
    }
    return _colorItemView;
}

- (AliyunFontSelectView *)fontItemView {
    if (!_fontItemView) {
        _fontItemView = [[AliyunFontSelectView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetMaxY(self.headerView.frame))];
        _fontItemView.delegate = self;
    }
    return _fontItemView;
}

- (AliyunFontEffectView *)fontEffectItermView {
    if (!_fontEffectItermView) {
        _fontEffectItermView = [[AliyunFontEffectView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), ScreenWidth, CGRectGetHeight(self.containerView.bounds) - CGRectGetMaxY(self.headerView.frame))];
        _fontEffectItermView.delegate = self;
    }
     [_fontEffectItermView setDefaultSelectItem:_textActionType];
    return _fontEffectItermView;
}

- (UIView *)headerView{
    if (!_headerView) {
        _headerView = [[AlivcTabbarHeaderView alloc]initWithFrame:CGRectMake(0, self.textInputView.op_height, ScreenWidth, tabBar_headerView_Height)];
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
    _selectedActionType = textEffectType;
}

#pragma mark - AliyunCaptionStyleViewDelegate -

- (void)captionStyleViewDidChangeColor:(AliyunColor *)color
{  
    [self.delegate tabControllerTextAndStrokeColor:color];

}

- (void)captionStyleViewDidChangeStrokeWidth:(CGFloat)width
{
    [self.delegate tabControllerStrokeWidth:width];
}

- (void)captionStyleViewDidChangeFont:(AliyunEffectFontInfo *)font faceType:(int)faceType
{
    [self.delegate tabControllerFontName:font.fontName faceType:faceType];
}

- (void)captionStyleViewDidChangeShadow:(UIColor *)shadowColor offset:(UIOffset)offset
{
    [self.delegate tabControllerShadowColor:shadowColor offset:offset];
}

- (void)captionTextAlignmentSelected:(NSInteger)type
{
    [self.delegate captionTextAlignmentSelected:type];
}


#pragma mark - AliyunCaptionFlowerViewDelegate -

- (void)captionFlowerViewDidSeletedFlowerPath:(NSString *)path
{
    [self.delegate tabControllerFlowerDidSeleted:path];
}

@end
