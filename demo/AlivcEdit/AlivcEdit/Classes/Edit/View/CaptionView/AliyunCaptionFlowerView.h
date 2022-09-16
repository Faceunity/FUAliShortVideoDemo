//
//  AliyunCaptionFlowerView.h
//  AlivcEdit
//
//  Created by mengyehao on 2021/5/26.
//

#import "AlivcTabbarBaseView.h"


@protocol AliyunCaptionFlowerViewDelegate <NSObject>
- (void)captionFlowerViewDidSeletedFlowerPath:(NSString *)path;
@end

@interface AliyunCaptionFlowerView : AlivcTabbarBaseView
@property(nonatomic, weak)id<AliyunCaptionFlowerViewDelegate>delegate;

@end


