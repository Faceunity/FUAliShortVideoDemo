//
//  AlivcPhotoPickerBundle.h
//  AlivcPhoto
//
//  Created by coder.pi on 2021/7/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcPhotoPickerBundle : NSObject
@property (nonatomic, class, readonly) NSString *name;
@property (nonatomic, class, readonly) NSBundle *main;
+ (UIImage *) imageNamed:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
