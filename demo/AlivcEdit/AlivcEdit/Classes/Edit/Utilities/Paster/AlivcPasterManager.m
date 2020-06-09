//
//  AlivcPasterManager.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/26.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcPasterManager.h"
//动图修正相关
#import <AliyunVideoSDKPro/AliyunPasterManager.h>
#import <AliyunVideoSDKPro/AliyunEffectPasterBase.h>
#import <AliyunVideoSDKPro/AliyunMoveAction.h>
#import <AliyunVideoSDKPro/AliyunScaleAction.h>
#import <AliyunVideoSDKPro/AliyunCustomAction.h>
#import <AliyunVideoSDKPro/AliyunAlphaAction.h>

#import "AliyunSubtitleActionItem.h"

@implementation AlivcPasterManager

-(BOOL)checkResourceIsExistence:(NSString *)path{
    //检测资源是否存在
    NSMutableString *docDir =[NSMutableString stringWithFormat:@"%@",NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject];
    NSString *resourcePath = [path stringByReplacingOccurrencesOfString:@"Documents/" withString:@""];
    resourcePath = [docDir stringByAppendingPathComponent:resourcePath];
    return [[NSFileManager defaultManager] fileExistsAtPath:resourcePath];
}

-(void)correctedPasterFrameAtPreviewStatusWithPasterManager:(AliyunPasterManager *)pasterManager{
    CGSize originDisplaySize = pasterManager.displaySize;
    NSArray *allPasterControllers = [pasterManager getAllPasterControllers];
    for (AliyunPasterController *controller in allPasterControllers) {
        CGSize displaySize = controller.displaySize;
        CGSize pasterSize = controller.pasterSize;
        CGPoint position = controller.pasterPosition;
        CGRect subtitleFrame = controller.subtitleFrame;

        CGSize newPasterSize =  CGSizeZero;
        newPasterSize.width = pasterSize.width / displaySize.width * originDisplaySize.width ;
        newPasterSize.height = pasterSize.height / displaySize.height * originDisplaySize.height ;
        controller.pasterSize = newPasterSize;

        CGPoint newPosition = CGPointZero;
        newPosition.x = position.x / displaySize.width * originDisplaySize.width;
        newPosition.y = position.y / displaySize.height * originDisplaySize.height;

        CGRect newSubtitleFrame = CGRectZero;
        newSubtitleFrame.origin.x = subtitleFrame.origin.x / pasterSize.width * newPasterSize.width;
        newSubtitleFrame.origin.y = subtitleFrame.origin.y / pasterSize.height * newPasterSize.height;
        newSubtitleFrame.size.width = subtitleFrame.size.width / pasterSize.width * newPasterSize.width;
        newSubtitleFrame.size.height = subtitleFrame.size.height / pasterSize.height * newPasterSize.height;

        controller.pasterPosition = newPosition;
        controller.displaySize = originDisplaySize;
        controller.subtitleFrame = newSubtitleFrame;

        [controller editWillStart];
        [controller editCompleted];

        NSArray *allActions = [[controller getEffectPaster] allActions];
        for (AliyunAction *action in allActions) {
            if ([action isKindOfClass:[AliyunMoveAction class]]) {
                AliyunMoveAction *moveAction = (AliyunMoveAction *)action;
                CGPoint newFromPoint = CGPointZero;
                newFromPoint.x = moveAction.fromePoint.x / displaySize.width * originDisplaySize.width;
                newFromPoint.y = moveAction.fromePoint.y / displaySize.height * originDisplaySize.height;
                CGPoint newToPoint = CGPointZero;
                newToPoint.x = moveAction.toPoint.x / displaySize.width * originDisplaySize.width;
                newToPoint.y = moveAction.toPoint.y / displaySize.height * originDisplaySize.height;
                moveAction.fromePoint = newFromPoint;
                moveAction.toPoint = newToPoint;
                moveAction.displaySize = originDisplaySize;
            }
            [[controller getEffectPaster] runAction:action];
        }
    }
}

