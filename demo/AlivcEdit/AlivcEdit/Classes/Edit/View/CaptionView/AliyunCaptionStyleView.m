//
//  AliyunCaptionStyleView.m
//  AlivcCommon
//
//  Created by mengyehao on 2021/5/27.
//

#import "AliyunCaptionStyleView.h"
#import "UIView+OPLayout.h"
#import "AliyunFontSelectView.h"
#import "AliyunFontEffectView.h"
#import "AliyunCaptionShadowView.h"
#import "AliyunColorPaletteView.h"
#import "AliyunCaptionTextAlignmentView.h"
#import "AlivcMacro.h"


typedef NS_ENUM(NSUInteger, AliyunCaptionStyleViewItemType) {
    AliyunCaptionStyleViewItemTypeColor,
    AliyunCaptionStyleViewItemTypeFont,
    AliyunCaptionStyleViewItemTypeShadow,
    AliyunCaptionStyleViewItemTypeTextAlignment,
};

@interface AliyunCaptionTitle : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, assign) AliyunCaptionStyleViewItemType type;
@end

@implementation AliyunCaptionTitle
@end

@interface AliyunCaptionStyleView()<UIScrollViewDelegate,AliyunCaptionTextAlignmentViewDelegate,AliyunCaptionShadowViewDelegate,AliyunFontSelectViewDelegate,AliyunColorPaletteViewDelegate>

@property (nonatomic, strong) UIScrollView *titleScrollView;
@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic ,copy) NSArray *titles;

@property (nonatomic, strong) AliyunColorPaletteView *colorItemView;//颜色view
@property (nonatomic, strong) AliyunFontSelectView *fontItemView;//字体view
@property (nonatomic, strong) AliyunCaptionShadowView *strokeView;//字体特效view
@property (nonatomic, strong) AliyunCaptionTextAlignmentView *textAlignmentView;//排版

@property (nonatomic, weak) UIButton *seletedButton;




@end

@implementation AliyunCaptionStyleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.scrollView];
        [self.bootomView addSubview:self.titleScrollView];
        
        self.bootomView.op_top = self.contentView.op_top;
        self.contentView.op_top = self.bootomView.op_bottom;
        self.bootomLine.hidden = YES;
        
        [self updateUI];
    }
    return self;
}

- (NSArray *)titles
{
    if (!_titles) {
        
        AliyunCaptionTitle *title1 = [AliyunCaptionTitle new];
        title1.type = AliyunCaptionStyleViewItemTypeColor;
        title1.title = @"颜色";
        
        AliyunCaptionTitle *title2 = [AliyunCaptionTitle new];
        title2.type = AliyunCaptionStyleViewItemTypeFont;
        title2.title = @"字体";
        
        AliyunCaptionTitle *title3 = [AliyunCaptionTitle new];
        title3.type = AliyunCaptionStyleViewItemTypeShadow;
        title3.title = @"阴影";
        
        AliyunCaptionTitle *title4 = [AliyunCaptionTitle new];
        title4.type = AliyunCaptionStyleViewItemTypeTextAlignment;
        title4.title = @"排版";
        
        _titles = @[title1,title2,title3,title4];
    }
    return _titles;
}

- (UIScrollView *)scrollView
{
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.contentView.bounds];
        _scrollView.contentSize = CGSizeMake(ScreenWidth * 4, _scrollView.op_height);
        _scrollView.pagingEnabled = YES;
        _scrollView.scrollEnabled = NO;
        _scrollView.bounces = NO;
        _scrollView.delegate = self;
    }
    
    return _scrollView;
}

- (UIScrollView *)titleScrollView
{
    if (!_titleScrollView) {
        _titleScrollView = [[UIScrollView alloc] initWithFrame:self.bootomView.bounds];

    }
    
    return _titleScrollView;
}

