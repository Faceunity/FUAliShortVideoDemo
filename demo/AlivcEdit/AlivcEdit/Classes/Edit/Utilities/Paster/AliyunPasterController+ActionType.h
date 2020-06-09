//
//  AliyunPasterController+ActionType.h
//  AliyunVideoClient_Entrance
//
//  Created by 孙震 on 2019/5/25.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import <AliyunVideoSDKPro/AliyunPasterController.h>
#import "AliyunSubtitleActionItem.h"

NS_ASSUME_NONNULL_BEGIN

@interface AliyunPasterController (ActionType)
//@property (nonatomic, assign) TextActionType type;

/**
 actionType which is applied by clicking confirm button(✅) in editing view
 */
- (void)setActionType:(TextActionType)actionType;
- (TextActionType)actionType;


/**
 actionType which is editing and not sure
 whether it will be applied or canceled
 */
- (void)setTempActionType:(TextActionType)tempActionType;
- (TextActionType)tempActionType;



@end

NS_ASSUME_NONNULL_END
