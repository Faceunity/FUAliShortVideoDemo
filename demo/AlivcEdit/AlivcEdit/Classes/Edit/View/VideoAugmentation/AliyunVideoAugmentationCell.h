//
//  AliyunVideoAugmentationCell.h
//  AlivcCommon
//
//  Created by Bingo on 2021/1/25.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunVideoAugmentationCellModel : NSObject

@property(nonatomic, copy) NSString *title;
@property(nonatomic, copy) NSString *iconPath;
@property(nonatomic, assign) NSInteger type;
@property(nonatomic, assign) CGFloat value;

@end

@interface AliyunVideoAugmentationCell : UICollectionViewCell

-(void)cellModel:(AliyunVideoAugmentationCellModel *)model;

@end

NS_ASSUME_NONNULL_END