- (void)updateUI
{
    CGFloat padding = 20;
    CGFloat buttonWidth = 70;
    CGFloat buttonheight = self.titleScrollView.op_height;

    for (AliyunCaptionTitle *model in self.titles) {
        UIButton *button = [[UIButton alloc ] init];
        [self.titleScrollView addSubview:button];
        button.frame = CGRectMake(padding + model.type * (buttonWidth + padding), 0, buttonWidth, buttonheight);
        button.tag = model.type;
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button setTitle:model.title forState:UIControlStateNormal];
        
        [button setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        
        [button setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];


        [button addTarget:self action:@selector(onButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        
        switch (model.type) {
            case AliyunCaptionStyleViewItemTypeColor:
            {
                [button sendActionsForControlEvents:UIControlEventTouchUpInside];
                [self.scrollView addSubview:self.colorItemView];
            }
                break;
            case AliyunCaptionStyleViewItemTypeFont:
            {
                [self.scrollView addSubview:self.fontItemView];

            }
                break;
            case AliyunCaptionStyleViewItemTypeShadow:
            {
                [self.scrollView addSubview:self.strokeView];

            }
                break;
            case AliyunCaptionStyleViewItemTypeTextAlignment:
            {
                [self.scrollView addSubview:self.textAlignmentView];

            }
                break;

        }
    }
}

- (void)onButtonClick:(UIButton *)button
{
    [self.seletedButton setSelected:NO];
    self.seletedButton = button;
    [self.seletedButton setSelected:YES];
    
    [self.scrollView scrollRectToVisible:CGRectMake(ScreenWidth * button.tag, 0, ScreenWidth, self.scrollView.op_height) animated:YES];
}



- (AliyunFontSelectView *)fontItemView {
    if (!_fontItemView) {
        _fontItemView = [[AliyunFontSelectView alloc] initWithFrame:CGRectMake(AliyunCaptionStyleViewItemTypeFont * ScreenWidth, 0, ScreenWidth, self.scrollView.op_height)];
        _fontItemView.delegate = self;
    }
    return _fontItemView;
}


- (AliyunCaptionShadowView *)strokeView
{
    if (!_strokeView) {
        _strokeView = [[AliyunCaptionShadowView alloc] initWithFrame:CGRectMake(AliyunCaptionStyleViewItemTypeShadow * ScreenWidth, 0, ScreenWidth, self.scrollView.op_height)];
        _strokeView.delegate = self;
    }
    return _strokeView;
}

- (AliyunColorPaletteView *)colorItemView {
    if (!_colorItemView) {
        _colorItemView = [[AliyunColorPaletteView alloc] initWithFrame:CGRectMake(AliyunCaptionStyleViewItemTypeColor * ScreenWidth, 0, ScreenWidth,self.scrollView.op_height)];
        _colorItemView.delegate = self;
    }
    return _colorItemView;
}

- (AliyunCaptionTextAlignmentView *)textAlignmentView{
    if (!_textAlignmentView) {
        _textAlignmentView = [[AliyunCaptionTextAlignmentView alloc] initWithFrame:CGRectMake(AliyunCaptionStyleViewItemTypeTextAlignment * ScreenWidth, 0, ScreenWidth,self.scrollView.op_height)];
        _textAlignmentView.delegate = self;
    }
    return _textAlignmentView;
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    int index = scrollView.contentOffset.x / ScreenWidth;
    
    for (UIButton *buttn in self.titleScrollView.subviews) {
        if (buttn.tag == index) {
            if (buttn != self.seletedButton) {
                [buttn sendActionsForControlEvents:UIControlEventTouchUpInside];
            }
            break;
        }
    }
}

#pragma mark - AliyunColorPaletteViewDelegate

- (void)colorPaletteViewTextColorChanged:(AliyunColor *)color
{
    [self.delegate captionStyleViewDidChangeColor:color];
}

- (void)colorPaletteViewtextStrokeWidthChanged:(CGFloat)width
{
    [self.delegate captionStyleViewDidChangeStrokeWidth:width];
}

#pragma mark - AliyunFontSelectViewDelegate

- (void)onSelectFontWithFontInfo:(AliyunEffectFontInfo *)fontInfo faceType:(int)faceType
{
    [self.delegate captionStyleViewDidChangeFont:fontInfo faceType:faceType];

}

#pragma mark - AliyunCaptionShadowViewDelegate

- (void)captionShadowDidChangedShadowView:(AliyunCaptionShadowView *)shadowView
{
    [self.delegate captionStyleViewDidChangeShadow:shadowView.color offset:shadowView.offset];
}


#pragma mark - AliyunCaptionTextAlignmentViewDelegate

- (void)captionTextAlignmentSelected:(NSInteger)type
{
    [self.delegate captionTextAlignmentSelected:type];
}

@end
