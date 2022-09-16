//
//  AliyunCaptionTextAlignmentView.h
//  AlivcEdit
//
//  Created by aliyun on 2021/6/26.
//

#import "AlivcTabbarBaseView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol AliyunCaptionTextAlignmentViewDelegate <NSObject>
- (void)captionTextAlignmentSelected:(NSInteger)type;
@end

@interface AliyunCaptionTextAlignmentView : AlivcTabbarBaseView
@property(nonatomic, weak)id<AliyunCaptionTextAlignmentViewDelegate>delegate;

@end

NS_ASSUME_NONNULL_END
