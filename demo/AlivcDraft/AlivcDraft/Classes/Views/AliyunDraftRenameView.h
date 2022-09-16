//
//  AliyunDraftRenameView.h
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/12.
//

#import <UIKit/UIKit.h>

@class AliyunDraftRenameView;
@protocol AliyunDraftRenameViewDelegate <NSObject>
- (void) onAliyunDraftRenameViewDidClose:(AliyunDraftRenameView *)renameView;
- (void) onAliyunDraftRenameViewDidConfirm:(AliyunDraftRenameView *)renameView title:(NSString *)title;
@end

@interface AliyunDraftRenameView : UIView
@property (nonatomic, weak) id<AliyunDraftRenameViewDelegate> delegate;
@property (nonatomic, copy) NSString *title;

+ (AliyunDraftRenameView *) LoadFromNib;
@end

@interface AliyunDraftRenameWindow : UIView
@property (nonatomic, strong, readonly) AliyunDraftRenameView *renameView;

+ (AliyunDraftRenameWindow *) ShowOn:(UIView *)view
                           withTitle:(NSString *)title
                             confirm:(void(^)(NSString *title))confirm;
@end
