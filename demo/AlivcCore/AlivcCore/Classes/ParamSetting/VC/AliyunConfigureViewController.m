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

#import "AliyunVideoUIConfig.h"
#import "AliyunVideoBase.h"
#import "AliyunMediaConfig.h"
#import "AlivcShortVideoRoute.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AliyunMediator.h"

#if SDK_VERSION != SDK_VERSION_BASE

#import "AliyunVideoCropParam.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

#endif

@interface AliyunConfigureViewController ()

@property (nonatomic, strong) AliyunMediaConfig *mediaInfo;

@property (nonatomic, assign) CGFloat videoOutputRatio;
@property (nonatomic, assign) CGFloat videoOutputWidth;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *chineseHeightConstraint;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *dataArray;
@property (weak, nonatomic) IBOutlet UIButton *rightButton;
@property (weak, nonatomic) IBOutlet UILabel *paramTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;

@end

@implementation AliyunConfigureViewController

- (instancetype)init
{
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcCore.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
        
    self = [self initWithNibName:@"AliyunConfigureViewController" bundle:bundle];;
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
    config.noneFilterText = NSLocalizedString(@"无滤镜", nil);
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;
    config.filterArray = @[NSLocalizedString(@"炽黄", nil),NSLocalizedString(@"粉桃", nil),NSLocalizedString(@"海蓝", nil),NSLocalizedString(@"红润", nil),NSLocalizedString(@"灰白", nil),NSLocalizedString(@"经典", nil),NSLocalizedString(@"麦茶", nil),NSLocalizedString(@"浓烈", nil),NSLocalizedString(@"柔柔", nil),NSLocalizedString(@"闪耀", nil),NSLocalizedString(@"鲜果", nil),NSLocalizedString(@"雪梨", nil),NSLocalizedString(@"阳光", nil),NSLocalizedString(@"优雅", nil),NSLocalizedString(@"朝阳", nil),NSLocalizedString(@"波普", nil),NSLocalizedString(@"光圈", nil),NSLocalizedString(@"海盐", nil),NSLocalizedString(@"黑白", nil),NSLocalizedString(@"胶片", nil),NSLocalizedString(@"焦黄", nil),NSLocalizedString(@"蓝调", nil),NSLocalizedString(@"迷糊", nil),NSLocalizedString(@"思念", nil),NSLocalizedString(@"素描", nil),NSLocalizedString(@"鱼眼", nil),NSLocalizedString(@"马赛克", nil),NSLocalizedString(@"模糊", nil)];
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
//    config.filterArray = @[@"Filter/炽黄",@"Filter/粉桃",@"Filter/海蓝",@"Filter/红润",@"Filter/灰白",@"Filter/经典",@"Filter/麦茶",@"Filter/浓烈",@"Filter/柔柔",@"Filter/闪耀",@"Filter/鲜果",@"Filter/雪梨",@"Filter/阳光",@"Filter/优雅",@"Filter/朝阳",@"Filter/波普",@"Filter/光圈",@"Filter/海盐",@"Filter/黑白",@"Filter/胶片",@"Filter/焦黄",@"Filter/蓝调",@"Filter/迷糊",@"Filter/思念",@"Filter/素描",@"Filter/鱼眼",@"Filter/马赛克",@"Filter/模糊"];
//    config.imageBundleName = @"QPSDK";
    config.recordType = AliyunIRecordActionTypeClick;
    config.filterBundleName = nil;
    config.showCameraButton = NO;
    
    [AliyunIConfig setConfig:config];
}

