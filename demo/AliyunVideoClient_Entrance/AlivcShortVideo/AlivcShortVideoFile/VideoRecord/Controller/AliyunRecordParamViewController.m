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
#import "AliyunMagicCameraViewController.h"
#import "AliyunMediaConfig.h"
#import "AliyunMediator.h"
#import "AlivcUIConfig.h"
#import "AlivcShortVideoRoute.h"

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

/**
 顶部view距离最顶部的约束
 */
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;

@end

@implementation AliyunRecordParamViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    Class c = NSClassFromString(@"AliyunEffectPrestoreManager");
    NSObject *prestore = (NSObject *)[[c alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [prestore performSelector:@selector(insertInitialData)];
#pragma clang diagnostic pop

    [AliyunIConfig config].hiddenImportButton = NO;
    self.automaticallyAdjustsScrollViewInsets = NO;
    [self setupParamData];
    [_tableView reloadData];
    self.heightConstraint.constant = SafeTop;
    self.tableViewBottomConstraint.constant = SafeBottom + 74;
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    _quVideo = [AliyunMediaConfig defaultConfig];
    _quVideo.minDuration = 2;
    _quVideo.maxDuration = 15;
   
    
    self.videoOutputRatio = 9.0f / 16.0f;
    self.videoOutputWidth = _quVideo.outputSize.width;
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight-44-SafeBottom, ScreenWidth, 44)];
    [button setTitle:@"开启录制界面" forState:0];
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(toRecordView) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = AlivcOxRGB(0x00c1de);
    [self.view addSubview:button];
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
    if ([model.reuseId isEqualToString:@"cellInput"]) {
        return 95;
    }else{
        if (indexPath.row == 5) {
            return 82;
        }else{
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
            return cell;
        }
        
    }
    return nil;
}


/**
 设置tableView的数据
 */
- (void)setupParamData {
    
    AliyunRecordParamCellModel *cellModel0 = [[AliyunRecordParamCellModel alloc] init];
    cellModel0.title = @"码率(bps)";
    cellModel0.placeHolder = @"默认为0，根据视频质量参数计算";
    cellModel0.reuseId = @"cellInput";
    cellModel0.valueBlock = ^(int value){
        _quVideo.bitrate = value;
    };

    
    AliyunRecordParamCellModel *cellModel1 = [[AliyunRecordParamCellModel alloc] init];
    cellModel1.title = @"最小时长";
    cellModel1.placeHolder = @"最小时长大于0，默认值2s";
    cellModel1.reuseId = @"cellInput";
    cellModel1.valueBlock = ^(int value){
        _quVideo.minDuration = value;
    };
    
    AliyunRecordParamCellModel *cellModel2 = [[AliyunRecordParamCellModel alloc] init];
    cellModel2.title = @"最大时长";
    cellModel2.placeHolder = @"不超过300S，默认值15s";
    cellModel2.reuseId = @"cellInput";
    cellModel2.valueBlock = ^(int value){
        _quVideo.maxDuration = value;
    };
    
    AliyunRecordParamCellModel *cellModel3 = [[AliyunRecordParamCellModel alloc] init];
    cellModel3.title = @"关键帧间隔";
    cellModel3.placeHolder = @"建议1-300，默认5";
    cellModel3.reuseId = @"cellInput";
    cellModel3.valueBlock = ^(int value) {
        _quVideo.gop = value;
    };
    
    AliyunRecordParamCellModel *cellModel4 = [[AliyunRecordParamCellModel alloc] init];
    cellModel4.title = @"视频质量";
    cellModel4.buttonTitleArray = @[@"优质",@"良好",@"一般",@"较差"];
    cellModel4.placeHolder = @"优质";
    cellModel4.reuseId = @"cellSilder";
    cellModel4.defaultValue = 0.75;
    cellModel4.valueBlock = ^(int value){
        _quVideo.videoQuality = value;
    };
    
    AliyunRecordParamCellModel *cellModel5 = [[AliyunRecordParamCellModel alloc] init];
    cellModel5.title = @"视频比例";
    cellModel5.buttonTitleArray = @[@"9:16",@"3:4",@"1:1"];
    cellModel5.placeHolder = @"9:16";
    cellModel5.reuseId = @"cellSilder";
    cellModel5.defaultValue = 1.0;
    cellModel5.ratioBack = ^(CGFloat videoRatio){
        self.videoOutputRatio = videoRatio;
    };
    
    AliyunRecordParamCellModel *cellModel6 = [[AliyunRecordParamCellModel alloc] init];
    cellModel6.title = @"分辨率";
    cellModel6.buttonTitleArray = @[@"360p",@"480p",@"540p",@"720p"];
    cellModel6.placeHolder = @"720p";
    cellModel6.reuseId = @"cellSilder";
    cellModel6.defaultValue = 0.75;
    cellModel6.sizeBlock = ^(CGFloat videoWidth){
        self.videoOutputWidth = videoWidth;
    };
    
    
    _dataArray = @[cellModel0,cellModel1,cellModel2,cellModel3,cellModel4,cellModel5,cellModel6];
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

    if((_quVideo.maxDuration == 0)&&(_quVideo.minDuration == 0)){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不小于最小时长" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if(_quVideo.minDuration == 0){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最小时长要大于0" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    
    if (_quVideo.maxDuration == -1) {
        _quVideo.maxDuration = 15;
    }
    if (_quVideo.minDuration == -1) {
        _quVideo.minDuration = 2;
    }
    if (_quVideo.maxDuration <= _quVideo.minDuration ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不小于最小时长" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    if (_quVideo.maxDuration > 300 ) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"最大时长不能超过300s" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
        return;
    }
    //配置
    [[AlivcShortVideoRoute shared]registerMediaConfig:_quVideo];
    UIViewController *record = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlRecord];
    [self.navigationController pushViewController:record animated:YES];
   
}
@end
