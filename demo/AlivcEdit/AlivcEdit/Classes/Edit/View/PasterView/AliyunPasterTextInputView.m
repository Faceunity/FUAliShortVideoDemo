//
//  AliyunPasterTextInputView.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/10.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterTextInputView.h"
#import "AliyunPasterTextStrokeView.h"
#import "AliyunImage.h"
#import "UIView+AlivcHelper.h"

@interface AliyunPasterTextInputView ()

@property (nonatomic, strong) UIView *borderView;
@property (nonatomic, strong) UIButton *closeButton;//关闭按钮

@end

@implementation AliyunPasterTextInputView
{
    CGFloat _keyboardHeight;//键盘高度
    AliyunColor *_color;
    NSString *_fontName;
    TextActionType _textActoinType;
}

#pragma mark - Life cycle -
- (id)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        _color = [[AliyunColor alloc] init];
        _color.tR = _color.tG = _color.tB = 255.0;
        _color.sR = _color.sG = _color.sB = 255.0;
        _color.isStroke = NO;
        _keyboardHeight = 258;
        [self addNotifications];
        [self addSubviews];
    }
    return self;
}

- (void)dealloc
{
    [self removeNotifications];
}

+ (id)createPasterTextInputView
{
    AliyunPasterTextInputView *pasterInputView = [[AliyunPasterTextInputView alloc] initWithFrame:CGRectMake(0, 0, 10, 46)];
    return pasterInputView;
}


- (void)addSubviews
{
    
    [self addVisualEffect];
    
    self.textView = [[AliyunPasterTextStrokeView alloc] initWithFrame:CGRectInset(self.bounds, 0, 5)];
    [self addSubview:self.textView];
    self.textView.font = [UIFont systemFontOfSize:16];
    self.textView.delegate = (id)self;
    self.textView.backgroundColor = [UIColor clearColor];
    self.textView.scrollEnabled = YES;
    self.textView.textColor = [UIColor whiteColor];
    self.textView.returnKeyType = UIReturnKeyDefault;
    
    self.textView.autocorrectionType = UITextAutocorrectionTypeNo;//关闭自动更正
    self.textView.spellCheckingType = UITextSpellCheckingTypeNo;  //关闭检查拼写
    
}

- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowAction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideAction:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShowAction:(NSNotification *)noti
{
    CGFloat animationDuration = [[[noti userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect keyboardFrame = [[[noti userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    _keyboardHeight = keyboardFrame.size.height;
    [self.delegate keyboardFrameChanged:keyboardFrame animateDuration:animationDuration];
}

- (void)keyboardWillHideAction:(NSNotification *)noti
{

}

- (void)setDelegate:(id<AliyunPasterTextInputViewDelegate>)delegate
{
    _delegate = delegate;
}

#pragma mark - Private Methods -

#pragma mark - Public Methods
- (NSString *)getText
{
    return self.textView.text;
}

- (void)setText:(NSString *)text
{
    self.textView.text = text;
}

- (void)shouldHiddenKeyboard
{
    [self.textView resignFirstResponder];
}

- (void)shouldAppearKeyboard
{
    [self.textView performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:.1];
}

#pragma mark -UITextViewDelegate -
- (void)textViewDidChange:(UITextView *)textView
{
    
    UITextRange *selectedRange = [textView markedTextRange];
    NSString * newText = [textView textInRange:selectedRange];
    if(newText.length>0) {
        return;
    }

    
    if ([self.delegate respondsToSelector:@selector(textInputViewTextDidChanged)]) {
        [self.delegate textInputViewTextDidChanged];
    }
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    return YES;
}


- (void)textViewDidBeginEditing:(UITextView *)textView
{
    NSLog(@"%s",__PRETTY_FUNCTION__);
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    return YES;
}


@end
