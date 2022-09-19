//
//  AlivcPhotoPickerBundle.m
//  AlivcPhotoPicker
//
//  Created by coder.pi on 2021/7/9.
//

#import "AlivcPhotoPickerBundle.h"

@implementation AlivcPhotoPickerBundle

+ (NSString *) name
{
    return @"AlivcPhotoPicker.bundle";
}

+ (NSBundle *) main
{
    NSString *path = [NSBundle.mainBundle.resourcePath stringByAppendingPathComponent:self.name];
    return [NSBundle bundleWithPath:path];
}

+ (UIImage *) imageNamed:(NSString *)name
{
    return [UIImage imageNamed:name inBundle:self.main compatibleWithTraitCollection:nil];
}
@end
