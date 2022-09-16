//
//  AliyunDraftMoreMenuView.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/12.
//

#import <UIKit/UIKit.h>
#import "AliyunDraftTableViewCell.h"

@class AliyunDraftMoreMenuView;
@protocol AliyunDraftMoreMenuViewDelegate <NSObject>
- (void) onAliyunDraftMoreMenuViewDidSync:(AliyunDraftMoreMenuView *)menuView;
- (void) onAliyunDraftMoreMenuViewDidUpdateCover:(AliyunDraftMoreMenuView *)menuView;
- (void) onAliyunDraftMoreMenuViewDidRename:(AliyunDraftMoreMenuView *)menuView;
- (void) onAliyunDraftMoreMenuViewDidCopy:(AliyunDraftMoreMenuView *)menuView;
- (void) onAliyunDraftMoreMenuViewDidDelete:(AliyunDraftMoreMenuView *)menuView;
@end

@class AliyunDraftInfo;
@interface AliyunDraftMoreMenuView : UIView
@property (nonatomic, weak) id<AliyunDraftMoreMenuViewDelegate> delegate;
@property (nonatomic, weak) AliyunDraftInfo *draft;
@property (nonatomic, assign) AliyunDraftType type;
@property (nonatomic, assign) BOOL isShow;

+ (AliyunDraftMoreMenuView *) LoadFromNib;
@end