#endif
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.paramTitleLabel.text = NSLocalizedString(@"导入参数", nil);
    if (IPHONEX) {
        self.heightConstraint.constant = 88;
        self.chineseHeightConstraint.constant = 88;
    }else{
        self.heightConstraint.constant = 64;
        self.chineseHeightConstraint.constant = 64;
    }

    self.rightButton.hidden = YES;
    
    _mediaInfo = [AliyunMediaConfig defaultConfig];
    _mediaInfo.minDuration = 2.0;
    _mediaInfo.maxDuration = 10.0*60;
    _mediaInfo.cutMode = AliyunMediaCutModeScaleAspectFill;
    _mediaInfo.videoOnly = NO;
    _mediaInfo.backgroundColor = [UIColor blackColor];
    _mediaInfo.gop = 250;

    
    self.videoOutputRatio = _mediaInfo.outputSize.width * 1.0f / _mediaInfo.outputSize.height * 1.0f;
    self.videoOutputWidth = _mediaInfo.outputSize.width;
   
    [self setupParamData];
    [_tableView reloadData];
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hiddenKeyboard:)];
    [self.tableView addGestureRecognizer:tapGesture];
    
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, ScreenHeight-44-SafeBottom, ScreenWidth, 44)];
    if ([self.isClipConfig isEqualToString:@"YES"]) {
        [button setTitle:NSLocalizedString(@"开启裁剪界面", nil) forState:0];
    }else{
        [button setTitle:NSLocalizedString(@"开启编辑界面", nil) forState:0];
    }
    
    button.titleLabel.font = [UIFont systemFontOfSize:16];
    [button addTarget:self action:@selector(buttonNextClick) forControlEvents:UIControlEventTouchUpInside];
    button.backgroundColor = AlivcOxRGB(0x00c1de);
    [self.backButton setImage:[AlivcImage imageNamed:@"back"] forState:UIControlStateNormal];
    [self.view addSubview:button];

}
- (IBAction)onClickRightButton:(UIButton *)sender {
    if ([[sender titleForState:UIControlStateNormal] isEqualToString:NSLocalizedString(@"硬编", nil)]) {
        [sender setTitle:NSLocalizedString(@"软编", nil) forState:UIControlStateNormal];
        _mediaInfo.encodeMode = AliyunEncodeModeSoftFFmpeg;
    }else{
        [sender setTitle:NSLocalizedString(@"硬编", nil) forState:UIControlStateNormal];
        _mediaInfo.encodeMode = AliyunEncodeModeHardH264;
    }
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
        [[AlivcShortVideoRoute shared]registerMediaConfig:_mediaInfo];
        UIViewController *vc = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlCrop];
        [vc setValue:self forKey:@"delegate"];
        [self.navigationController pushViewController:vc animated:YES];
    }else {
        [[AlivcShortVideoRoute shared]registerMediaConfig:_mediaInfo];
        UIViewController *targetVC = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlEditVideoSelect];
        if (self.videoOutputRatio == -1) {
            [targetVC setValue:@(YES) forKey:@"isOriginal"];
        }else{
            [targetVC setValue:@(NO) forKey:@"isOriginal"];
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
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
        NSLog(@"文件不存在!");
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:videoPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error) {
            NSLog(@"裁剪完成，保存到相册失败");
        }
        BOOL isVideoOK = UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(videoPath);
        if (!isVideoOK){
            NSLog(@"视频已损坏:%@",videoPath);
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"裁剪完成", nil) message:NSLocalizedString(@"已保存到手机相册", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//            [alert show];
            [[NSNotificationCenter defaultCenter] postNotificationName:kNotifySavedPhotosAlbumFinish object:nil];
            [MBProgressHUD showMessage:NSLocalizedString(@"已保存到手机相册", nil) inView:self.view];
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
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"裁剪完成", nil) message:NSLocalizedString(@"已保存到手机相册", nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
//        [alert show];
        [MBProgressHUD showMessage:NSLocalizedString(@"已保存到手机相册", nil) inView:self.view];
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
    }else if([model.reuseId isEqualToString:@"switch"] || [model.reuseId isEqualToString:@"switch_subtitle"]){
        return 60;
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


- (void)setupParamData {
    __weak typeof(self)weakSelf = self;
    
    AliyunRecordParamCellModel *cellModel0 = [[AliyunRecordParamCellModel alloc] init];
    cellModel0.title = NSLocalizedString(@"帧率", nil);
    cellModel0.placeHolder = NSLocalizedString(@"建议20-30，默认30", nil);
    cellModel0.reuseId = @"cellInput";
    cellModel0.valueBlock = ^(int value){
        weakSelf.mediaInfo.fps = value;
    };
    
    AliyunRecordParamCellModel *cellModel1 = [[AliyunRecordParamCellModel alloc] init];
    cellModel1.title = NSLocalizedString(@"关键帧间隔", nil);
    cellModel1.placeHolder = NSLocalizedString(@"建议1-300，默认250", nil);
    cellModel1.reuseId = @"cellInput";
    cellModel1.valueBlock = ^(int value) {
        weakSelf.mediaInfo.gop = value;
    };

    AliyunRecordParamCellModel *cellModel3 = [[AliyunRecordParamCellModel alloc] init];
    cellModel3.title = NSLocalizedString(@"视频质量", nil);
    cellModel3.buttonTitleArray = @[NSLocalizedString(@"优质", nil),NSLocalizedString(@"良好", nil),NSLocalizedString(@"一般", nil),NSLocalizedString(@"较差", nil)];
    cellModel3.placeHolder = NSLocalizedString(@"良好", nil);
    cellModel3.reuseId = @"cellSilder";
    cellModel3.defaultValue = 0.75;
    cellModel3.valueBlock = ^(int value){
        weakSelf.mediaInfo.videoQuality = value;
    };
    
    AliyunRecordParamCellModel *cellModel4 = [[AliyunRecordParamCellModel alloc] init];
    cellModel4.title = NSLocalizedString(@"视频比例", nil);
    cellModel4.buttonTitleArray = @[@"9:16",@"3:4",@"1:1",NSLocalizedString(@"原比例", nil)];
    cellModel4.placeHolder = @"9:16";
    cellModel4.reuseId = @"cellSilder";
    cellModel4.defaultValue = 1.0;
    cellModel4.ratioBack = ^(CGFloat videoRatio){
        weakSelf.videoOutputRatio = videoRatio;
    };
    
    AliyunRecordParamCellModel *cellModel5 = [[AliyunRecordParamCellModel alloc] init];
    cellModel5.title = NSLocalizedString(@"分辨率", nil);
    cellModel5.buttonTitleArray = @[@"360p",@"480p",@"540p",@"720p"];
    cellModel5.placeHolder = @"720p";
    cellModel5.reuseId = @"cellSilder";
    cellModel5.defaultValue = 0.75;
    cellModel5.sizeBlock = ^(CGFloat videoWidth){
        weakSelf.videoOutputWidth = videoWidth;
    };
    
    AliyunRecordParamCellModel *cellModel6 = [[AliyunRecordParamCellModel alloc] init];
    cellModel6.title = NSLocalizedString(@"裁剪模式", nil);
    cellModel6.buttonTitleArray = @[NSLocalizedString(@"画面裁剪", nil),NSLocalizedString(@"画面填充", nil)];
    cellModel6.placeHolder = NSLocalizedString(@"画面填充", nil);
    cellModel6.reuseId = @"cellSilder";
    cellModel6.defaultValue = 0.75;
    cellModel6.valueBlock = ^(int value){
        weakSelf.mediaInfo.cutMode = value;
    };
    
    AliyunRecordParamCellModel *cellModel6_1 = [[AliyunRecordParamCellModel alloc] init];
    cellModel6_1.title = NSLocalizedString(@"转码", nil);
    cellModel6_1.reuseId = @"switch_subtitle";
    cellModel6_1.placeHolder = @"当视频大于1080p时，转码到1080p下";
    cellModel6_1.switchBlock = ^(BOOL open){
        weakSelf.mediaInfo.needTransCode = open;
    };
    
    AliyunRecordParamCellModel *cellModel7 = [[AliyunRecordParamCellModel alloc] init];
    cellModel7.title = NSLocalizedString(@"片尾", nil);
    cellModel7.reuseId = @"switch";
    cellModel7.switchBlock = ^(BOOL open){
        weakSelf.mediaInfo.hasEnd = open;
    };
    
    AliyunRecordParamCellModel *cellModel9 = [[AliyunRecordParamCellModel alloc] init];
    cellModel9.title = NSLocalizedString(@"降噪", nil);
    cellModel9.reuseId = @"switch";
    cellModel9.switchBlock = ^(BOOL open){
        weakSelf.mediaInfo.denoise = open;
    };
    
    AliyunRecordParamCellModel *cellModel8 = [[AliyunRecordParamCellModel alloc] init];
    cellModel8.title = NSLocalizedString(@"视频编码方式", nil);
    cellModel8.buttonTitleArray = @[NSLocalizedString(@"硬编", nil),NSLocalizedString(@"软编", nil)];
    cellModel8.placeHolder = NSLocalizedString(@"硬编", nil);
    cellModel8.reuseId = @"cellSilder";
    cellModel8.encodeModelBlock = ^(NSInteger encodeMode) {
        weakSelf.mediaInfo.encodeMode = (AliyunEncodeMode)encodeMode;
    };
    if ([self.isClipConfig isEqualToString:@"YES"]) {
        _dataArray = @[cellModel0,cellModel1,cellModel3,cellModel4,cellModel5,cellModel6,cellModel6_1,cellModel8];
    }else{
        _dataArray = @[cellModel0,cellModel1,cellModel3,cellModel4,cellModel5,cellModel6,cellModel6_1,cellModel7, cellModel9,cellModel8];
    }
    
}
@end
