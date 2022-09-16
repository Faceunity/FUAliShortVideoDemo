//
//  AliyunDraftBundle.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/9.
//

#import "AliyunDraftBundle.h"

@implementation AliyunDraftBundle

+ (NSString *) name
{
    return @"AlivcDraft.bundle";
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
