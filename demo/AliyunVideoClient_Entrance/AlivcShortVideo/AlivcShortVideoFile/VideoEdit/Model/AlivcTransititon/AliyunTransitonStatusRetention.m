//
//  AliyunTransitonStatusRetention.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/5.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunTransitonStatusRetention.h"
#import "AliyunTransitionIcon.h"
#import "AliyunTransitionCover.h"

@implementation AliyunTransitonStatusRetention

-(id)init{
    self = [super init];
    if (self) {
        _isFirstEdit = YES;
    }
    return self;
}

-(void)initTransitionInfo:(int)clipsNumber{
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:7];
    for (int i = 0; i<clipsNumber-1; i++) {
        [dic setObject:@(0) forKey:[NSString stringWithFormat:@"%d",i]];
//        NSLog(@"count:%d,  clipsNumber:%d",i,clipsNumber);
    }
    self.lastTransitionInfo = [dic copy];
}
-(void)setTransitionIcons:(NSArray<AliyunTransitionIcon *> *)transitionIcons{
    _transitionIcons =transitionIcons;
    if (transitionIcons) {
        _isFirstEdit = NO;
    }
}
-(void)setTransitionCovers:(NSArray<AliyunTransitionCover *> *)transitionCovers{
    _transitionCovers = transitionCovers;
    if (transitionCovers) {
        _isFirstEdit = NO;
    }
}

@end
