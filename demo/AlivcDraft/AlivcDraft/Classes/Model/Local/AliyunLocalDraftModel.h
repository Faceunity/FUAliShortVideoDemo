//
//  AliyunLocalDraftModel.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/30.
//

#import "AliyunDraftInfo.h"
#import <AliyunVideoSDKPro/AliyunDraft.h>

@interface AliyunLocalDraftModel : AliyunDraftInfo
@property (nonatomic, strong, readonly) AliyunDraft *draft;
@end
