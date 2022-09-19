//
//  AlivcResourceItem.h
//  AlivcEdit
//
//  Created by Bingo on 2021/11/23.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, AlivcResourceItemType) {
    AlivcResourceItemTypeApp,
    AlivcResourceItemTypeHome,
};

@interface AlivcResourceItem : NSObject

@property (nonatomic, assign, readonly) AlivcResourceItemType *type;

@property (nonatomic, copy, readonly) NSString *gid;
@property (nonatomic, copy, readonly) NSString *eid;
@property (nonatomic, copy, readonly) NSString *name;

//- (instancetype)initWithPath:(NSString *)path withResourceType:();

@end