-(void)correctedPasterFrameAtEditStatusWithPasterManager:(AliyunPasterManager *)pasterManager withEditFrame:(CGRect)editFrame{
    NSArray *allPasterControllers = [pasterManager getAllPasterControllers];
    for (AliyunPasterController *controller in allPasterControllers) {
        CGSize displaySize = controller.displaySize;
        CGSize pasterSize = controller.pasterSize;
        CGPoint position = controller.pasterPosition;
        CGRect subtitleFrame = controller.subtitleFrame;
        
        CGSize newPasterSize =  CGSizeZero;
        newPasterSize.width = pasterSize.width / displaySize.width * editFrame.size.width ;
        newPasterSize.height = pasterSize.height / displaySize.height * editFrame.size.height;
        controller.pasterSize = newPasterSize;
        
        CGPoint newPosition = CGPointZero;
        newPosition.x = position.x / displaySize.width * editFrame.size.width;
        newPosition.y = position.y / displaySize.height * editFrame.size.height;
        
        CGRect newSubtitleFrame = CGRectZero;
        newSubtitleFrame.origin.x = subtitleFrame.origin.x / pasterSize.width * newPasterSize.width;
        newSubtitleFrame.origin.y = subtitleFrame.origin.y / pasterSize.height * newPasterSize.height;
        newSubtitleFrame.size.width = subtitleFrame.size.width / pasterSize.width * newPasterSize.width;
        newSubtitleFrame.size.height = subtitleFrame.size.height / pasterSize.height * newPasterSize.height;
        
        controller.pasterPosition = newPosition;
        controller.displaySize = pasterManager.displaySize;
        controller.subtitleFrame = newSubtitleFrame;
        
        [controller editWillStart];
        [controller editCompleted];
        
        NSArray *allActions = [[controller getEffectPaster] allActions];
        for (AliyunAction *action in allActions) {
            if ([action isKindOfClass:[AliyunMoveAction class]]) {
                AliyunMoveAction *moveAction = (AliyunMoveAction *)action;
                CGPoint newFromPoint = CGPointZero;
                newFromPoint.x = moveAction.fromePoint.x / displaySize.width * editFrame.size.width;
                newFromPoint.y = moveAction.fromePoint.y / displaySize.height * editFrame.size.height;
                CGPoint newToPoint = CGPointZero;
                newToPoint.x = moveAction.toPoint.x / displaySize.width * editFrame.size.width;
                newToPoint.y = moveAction.toPoint.y / displaySize.height * editFrame.size.height;
                moveAction.fromePoint = newFromPoint;
                moveAction.toPoint = newToPoint;
                moveAction.displaySize = editFrame.size;
            }
            [[controller getEffectPaster] runAction:action];
        }
    }
}

//字幕气泡和字幕中心点计算
//    if (effectPaster && [effectPaster respondsToSelector:@selector(effectSubtitle)]) {
//        subtitle = [effectPaster performSelector:@selector(effectSubtitle)];
//    }
//字幕偏移量
//    CGFloat offset = (CGRectGetMidY(pasterController.subtitleFrame)-CGRectGetHeight(pasterController.pasterFrame)/2);
//    //字幕中心点Y轴
//    CGFloat subtitleY = pasterController.pasterPosition.y+offset;

-(NSInteger)getAlivcSubtitleAnimateTypeWithPasterController:(NSObject *)pasterController{
    if ([pasterController isKindOfClass:[AliyunPasterController class]]) {
        NSArray *allActions = [[(AliyunPasterController *)pasterController getEffectPaster] allActions];
        AliyunAction *action = [allActions firstObject];
        if (allActions.count == 0) {//无效果
            return TextActionTypeClear;
        }else if ([action isKindOfClass:[AliyunScaleAction class]]){//缩放
            return TextActionTypeScale;
        }else if ([action isKindOfClass:[AliyunCustomAction class]]){//线性擦除
            return TextActionTypeLinerWipe;
        }else if ([action isKindOfClass:[AliyunAlphaAction class]]){//淡入淡出
            return TextActionTypeFade;
        }else if ([action isKindOfClass:[AliyunMoveAction class]]){
            AliyunMoveAction *moveAction = (AliyunMoveAction *)action;
            CGFloat start_x = moveAction.fromePoint.x;
            CGFloat start_y = moveAction.fromePoint.y;
            CGFloat end_x = moveAction.toPoint.x;
            CGFloat end_y = moveAction.toPoint.y;
            if (start_x == end_x && start_y > end_y) {
                return TextActionTypeMoveTop;
            }else if (start_x == end_x && start_y < end_y){
                return TextActionTypeMoveDown;
            }else if (start_y == end_y && start_x > end_x){
                return TextActionTypeMoveLeft;
            }else if (start_y == end_y && start_x < end_x){
                return TextActionTypeMoveRight;
            }else{
                NSLog(@"#Error:TextAcitonTpyeMove type is Unidentified!");
                return -1;
            }
        }else {
            NSLog(@"#Error:TextAcitonTpye Unidentified!");
            return -1;
        }
    }
    NSLog(@"#Error:parameter isn't of AliyunPasterController type!");
    return -1;
}


@end
