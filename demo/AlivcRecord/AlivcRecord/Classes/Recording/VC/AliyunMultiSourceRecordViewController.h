//
//  AliyunMultiSourceRecordViewController.h
//  AlivcRecord
//
//  Created by coder.pi on 2021/5/17.
//

#import <UIKit/UIKit.h>
#import "AlivcShortVideoRoute.h"

NS_ASSUME_NONNULL_BEGIN

@interface AliyunMultiSourceRecordViewController : UIViewController

/**
 视频参数配置
 */
@property (nonatomic, strong, nullable) AliyunMediaConfig *quVideo;

/**
 视频拍摄界面UI配置，可不传
 */
@property (nonatomic, strong, nullable) AlivcRecordUIConfig *uiConfig;

/**
 拍摄完成的回调
 */
@property (nonatomic, copy, nullable) AlivcRecordFinishBlock finishBlock;

@end

NS_ASSUME_NONNULL_END
