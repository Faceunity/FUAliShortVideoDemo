//
//  AliyunEffectTransitionVIew.h
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PTEHorizontalTableView.h"
@class AliyunTransitionCover;
@class AliyunTransitionIcon;
@class AliyunEffectInfo;
@class AliyunTransitionEffect;


/**
 转场效果Type

 - TransitionTypeNull: 无效果
 - TransitionTypeMoveUp: 向上移动
 - TransitionTypeMoveDown: 向下移动
 - TransitionTypeMoveLeft: 向左移动
 - TransitionTypeMoveRight: 向右移动
 - TransitionTypeShuffer: 百叶窗
 - TransitionTypeFade: 淡入淡出
 - TransitionTypeCircle: 圆形
 - TransitionTypeStar: 多边形
 */
typedef NS_ENUM(NSInteger, TransitionType){
    TransitionTypeNull = 0,
    TransitionTypeMoveUp,
    TransitionTypeMoveDown,
    TransitionTypeMoveLeft,
    TransitionTypeMoveRight,
    TransitionTypeShuffer,
    TransitionTypeFade,
    TransitionTypeCircle,
    TransitionTypeStar,
    TransitionTypeCustom,
};

@protocol AliyunEffectTransitionViewDelegate <NSObject>


/**
 取消按钮事件
 
 @param transitionInfo 转场动画信息
 */
- (void)transitionCancelButtonClickTransitionInfo:(NSDictionary *)transitionInfo;


/**
 确认按钮事件

 @param covers 片段之间动画效果数据模型集合
 @param icons 动画效果数据模型集合
 @param transitionInfo 转场动画信息
 */
- (void)applyButtonClickCovers:(NSArray<AliyunTransitionCover*> *)covers andIcons:(NSArray<AliyunTransitionIcon *> *)icons transitionInfo:(NSDictionary *)transitionInfo;


/**
 选择一个转场特效事件

 @param type 转场效果类型
 @param idx 转场片段序号
 */
- (void)didSelectTransitionType:(TransitionType)type resoucePath:(NSString*)path index:(int)idx;

/**
 预览一个转场特效事件

 @param idx 转场片段序号
 */
- (void)previewTransitionIndex:(AliyunTransitionCover*)cover;

/**
点击更多
 */
- (void)didShowMoreTransition;

//清除保留存储
- (void)clearRetentionByPath:(NSString*)path;

@end



/**
 转场View
 */
@interface AliyunEffectTransitionView : UIView<PTETableViewDelegate>
@property (nonatomic, assign) id<AliyunEffectTransitionViewDelegate> delegate;

/**
 上方当前选中的转场效果的icon展示tabbleview
 */
@property (nonatomic, strong) PTEHorizontalTableView *coverTableView;

/**
 下边所有转场效果展示tabbleview
 */
@property (nonatomic, strong) PTEHorizontalTableView *transitionTableView;

/**
 过渡效果集合
 */
@property (nonatomic, strong) NSMutableArray<AliyunTransitionCover*> *covers;

/**
 动画集合
 */
@property (nonatomic, strong) NSMutableArray<AliyunTransitionIcon*> *icons;

@property (nonatomic,copy) void (^didChangeEffectFinish)(AliyunTransitionEffect* effect,int idx);


/**
 初始化方法

 @param frame frame
 @param delegate 代理
 @return 返回一个实例
 */
- (id)initWithFrame:(CGRect)frame delegate:(id<AliyunEffectTransitionViewDelegate>)delegate;


/**
 设置数据源

 @param images 转场片段预览截图集合
 @param block 结束回调
 */
-(void)setupDataSourceClips:(NSArray *)images
blockHandle:(void(^)(NSArray<AliyunTransitionCover *> *covers,NSArray<AliyunTransitionIcon *> *icons))block;


- (void)fetchEffectGroupDataWithCurrentShowGroup:(AliyunEffectInfo *)group;


-(void)showRegulatorView:(AliyunTransitionEffect*)effect paramList:(NSArray*)paramList index:(int)idx;

-(void)updateRegulatorViewWithCover:(AliyunTransitionCover*)cover;

//更新分组选择器默认选中栏
-(void)updateGroupSelector;

@end
