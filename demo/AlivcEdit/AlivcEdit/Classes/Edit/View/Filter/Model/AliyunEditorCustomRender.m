//
//  AliyunEditorCustomRender.m
//  AlivcEdit
//
//  Created by coder.pi on 2022/7/5.
//

#import "AliyunEditorCustomRender.h"
#import "AliyunCustomFilter.h"

@interface AliyunEditorCustomRender ()
@property(nonatomic, strong) AliyunCustomFilter *filter;
@end

@implementation AliyunEditorCustomRender

#define CUSTOM_RENDER 0

#if CUSTOM_RENDER
- (void)renderSetup {
    NSLog(@"==== renderSetup");
}

- (void)renderDestroy {
    NSLog(@"==== renderDestroy");
    self.filter = nil;
}

- (int)customRender:(int)srcTexture size:(CGSize)size pts:(int64_t)pts {
//    NSLog(@"====== CustomRender: %d; size: %lf, %lf; pts: %lld", srcTexture, size.width, size.height, pts);
    // 自定义滤镜渲染
    if (!self.filter) {
        self.filter = [[AliyunCustomFilter alloc] initWithSize:size];
    }
    return [self.filter render:srcTexture];
}
#endif // CUSTOM_RENDER

@end
