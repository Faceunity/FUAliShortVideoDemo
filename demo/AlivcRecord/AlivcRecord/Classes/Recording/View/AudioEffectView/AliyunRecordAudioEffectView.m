//
//  AliyunRecordAudioEffectView.m
//  AlivcRecord
//
//  Created by coder.pi on 2021/10/9.
//

#import "AliyunRecordAudioEffectView.h"

@interface AliyunRecordAudioEffectView()<AlivcAudioEffectViewDelegate>
@property (nonatomic, strong) AlivcAudioEffectView *contentView;
@end

@implementation AliyunRecordAudioEffectView

- (instancetype) init {
    return [self initWithFrame:UIScreen.mainScreen.bounds];
}

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = UIColor.clearColor;
        _contentView = [[AlivcAudioEffectView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 185)];
        _contentView.delegate = self;
        [self addSubview:_contentView];
        self.hidden = YES;
        [self updateUI];
    }
    return self;
}

// MARK - AlivcAudioEffectViewDelegate
- (void)AlivcAudioEffectViewDidSelectCell:(AlivcEffectSoundType)type {
    if ([_delegate respondsToSelector:@selector(onAliyunRecordAudioEffectView:didSelect:)]) {
        [_delegate onAliyunRecordAudioEffectView:self didSelect:type];
    }
}

- (void) setSelectedType:(AlivcEffectSoundType)selectedType {
    _contentView.selectedType = selectedType;
}
- (AlivcEffectSoundType) selectedType {
    return _contentView.selectedType;
}

- (void) updateUI {
    CGRect frame = _contentView.frame;
    frame.origin.y = self.bounds.size.height;
    if (_isShow) {
        frame.origin.y -= frame.size.height;
    }
    _contentView.frame = frame;
}

- (void) setIsShow:(BOOL)isShow {
    if (_isShow == isShow) {
        return;
    }
    
    _isShow = isShow;
    if (isShow) {
        self.hidden = NO;
    }
    [UIView animateWithDuration:0.2
                     animations:^{
        [self updateUI];
    } completion:^(BOOL finished) {
        if (!isShow) {
            self.hidden = YES;
        }
    }];
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        self.isShow = NO;
    }
    return view;
}
@end
