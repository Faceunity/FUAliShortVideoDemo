//
//  AlivcPhotoPathManager.h
//  AlivcPhotoPicker
//
//  Created by mengyehao on 2021/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcPhotoPathManager : NSObject

+ (NSString *)quCachePath;


+ (NSString *)compositionRootDir;

+ (NSString*)randomString;
@end

NS_ASSUME_NONNULL_END
