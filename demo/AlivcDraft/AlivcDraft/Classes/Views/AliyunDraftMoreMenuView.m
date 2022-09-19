//
//  AliyunDraftMoreMenuView.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/12.
//

#import "AliyunDraftMoreMenuView.h"
#import "AliyunDraftBundle.h"

@interface AliyunDraftMoreMenuView()
@property (weak, nonatomic) IBOutlet UIView *bgView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *containerOfCover;
@property (weak, nonatomic) IBOutlet UIView *containerOfRename;
@property (weak, nonatomic) IBOutlet UIView *containerOfSync;
@property (weak, nonatomic) IBOutlet UIView *containerOfCopy;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfCover;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfRename;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfSync;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightOfCopy;
@property (weak, nonatomic) IBOutlet UIView *containerOfDelete;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *deleteSafeBottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottom;

@property (nonatomic, assign) BOOL showingAnimation;
@end

@implementation AliyunDraftMoreMenuView

+ (AliyunDraftMoreMenuView *) LoadFromNib
{
    return [AliyunDraftBundle.main loadNibNamed:@"AliyunDraftMoreMenuView" owner:nil options:nil].firstObject;
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    
    _isShow = YES;
    self.isShow = NO;
}

- (void)setType:(AliyunDraftType)type {
    _type = type;
    if (type == AliyunDraftType_Cloud) {
        _containerOfRename.hidden = YES;
        _heightOfRename.constant = 0;
        _containerOfCopy.hidden = YES;
        _heightOfCopy.constant = 0;
        _containerOfSync.hidden = YES;
        _heightOfSync.constant = 0;
        _containerOfCover.hidden = YES;
        _heightOfCover.constant = 0;
    }
    else {
        CGFloat height = _containerOfDelete.frame.size.height;
        if (type == AliyunDraftType_Local) {
            _containerOfSync.hidden = NO;
            _heightOfSync.constant = height;
        }
        else {
            _containerOfSync.hidden = YES;
            _heightOfSync.constant = 0;
        }
        _containerOfRename.hidden = NO;
        _heightOfRename.constant = height;
        _containerOfCopy.hidden = NO;
        _heightOfCopy.constant = height;
        _containerOfCover.hidden = NO;
        _heightOfCover.constant = height;
    }
    
    [self layoutIfNeeded];
    self.isShow = _isShow;
}

- (void) setIsShow:(BOOL)isShow
{
    if (_isShow == isShow) {
        return;
    }
    
    _isShow = isShow;
    if (_isShow) {
        _showingAnimation = YES;
    }
    
    CGFloat height = self.containerView.frame.size.height;
    _containerBottom.constant = isShow ? 0 : height;
    _deleteSafeBottom.constant = isShow ? 0 : height;
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.alpha = isShow ? 1.0 : 0.0;
        [self updateConstraintsIfNeeded];
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.showingAnimation = self.isShow;
    }];
}

- (IBAction)editCoverDidPressed:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(onAliyunDraftMoreMenuViewDidUpdateCover:)]) {
        [_delegate onAliyunDraftMoreMenuViewDidUpdateCover:self];
    }
    self.isShow = NO;
}

- (IBAction)renameDidPressed:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(onAliyunDraftMoreMenuViewDidRename:)]) {
        [_delegate onAliyunDraftMoreMenuViewDidRename:self];
    }
    self.isShow = NO;
}

- (IBAction)syncDidPressed:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(onAliyunDraftMoreMenuViewDidSync:)]) {
        [_delegate onAliyunDraftMoreMenuViewDidSync:self];
    }
    self.isShow = NO;
}

- (IBAction)copyDidPressed:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(onAliyunDraftMoreMenuViewDidCopy:)]) {
        [_delegate onAliyunDraftMoreMenuViewDidCopy:self];
    }
    self.isShow = NO;
}

- (IBAction)deleteDidPressed:(UIButton *)sender
{
    if ([_delegate respondsToSelector:@selector(onAliyunDraftMoreMenuViewDidDelete:)]) {
        [_delegate onAliyunDraftMoreMenuViewDidDelete:self];
    }
    self.isShow = NO;
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (!self.isShow) {
        return (self.showingAnimation ? self : nil);
    }
    
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self.bgView) {
        self.isShow = NO;
        return view;
    }
    
    return view;
}

@end
