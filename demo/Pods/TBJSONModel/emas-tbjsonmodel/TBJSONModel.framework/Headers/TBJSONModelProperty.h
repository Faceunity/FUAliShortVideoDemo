//
//  TBJSONModelProperty.h
//  TBJSONModel
//
//  Created by Luke on 8/16/13.
//  Copyright (c) 2013 taobao. All rights reserved.
//

#import <Foundation/Foundation.h>
/*
 相关知识请参见Runtime文档
 Type Encodings https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
 Property Type String https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtPropertyIntrospection.html#//apple_ref/doc/uid/TP40008048-CH101-SW6
 */
typedef NS_ENUM(NSInteger, TBJSONModelPropertyValueType) {
    TBClassPropertyValueTypeNone = 0,
    TBClassPropertyTypeChar,
    TBClassPropertyTypeInt,
    TBClassPropertyTypeShort,
    TBClassPropertyTypeLong,
    TBClassPropertyTypeLongLong,
    TBClassPropertyTypeUnsignedChar,
    TBClassPropertyTypeUnsignedInt,
    TBClassPropertyTypeUnsignedShort,
    TBClassPropertyTypeUnsignedLong,
    TBClassPropertyTypeUnsignedLongLong,
    TBClassPropertyTypeFloat,
    TBClassPropertyTypeDouble,
    TBClassPropertyTypeBool,
    TBClassPropertyTypeVoid,
    TBClassPropertyTypeCharString,
    TBClassPropertyTypeObject,
    TBClassPropertyTypeClassObject,
    TBClassPropertyTypeSelector,
    TBClassPropertyTypeArray,
    TBClassPropertyTypeStruct,
    TBClassPropertyTypeUnion,
    TBClassPropertyTypeBitField,
    TBClassPropertyTypePointer,
    TBClassPropertyTypeUnknow
};

@interface TBJSONModelProperty : NSObject{
    @public
    NSString *_name;
    TBJSONModelPropertyValueType _valueType;
    NSString *_typeName;
    Class _objectClass;
    NSArray *_objectProtocols;
    Class _containerElementClass;
    BOOL _isReadonly;
}

+ (instancetype)propertyWithName:(NSString *)name typeString:(NSString *)typeString;

@end
