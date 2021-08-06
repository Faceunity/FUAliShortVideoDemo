//
//  AliyunRollCaptionWordsController.h
//  AlivcCommon
//
//  Created by aliyun on 2021/3/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface AliyunRollCaptionWordsController : UIViewController

@property(nonatomic,weak) NSMutableArray *dataArr;

@property (nonatomic,copy) void (^didChangeWordsFinish)(NSArray *selDataArr);

@end

NS_ASSUME_NONNULL_END
