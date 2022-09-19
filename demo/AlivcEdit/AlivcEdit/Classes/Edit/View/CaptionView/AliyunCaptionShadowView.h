//
//  AliyunCaptionShadowView.h
//  AlivcEdit
//
//  Created by mengyehao on 2021/5/26.
//

#import "AlivcTabbarBaseView.h"
#import <UIKit/UIKit.h>

@class AliyunColor, AliyunCaptionShadowView;

@protocol AliyunCaptionShadowViewDelegate <NSObject>

- (void)captionShadowDidChangedShadowView:(AliyunCaptionShadowView *)shadowView ;


@end

@interface AliyunCaptionShadowView : AlivcTabbarBaseView
@property(nonatomic, weak)id<AliyunCaptionShadowViewDelegate>delegate;

@property(nonatomic, assign) UIOffset offset;
@property(nonatomic, strong)UIColor *color;

@end


