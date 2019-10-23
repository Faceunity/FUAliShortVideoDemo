//
//  NSArray+TBMTOPModel.h
//  taobao4ipad
//
//  Created by Luke on 8/9/13.
//  Copyright (c) 2013 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray(TBJSONModel)

/*!
 将JSON转过来的一个数组转换成相应的model类型的数组，支持多级内嵌的模式
 简单的形式，字典的数组转换成model的数组:
 [{},{},{}] ===> [m1,m2,m3]
 
 也可能是nested的数组
 [[{},{}],[{},{}],[{}]] ===> [[m1,m2],[m3,m4],[m5]]
 
 从上面也可以看出局限性，就是数组或者内嵌数组中的元素转换后的目标model类型必须是同种类型
 
 strictMode 严格模式就是只有当每一个element能转成modelClass的对象的时候才会进行转换，否则会被忽略
 */
- (NSArray *)modelArrayWithClass:(Class)modelClass;
- (NSArray *)modelArrayWithClass:(Class)modelClass strictMode:(BOOL)strictMode;

- (NSArray *)toJSONArray;

@end
