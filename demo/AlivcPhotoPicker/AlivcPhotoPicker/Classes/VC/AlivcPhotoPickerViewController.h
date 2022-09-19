//
//  AlivcPhotoPickerViewController.h
//  Pods
//
//  Created by mengyehao on 2021/11/10.
//

#import <UIKit/UIKit.h>

@class AliyunCompositionInfo;


@protocol AlivcPhotoPickerViewControllerDelegate <NSObject>

- (void)photoPickerViewControllerDidClickNextWithAssets:(NSArray<AliyunCompositionInfo *> *)assets;

- (void)photoPickerViewControllerDidClickCancel;

@end


typedef struct _AlivcVideoDurationRange {
    int min; //单位：秒
    int max;
} AlivcVideoDurationRange;

@interface AlivcPhotoPickerViewController : UIViewController

@property (nonatomic, copy) void(^didClickNextBlock)(NSArray<AliyunCompositionInfo *> * assets);
@property (nonatomic, copy) void(^didClickCancelBlock)(void);
@property (nonatomic, weak) id<AlivcPhotoPickerViewControllerDelegate>delegate;

@property (nonatomic, assign) int maxSelectCount; //0 表示不限制，默认0
@property (nonatomic, assign) BOOL allowPickingImage; //0 表示不限制，默认0
@property (nonatomic, assign) BOOL allowPickingVideo; //0 表示不限制，默认0
@property (nonatomic, assign) AlivcVideoDurationRange timeRange;// {0,0}为不限时长, 默认{0,0}

@end


