//
//  AlivcTemplatePlayer.h
//  AlivcEdit
//
//  Created by Bingo on 2021/11/22.
//

#import <AVKit/AVKit.h>

@interface AlivcTemplatePlayer : NSObject

- (instancetype)initWithContainerView:(UIView *)containerView;
@property (nonatomic, strong) NSString *playUrl;

- (BOOL)isPlaying;
- (void)play;
- (void)pause;
- (void)resume;
- (void)stop;

@end
