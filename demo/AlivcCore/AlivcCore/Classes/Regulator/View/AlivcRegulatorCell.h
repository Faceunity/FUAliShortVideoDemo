//
//  AlivcRegulatorCell.h
//  AFNetworking
//
//  Created by lileilei on 2020/1/6.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AliyunParam;

@interface AlivcRegulatorCell : UITableViewCell

-(void)setModel:(AliyunParam*)model isEnable:(BOOL)isEnable;

@property (nonatomic,copy) void(^didSliderChangeBlock)(float);

@end

NS_ASSUME_NONNULL_END
