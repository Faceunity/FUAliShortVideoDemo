//
//  AlivcGroupSelectorCell.h
//  AFNetworking
//
//  Created by lileilei on 2020/1/3.
//

#import <UIKit/UIKit.h>

@class AliyunEffectInfo;

NS_ASSUME_NONNULL_BEGIN

@interface AlivcGroupSelectorCell : UICollectionViewCell

/**
 分组name
 */
@property(nonatomic, strong)UILabel *lab;
/**
 分组Icon View
 */
@property (nonatomic, strong) UIImageView *iconImageView;

/**
 当前cell分组模型
 */
@property (nonatomic, strong) AliyunEffectInfo *group;

@end

NS_ASSUME_NONNULL_END
