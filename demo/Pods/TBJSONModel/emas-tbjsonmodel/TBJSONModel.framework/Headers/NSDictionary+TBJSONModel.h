//
//  NSDictionary+TBJSONModel.h
//  TBModelFactory
//
//  Created by Luke on 8/16/13.
//  Copyright (c) 2013 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TBJSONModel.h"

@interface NSDictionary(TBJSONModel)

/*!
 将JSON转过来的一个字典中的每一个key都转换成相应类型的model对象，不支持嵌套
 转换过程为:
 {key1:{},key2:{}} ===> {key1:m1,key2:m2}
 
 当然每一个key所对应的value转换后的model类型须为同一个类型
 */
- (NSDictionary *)modelDictionaryWithClass:(Class)modelClass;
- (NSDictionary *)modelDictionaryWithClass:(Class)modelClass strictMode:(BOOL)strictMode;

- (NSDictionary *)toJSONDictionary;

@end
