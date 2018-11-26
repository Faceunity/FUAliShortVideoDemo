//
//  QUConfigureViewController.m
//  AliyunVideo
//
//  Created by dangshuai on 17/1/12.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunConfigureViewController.h"
#import "AVC_ShortVideo_Config.h"
#import "AlivcUIConfig.h"
#import "AliyunRecordParamTableViewCell.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "AliyunCompositionViewController.h"
#if SDK_VERSION == SDK_VERSION_BASE
#import <AliyunVideoSDK/AliyunVideoSDK.h>
#else
#import "AliyunMediaConfig.h"
#import "AliyunMediator.h"
#import "AliyunVideoBase.h"
#import "AliyunVideoUIConfig.h"
#import "AliyunVideoCropParam.h"

#endif

@interface AliyunConfigureViewController ()

@property (nonatomic, strong) AliyunMediaConfig *mediaInfo;

@property (nonatomic, assign) CGFloat videoOutputRatio;
@property (nonatomic, assign) CGFloat videoOutputWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chineseHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@end

@implementation AliyunConfigureViewController
- (instancetype)init
{
    self = [super init];
    if (self) {

#if (SDK_VERSION == SDK_VERSION_BASE)
        [self setupSDKBaseVersionUI];
#else
        [self setupSDKUI];
#endif
    }
    return self;
}
#if (SDK_VERSION == SDK_VERSION_BASE)
- (void)setupSDKBaseVersionUI {
    AliyunVideoUIConfig *config = [[AliyunVideoUIConfig alloc] init];
    
    config.backgroundColor = RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.cutTopLineColor = [UIColor redColor];
    config.cutBottomLineColor = [UIColor redColor];
    config.noneFilterText = @"无滤镜";
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[@"炽黄",@"粉桃",@"海蓝",@"红润",@"灰白",@"经典",@"麦茶",@"浓烈",@"柔柔",@"闪耀",@"鲜果",@"雪梨",@"阳光",@"优雅",@"朝阳",@"波普",@"光圈",@"海盐",@"黑白",@"胶片",@"焦黄",@"蓝调",@"迷糊",@"思念",@"素描",@"鱼眼",@"马赛克",@"模糊"];
    config.imageBundleName = @"QPSDK";
    config.filterBundleName = @"FilterResource";
    config.recordType = AliyunVideoRecordTypeCombination;
    config.showCameraButton = NO;
    
    [[AliyunVideoBase shared] registerWithAliyunIConfig:config];
}
#else
- (void)setupSDKUI {
    
    AliyunIConfig *config = [[AliyunIConfig alloc] init];
    
    config.backgroundColor = RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[@"filter/炽黄",@"filter/粉桃",@"filter/海蓝",@"filter/红润",@"filter/灰白",@"filter/经典",@"filter/麦茶",@"filter/浓烈",@"filter/柔柔",@"filter/闪耀",@"filter/鲜果",@"filter/雪梨",@"filter/阳光",@"filter/优雅",@"filter/朝阳",@"filter/波普",@"filter/光圈",@"filter/海盐",@"filter/黑白",@"filter/胶片",@"filter/焦黄",@"filter/蓝调",@"filter/迷糊",@"filter/思念",@"filter/素描",@"filter/鱼眼",@"filter/马赛克",@"filter/模糊"];
    config.imageBundleName = @"QPSDK";
    config.recordType = AliyunIRecordActionTypeClick;
    config.filterBundleName = nil;
    config.showCameraButton = NO;
    
    [AliyunIConfig setConfig:config];
}

#endif
- (void)viewDidLoad {
    [super viewDidLoad];
    if (IPHONEX) {
        self.heightConstraint.constant = 88;
        self.chineseHeightConstraint.constant = 88;
    }else{
        self.heightConstraint.constant = 64;
        self.chineseHeightConstraint.constant = 64;
    }
   
    
    _mediaInfo = [AliyunMediaConfig defaultConfig];
    _mediaInfo.minDuration = 2.0;
    _mediaInfo.maxDuration = 10.0*60;
    _mediaInfo.fps = 25;
    _mediaInfo.gop = 5;
    _mediaInfo.cutMode = AliyunMediaCutModeScaleAspectFill;
    _mediaInfo.videoOnly = NO;
    _mediaInfo.backgroundColor = [UIColor blackColor];

    
    self.videoOutputRatio = _mediaInfo.outputSize.width * 1.0f / _mediaInfo.outputSize.height * 1.0f;
    self.videoOutputWidth = _mediaInfo.outputSize.width;
   
    [self setupParamData];
    [_tableView reloadData];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard:)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight-44-SafeBottom, ScreenWidth, 44)];
    if ([self.isClipConfig isEqualToString:@"YES"]) {
        [button setTitle:@"开启裁剪界面" forState:0];
    }else{
        [button setTitle:@"开启编辑界面" forState:0];
    }
    
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(buttonNextClick) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = AlivcOxRGB(0x00c1de);
    [self.view addSubview:button];

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
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



- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
}


- (void)hiddenKeyboard:(id)sender {
    [self.view endEditing:YES];
}

- (IBAction)buttonCencelCLick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)buttonNextClick{
    
    [self updatevideoOutputVideoSize];
    if ([self.isClipConfig isEqualToString:@"YES"]) {
    #if SDK_VERSION != SDK_VERSION_BASE
        [AliyunIConfig config].showCameraButton = NO;
    #endif
        UIViewController *vc = [[AliyunMediator shared] cropModule];
        [vc setValue:_mediaInfo forKey:@"cutInfo"];
        [vc setValue:self forKey:@"delegate"];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        AliyunCompositionViewController *targetVC = [[AliyunCompositionViewController alloc]init];
        targetVC.compositionConfig = _mediaInfo;
        if (self.videoOutputRatio == -1) {
            targetVC.isOriginal = YES;
        }else{
            targetVC.isOriginal = NO;
        }
        
        [self.navigationController pushViewController:targetVC animated:YES];
    }
}



-(IBAction)switchEncode:(UISwitch *)sender {
//    _mediaInfo.encodeMode = sender.on;
}

- (IBAction)switchCrop:(UISwitch *)sender {
    _mediaInfo.hasEnd = sender.on;
}



// 根据调节结果更新videoSize
- (void)updatevideoOutputVideoSize {
    
    CGFloat width = self.videoOutputWidth;
    CGFloat height = 0;
    if (self.videoOutputRatio != -1) {
        height = ceilf(self.videoOutputWidth / self.videoOutputRatio); // 视频的videoSize需为整偶数
    }
    _mediaInfo.outputSize = CGSizeMake(width, height);
    NSLog(@"videoSize:w:%f  h:%f", _mediaInfo.outputSize.width, _mediaInfo.outputSize.height);
    
}

#pragma mark - RecordViewControllerDelegate
- (void)exitRecord {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)recoderFinish:(UIViewController *)vc videopath:(NSString *)videoPath {
    
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
            if (error) {
                NSLog(@"录制完成，保存到相册失败");
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.navigationController popViewControllerAnimated:YES];
            });
        }];
}

#pragma mark - PhotoViewControllerDelgate
- (void)recodBtnClick:(UIViewController *)vc {
#if SDK_VERSION != SDK_VERSION_BASE
    [AliyunIConfig config].hiddenImportButton = YES;
#endif
//    self.isPhotoToRecord = YES;
    UIViewController *recordVC = [[AliyunMediator shared] recordViewController_Basic];
    [recordVC setValue:self forKey:@"delegate"];
    [recordVC setValue:[vc valueForKey:@"cutInfo"] forKey:@"quVideo"];
    [recordVC setValue:@(NO) forKey:@"isSkipEditVC"];
    [self.navigationController pushViewController:recordVC animated:YES];
}

- (void)videoBase:(AliyunVideoBase *)base cutCompeleteWithCropViewController:(UIViewController *)cropVC image:(UIImage *)image {
    //裁剪图片
    if (image) {
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}


- (void)cropFinished:(UIViewController *)cropViewController videoPath:(NSString *)videoPath sourcePath:(NSString *)sourcePath {
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"裁剪完成，保存到相册失败");
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪完成" message:@"已保存到手机相册" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [alert show];
        });
    }];
}

- (void)cropFinished:(UIViewController *)cropViewController mediaType:(kPhotoMediaType)type photo:(UIImage *)photo videoPath:(NSString *)videoPath {
    if (type == kPhotoMediaTypePhoto) {
        UIImageWriteToSavedPhotosAlbum(photo, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    }
}

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo {
    if(error != NULL){
        NSLog(@"裁剪完成，保存到相册失败");
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"裁剪完成" message:@"已保存到手机相册" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
        [alert show];
    });
}

