//
//  AlivcAudioEffectCell.h
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/3/4.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcAudioEffectModel : NSObject

@property(nonatomic, strong)NSString *title;
@property(nonatomic, strong)NSString *iconPath;
@property(nonatomic, assign)NSInteger type;

@end

@interface AlivcAudioEffectCell : UICollectionViewCell

-(void)cellModel:(AlivcAudioEffectModel *)model;

@end

NS_ASSUME_NONNULL_END
