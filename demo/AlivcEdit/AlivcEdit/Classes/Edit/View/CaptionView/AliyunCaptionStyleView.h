//
//  AliyunCaptionStyleView.h
//  AlivcCommon
//
//  Created by mengyehao on 2021/5/27.
//

#import "AlivcTabbarBaseView.h"
#import <UIKit/UIKit.h>

@class AliyunColor;
@class AliyunEffectFontInfo;

@protocol AliyunCaptionStyleViewDelegate <NSObject>

- (void)captionStyleViewDidChangeColor:(AliyunColor *)color;

- (void)captionStyleViewDidChangeStrokeWidth:(CGFloat)width;

- (void)captionStyleViewDidChangeFont:(AliyunEffectFontInfo *)font faceType:(int)faceType;

- (void)captionStyleViewDidChangeShadow:(UIColor *)shadowColor offset:(UIOffset)offset;

//排版
- (void)captionTextAlignmentSelected:(NSInteger)type;

@end


@interface AliyunCaptionStyleView : AlivcTabbarBaseView

@property(nonatomic, weak)id<AliyunCaptionStyleViewDelegate> delegate;

@end


