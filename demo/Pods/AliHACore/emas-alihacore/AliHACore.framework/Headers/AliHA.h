//
//  AliHA.h
//  AliHA
//
//  Ali High Availability SDK,
//  iOS端上高可用容器层，涵盖crash监控、性能指标度量、卡顿监控、内存监控、abort监控、tlog
//
//  Created by hansong.lhs on 2017/7/29.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AliHAProtocol/AliHAProtocol.h>

@interface AliHA : NSObject

+ (instancetype)shareInstance;

#pragma register plugin and initialize
- (void)registerHAPlugin:(id<AliHAPluginProtocol>)plugin;
- (void)initializeAliHA:(NSString *)appId
             appVersion:(NSString *)appVersion
                channel:(NSString *)channel
                   nick:(NSString *)nick;

- (void)initializeAliHA:(NSString *)appId
             appVersion:(NSString *)appVersion
                channel:(NSString *)channel
                   nick:(NSString *)nick
                 isSync:(BOOL)isSync;

#pragma get logger and record tasks
- (id<AliHALoggerProtocol>)getLogger;
- (void)onTaskBegin:(NSString *)taskName thread:(NSString *)thread;
- (void)onTaskEnd:(NSString *)taskName;

#pragma set reporter and config delegate
- (void)setConfigDelegate:(id<AliHAConfigProtocol>)configDelegate;
- (void)setPageResolverDelegate:(id<AliHAPageResolverProtocol>)utilDelegate;

#pragma triger plugin callbacks
- (void)onApplicationOpenFromURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication;
- (void)onAppEnterForeground;
- (void)onAppEnterBackground;
- (void)onAppResignActive;
- (void)onAppTerminate;
- (void)onUserEvent:(id)sender;
- (void)onViewDidLoad:(UIViewController *)viewController;
- (void)onViewWillExit:(UIViewController *)viewController;
- (void)onViewWillAppear:(BOOL)animated viewController:(UIViewController *)viewController;
- (void)onViewDidAppear:(BOOL)animated viewController:(UIViewController *)viewController;
- (void)onViewWillDisappear:(BOOL)animated viewController:(UIViewController *)viewController;
- (void)onViewDidDisappear:(BOOL)animated viewController:(UIViewController *)viewController;
- (void)onViewDidLayoutSubviews:(UIViewController *)viewController;
- (void)onUIViewLayoutSubviews:(UIView *)view;
- (void)onUIWebViewLoadRequest:(NSURLRequest *)request;
- (void)onPageChange:(PageChangeType)pageChangeType fromVC:(UIViewController *)fromVC toVC:(UIViewController *)toVC args:(NSDictionary *)args;
- (void)onNavigationDidEndTransitionFromView:(id)fromView toView:(id)toView;

@end
