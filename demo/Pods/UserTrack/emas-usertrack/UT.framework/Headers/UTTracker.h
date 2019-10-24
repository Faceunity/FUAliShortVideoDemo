//
// UTTracker.h
// 
// UserTrack 
// 开发团队：数据通道团队 
// UT答疑群：11791581(钉钉) 
// UT埋点平台答疑群：11779226(钉钉) 
// 
// Copyright (c) 2014-2017 Taobao. All rights reserved. 
//

#import <Foundation/Foundation.h>
#import <UIKit/UIViewController.h>
#import <UIKit/UIWebView.h>
#import "UTTPKItem.h"
typedef enum _UTPageStatus{
    UT_H5_IN_WebView//设置容器中的H5页面事件的eventid为2001,不设置默认为2006
} UTPageStatus;

@interface UTTracker : NSObject

-(instancetype) initWithTrackId:(NSString *) pTrackId;

-(void) setGlobalProperty:(NSString *) pKey value:(NSString *) pValue;

-(void) removeGlobalProperty:(NSString *) pKey;

-(NSString *) getGlobalProperty:(NSString *) pKey;

-(void) send:(NSDictionary *) pLogDict;

#pragma mark 页面埋点
/**
 * @brief                   页面进入.
 *
 * @param     pPageObject   页面对象,如viewcontroller指针
 *
 * @warning                 调用说明:1.必须和pageDisAppear配对使用,否则不会成功埋点
 *                                  2.确定页面名称优先级:updatePageName > NSStringFromClass(pObject.class)
 *
 *                          最佳位置:若是viewcontroller页面,则需在viewDidAppear函数内调用
 */
-(void) pageAppear:(id) pPageObject;

/**
 * @brief                   页面进入.
 *
 * @param     pPageObject   页面对象,如viewcontroller指针
 * @param     pPageName     页面名称,如Page_Detail
 *
 * @warning                 调用说明:1.必须和pageDisAppear配对使用,否则不会成功埋点
 *                                  2.确定页面名称优先级:updatePageName > pPageName > NSStringFromClass(pObject.class)
 *                                    若当调用pageAppear时已知页面名称,强烈建议使用该接口
 *                          最佳位置:若是viewcontroller页面,则需在viewDidAppear函数内调用
 */
-(void) pageAppear:(id) pPageObject withPageName:(NSString *) pPageName;

/**
 * @brief                   页面离开.
 *
 * @param     pPageObject   页面对象,如viewcontroller指针
 *
 * @warning                 调用说明:必须和pageAppear配对使用,否则不会成功埋点
 *
 *                          最佳位置:若是viewcontroller页面,则需在viewDidDisAppear函数内调用
 */
-(void) pageDisAppear:(id) pPageObject;

/**
 * @brief                   更新页面业务参数.
 *
 * @param     pPageObject   页面对象,如viewcontroller指针
 * @param     pProperties   业务参数,kv对
 *
 * @warning                 调用说明:必须在pageDisAppear之前调用
 *
 *                          最佳位置:在pageDisAppear之前调用即可
 */
-(void) updatePageProperties:(id) pPageObject properties:(NSDictionary *) pProperties;

/**
 * @brief                   更新页面业务参数.
 *
 * @param     pProperties   传给下一个页面业务参数,kv对
 *
 * @warning                 调用说明:必须在下一个页面pageAppear之前调用,否则会携带错误
 *
 *                          最佳位置:必须在下一个页面pageAppear之前调用
 */
-(void) updateNextPageProperties:(NSDictionary *) pProperties;

/**
 * @brief                   添加业务透传参数.
 *
 * @param     pItem         透传规则
 *
 * @warning                 调用说明:
 *
 *                          最佳位置:需要进行透传的初始位置,该位置以后的页面事件会进行透传对应参数,
 *                                  切后台超过30秒再切前台,透传参数会被自动清除
 */
-(void) addTPKItem:(UTTPKItem *) pItem;

#pragma  mark 页面埋点的辅助函数
/**
 * @brief                   更新页面名称.
 *
 * @param     pPageObject   页面对象,如viewcontroller指针
 * @param     pPageName     更新后的页面名称
 *
 * @warning                 调用说明:只有当调用pageAppear时还未知页面名称,后续可使用该接口更新
 *
 *                          最佳位置:在pageDisAppear之前调用
 */
-(void) updatePageName:(id) pPageObject pageName:(NSString *) pPageName;

/**
 * @brief                   更新页面url.
 *
 * @param     pPageObject   页面对象,如viewcontroller指针
 * @param     pUrl          页面对应的url
 *
 * @warning                 调用说明:如手淘统一导航将每次页面跳转的url塞给对应的viewcontroller
 *
 *                          最佳位置:在pageDisAppear之前调用
 */
-(void) updatePageUrl:(id) pPageObject url:(NSURL *) pUrl;

/**
 * @brief                   更新页面状态.
 *
 * @param     pPageObject   页面对象,如viewcontroller指针
 * @param     aStatus       页面状态 enum类型
 *
 * @warning                 调用说明:告知页面处于某些特殊的业务场景,如回退等
 *
 *                          最佳位置:必须在pageAppear之前调用
 */
-(void) updatePageStatus:(id) pPageObject status:(UTPageStatus) aStatus;


-(void) skipPage:(id) pPageObject;

//!!!只提供特殊用途，需要使用时需跟ut方面同学沟通!!!
-(NSDictionary *) getPageProperties:(id) pPageObject;

#pragma mark utparam interface
/** 新增接口:更新utparam到这一个页面 **/
-(void) updatePageUtparam:(id) pPageObject utParamJson:(NSString *) utParamJsonStr;

/** 新增接口:更新utparam到下一个页面 **/
-(void) updateNextPageUtparam:(NSString *) utParamJsonStr;

#pragma mark exposure interface

/**
 @deprecated This method has been deprecated.Please using setExposureView:block:viewId:args:
 */

- (void) setExposureView:(UIView *) view
             controlName:(NSString *)controlName
               viewIndex:(NSString *) viewIndex
                    args:(NSDictionary *)dict DEPRECATED_ATTRIBUTE;

/**
 设置曝光元素标识
 
 @param view 需要曝光的视图
 @param block 曝光所属的分区
 @param viewId 视图唯一id
 @param args 附加信息,如果有spm、scm,请按照spm,scm小写字符串为key传入
 */
- (void)setExposureView:(UIView *)view
                  block:(NSString *)block
                 viewId:(NSString *)viewId
                   args:(NSDictionary *)args;

/**
 刷新当前页面的曝光数据；当应用更新数据后，可以通过该接口主动更新，SDK会重新曝光。否则当前页面已经曝光的数据不再曝光
 */
- (void) refreshPageExposure;

/**
 刷新当前页面的曝光数据；当应用更新数据后，可以通过该接口主动更新，SDK会重新曝光。否则当前页面已经曝光的数据不再曝光

 @param block 刷新范围为区块
 */
- (void) refreshBlockExposure:(NSString *)block;

/**
 @deprecated This method has been deprecated.Please using refreshExposureViewWithBlock:andViewId:
 */
- (void) refreshViewExposure:(NSString *)block viewIndex:(NSString *) viewIndex DEPRECATED_ATTRIBUTE;

/**
 刷新当前页面的曝光数据；当应用更新数据后，可以通过该接口主动更新，SDK会重新曝光。否则当前页面已经曝光的数据不再曝光
 
 @param block 曝光所属的分区
 @param viewId 视图唯一id
 */
- (void) refreshExposureViewWithBlock:(NSString *)block andViewId:(NSString *)viewId;

@end