- (void)backBtnClick:(UIViewController *)vc {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return _dataArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    AliyunRecordParamCellModel *model = _dataArray[indexPath.row];
    if ([model.reuseId isEqualToString:@"cellInput"]) {
        return 95;
    }else{
        if (indexPath.row == 6) {
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


- (void)setupParamData {
    
    AliyunRecordParamCellModel *cellModel0 = [[AliyunRecordParamCellModel alloc] init];
    cellModel0.title = @"帧率";
    cellModel0.placeHolder = @"建议20-30，默认25";
    cellModel0.reuseId = @"cellInput";
    cellModel0.valueBlock = ^(int value){
        _mediaInfo.fps = value;
    };
    
    AliyunRecordParamCellModel *cellModel1 = [[AliyunRecordParamCellModel alloc] init];
    cellModel1.title = @"关键帧间隔";
    cellModel1.placeHolder = @"建议1-300，默认5";
    cellModel1.reuseId = @"cellInput";
    cellModel1.valueBlock = ^(int value) {
        _mediaInfo.gop = value;
    };
    
    AliyunRecordParamCellModel *cellModel2 = [[AliyunRecordParamCellModel alloc] init];
    cellModel2.title = @"码率";
    cellModel2.placeHolder = @"默认值为0，根据视频质量参数计算";
    cellModel2.reuseId = @"cellInput";
    cellModel2.valueBlock = ^(int value){
        _mediaInfo.bitrate = value;
    };
    
    AliyunRecordParamCellModel *cellModel3 = [[AliyunRecordParamCellModel alloc] init];
    cellModel3.title = @"视频质量";
    cellModel3.buttonTitleArray = @[@"优质",@"良好",@"一般",@"较差"];
    cellModel3.placeHolder = @"优质";
    cellModel3.reuseId = @"cellSilder";
    cellModel3.defaultValue = 0.75;
    cellModel3.valueBlock = ^(int value){
        _mediaInfo.videoQuality = value;
    };
    
    AliyunRecordParamCellModel *cellModel4 = [[AliyunRecordParamCellModel alloc] init];
    cellModel4.title = @"视频比例";
    cellModel4.buttonTitleArray = @[@"9:16",@"3:4",@"1:1",@"原比例"];
    cellModel4.placeHolder = @"9:16";
    cellModel4.reuseId = @"cellSilder";
    cellModel4.defaultValue = 1.0;
    cellModel4.ratioBack = ^(CGFloat videoRatio){
        self.videoOutputRatio = videoRatio;
    };
    
    AliyunRecordParamCellModel *cellModel5 = [[AliyunRecordParamCellModel alloc] init];
    cellModel5.title = @"分辨率";
    cellModel5.buttonTitleArray = @[@"360p",@"480p",@"540p",@"720p"];
    cellModel5.placeHolder = @"720p";
    cellModel5.reuseId = @"cellSilder";
    cellModel5.defaultValue = 0.75;
    cellModel5.sizeBlock = ^(CGFloat videoWidth){
        self.videoOutputWidth = videoWidth;
    };
    
    AliyunRecordParamCellModel *cellModel6 = [[AliyunRecordParamCellModel alloc] init];
    cellModel6.title = @"裁剪模式";
    cellModel6.buttonTitleArray = @[@"画面裁剪",@"画面填充"];
    cellModel6.placeHolder = @"画面填充";
    cellModel6.reuseId = @"cellSilder";
    cellModel6.defaultValue = 0.75;
    cellModel6.valueBlock = ^(int value){
        _mediaInfo.cutMode = value;
    };
    
    AliyunRecordParamCellModel *cellModel7 = [[AliyunRecordParamCellModel alloc] init];
    cellModel7.title = @"片尾";
    cellModel7.reuseId = @"switch";
    cellModel7.switchBlock = ^(BOOL open){
        _mediaInfo.hasEnd = open;
    };
    if ([self.isClipConfig isEqualToString:@"YES"]) {
        _dataArray = @[cellModel0,cellModel1,cellModel2,cellModel3,cellModel4,cellModel5,cellModel6];
    }else{
        _dataArray = @[cellModel0,cellModel1,cellModel2,cellModel3,cellModel4,cellModel5,cellModel6,cellModel7];
    }
    
}
@end
