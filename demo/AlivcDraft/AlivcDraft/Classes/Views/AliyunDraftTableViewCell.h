//
//  AliyunDraftTableViewCell.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AliyunDraftTableViewCell;
@protocol AliyunDraftTableViewCellDelegate <NSObject>
@optional
- (void) onAliyunDraftTableViewCellDidClickMore:(AliyunDraftTableViewCell *)cell;
- (void) onAliyunDraftTableViewCellDidClickDownload:(AliyunDraftTableViewCell *)cell;
@end

typedef NS_ENUM(NSUInteger, AliyunDraftType) {
    AliyunDraftType_Local = 0,
    AliyunDraftType_Template = 1,
    AliyunDraftType_Cloud = 2,
};

@class AliyunDraftInfo;
@interface AliyunDraftTableViewCell : UITableViewCell
@property (nonatomic, weak) id<AliyunDraftTableViewCellDelegate> delegate;
@property (nonatomic, assign) AliyunDraftType type;
@property (nonatomic, strong) AliyunDraftInfo *draft;
@end

NS_ASSUME_NONNULL_END
