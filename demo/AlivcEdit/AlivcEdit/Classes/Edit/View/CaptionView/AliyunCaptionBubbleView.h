//
//  AliyunCaptionBubbleView.h
//  AlivcEdit
//
//  Created by mengyehao on 2021/5/26.
//

#import "AlivcTabbarBaseView.h"
#import "AliyunEffectPasterInfo.h"

@protocol AliyunCaptionBubbleViewDelegate <NSObject>

- (void)captionBubbleViewDidSeleted:(AliyunEffectPasterInfo *)info;

@end

@interface AliyunCaptionBubbleView : AlivcTabbarBaseView
@property (nonatomic ,weak) id<AliyunCaptionBubbleViewDelegate> delegate;

@property (nonatomic ,strong) UICollectionView *collectionView;
@end


