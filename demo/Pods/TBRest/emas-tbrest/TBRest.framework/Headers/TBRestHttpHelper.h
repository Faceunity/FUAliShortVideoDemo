//
//  TBRestHttpHelper.h
//  TBRestApi
//
//  Created by Alvin on 14-8-21.
//  Copyright (c) 2014年 Alvin. All rights reserved.
//

#ifndef TBRestApi_TBRestHttpHelper_h
#define TBRestApi_TBRestHttpHelper_h

#import <Foundation/Foundation.h>

@interface TBRestHttpHelper :NSObject

+ (NSData *)post:(NSData *)data len:(NSInteger *)len errorCode:(NSInteger *)code appKey:(NSString *)appKey;

@end

#endif
