//
//  AlivcRegulatorView.h
//  AFNetworking
//
//  Created by lileilei on 2020/1/6.
//

#import <UIKit/UIKit.h>
#import <AliyunVideoSDKPro/AliyunEffectConfig.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcRegulatorView : UIView

@property (nonatomic,assign) BOOL isSliderEnable;

@property (nonatomic,copy) void(^didRegulatorViewSliderChangeBlock)(NSArray *dataArr,float value,long row);

+ (AlivcRegulatorView*)initUIwithData:(NSArray *)data inView:(UIView*)container;

+(NSArray*)getSliderParams:(AliyunEffectConfig*)data;

- (void)setSilderEnable:(BOOL)isEnable;

@end

NS_ASSUME_NONNULL_END
