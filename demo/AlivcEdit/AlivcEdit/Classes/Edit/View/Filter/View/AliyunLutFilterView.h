//
//  AliyunLutFilterView.h
//  AlivcEdit
//
//  Created by mengyehao on 2021/11/18.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@interface AliyunLutFilterModel : NSObject
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *lookupPath;
@property (nonatomic, copy) NSString *iconPath;
@end





@protocol AliyunLutFilterViewDelegate <NSObject>
@optional



/**
 选中某个滤镜滤镜

 @param filter 滤镜数据模型
 */
- (void)lutFilterViewDelegateDidSelectLutFilter:(NSString *)path indensity:(float)indensity;

- (void)lutFilterViewDelegateDidUpdateIndensity:(float)indensity;



@end

@interface AliyunLutFilterView : UIView
@property (nonatomic, weak) id<AliyunLutFilterViewDelegate>delegate;

- (void)updateSelectedFilterWithResource:(NSString *)resourcePath insensity:(float)insensity;

@end

NS_ASSUME_NONNULL_END
