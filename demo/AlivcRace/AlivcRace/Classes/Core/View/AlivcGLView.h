//
//  AlivcGLView.h
//  AlivcRace
//
//  Created by 孙震 on 2020/2/25.
//

#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface AlivcGLView : UIView

@property (nonatomic,assign) CGFloat tWidth; //纹理的宽
@property (nonatomic,assign) CGFloat tHeight; //纹理的高


- (void)draw:(int)texture;

- (void)draw:(CVPixelBufferRef)pixelBuffer facePoint:(NSArray *)points;

- (void)drawWithPixelBuffer:(CVPixelBufferRef)pixelBuffer;

@end

NS_ASSUME_NONNULL_END
