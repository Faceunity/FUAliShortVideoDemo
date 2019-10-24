//
//  TBJSONModelError.h
//  TBJSONModel
//
//  Created by Luke on 12/1/13.
//  Copyright (c) 2013 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const TBJSONModelErrorDomain;

typedef NS_ENUM(int, TBJSONModelErrorCode) {
    TBJSONModelErrorCodeNilInput = 1,
    TBJSONModelErrorCodeDataInvalid = 2
};

@interface TBJSONModelError : NSError

+ (id)errorNilInput;
+ (id)errorDataInvalidWithDescription:(NSString *)description;

@end
