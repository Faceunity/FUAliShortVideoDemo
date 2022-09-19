//
//  AlivcPlayManager.m
//  AlivcEdit
//
//  Created by Bingo on 2021/11/25.
//

#import "AlivcPlayManager.h"


@interface AlivcPlayManager () <AliyunIPlayerCallback>

@property (nonatomic, strong) NSHashTable<id<AlivcPlayManagerObserver>> *observerTable;
@property (nonatomic, weak) id<AliyunIPlayer> player;

@end

@implementation AlivcPlayManager

- (instancetype)initWithPlayer:(id<AliyunIPlayer>)player {
    self = [super init];
    if (self) {
        self.player = player;
    }
    return self;
}

- (NSHashTable<id<AlivcPlayManagerObserver>> *)observerTable {
    if (!_observerTable) {
        _observerTable = [NSHashTable weakObjectsHashTable];
    }
    return _observerTable;
}

- (id<AliyunIPlayerCallback>)callbackSource {
    return self;
}

- (void)play {
    [self.player play];
    [self onPlayStatusChanged];
}

- (void)pause {
    [self.player pause];
    [self onPlayStatusChanged];
}

- (void)stop {
    [self.player stop];
    [self onPlayStatusChanged];
}

- (void)replay {
    [self.player replay];
    [self onPlayStatusChanged];
}

- (void)seek:(float)time {
    [self.player seek:time];
    [self onPlayStatusChanged];
}

- (double)getDuration {
    return [self.player getDuration];
}

- (double)getCurrentTime {
    return [self.player getCurrentTime];
}

- (BOOL)isPlaying {
    return self.player.isPlaying;
}

- (void)refreshPlayState {
    [self onPlayStatusChanged];
    [self playProgress:0 streamProgress:0];
}

- (void)addObserver:(id<AlivcPlayManagerObserver>)observer {
    [self.observerTable addObject:observer];
    if ([self.observerTable containsObject:observer])
    {
        return;
    }
    [self.observerTable addObject:observer];
}

- (void)removeObserver:(id<AlivcPlayManagerObserver>)observer {
    [self.observerTable removeObject:observer];
}

- (void)onPlayStatusChanged {
    NSEnumerator<id<AlivcPlayManagerObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playStatus:)])
        {
            [observer playStatus:self.isPlaying];
        }
    }
}

#pragma AliyunIPlayerCallback

- (void)playerDidEnd {
    NSEnumerator<id<AlivcPlayManagerObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playerDidEnd)])
        {
            [observer playerDidEnd];
        }
    }
}

- (void)playProgress:(double)playSec streamProgress:(double)streamSec {
    double progress = self.player.getCurrentTime / self.player.getDuration;
    NSEnumerator<id<AlivcPlayManagerObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playProgress:)])
        {
            [observer playProgress:progress];
        }
    }
}

- (void)playError:(int)errorCode {
    NSEnumerator<id<AlivcPlayManagerObserver>>* enumerator = [self.observerTable objectEnumerator];
    id observer = nil;
    while ((observer = [enumerator nextObject]))
    {
        if ([observer respondsToSelector:@selector(playError:)])
        {
            [observer playError:errorCode];
        }
    }
}


@end
