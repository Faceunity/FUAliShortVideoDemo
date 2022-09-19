//
//  QURecordParamViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunRecordParamViewController.h"
#import "AliyunRecordParamTableViewCell.h"
#import "AVC_ShortVideo_Config.h"
#import <AssetsLibrary/AssetsLibrary.h>
//#import "AliyunMagicCameraViewController.h"
#import "AliyunMediaConfig.h"
#import "AlivcUIConfig.h"
#import "AlivcShortVideoRoute.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import "AliyunCompositionViewController.h"
#import "NSString+AlivcHelper.h"
#import "MBProgressHUD+AlivcHelper.h"
@interface AliyunRecordParamViewController ()<UITableViewDataSource,UITableViewDelegate>

/**
 tavleView的距离底部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewBottomConstraint;
    
/**
 中间view
 */
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/**
 数据模型数组
 */
@property (nonatomic, strong) NSArray *dataArray;

/**
 录制参数
 */
@property (nonatomic, strong) AliyunMediaConfig *quVideo;

/**
 分辨率
 */
@property (nonatomic, assign) CGFloat videoOutputWidth;

/**
 视频比例
 */
@property (nonatomic, assign) CGFloat videoOutputRatio;

@property (weak, nonatomic) IBOutlet UIButton *backButton;

/**
 录制方式
 */
@property (nonatomic, assign) AlivcRecordType recordType;

/**
 顶部view距离最顶部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) UIButton *recordButton;
@property (assign, nonatomic) CGFloat maxDuration;
@property (weak, nonatomic) IBOutlet UILabel *paramTitleLabel;
@end

@implementation AliyunRecordParamViewController

- (instancetype)init {
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcRecord.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    return [self initWithNibName:@"AliyunRecordParamViewController" bundle:bundle];
}
- (void)viewDidLoad {
    [super viewDidLoad];

    _quVideo = [AliyunMediaConfig defaultConfig];
    _quVideo.minDuration = 2;
    _maxDuration = 15;
    _quVideo.maxDuration = 15;
    _quVideo.gop = 30;
    
    self.paramTitleLabel.text = NSLocalizedString(@"录制参数", nil);
    [AliyunIConfig config].hiddenImportButton = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupParamData];
    [_tableView reloadData];
    self.heightConstraint.constant = SafeTop;
    self.tableViewBottomConstraint.constant = SafeBottom + 74;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard)];
    [self.tableView addGestureRecognizer:tapGesture];
   
    self.videoOutputRatio = 9.0f / 16.0f;
    self.videoOutputWidth = _quVideo.outputSize.width;
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight-44-SafeBottom, ScreenWidth, 44)];
    [button setTitle:NSLocalizedString(@"开启录制界面", nil) forState:0];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(toRecordView) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = AlivcOxRGB(0x00c1de);
    [self.view addSubview:button];
    [self.backButton setImage:[AlivcImage imageNamed:@"back"] forState:UIControlStateNormal];
    self.recordButton = button;
    self.rightButton.hidden = YES;

 
 
}

- (IBAction)rightButtonClick:(UIButton *)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"硬编", nil)]) {
        [sender setTitle:NSLocalizedString(@"软编", nil) forState:UIControlStateNormal];
        _quVideo.encodeMode = AliyunEncodeModeSoftFFmpeg;
    }else{
        [sender setTitle:NSLocalizedString(@"硬编", nil) forState:UIControlStateNormal];
        _quVideo.encodeMode = AliyunEncodeModeHardH264;
    }
}

/**
 控制器view的点击手势触发事件
 */
