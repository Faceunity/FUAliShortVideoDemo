//
//  TLogFactory.h
//  TRemoteDebugger
//
//  Created by 洋大 on 15/4/1.
//  Copyright (c) 2015年 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TLogBiz.h"

@interface TLogFactory : NSObject

+ (TLogBiz *)createTLogForModuleName:(NSString*)moduleName;

@end
