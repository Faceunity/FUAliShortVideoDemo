//
//  AlivcTemplateManager.h
//  AlivcEdit
//
//  Created by Bingo on 2021/11/22.
//

#import <Foundation/Foundation.h>
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

@interface AlivcTemplateManager : NSObject

+ (void)loadAllTemplates:(void(^)(NSArray<AliyunTemplateLoader *> * templateLoaders))completed;


@end
