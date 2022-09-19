//
//  AliyunDraftRenameView.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/12.
//

#import "AliyunDraftRenameView.h"
#import "AliyunDraftBundle.h"

@interface AliyunDraftRenameView () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLengthLimitLabel;
@property (nonatomic, assign) int curTitleLen;
@end

@implementation AliyunDraftRenameView

static const int MaxLen = 50;

+ (AliyunDraftRenameView *) LoadFromNib {
    return [AliyunDraftBundle.main loadNibNamed:@"AliyunDraftRenameView" owner:nil options:nil].firstObject;
}

- (void) awakeFromNib {
    [super awakeFromNib];
    self.title = @"";
}

- (void) setTitle:(NSString *)title {
    _titleTextField.text = title;
    self.curTitleLen = (int)title.length;
}

- (NSString *) title {
    return _titleTextField.text;
}

- (void) close {
    if ([_delegate respondsToSelector:@selector(onAliyunDraftRenameViewDidClose:)]) {
        [_delegate onAliyunDraftRenameViewDidClose:self];
    }
}

- (IBAction)closeDidPressed:(UIButton *)sender {
    [self close];
}

- (IBAction)confirmDidPressed:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(onAliyunDraftRenameViewDidConfirm:title:)]) {
        [_delegate onAliyunDraftRenameViewDidConfirm:self title:self.title];
    }
    [self close];
}

- (void) setCurTitleLen:(int)curTitleLen
{
    _curTitleLen = curTitleLen;
    _titleLengthLimitLabel.text = [NSString stringWithFormat:@"%d/%d", curTitleLen, MaxLen];
}

// MARK: - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSMutableString *text = textField.text.mutableCopy;
    [text replaceCharactersInRange:range withString:string];
    if (text.length <= MaxLen) {
        self.curTitleLen = (int)text.length;
        return YES;
    }
    return NO;
}
@end

typedef void(^ConfirmFunc)(NSString *);
@interface AliyunDraftRenameWindow () <AliyunDraftRenameViewDelegate>
@property (nonatomic, strong) UIView *bgView;
@property (nonatomic, assign) BOOL isShow;
@property (nonatomic, copy) ConfirmFunc confirm;
@end

@implementation AliyunDraftRenameWindow

+ (AliyunDraftRenameWindow *) ShowOn:(UIView *)view
                           withTitle:(NSString *)title
                             confirm:(void(^)(NSString *title))confirm
{
    AliyunDraftRenameWindow *win = [[AliyunDraftRenameWindow alloc] initWithFrame:view.bounds];
    win.renameView.title = title;
    win.confirm = confirm;
    [view addSubview:win];
    win.isShow = YES;
    return win;
}

- (void) dealloc
{
    [NSNotificationCenter.defaultCenter removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _bgView = [[UIView alloc] initWithFrame:frame];
        _bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.6];
        [self addSubview:_bgView];
        _bgView.alpha = 0.0;
        
        _renameView = [AliyunDraftRenameView LoadFromNib];
        _renameView.delegate = self;
        [self addSubview:_renameView];
        _renameView.center = self.center;
        _renameView.alpha = 0.0;
        
        [NSNotificationCenter.defaultCenter addObserver:self
                                               selector:@selector(onKeyboardDidChange:)
                                                   name:UIKeyboardWillChangeFrameNotification
                                                 object:nil];
    }
    return self;
}

- (void) onKeyboardDidChange:(NSNotification *)notify
{
    NSDictionary *keyBoardDict = notify.userInfo;
    CGRect endKeyBoardFrame = [keyBoardDict[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [keyBoardDict[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    CGPoint center = self.center;
    center.y = endKeyBoardFrame.origin.y * 0.5;
    
    [UIView animateWithDuration:duration animations:^{
        self.renameView.center = center;
    }];
}

- (void) setIsShow:(BOOL)isShow
{
    if (_isShow == isShow) {
        return;
    }
    _isShow = isShow;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.bgView.alpha = isShow ? 1.0 : 0.0;
        self.renameView.alpha = isShow ? 1.0 : 0.0;
    } completion:^(BOOL finished) {
        if (isShow) {
            [self.renameView becomeFirstResponder];
        } else {
            [self removeFromSuperview];
        }
    }];
}

// MARk: - AliyunDraftRenameViewDelegate
- (void) onAliyunDraftRenameViewDidClose:(AliyunDraftRenameView *)renameView {
    self.isShow = NO;
}

- (void) onAliyunDraftRenameViewDidConfirm:(AliyunDraftRenameView *)renameView title:(NSString *)title {
    if (title.length == 0) {
        title = @"未命名草稿";
    }
    
    if (_confirm) {
        _confirm(title);
    }
}

- (UIView *) hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    if (!self.isShow) {
        return nil;
    }
    
    UIView *view = [super hitTest:point withEvent:event];
    if (view == _bgView) {
        [_renameView endEditing:YES];
    }
    
    return view;
}

@end
