//
//  AliyunRecordParamTableViewCell.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordParamTableViewCell.h"
#import "UIImage+AlivcHelper.h"
#import "AlivcUIConfig.h"
#import "AliyunMediaConfig.h"
#import "AlivcTextField.h"
@interface AliyunRecordParamTableViewCell ()

/**
 标题显示控件
 */
@property (nonatomic, strong) UILabel *titleLabel;

/**
 输入框
 */
@property (nonatomic, strong) AlivcTextField *inputView;

/**
 提示显示控件
 */
@property (nonatomic, strong) UILabel *infoLabel;

/**
 开关控件
 */
@property (nonatomic, strong) UISwitch *switcher;

/**
 数据模型
 */
@property (nonatomic, strong) AliyunRecordParamCellModel *cellModel;

/**
 选中的按钮
 */
@property (nonatomic, weak) UIButton *selectButton;
@end

@implementation AliyunRecordParamTableViewCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = 2;
        _titleLabel.font = [UIFont systemFontOfSize:14];
        _titleLabel.textColor = [UIColor whiteColor];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        
        [self.contentView addSubview:_titleLabel];
        if ([reuseIdentifier isEqualToString:@"cellInput"]) {
            [self setupInputView];
        }else if([reuseIdentifier isEqualToString:@"switch"]){
            [self setupSwitchView];
        }else {
            [self setupButtonView];
        }
    }
    return self;
}

/**
 添加按钮类的子控件
 */
- (void)setupButtonView {
    
    CGFloat height = 36;
    CGFloat leftInsect = 15;
    CGFloat topInset = 45;
    CGFloat middleInsect = 22;
    CGFloat width = (ScreenWidth - 2*leftInsect - 2*middleInsect)/3;
    for (int i=0; i<_cellModel.buttonTitleArray.count; i++) {
        UIButton *btn = [[UIButton alloc] init];
        btn.layer.cornerRadius = 5;
        btn.layer.masksToBounds = YES;
        if ([_cellModel.placeHolder isEqualToString:_cellModel.buttonTitleArray[i]]) {
            btn.selected = YES;
            self.selectButton = btn;
        }
        btn.tag = i;
        [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [btn setTitle:_cellModel.buttonTitleArray[i] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage avc_imageWithColor:rgba(255, 255, 255, 0.1)] forState:UIControlStateNormal];
        [btn setBackgroundImage:[UIImage avc_imageWithColor:[AlivcUIConfig shared].kAVCThemeColor] forState:UIControlStateSelected];
        int row = i/3;
        int column = i%3;
        btn.frame = CGRectMake(leftInsect+column*(width+middleInsect), topInset+row*(height+leftInsect), width, height);
        [self.contentView addSubview:btn];
        while ([btn.titleLabel.text sizeWithAttributes:@{NSFontAttributeName:btn.titleLabel.font}].width>CGRectGetWidth(btn.frame)) {
            btn.titleLabel.font = [UIFont systemFontOfSize:([btn.titleLabel.font pointSize]-1)];
        }
    }
    
}


/**
 按钮的点击时间

 @param clickButton 点击的按钮
 */
- (void)btnClick:(UIButton *)clickButton{
    if(clickButton == self.selectButton){
        return;
    }
    clickButton.selected = YES;
    self.selectButton.selected = NO;
    self.selectButton = clickButton;
    _cellModel.placeHolder = [clickButton titleForState:UIControlStateNormal];
    if ([_cellModel.title isEqualToString:NSLocalizedString(@"视频质量", nil)]) {
        _cellModel.valueBlock((int)clickButton.tag);
    } else if ([_cellModel.title isEqualToString:NSLocalizedString(@"分辨率", nil)]) {
        CGFloat videoWidth = 360;
        if (clickButton.tag == 0) {
            videoWidth = 360;
        } else if (clickButton.tag == 1) {
            videoWidth = 480;
        } else if (clickButton.tag == 2) {
            videoWidth = 540;
        } else if (clickButton.tag == 3) {
            videoWidth = 720;
        }else{
            videoWidth = 0;
        }
        _cellModel.sizeBlock(videoWidth);
    } else if([_cellModel.title isEqualToString:NSLocalizedString(@"视频比例", nil)]){
        
        CGFloat videoRatio = 1.0;
        switch (clickButton.tag) {
            case 0:
                 videoRatio = 9.0/16.0;
                break;
            case 1:
                videoRatio = 3.0/4.0;
                break;
            case 2:
                videoRatio = 1.0;
                break;
            case 3:
                videoRatio = -1;
                break;
                
            default:
                videoRatio = 1.0;
                break;
        }

        _cellModel.ratioBack(videoRatio);
    } else if([_cellModel.title isEqualToString:NSLocalizedString(@"裁剪模式", nil)]){
        if (clickButton.tag == 0) {
            //裁剪
            _cellModel.valueBlock((int)AliyunMediaCutModeScaleAspectCut);
        }else{
            _cellModel.valueBlock((int)AliyunMediaCutModeScaleAspectFill);
        }
        
    } else if ([_cellModel.title isEqualToString:NSLocalizedString(@"视频编码方式", nil)]){
        _cellModel.encodeModelBlock(clickButton.tag);
    }else if ([_cellModel.title isEqualToString: NSLocalizedString(@"拍摄方式", nil) ]){
        if ([clickButton.titleLabel.text isEqualToString:NSLocalizedString(@"普通", nil)]) {
             _cellModel.recodeTypeBlock(AlivcRecordTypeNormal);
        }else {
            _cellModel.recodeTypeBlock(AlivcRecordTypeMerge);
        }
    }else if ([_cellModel.title isEqualToString: NSLocalizedString(@"高级美颜", nil) ]){
        if ([clickButton.titleLabel.text isEqualToString:NSLocalizedString(@"Race", nil)]) {
            _cellModel.beautyTypeBlock(0);
        }else {
            _cellModel.beautyTypeBlock(1);
        }
    }
}


