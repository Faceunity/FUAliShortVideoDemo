//
//  AliyunEditButtonsView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEditButtonsView.h"

@implementation AliyunEditButtonsView
{
    NSArray *_btnImages;
    NSArray *_btnSelNames;
    NSArray *_titleStrings;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithConfig:(AlivcEditUIConfig *)uiConfig{
    self = [super initWithFrame:CGRectMake(0, ScreenHeight - 70 - SafeBottom, ScreenWidth, 70)];
    if(self){
        if (!uiConfig){
            uiConfig = [[AlivcEditUIConfig alloc]init];
        }
        //滤镜 音乐 动图 字幕 MV 特效 时间特效 转场 涂鸦
        _titleStrings = @[@"滤镜",
                          @"音乐",
                          @"动图",
                          @"字幕",
                          @"MV",
                          @"特效",
                          @"变速",
                          @"转场",
                          @"涂鸦"];
        
        _btnImages =    @[uiConfig.filterImage,
                           uiConfig.musicImage,
                           uiConfig.pasterImage,
                           uiConfig.captionImage,
                           uiConfig.mvImage,
                           uiConfig.effectImage,
                           uiConfig.timeImage,
                           uiConfig.translationImage,
                           uiConfig.paintImage];
        
        _btnSelNames = @[@"filterButtonClicked:",
                         @"musicButtonClicked:",
                         @"pasterButtonClicked:",
                         @"subtitleButtonClicked:",
                         @"mvButtonClicked:",
                         @"effectButtonClicked:",
                         @"timeButtonClicked:",
                         @"translationButtonCliked:",
                         @"paintButtonClicked:"];
        [self addButtons];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}



/**
 逻辑：在一个屏幕的宽度下，固定放5个半的图标，超出部分以滑动的形式显示
 */
- (void)addButtons {
    //2个按钮中心之间的间距
    CGFloat devide = ScreenWidth / 5.5;
    //基础参数
    UIImage *image = _btnImages.firstObject;
    CGFloat buttonWidth = image.size.width;
    CGFloat labelHeight = 30;
    CGFloat buttonHeight = buttonWidth + labelHeight;

    //强制宽度等于屏幕宽
    CGRect frame = self.frame;
    if (frame.size.width != ScreenWidth) {
        frame.size.width = ScreenWidth;
        self.frame = frame;
    }
    //添加scrollView
    UIScrollView *scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    scrollView.contentSize = CGSizeMake(devide * _btnImages.count, frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    
    
    for (int idx = 0; idx < [_btnImages count]; idx++) {
        UIImage *image = [_btnImages objectAtIndex:idx];
        NSString *selName = [_btnSelNames objectAtIndex:idx];
        NSString *title = [_titleStrings objectAtIndex:idx];
        SEL sel = NSSelectorFromString(selName);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, buttonWidth, buttonHeight);
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
        
        if(image){
            [btn setImage:image forState:UIControlStateNormal];
        }
        
        
        [btn setTitle:title forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [btn.titleLabel sizeToFit];
        
        //
        CGFloat titleHeight = btn.titleLabel.intrinsicContentSize.height;
//        CGFloat titleWidth = btn.titleLabel.intrinsicContentSize.width;
        CGFloat imageWidth = btn.imageView.frame.size.width;
        CGFloat imageHeight = btn.imageView.frame.size.height;
        btn.imageEdgeInsets = UIEdgeInsetsMake(0, 0, titleHeight + 8, 0);
        btn.titleEdgeInsets = UIEdgeInsetsMake(imageHeight + 8, -imageWidth, 0, 0);
        [scrollView addSubview:btn];
        btn.center = CGPointMake((idx+0.5) * devide, frame.size.height / 2);
        //设置阴影
        [btn setExclusiveTouch:YES];
        btn.layer.shadowColor = [UIColor grayColor].CGColor;
        btn.layer.shadowOpacity = 0.5;
        btn.layer.shadowOffset = CGSizeMake(1, 1);
        
    }
}



//滤镜
- (void)filterButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(filterButtonClicked:)]) {
        [self.delegate filterButtonClicked:AliyunEditButtonTypeFilter];
    }
    
}

//音乐
- (void)musicButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(musicButtonClicked)]) {
        [self.delegate musicButtonClicked];
    }
    
}

//动图
- (void)pasterButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(pasterButtonClicked)]) {
        [self.delegate pasterButtonClicked];
    }
   
}

//字幕
- (void)subtitleButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(subtitleButtonClicked)]) {
        [self.delegate subtitleButtonClicked];
    }
    
}

//mv
- (void)mvButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(mvButtonClicked:)]) {
        [self.delegate mvButtonClicked:AliyunEditButtonTypeMV];
    }
    
}

//特效
- (void)effectButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(effectButtonClicked)]) {
        [self.delegate effectButtonClicked];
    }
    
}

//时间特效
- (void)timeButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(timeButtonClicked)]) {
        [self.delegate timeButtonClicked];
    }
}

//转场
- (void)translationButtonCliked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(translationButtonCliked)]) {
        [self.delegate translationButtonCliked];
    }
   
}

//涂鸦
- (void)paintButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(paintButtonClicked)]) {
        [self.delegate paintButtonClicked];
    }
}




@end
