//
//  AlivcPlayManager.h
//  AlivcEdit
//
//  Created by Bingo on 2021/11/25.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

@protocol AlivcPlayManagerObserver <NSObject>

@optional
- (void)playerDidEnd;
- (void)playProgress:(double)progress;
- (void)playError:(int)errorCode;
- (void)playStatus:(BOOL)isPlaying;

@end

@interface AlivcPlayManager : NSObject

- (instancetype)initWithPlayer:(id<AliyunIPlayer>)player;

@property (nonatomic, readonly) id<AliyunIPlayerCallback> callbackSource;

- (void)refreshPlayState;
- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)stop;
- (void)replay;
- (void)seek:(float)time;

- (double)getDuration;
- (double)getCurrentTime;

- (void)addObserver:(id<AlivcPlayManagerObserver>)observer;
- (void)removeObserver:(id<AlivcPlayManagerObserver>)observer;


@end