/**
 添加带有输入框的子控件
 */
- (void)setupInputView {
    self.inputView = [[AlivcTextField alloc] init];
    _inputView.backgroundColor = rgba(255, 255, 255, 0.1);
    _inputView.borderStyle = UITextBorderStyleRoundedRect;
    _inputView.font = [UIFont systemFontOfSize:14];
    _inputView.textColor = [UIColor whiteColor];
    _inputView.keyboardType = UIKeyboardTypeNumberPad;
    
    [_inputView addTarget:self action:@selector(textFieldEditingChanged) forControlEvents:UIControlEventEditingChanged];
    [self.contentView addSubview:_inputView];
}


/**
 添加带有开关的子控件
 */
- (void)setupSwitchView{
    _switcher = [[UISwitch alloc] init];
    _switcher.tintColor = [AlivcUIConfig shared].kAVCThemeColor;
    _switcher.onTintColor = [AlivcUIConfig shared].kAVCThemeColor;
    _switcher.on = NO;
    [_switcher addTarget:self action:@selector(switchAction:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_switcher];
    
}


- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat midY  = CGRectGetMidY(self.contentView.bounds);
    CGFloat width = CGRectGetWidth(self.contentView.bounds);
    _titleLabel.frame = CGRectMake(30, 15, 120, 20);
    if ([self.reuseIdentifier isEqualToString:@"cellInput"]) {
        _inputView.frame = CGRectMake(15, 45, width - 30, 50);
    }else if ([self.reuseIdentifier isEqualToString:@"switch"]){
        _switcher.frame = CGRectMake(CGRectGetMaxX(_titleLabel.frame) + 20, 25, 54, 20);
        _titleLabel.frame = CGRectMake(30, 30, 120, 20);
    }else {
        _infoLabel.frame = CGRectMake(width - 70, midY - 10, 70, 20);
    }
}

- (void)configureCellModel:(AliyunRecordParamCellModel *)cellModel {
    _cellModel = cellModel;
    _titleLabel.text = cellModel.title;
    
    if ([cellModel.reuseId isEqualToString:@"cellInput"]) {
        NSMutableParagraphStyle *style = [_inputView.defaultTextAttributes[NSParagraphStyleAttributeName] mutableCopy];
        
        _inputView.text = cellModel.value == cellModel.defaultValue ? @"" : [NSString stringWithFormat:@"%d",(int)cellModel.value];
        
        
        _inputView.attributedPlaceholder = [[NSAttributedString alloc]initWithString:cellModel.placeHolder attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style,NSForegroundColorAttributeName:AlivcOxRGB(0xc3c5c6)}];
    }else{
         [self setupButtonView];
    }
    _infoLabel.text = cellModel.placeHolder;
    
}

/**
 textField 文字变化的时候调用的方法
 */
- (void)textFieldEditingChanged {
    CGFloat r;
    if([_inputView.text isEqualToString:@""]){
        r = self.cellModel.defaultValue;
    }else{
        r = [_inputView.text intValue];
    }
    _cellModel.value = r;
    _cellModel.valueBlock(r);
}


/**
 切换开关时调用的方法

 @param sender 开关
 */
-(void)switchAction:(id)sender
{
    UISwitch *switchButton = (UISwitch*)sender;
    BOOL isButtonOn = [switchButton isOn];
    if (isButtonOn) {
        _infoLabel.text = @"";
    }else {
        _infoLabel.text = @"";
    }
    _cellModel.switchBlock(isButtonOn);
}

- (void)dealloc {
    [self.inputView removeFromSuperview];
    self.inputView = nil;
}

@end

@implementation AliyunRecordParamCellModel


@end
