//
//  AliyunVideoAugmentationView.h
//  AlivcCommon
//
//  Created by Bingo on 2021/1/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AliyunVideoAugmentationViewDelegate <NSObject>

- (float)videoAugmentationGetCurrentValue:(NSInteger)type;
- (void)videoAugmentationDidSelectType:(NSInteger)type value:(CGFloat)value;

@end

@interface AliyunVideoAugmentationView : UIView

@property(nonatomic, weak) id<AliyunVideoAugmentationViewDelegate> delegate;

@end

NS_ASSUME_NONNULL_END
