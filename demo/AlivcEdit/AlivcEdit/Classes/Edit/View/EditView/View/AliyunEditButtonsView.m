//
//  AliyunEditButtonsView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEditButtonsView.h"
#import "AlivcEditItemModel.h"

@implementation AliyunEditButtonsView

- (instancetype)initWithModels:(NSArray<AlivcEditItemModel *> *)models{
    self = [super initWithFrame:CGRectMake(0, ScreenHeight - 70 - SafeBottom, ScreenWidth, 70)];
    if(self){
        [self addButtonsWithModels:models];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}
/**
 逻辑：在一个屏幕的宽度下，固定放5个半的图标，超出部分以滑动的形式显示
 */
- (void)addButtonsWithModels:(NSArray<AlivcEditItemModel *> *)models{
    //滤镜 音乐 动图 字幕 MV 特效 时间特效 转场 涂鸦
    AlivcEditItemModel *firstModel = models.firstObject;
    
    CGFloat buttonCount = 5.5;
    NSArray* languages = [[NSUserDefaults standardUserDefaults] objectForKey:@"AppleLanguages"];
    NSString* preferredLang = [languages objectAtIndex:0];
    if ([preferredLang containsString:@"en"]) {
        buttonCount = 4.5;
    }
    
    //2个按钮中心之间的间距
    CGFloat devide = ScreenWidth / buttonCount;
    //基础参数
    UIImage *image = firstModel.showImage;
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
    scrollView.contentSize = CGSizeMake(devide * models.count, frame.size.height);
    scrollView.showsHorizontalScrollIndicator = NO;
    [self addSubview:scrollView];
    
    for (int idx = 0; idx < [models count]; idx++) {
        AlivcEditItemModel *itemModel = models[idx];
        UIImage *image = itemModel.showImage;
        NSString *selName = itemModel.selString;
        NSString *title = itemModel.title;
        SEL sel = NSSelectorFromString(selName);
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, 0, devide, buttonHeight);
        [btn addTarget:self action:sel forControlEvents:UIControlEventTouchUpInside];
        
        if(image){
            [btn setImage:image forState:UIControlStateNormal];
        }
        
        [btn setTitle:title forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [btn.titleLabel sizeToFit];
        //
        CGFloat titleHeight = btn.titleLabel.intrinsicContentSize.height;
        CGFloat titleWidth = btn.titleLabel.intrinsicContentSize.width;
        CGFloat imageWidth = btn.imageView.frame.size.width;
        CGFloat imageHeight = btn.imageView.frame.size.height;
        btn.imageEdgeInsets = UIEdgeInsetsMake(-titleHeight-8, 0, 0, -titleWidth);
        btn.titleEdgeInsets = UIEdgeInsetsMake(0, -imageWidth, -imageHeight-8, 0);
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
        [self.delegate filterButtonClicked:AliyunEditMaterialTypeFilter];
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
        [self.delegate mvButtonClicked:AliyunEditMaterialTypeMV];
    }
    
}

//音效
-(void)soundButtonClicked:(id)sender{
    if (self.delegate && [self.delegate respondsToSelector:@selector(soundButtonClicked)]) {
        [self.delegate soundButtonClicked];
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

//封面选择
- (void)coverButtonClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(coverButtonClicked)]) {
        [self.delegate coverButtonClicked];
    }
}
@end