- (void)hiddenKeyboard {
    [self.view endEditing:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [[UIApplication sharedApplication] setStatusBarHidden:NO];

}

// 支持设备自动旋转
- (BOOL)shouldAutorotate
{
    return YES;
}

// 支持竖屏显示
- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark - UITableViewDelegate&&UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
     AliyunRecordParamCellModel *model = _dataArray[indexPath.row];
    if(model.btnEnable==1) {
        return 0;
    }else if ([model.reuseId isEqualToString:@"cellInput"]) {
        return 95;
    }else if([model.reuseId isEqualToString:@"switch"] || [model.reuseId isEqualToString:@"switch_subtitle"]){
        return 60;
    }else{
        if (indexPath.row == 4 || indexPath.row == 6 || indexPath.row == 7 || indexPath.row == 9 || indexPath.row == 10
            ||indexPath.row == 11 ||indexPath.row == 12) {
            return 82;
        }
        else{
            return 133;
        }
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    AliyunRecordParamCellModel *model = _dataArray[indexPath.row];
    if (model) {
        NSString *identifier = model.reuseId;
        if([identifier isEqualToString:@"cellInput"]){
            AliyunRecordParamTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
            if (!cell) {
                cell = [[AliyunRecordParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            }
            [cell configureCellModel:model];
            return cell;
        }else{
            AliyunRecordParamTableViewCell *cell = [[AliyunRecordParamTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
            [cell configureCellModel:model];
            cell.hidden = model.btnEnable==1;
            return cell;
        }
        
    }
    return nil;
}


/**
 设置tableView的数据
 */
- (void)setupParamData {
    __weak typeof(self)weakSelf = self;

    AliyunRecordParamCellModel *cellModel1 = [[AliyunRecordParamCellModel alloc] init];
    cellModel1.title = NSLocalizedString(@"最小时长", nil);
    cellModel1.placeHolder = NSLocalizedString(@"最小时长大于0，默认值2s", nil);
    cellModel1.reuseId = @"cellInput";
    cellModel1.defaultValue = 2;
    cellModel1.value = 2;
    cellModel1.valueBlock = ^(int value){
        weakSelf.quVideo.minDuration = value;
    };
    
    AliyunRecordParamCellModel *cellModel2 = [[AliyunRecordParamCellModel alloc] init];
    cellModel2.title = NSLocalizedString(@"最大时长", nil);
    cellModel2.placeHolder = NSLocalizedString(@"不超过300S，默认值15s", nil);
    cellModel2.reuseId = @"cellInput";
    cellModel2.defaultValue = 15;
    cellModel2.value = 15;
    cellModel2.valueBlock = ^(int value){
        weakSelf.quVideo.maxDuration = value;
        weakSelf.maxDuration = value;
    };
    
    AliyunRecordParamCellModel *cellModel3 = [[AliyunRecordParamCellModel alloc] init];
    cellModel3.title = NSLocalizedString(@"关键帧间隔", nil);
    cellModel3.placeHolder = NSLocalizedString(@"建议1-300，默认30", nil);
    cellModel3.reuseId = @"cellInput";
    cellModel3.defaultValue = 30;
    cellModel3.value = 30;
    cellModel3.valueBlock = ^(int value) {
        weakSelf.quVideo.gop = value;
    };
    
    AliyunRecordParamCellModel *cellModel4 = [[AliyunRecordParamCellModel alloc] init];
    cellModel4.title = NSLocalizedString(@"视频质量", nil);
    cellModel4.buttonTitleArray = @[NSLocalizedString(@"优质", nil),NSLocalizedString(@"良好", nil),NSLocalizedString(@"一般", nil),NSLocalizedString(@"较差", nil)];
    cellModel4.placeHolder = NSLocalizedString(@"良好", nil);
    cellModel4.reuseId = @"cellSilder";
    cellModel4.defaultValue = 0.75;
    cellModel4.value = 0.75;
    cellModel4.valueBlock = ^(int value){
        weakSelf.quVideo.videoQuality = value;
    };
    
    AliyunRecordParamCellModel *cellModel5 = [[AliyunRecordParamCellModel alloc] init];
    cellModel5.title = NSLocalizedString(@"视频比例", nil);
    cellModel5.buttonTitleArray = @[@"9:16",@"3:4",@"1:1"];
    cellModel5.placeHolder = @"9:16";
    cellModel5.reuseId = @"cellSilder";
    cellModel5.defaultValue = 1.0;
    cellModel5.value = 1.0;
    cellModel5.ratioBack = ^(CGFloat videoRatio){
        weakSelf.videoOutputRatio = videoRatio;
    };
    
    AliyunRecordParamCellModel *cellModel6 = [[AliyunRecordParamCellModel alloc] init];
    cellModel6.title = NSLocalizedString(@"分辨率", nil);
    cellModel6.buttonTitleArray = @[@"360p",@"480p",@"540p",@"720p"];
    cellModel6.placeHolder = @"720p";
    cellModel6.reuseId = @"cellSilder";
    cellModel6.defaultValue = 0.75;
    cellModel6.defaultValue = 0.75;
    cellModel6.sizeBlock = ^(CGFloat videoWidth){
        weakSelf.videoOutputWidth = videoWidth;
    };
    
    AliyunRecordParamCellModel *cellModel7 = [[AliyunRecordParamCellModel alloc] init];
    cellModel7.title = NSLocalizedString(@"视频编码方式", nil);
    cellModel7.buttonTitleArray = @[NSLocalizedString(@"硬编", nil),NSLocalizedString(@"软编", nil)];
    cellModel7.placeHolder = NSLocalizedString(@"硬编", nil);
    cellModel7.reuseId = @"cellSilder";
    cellModel7.encodeModelBlock = ^(NSInteger encodeMode) {
        weakSelf.quVideo.encodeMode = (AliyunEncodeMode)encodeMode;
    };
    
    AliyunRecordParamCellModel *cellModel8 = [[AliyunRecordParamCellModel alloc] init];
    cellModel8.title = NSLocalizedString(@"拍摄方式", nil);
    cellModel8.buttonTitleArray = @[NSLocalizedString(@"普通", nil),NSLocalizedString(@"合拍", nil),NSLocalizedString(@"多源", nil)];
    cellModel8.placeHolder = NSLocalizedString(@"普通", nil);
    cellModel8.reuseId = @"cellSilder";
    cellModel8.recodeTypeBlock = ^(AlivcRecordType recordType) {
        weakSelf.recordType = recordType;
        AliyunRecordParamCellModel *cellModel8_1 = weakSelf.dataArray[8];
        AliyunRecordParamCellModel *cellModel8_5 = weakSelf.dataArray[9];
        AliyunRecordParamCellModel *cellModel8_2 = weakSelf.dataArray[10];
        AliyunRecordParamCellModel *cellModel8_3 = weakSelf.dataArray[11];
        if (recordType == AlivcRecordTypeNormal){
            cellModel8_1.btnEnable = 1;
            cellModel8_5.btnEnable = 1;
            cellModel8_2.btnEnable = 1;
            cellModel8_3.btnEnable = 1;
        } else if(recordType==AlivcRecordTypeMerge){
            cellModel8_1.btnEnable = 2;
            cellModel8_5.btnEnable = 2;
            cellModel8_2.btnEnable = 2;
            cellModel8_3.btnEnable = 2;
        } else {
            cellModel8_1.btnEnable = 1;
            cellModel8_5.btnEnable = 1;
            cellModel8_2.btnEnable = 2;
            cellModel8_3.btnEnable = 2;
        }
        
#if SDK_VERSION == SDK_VERSION_CUSTOM
        AliyunRecordParamCellModel *cellModel9_3 = weakSelf.dataArray[13];
        AliyunRecordParamCellModel *cellModel9_2 = weakSelf.dataArray[14];
        AliyunRecordParamCellModel *cellModel9_4 = weakSelf.dataArray[15];
        AliyunRecordParamCellModel *cellModel9_5 = weakSelf.dataArray[16];
        AliyunRecordParamCellModel *cellModel9_6 = weakSelf.dataArray[17];
        if (recordType == AlivcRecordTypeNormal) {
            cellModel9_2.btnEnable = 1;
            cellModel9_3.btnEnable = 1;
            cellModel9_4.btnEnable = 1;
            cellModel9_5.btnEnable = 1;
            cellModel9_6.btnEnable = 1;

        } else if (recordType == AlivcRecordTypeMerge) {
            cellModel9_2.btnEnable = 2;
            cellModel9_3.btnEnable = 2;
            cellModel9_4.btnEnable = 2;
            cellModel9_5.btnEnable = 1;
            cellModel9_6.btnEnable = 1;

        } else {
            cellModel9_2.btnEnable = 2;
            cellModel9_3.btnEnable = 1;
            cellModel9_4.btnEnable = 1;
            cellModel9_5.btnEnable = 2;
            cellModel9_6.btnEnable = 2;
        }
#endif
        
        [weakSelf.tableView reloadData];
    };
    
    AliyunRecordParamCellModel *cellModel8_1 = [[AliyunRecordParamCellModel alloc] init];
    cellModel8_1.title = NSLocalizedString(@"合拍音频类型", nil);
    cellModel8_1.buttonTitleArray = @[NSLocalizedString(@"视频原音", nil), NSLocalizedString(@"录制声音", nil), NSLocalizedString(@"混音", nil),  NSLocalizedString(@"视频静音", nil)];
    cellModel8_1.placeHolder = NSLocalizedString(@"视频原音", nil);
    cellModel8_1.reuseId = @"cellSilder";
    cellModel8_1.btnEnable = 1;
    cellModel8_1.mixAudioSourceBlock = ^(int recordType) {
        weakSelf.quVideo.mixAudioType = recordType;
    };
    
    AliyunRecordParamCellModel *cellModel8_5 = [[AliyunRecordParamCellModel alloc] init];
    cellModel8_5.title = NSLocalizedString(@"合拍回声消除", nil);
    cellModel8_5.buttonTitleArray = @[NSLocalizedString(@"不设置", nil), NSLocalizedString(@"硬件回声消除", nil), NSLocalizedString(@"3A回声消除", nil)];
    cellModel8_5.placeHolder = NSLocalizedString(@"不设置", nil);
    cellModel8_5.reuseId = @"cellSilder";
    cellModel8_5.btnEnable = 1;
    cellModel8_5.mixAECTypeBlock = ^(int aecType) {
        weakSelf.quVideo.mixAECType = aecType;
    };
    
    AliyunRecordParamCellModel *cellModel8_2 = [[AliyunRecordParamCellModel alloc] init];
    cellModel8_2.title = NSLocalizedString(@"合拍背景颜色", nil);
    cellModel8_2.buttonTitleArray = @[NSLocalizedString(@"不设置", nil),NSLocalizedString(@"红色", nil),NSLocalizedString(@"绿色", nil)];
    cellModel8_2.placeHolder = NSLocalizedString(@"不设置", nil);
    cellModel8_2.reuseId = @"cellSilder";
    cellModel8_2.btnEnable = 1;
    cellModel8_2.mixBgColorBlock = ^(int type) {
        weakSelf.quVideo.mixbgColorType = type;
    };
    
    AliyunRecordParamCellModel *cellModel8_3 = [[AliyunRecordParamCellModel alloc] init];
    cellModel8_3.title = NSLocalizedString(@"合拍背景图片", nil);
    cellModel8_3.buttonTitleArray = @[NSLocalizedString(@"不设置", nil),NSLocalizedString(@"图片1", nil),NSLocalizedString(@"图片2", nil)];
    cellModel8_3.placeHolder = NSLocalizedString(@"不设置", nil);
    cellModel8_3.reuseId = @"cellSilder";
    cellModel8_3.btnEnable = 1;
    cellModel8_3.mixBgImgBlock = ^(int type) {
        weakSelf.quVideo.mixbgImgType = type;
        AliyunRecordParamCellModel *cellModel8_4 = weakSelf.dataArray[12];
        if (type==0) {
            cellModel8_4.btnEnable = 1;
        }else{
            cellModel8_4.btnEnable = 2;
        }
        [self.tableView reloadData];
    };
    
    AliyunRecordParamCellModel *cellModel8_4 = [[AliyunRecordParamCellModel alloc] init];
    cellModel8_4.title = NSLocalizedString(@"合拍背景图片填充模式", nil);
    cellModel8_4.buttonTitleArray = @[NSLocalizedString(@"比例填充", nil),NSLocalizedString(@"比例适配", nil),NSLocalizedString(@"拉伸填充", nil)];
    cellModel8_4.placeHolder = NSLocalizedString(@"比例填充", nil);
    cellModel8_4.reuseId = @"cellSilder";
    cellModel8_4.btnEnable = 1;
    cellModel8_4.mixBgImgScaleBlock = ^(int type) {
        weakSelf.quVideo.mixbgImgScaleType = type;
    };
    
    AliyunRecordParamCellModel *cellModel9 = [[AliyunRecordParamCellModel alloc] init];
    cellModel9.title = NSLocalizedString(@"退出删除录制片段", nil);
    cellModel9.reuseId = @"switch";
    cellModel9.switchBlock = ^(BOOL open){
        weakSelf.quVideo.deleteVideoClipOnExit = open;
    };

    AliyunRecordParamCellModel *cellModel9_0 = [[AliyunRecordParamCellModel alloc] init];
    cellModel9_0.title = NSLocalizedString(@"镜像输出", nil);
    cellModel9_0.reuseId = @"switch";
    cellModel9_0.switchBlock = ^(BOOL open){
        weakSelf.quVideo.videoFlipH = open;
    };
    
    AliyunRecordParamCellModel *cellModel9_2 = [[AliyunRecordParamCellModel alloc] init];
    cellModel9_2.title = NSLocalizedString(@"视频边框", nil);
    cellModel9_2.reuseId = @"switch";
    cellModel9_2.switchBlock = ^(BOOL open){
        weakSelf.quVideo.hasVideoBorder = open;
    };
    
    AliyunRecordParamCellModel *cellModel9_3 = [[AliyunRecordParamCellModel alloc] init];
    cellModel9_3.title = NSLocalizedString(@"合拍视频在最顶层", nil);
    cellModel9_3.reuseId = @"switch";
    cellModel9_3.switchBlock = ^(BOOL open){
        weakSelf.quVideo.isMixVideoTopLayer = open;
    };
    
    
    AliyunRecordParamCellModel *cellModel9_4 = [[AliyunRecordParamCellModel alloc] init];
    cellModel9_4.title = NSLocalizedString(@"转码", nil);
    cellModel9_4.reuseId = @"switch_subtitle";
    cellModel9_4.btnEnable = 1;
    cellModel9_4.placeHolder = @"当视频大于540p时，转码到540p下";//1080p的一半
    cellModel9_4.switchBlock = ^(BOOL open){
        weakSelf.quVideo.needTransCode = open;
    };
    
    AliyunRecordParamCellModel *cellModel9_5 = [[AliyunRecordParamCellModel alloc] init];
    cellModel9_5.title = NSLocalizedString(@"合拍视频", nil);
    cellModel9_5.reuseId = @"switch";
    cellModel9_5.switchBlock = ^(BOOL open){
        weakSelf.quVideo.needMixVideo = open;
    };
    
    AliyunRecordParamCellModel *cellModel9_6 = [[AliyunRecordParamCellModel alloc] init];
    cellModel9_6.title = NSLocalizedString(@"回声消除", nil);
    cellModel9_6.reuseId = @"switch";
    cellModel9_6.switchBlock = ^(BOOL open){
        weakSelf.quVideo.mixAECType = open;
    };

    AliyunRecordParamCellModel *cellModel10 = [[AliyunRecordParamCellModel alloc] init];
    cellModel10.title = NSLocalizedString(@"高级美颜", nil);
    if (isRace) {
         cellModel10.buttonTitleArray = @[NSLocalizedString(@"Queen", nil)];
    }else {
        cellModel10.buttonTitleArray = @[NSLocalizedString(@"Queen", nil),NSLocalizedString(@"FaceUnity", nil)];
    }
    
    cellModel10.placeHolder = NSLocalizedString(@"Queen", nil);
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AlivcBeautyType_cell"];
    cellModel10.reuseId = @"cellSilder";
    cellModel10.beautyTypeBlock = ^(NSInteger beautyType) {
        weakSelf.quVideo.beautyType = (AlivcBeautyType)beautyType;
        if (beautyType == 1) {
            [[NSUserDefaults standardUserDefaults] setObject:@"FaceUnity" forKey:@"AlivcBeautyType_cell"];
        }else {
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"AlivcBeautyType_cell"];
        }
    };

#if SDK_VERSION == SDK_VERSION_CUSTOM
    _dataArray = @[cellModel1,cellModel2,cellModel3,cellModel4,cellModel5,cellModel6,cellModel7,cellModel8,cellModel8_1,cellModel8_5,cellModel8_2,cellModel8_3,cellModel8_4,cellModel9_3,cellModel9_2,cellModel9_4,cellModel9_5,cellModel9_6,cellModel9_0,cellModel9,cellModel10];
#else
    [[NSUserDefaults standardUserDefaults] setObject:@"FaceUnity" forKey:@"AlivcBeautyType_cell"];
    self.quVideo.beautyType = AlivcBeautyTypeFaceUnity;
    _dataArray = @[cellModel1,cellModel2,cellModel3,cellModel4,cellModel5,cellModel6,cellModel7,cellModel8,cellModel8_1,cellModel8_5,cellModel8_2,cellModel8_3,cellModel8_4];
#endif
    
    
}

// 根据调节结果更新videoSize
- (void)updatevideoOutputVideoSize {
    
    CGFloat width = self.videoOutputWidth;
    CGFloat height = ceilf(self.videoOutputWidth / self.videoOutputRatio); // 视频的videoSize需为整偶数
    _quVideo.outputSize = CGSizeMake(width, height);
    NSLog(@"videoSize:w:%f  h:%f", _quVideo.outputSize.width, _quVideo.outputSize.height);
}

/**
 返回按钮的点击事件

 @param sender 返回按钮
 */
- (IBAction)buttonBackClick:(id)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

/**
 进入录制界面
 */
- (void)toRecordView {
    [self.view endEditing:YES];
    
    [self updatevideoOutputVideoSize];
    _quVideo.maxDuration = self.maxDuration;
    if((_quVideo.maxDuration == 0)&&(_quVideo.minDuration == 0)){
        [MBProgressHUD showWarningMessage:NSLocalizedString(@"最大时长不小于最小时长", nil) inView:self.view];
        return;
    }
    
    if(_quVideo.minDuration <= 0){
        [MBProgressHUD showWarningMessage:NSLocalizedString(@"最小时长要大于0", nil) inView:self.view];
        return;
    }
    
    
    if (_quVideo.maxDuration <= _quVideo.minDuration ) {
        [MBProgressHUD showWarningMessage:NSLocalizedString(@"最大时长不小于最小时长", nil) inView:self.view];
        return;
    }
    if (_quVideo.maxDuration > 300 ) { 
        [MBProgressHUD showWarningMessage:NSLocalizedString(@"最大时长不能超过300s", nil) inView:self.view];
        
        return;
    }
     __weak typeof(self) weakSelf = self;
    [self requestAuthorizataion:^(BOOL result) {
        if (!result) {
            return;
        }
        if (weakSelf.recordType == AlivcRecordTypeNormal) {
            //配置
            [[AlivcShortVideoRoute shared]registerMediaConfig:weakSelf.quVideo];
            UIViewController *record = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlRecord];
            [weakSelf.navigationController pushViewController:record animated:YES];
        }else if (weakSelf.recordType == AlivcRecordTypeMerge) {
            //合拍
            AliyunCompositionViewController *targetVC = [[AliyunCompositionViewController alloc]init];
            
            weakSelf.quVideo.videoOnly = YES;
            //        _quVideo.minDuration = 2;
            weakSelf.quVideo.maxDuration = 31;
            targetVC.compositionConfig = weakSelf.quVideo;
            targetVC.controllerType = AlivcCompositionViewControllerTypeVideoMix;
            
            [weakSelf.navigationController pushViewController:targetVC animated:YES];
        }else if (weakSelf.recordType == AlivcRecordTypeMultiSource) {
            // 多源录制
            if (weakSelf.quVideo.needMixVideo) {
                AliyunCompositionViewController *targetVC = [[AliyunCompositionViewController alloc]init];
                weakSelf.quVideo.videoOnly = YES;
                weakSelf.quVideo.minDuration = 2;
                weakSelf.quVideo.maxDuration = 31;
                targetVC.compositionConfig = weakSelf.quVideo;
                targetVC.controllerType = AlivcCompositionViewControllerTypeVideoMultiRec;
                [weakSelf.navigationController pushViewController:targetVC animated:YES];
            } else {
                [[AlivcShortVideoRoute shared] registerMediaConfig:weakSelf.quVideo];
                UIViewController *record = [AlivcShortVideoRoute.shared alivcViewControllerWithType:AlivcViewControlMultiSourceRecord];
                [weakSelf.navigationController pushViewController:record animated:YES];
            }
        }
    }];
    
}


- (void)requestAuthorizataion:(void (^)(BOOL result))handler{
     __weak typeof(self) weakSelf = self;
    [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
        if (granted) {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                if (granted) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                       handler(YES);
                    });
                   
                }else {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf showAVAuthorizationAlertWithMediaType:AVMediaTypeAudio];
                         handler(NO);
                    });
                }
            }];
        }else {
            dispatch_async(dispatch_get_main_queue(), ^{
                 [weakSelf showAVAuthorizationAlertWithMediaType:AVMediaTypeVideo];
                 handler(NO);
            });
        }
       
    }];
}

