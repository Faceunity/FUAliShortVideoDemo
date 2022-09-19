//
//  AlivcTemplatePlayer.m
//  AlivcEdit
//
//  Created by Bingo on 2021/11/22.
//

#import "AlivcTemplatePlayer.h"

typedef NS_ENUM(NSUInteger, AlivcTemplatePlayerState) {
    AlivcTemplatePlayerStateInit,
    AlivcTemplatePlayerStatePlaying,
};

@interface AlivcTemplatePlayer ()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) AVPlayerLayer *playerLayer;
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, assign) AlivcTemplatePlayerState playerState;

@end

@implementation AlivcTemplatePlayer

- (instancetype)initWithContainerView:(UIView *)containerView {
    self = [super init];
    if (self) {
        self.containerView = containerView;
    }
    return self;
}

- (BOOL)isPlaying {
    return self.player != nil;
}

- (void)play {
    if (self.player || self.playUrl.length == 0) {
        return;
    }
    
    NSURL *url = nil;
    if ([[self.playUrl lowercaseString] hasPrefix:@"http://"] || [[self.playUrl lowercaseString] hasPrefix:@"https://"]) {
        url = [NSURL URLWithString:self.playUrl];
    }
    else {
        url = [NSURL fileURLWithPath:self.playUrl];
    }
    AVURLAsset *asset = [AVURLAsset assetWithURL:url];
    self.playerItem = [AVPlayerItem playerItemWithAsset:asset];
    
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    
    AVPlayerLayer *layer = [AVPlayerLayer playerLayerWithPlayer:self.player];
    layer.frame = self.containerView.bounds;
    layer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.containerView.layer addSublayer:layer];
    self.playerLayer = layer;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onPlayToEndTime:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.playerItem];
    
    [self.player play];
}

- (void)pause {
    [self.player pause];
}

- (void)resume {
    [self.player play];
}

- (void)stop {
    
    if (!self.player) {
        return;
    }
    [self.player pause];
    [self.player replaceCurrentItemWithPlayerItem:nil];
    [self.playerLayer removeFromSuperlayer];
    self.playerItem = nil;
    self.player = nil;
    self.playerLayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
}

- (void)onPlayToEndTime:(NSNotification *)notification
{
    if (notification.object == self.playerItem) {
        [self.player seekToTime:CMTimeMake(0, 1)];
        [self.player play];
    }
}

@end
