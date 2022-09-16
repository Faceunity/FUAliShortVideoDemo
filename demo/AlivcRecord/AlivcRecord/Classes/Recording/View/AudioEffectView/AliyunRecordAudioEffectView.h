//
//  AliyunRecordAudioEffectView.h
//  AlivcRecord
//
//  Created by coder.pi on 2021/10/9.
//

#import <UIKit/UIKit.h>
#import "AlivcAudioEffectView.h"

@class AliyunRecordAudioEffectView;
@protocol AliyunRecordAudioEffectViewDelegate <NSObject>
- (void) onAliyunRecordAudioEffectView:(AliyunRecordAudioEffectView *)view didSelect:(AlivcEffectSoundType)soundType;
@end

@interface AliyunRecordAudioEffectView : UIView
@property (nonatomic, weak) id<AliyunRecordAudioEffectViewDelegate> delegate;
@property (nonatomic, assign) AlivcEffectSoundType selectedType;
@property (nonatomic, assign) BOOL isShow;
@end