//显示一个权限弹窗
-(void)showAVAuthorizationAlertWithMediaType:(AVMediaType)mediaType{
    NSString *title =[@"打开相机失败" localString];
    NSString *message =[@"摄像头无权限" localString];
    if (mediaType == AVMediaTypeAudio) {
        title = [@"获取麦克风权限失败" localString];
        message =[@"麦克风无权限" localString];
    }
     __weak typeof(self) weakSelf = self;
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action1 =[UIAlertAction actionWithTitle:[@"取消" localString] style:UIAlertActionStyleDestructive handler:nil];
    UIAlertAction *action2 =[UIAlertAction actionWithTitle:[@"设置" localString] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [weakSelf goSetting];
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)goSetting {
     [[UIApplication sharedApplication]openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
}

#pragma mark - setter & getter
- (void)setRecordType:(AlivcRecordType)recordType {
    _recordType = recordType;
    if (recordType == AlivcRecordTypeNormal || recordType == AlivcRecordTypeMultiSource) {
        [self.recordButton setTitle:NSLocalizedString(@"开启录制界面", nil) forState:0];
    } else {
        [self.recordButton setTitle:NSLocalizedString(@"选择合拍视频", nil) forState:0];
    }
}

- (void)dealloc {
    NSLog(@"---------- AliyunRecordParamViewController dealloc -----------");
}
@end
