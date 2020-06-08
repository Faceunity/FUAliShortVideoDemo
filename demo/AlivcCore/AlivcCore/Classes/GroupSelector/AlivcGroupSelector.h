//
//  AlivcGroupSelector.h
//  AFNetworking
//
//  Created by lileilei on 2020/1/3.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AliyunEffectInfo;

@protocol AlivcGroupSelectorDelegate <NSObject>

- (void)didGroupSelectorShowMore;

-(void)didGroupSelectorHitByInfo:(AliyunEffectInfo*)info;

@end

@interface AlivcGroupSelector : UIView

//选中标题
@property (nonatomic, strong,nullable) NSString *selectTitle;

/**
 选中特效的序号
 */
@property (nonatomic, assign) NSInteger selectIndex;

//分组数据源
@property (nonatomic, strong) NSMutableArray *groupData;

//记录当前选中的资源路径
@property (nonatomic,copy) NSString *resurcePath;

@property (nonatomic, weak) id<AlivcGroupSelectorDelegate> delegate;


-(void)refreshData;

-(BOOL)checkPathisEqualTo:(NSString*)path;

@end

NS_ASSUME_NONNULL_END
