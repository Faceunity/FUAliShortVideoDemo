//
//  QUCompositionViewController.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCompositionViewController.h"
#import "UIDevice+AlivcInfo.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import <AliyunVideoSDKPro/AliyunErrorCode.h>
#import <MBProgressHUD/MBProgressHUD.h>
#if (SDK_VERSION != SDK_VERSION_BASE)
#import <AliyunVideoSDKPro/AliyunImporter.h>
#import <AliyunVideoSDKPro/AliyunNativeParser.h>
#endif

#import "AliyunImportHeaderView.h"
#import "AliyunAlbumViewController.h"
#import "AliyunCompositionCell.h"
#import "AliyunCompositionPickView.h"
#import "AliyunPhotoLibraryManager.h"
#import "AliyunCompositionInfo.h"
#import "AliyunPathManager.h"
#import "AVAsset+VideoInfo.h"
#import "AliyunCompressManager.h"
#import "AliyunMediator.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcShortVideoRoute.h"
#import "AlivcShortVideoTempSave.h"

//#import "AlivcShortVideoPublishManager.h"

#import "AlivcDefine.h"
#import "AVC_ShortVideo_Config.h"

#if (SDK_VERSION == SDK_VERSION_BASE)
#import "AliyunVideoUIConfig.h"
#import "AliyunVideoBase.h"
#endif

@interface AliyunCompositionViewController () <AliyunImportHeaderViewDelegate, AliyunCompositionPickViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) AliyunImportHeaderView *headerView;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) AliyunCompositionPickView *pickView;
@property (nonatomic, strong) NSArray<AliyunAssetModel *> *libraryDataArray;
@property (nonatomic, strong) AliyunCompositionInfo *cropCompositionInfo;
@property (nonatomic, strong) AliyunCompressManager *manager;
@property (nonatomic, strong) AliyunNativeParser *parser;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation AliyunCompositionViewController
{
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
#if (SDK_VERSION == SDK_VERSION_BASE)
        [self setupSDKBaseVersionUI];
#else
        [self setupSDKUI];
#endif
        self.view.clipsToBounds =YES;
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
    
    if (!self.isOriginal) {
        //保证分辨率为正偶数
        _compositionConfig.outputSize = [_compositionConfig fixedSize];
    }
    [self setupSubviews];
    
    [AliyunPathManager clearDir:[AliyunPathManager compositionRootDir]];
    
    [self fetchPhotoData];
}

- (void)fetchPhotoData {
    __weak typeof(self)weakSelf =self;
    [[AliyunPhotoLibraryManager sharedManager] requestAuthorization:^(BOOL authorization) {
        if (authorization) {
            dispatch_async(dispatch_get_main_queue(), ^{
                VideoDurationRange duration = {weakSelf.compositionConfig.minDuration, weakSelf.compositionConfig.maxDuration};
                BOOL videoOnly = weakSelf.compositionConfig.videoOnly;
                
                [[AliyunPhotoLibraryManager sharedManager] getCameraRollAssetWithallowPickingVideo:YES allowPickingImage:!videoOnly durationRange:duration completion:^(NSArray<AliyunAssetModel *> *models, NSInteger videoCount) {
                    weakSelf.libraryDataArray = models;
                    [weakSelf.collectionView reloadData];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [weakSelf.collectionView reloadData];
//                    });
                    
                }];
            });
        }
    }];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    //设置合拍分辨率 720 * 640
    if (self.controllerType == AlivcCompositionViewControllerTypeVideoMix) {
        _compositionConfig.outputSize = CGSizeMake(720, 640);
    }
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.manager stopCompress];
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
- (void)setupSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = RGBToColor(35, 42, 66);
    CGFloat top =  IS_IPHONEX ? 24 : 0;
    AliyunImportHeaderView *headerView = [[AliyunImportHeaderView alloc] initWithFrame:CGRectMake(0, top, ScreenWidth, 64)];
    self.headerView = headerView;
    self.headerView.delegate = self;
    [self.headerView setTitle:NSLocalizedString(@"相机胶卷", nil)];
    [self.view addSubview:self.headerView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat w = (ScreenWidth - (4 * 3))/ 4.0;
    layout.itemSize = CGSizeMake(w, w);
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 3;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:
    CGRectMake(0, 64+top, ScreenWidth, ScreenHeight-64-140-SafeBottom-top) collectionViewLayout:layout];
    self.collectionView = collectionView;
    self.collectionView.backgroundColor = RGBToColor(35, 42, 66);
    [self.collectionView registerClass:[AliyunCompositionCell class] forCellWithReuseIdentifier:@"AliyunCompositionCell"];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    AliyunCompositionPickView *pickView = [[AliyunCompositionPickView alloc] initWithFrame:CGRectMake(0, ScreenHeight-140-SafeBottom, ScreenWidth, 140)];
    self.pickView = pickView;
    self.pickView.delegate = self;
    [self.view addSubview:self.pickView];
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _libraryDataArray.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AliyunCompositionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunCompositionCell" forIndexPath:indexPath];
    _selectedIndexPath = indexPath;
    AliyunAssetModel *model = _libraryDataArray[indexPath.item];
    cell.labelDuration.text = model.timeLength;
    cell.labelDuration.hidden = model.type == 0;
    cell.imageView.image = nil;
    if (model.fetchThumbnail) {
        cell.imageView.image = model.thumbnailImage;
    } else {
        [[AliyunPhotoLibraryManager sharedManager] getPhotoWithAsset:model.asset thumbnailImage:YES photoWidth:80 completion:^(UIImage *photo, NSDictionary *info) {
            if(photo) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    model.fetchThumbnail = YES;
                    model.thumbnailImage = photo;
                    cell.imageView.image = photo;
                    
                });
            }
        }];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunAssetModel *asset = _libraryDataArray[indexPath.item];
    if (asset.asset.pixelWidth+asset.asset.pixelHeight <=0) {//防止一些text等非媒体文件手动改成png等媒体文件格式传进来
        [MBProgressHUD showMessage:NSLocalizedString(@"文件已损坏", nil) inView:self.view];
        return;
    }
    
    if (self.controllerType == AlivcCompositionViewControllerTypeVideoMix) {
        [self.pickView removeAssetsAtIndex:0];
    }
    
    [self addAssetToPickView:asset];
}

- (void)reloadLibrarydWithAlbumModel:(AliyunAlbumModel *)model {
    [self.headerView setTitle:model.albumName];
    __weak typeof(self)weakSelf =self;
    [[AliyunPhotoLibraryManager sharedManager] getAssetsFromFetchResult:model.fetchResult allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<AliyunAssetModel *> *models) {
        weakSelf.libraryDataArray = models;
        [weakSelf.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];
}

#pragma mark - pick view

-(void)addAssetToPickView:(AliyunAssetModel *)asset {
    NSString *filename = [asset.asset valueForKey:@"filename"];
    if (asset.type == AliyunAssetModelMediaTypeVideo && ![self validateVideo:filename]) {
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"nonsupport_video_type_composition", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"video_affirm_common", nil) otherButtonTitles:nil, nil];
//        [alert show];
        [MBProgressHUD showWarningMessage:NSLocalizedString(@"nonsupport_video_type_composition", nil) inView:self.view];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf =self;
    //
    if (asset.type == AliyunAssetModelMediaTypeVideo) {
        [[AliyunPhotoLibraryManager sharedManager] getVideoWithAsset:asset.asset completion:^(AVAsset *avAsset, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                AliyunCompositionInfo *info = [[AliyunCompositionInfo alloc] init];
                info.duration = [avAsset avAssetVideoTrackDuration];
                AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
                info.asset = urlAsset;
                info.sourcePath = [urlAsset.URL path];
                
                //                NSString *videoPath_ss = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/cutVideo.mp4"];
                
                //                UISaveVideoAtPathToSavedPhotosAlbum([urlAsset.URL path], self, nil, nil);
                
                info.thumbnailImage = asset.thumbnailImage;
                info.type = AliyunCompositionInfoTypeVideo;
                [weakSelf.pickView addCompositionInfo:info];
            });
        }];
    } else if (asset.type == AliyunAssetModelMediaTypePhotoGif) {
        NSString *root = [AliyunPathManager compositionRootDir];
        NSString *path = [[root stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"gif"];
        
        [[AliyunPhotoLibraryManager sharedManager] saveGifWithAsset:asset.asset maxSize:[self maxPhotoSize] outputPath:path completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                weakSelf.parser = [[AliyunNativeParser alloc] initWithPath:path];
                CGFloat duration = [[weakSelf.parser getValueForKey:ALIYUN_VIDEO_DURATION] integerValue]/1000000.0f;
                NSInteger frameCount = [weakSelf.parser getVideoFrameCount];
                if (frameCount == 1) {
                    //单帧gif转图片，其余按照原先的类型处理
                    AliyunCompositionInfo *info = [[AliyunCompositionInfo alloc] init];
                    info.phAsset = asset.asset;
                    info.thumbnailImage = asset.thumbnailImage;
                    info.duration = 3;//图片默认3秒
                    info.type = AliyunCompositionInfoTypePhoto;
                    info.sourcePath = path;
                    [weakSelf.pickView addCompositionInfo:info];
                }else{
                    AliyunCompositionInfo *cinfo = [[AliyunCompositionInfo alloc] init];
                    cinfo.phAsset = asset.asset;
                    cinfo.duration = duration;
                    cinfo.type = AliyunCompositionInfoTypeGif;
                    cinfo.sourcePath = path;
                    cinfo.thumbnailImage = asset.thumbnailImage;
                    [weakSelf.pickView addCompositionInfo:cinfo];
                }
                
            });
        }];
    }else {
        NSString *tmpPhotoPath = [[[AliyunPathManager compositionRootDir] stringByAppendingPathComponent:[AliyunPathManager randomString] ] stringByAppendingPathExtension:@"jpg"];
        [[AliyunPhotoLibraryManager sharedManager] savePhotoWithAsset:asset.asset maxSize:[self maxPhotoSize] outputPath:tmpPhotoPath completion:^(NSError *error, UIImage * _Nullable result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:weakSelf.view animated:YES];
                AliyunCompositionInfo *info = [[AliyunCompositionInfo alloc] init];
                info.phAsset = asset.asset;
                info.phImage = result;
                info.thumbnailImage = asset.thumbnailImage;
                info.duration = 3;//图片默认3秒
                info.type = AliyunCompositionInfoTypePhoto;
                info.sourcePath = tmpPhotoPath;
                [weakSelf.pickView addCompositionInfo:info];
            });
        }];
    }
}

#pragma mark - AliyunImportHeaderViewDelegate

-(void)headerViewDidCancel {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)headerViewDidSelect {
    AliyunAlbumViewController *albumViewController = [[AliyunAlbumViewController alloc] init];
    albumViewController.albumTitle = self.headerView.title;
    BOOL videoOnly = self.compositionConfig.videoOnly;
    albumViewController.videoOnly = videoOnly;
    VideoDurationRange duration = {_compositionConfig.minDuration, _compositionConfig.maxDuration};
    albumViewController.videoRange = duration;
    __weak typeof(self)weakSelf =self;
    albumViewController.selectBlock = ^(AliyunAlbumModel *albumModel) {
        [weakSelf reloadLibrarydWithAlbumModel:albumModel];
    };
    [self.navigationController pushViewController:albumViewController animated:NO];
}

#pragma mark - AliyunCompositionPickViewDelegate

-(void)pickViewDidSelectCompositionInfo:(AliyunCompositionInfo *)info {
    //合拍不允许裁剪
    if(self.controllerType == AlivcCompositionViewControllerTypeVideoMix){
        return;
    }
    
    if (info.type == AliyunCompositionInfoTypeGif || [[info.sourcePath.pathExtension lowercaseString] isEqualToString:@"gif"]) {
        [MBProgressHUD showMessage:NSLocalizedString(@"暂时不支持gif文件裁剪", nil) inView:self.view];
        return;
    }
    _cropCompositionInfo = info;
    UIViewController *cropVC = [[AliyunMediator shared] cropViewController];
    
    NSString *path = nil;
    NSURL *url = nil;
    if (info.phAsset == NULL) {//是视频资源
        url = [info.asset URL];
        NSString *root = [AliyunPathManager compositionRootDir];
        path = [[root stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
    }
    if (self.isOriginal){
        [self handleOriginalSizeWithInfo:info];
    }
    AliyunMediaConfig *config = [AliyunMediaConfig cutConfigWithOutputPath:path outputSize:_compositionConfig.outputSize minDuration:2 maxDuration:info.duration cutMode:_compositionConfig.cutMode videoQuality:_compositionConfig.videoQuality fps:_compositionConfig.fps gop:_compositionConfig.gop];
    config.sourcePath = [url path];
    if (info.phAsset) {
        config.phAsset = info.phAsset;
    }
    config.phImage = info.phImage;
    config.encodeMode = _compositionConfig.encodeMode;//编码
    config.backgroundColor = _compositionConfig.backgroundColor;
    config.cutMode = _compositionConfig.cutMode;
    config.gpuCrop = _compositionConfig.gpuCrop;
    [cropVC setValue:config forKey:@"cutInfo"];
    [cropVC setValue:self forKey:@"delegate"];
    [cropVC setValue:@(YES) forKey:@"fakeCrop"];
    [self.navigationController pushViewController:cropVC animated:YES];
    
}

-(void)pickViewDidFinishWithAssets:(NSArray<AliyunCompositionInfo *> *)assets duration:(CGFloat)duration {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    if (self.isOriginal) {
        AliyunCompositionInfo *info = [assets firstObject];
        [self handleOriginalSizeWithInfo:info];
    }

#if (SDK_VERSION != SDK_VERSION_BASE)
    __weak typeof(self)weakSelf = self;
    [self compressVideoIfNeededWithAssets:assets completion:^(BOOL failed , int errorResult){
        if (failed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                if (errorResult != ALIVC_SVIDEO_ERROR_TRANSCODE_BACKGROUND) {
                    NSString *msg = NSLocalizedString(@"视频格式不支持", nil);
                    if (errorResult == -1) {
                        msg = NSLocalizedString(@"图片过宽或过高", nil);
                    }
//                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:msg message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"video_affirm_common", nil) otherButtonTitles:nil, nil];
//                    [alert show];
                    [MBProgressHUD showWarningMessage:msg inView:self.view];
                }
            });
            return;
        }
        
        
        NSString *editDir = [AliyunPathManager compositionRootDir];
        NSString *taskPath = [editDir stringByAppendingPathComponent:[AliyunPathManager randomString]];
        
        AliyunImporter *importor = [[AliyunImporter alloc] initWithPath:taskPath outputSize:weakSelf.compositionConfig.outputSize];
        // add paths
        NSMutableArray *saveAVURLAssetArray = [[NSMutableArray alloc]init];
        for (int i = 0; i < assets.count; i++) {
            AliyunCompositionInfo *info = assets[i];
            if (info.type == AliyunCompositionInfoTypePhoto) {
                AliyunClip *clip = [[AliyunClip alloc] initWithImagePath:info.sourcePath duration:info.duration animDuration:i == 0 ? 0 : 1];
                [importor addMediaClip:clip];
            } else if (info.type == AliyunCompositionInfoTypeGif) {
                AliyunClip *clip = [[AliyunClip alloc] initWithGifPath:info.sourcePath startTime:info.startTime duration:info.duration];
                [importor addMediaClip:clip];
            } else {
                AliyunClip *clip = [[AliyunClip alloc] initWithVideoPath:info.sourcePath startTime:info.startTime duration:info.duration animDuration:i == 0 ? 0 : 1];
                [importor addMediaClip:clip];
            }
            if (info.asset) {
                [saveAVURLAssetArray addObject:info.asset];
            }
            
        }
        
        //        //趣视频编辑界面屏幕适配
        //        if (kAlivcProductType == AlivcOutputProductTypeSmartVideo) {
        //            if ([_compositionConfig mediaRatio] == AliyunMediaRatio9To16) {
        //                _compositionConfig.cutMode = AliyunMediaCutModeScaleAspectCut;
        //            }else {
        //                _compositionConfig.cutMode = AliyunMediaCutModeScaleAspectFill;
        //            }
        //        }
        
        // set video param
        AliyunVideoParam *param = [[AliyunVideoParam alloc] init];
        param.fps = weakSelf.compositionConfig.fps;
        param.gop = weakSelf.compositionConfig.gop;
        param.videoQuality = (AliyunVideoQuality)weakSelf.compositionConfig.videoQuality;
        if (weakSelf.compositionConfig.cutMode == AliyunMediaCutModeScaleAspectCut) {
            param.scaleMode = AliyunScaleModeFit;
        }else{
            param.scaleMode = AliyunScaleModeFill;
        }
        // 编码模式
        if (weakSelf.compositionConfig.encodeMode ==  AliyunEncodeModeHardH264) {
            param.codecType = AliyunVideoCodecHardware;
        }else if(weakSelf.compositionConfig.encodeMode == AliyunEncodeModeSoftFFmpeg) {
            param.codecType = AliyunVideoCodecFFmpeg;
        }
        
        [importor setVideoParam:param];
        // generate config
        [importor generateProjectConfigure];
        // output path
        weakSelf.compositionConfig.outputPath = [[taskPath stringByAppendingPathComponent:[AliyunPathManager randomString]]stringByAppendingPathExtension:@"mp4"];
        // edit view controller
        
        [[AlivcShortVideoRoute shared]registerEditVideoPath:nil];
        [[AlivcShortVideoRoute shared]registerEditMediasPath:taskPath];
        [[AlivcShortVideoRoute shared] registerHasRecordMusic:NO];
        
        [[AlivcShortVideoRoute shared] registerMediaConfig:weakSelf.compositionConfig];
        //存储点击的相册资源，防止之后合成没有相关资源导致失败
        [[AlivcShortVideoTempSave shared]saveResources:(NSArray *)saveAVURLAssetArray];
        
        if (self.controllerType == AlivcCompositionViewControllerTypeVideoEdit) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UIViewController *editVC = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlEdit];
                [hud hideAnimated:YES];
                [self.navigationController pushViewController:editVC animated:YES];
            });
        }else{
            //配置
            AliyunCompositionInfo *info = assets.firstObject;
            AliyunMediaConfig *tempConfig = [weakSelf.compositionConfig copy];
            tempConfig.maxDuration = info.duration;
            tempConfig.sourcePath = assets.firstObject.sourcePath;
            [[AlivcShortVideoRoute shared]registerMediaConfig:tempConfig];
            UIViewController *record = [[AlivcShortVideoRoute shared] alivcViewControllerWithType:AlivcViewControlRecordMix];
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                [self.navigationController pushViewController:record animated:YES];
            });
        }
    }];
    
#endif
    
}

#pragma mark - AliyunCropViewControllerDelegate

-(void)cropViewControllerExit {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cropViewControllerFakeFinish:(AliyunMediaConfig *)mediaInfo viewController:(UIViewController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
    __weak typeof(self)weakSelf =self;
    _cropCompositionInfo.startTime = mediaInfo.startTime;
    _cropCompositionInfo.duration = mediaInfo.endTime - mediaInfo.startTime;
    _compositionConfig.cutMode = mediaInfo.cutMode;
    [self getThumbnailWithAsset:_cropCompositionInfo.asset atTime:mediaInfo.startTime complete:^(UIImage *image) {
        if (!image) {//取不到缩略图重新取一下
            NSLog(@"--------image is null");
            [weakSelf getThumbnailWithAsset:_cropCompositionInfo.asset atTime:mediaInfo.startTime+0.5 complete:^(UIImage *image) {
                if (!image) {
                    NSLog(@"--------image is null");
                }
                self->_cropCompositionInfo.thumbnailImage = image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.pickView refresh];
                });
            }];
        }else{
            self->_cropCompositionInfo.thumbnailImage = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.pickView refresh];
            });
        }
        
    }];
    
}
- (void)cropViewControllerFinish:(AliyunMediaConfig *)mediaInfo viewController:(UIViewController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
    __weak typeof(self)weakSelf =self;
    _compositionConfig.cutMode = mediaInfo.cutMode;
    if (_cropCompositionInfo.phAsset) {//图片资源
        _cropCompositionInfo.phImage = mediaInfo.phImage;
        _cropCompositionInfo.thumbnailImage = mediaInfo.phImage;
        _cropCompositionInfo.isFromCrop = YES;
        _cropCompositionInfo.sourcePath = mediaInfo.sourcePath;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.pickView refresh];
        });
    } else {
        _cropCompositionInfo.sourcePath = mediaInfo.outputPath;
        if (![mediaInfo.outputPath isEqualToString:mediaInfo.sourcePath]) {
            _cropCompositionInfo.asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:mediaInfo.outputPath]];
        }
        _cropCompositionInfo.duration = [_cropCompositionInfo.asset avAssetVideoTrackDuration];
        
        _cropCompositionInfo.startTime = mediaInfo.startTime;
        _cropCompositionInfo.duration = mediaInfo.endTime - mediaInfo.startTime;
        
        [self getThumbnailWithAsset:_cropCompositionInfo.asset atTime:mediaInfo.startTime complete:^(UIImage *image) {
            if (!image) {//取不到缩略图重新取一下
                NSLog(@"--------image is null");
                [weakSelf getThumbnailWithAsset:_cropCompositionInfo.asset atTime:mediaInfo.startTime+0.5 complete:^(UIImage *image) {
                    if (!image) {
                        NSLog(@"--------image is null");
                    }
                    _cropCompositionInfo.thumbnailImage = image;
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [weakSelf.pickView refresh];
                    });
                }];
            }else{
                _cropCompositionInfo.thumbnailImage = image;
                dispatch_async(dispatch_get_main_queue(), ^{
                    [weakSelf.pickView refresh];
                });
            }
            
        }];
    }
}

#pragma mark - tool
//不支持非MP4，MOV
- (BOOL)validateVideo:(NSString *)path {
    NSString *format = [path.pathExtension uppercaseString];
    if ([format isEqualToString:@"MP4"] || [format isEqualToString:@"MOV"] || [format isEqualToString:@"3GP"]) {
        return YES;
    }
    return NO;
}

//如果视频分辨率过大或fps,gop过大或存在b帧，压缩视频
- (void)compressVideoIfNeededWithAssets:(NSArray<AliyunCompositionInfo *> *)assets completion:(void(^)(BOOL failed ,int errorCode))completion {
    __weak typeof(self)weakSelf =self;
    __block BOOL failed = NO;
    __block int errorResult =0;
    NSString *root = [AliyunPathManager compositionRootDir];
    dispatch_queue_t _compressQueue = dispatch_queue_create("com.duanqu.sdk.compress", DISPATCH_QUEUE_SERIAL);
    dispatch_semaphore_t _semaphore = dispatch_semaphore_create(0);
    dispatch_async(_compressQueue, ^{
        for (int i = 0; i < assets.count; i++) {
            if (failed) break;
            __weak AliyunCompositionInfo *info = assets[i];
            if (!info.phAsset) {
                AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:info.sourcePath]];
                CGFloat resolution = [asset avAssetNaturalSize].width * [asset avAssetNaturalSize].height;
                CGFloat max = [weakSelf maxVideoSize].width * [weakSelf maxVideoSize].height;
                AliyunNativeParser *avParser = [[AliyunNativeParser alloc] initWithPath:info.sourcePath];
                NSLog(@"--------->frameRate:%f  GopSize:%zd",asset.frameRate,avParser.getGopSize);
                //分辨率过大              //fps过大                    //Gop过大
                if (resolution > max || asset.frameRate > 35 || avParser.getGopSize >35 || self.controllerType == AlivcCompositionViewControllerTypeVideoMix) {
                    NSString *outputPath = [[root stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
                    CGFloat factor = MAX(weakSelf.compositionConfig.outputSize.width,weakSelf.compositionConfig.outputSize.height)/MAX([asset avAssetNaturalSize].width, [asset avAssetNaturalSize].height);
                    if (factor > 1) {
                        factor = 1.0f;
                    }
                    CGSize size = [asset avAssetNaturalSize];
                    // 最终分辨率必须为偶数
                    CGFloat outputWidth = rint(size.width * factor / 2) * 2;
                    CGFloat outputHeight = rint(size.height * factor / 2) * 2;
                    CGSize outputSize = CGSizeMake(outputWidth, outputHeight);
                    [weakSelf.manager compressWithSourcePath:info.sourcePath
                                                  outputPath:outputPath
                                                  outputSize:outputSize
                                                     success:^{
                        info.sourcePath = outputPath;
                        dispatch_semaphore_signal(_semaphore);
                    } failure:^(int errorCode) {
                        failed = YES;
                        errorResult = errorCode;
                        dispatch_semaphore_signal(_semaphore);
                    }];
                    dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
                }
            } else {
                if (self.compositionConfig.outputSize.width > 3840 || self.compositionConfig.outputSize.height > 3840) {
                    failed = YES;
                    errorResult = -1;
                }
            }
        }
        completion(failed,errorResult);
    });
}

-(void)getThumbnailWithAsset:(AVAsset *)asset atTime:(CGFloat)time complete:(void (^)(UIImage *))complete {
    // picked a video, extract a frame
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    NSArray *tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    imageGenerator.maximumSize = CGSizeMake(200, 200);
    imageGenerator.appliesPreferredTrackTransform = YES;
    if (tracks.count >0) {
        int64_t value = time * 1000;
        CMTime time = CMTimeMake(value, 1000);
        [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:time]] completionHandler:^(CMTime requestedTime, CGImageRef image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError *error) {
            if (!error && result == AVAssetImageGeneratorSucceeded) {
                UIImage *thumbnail = [UIImage imageWithCGImage:image];
                complete(thumbnail);
            }else {
                complete(nil);
            }
        }];
    } else {
        complete(nil);
    }
}

- (AliyunCompressManager *)manager {
    if (!_manager) {
        _manager = [[AliyunCompressManager alloc] initWithMediaConfig:_compositionConfig];
    }
    return _manager;
}

- (CGSize)maxVideoSize {
    CGSize size;
    if ([self isBelowIphone_5]){
        size = CGSizeMake(720, 960);
    } else if ([self isBelowIphone_6]){
        size = CGSizeMake(1080, 1080);
    } else {
        size = CGSizeMake(1080, 1920);
    }
    return size;
    
}

- (int)deviceCode {
    return [UIDevice iphoneDeviceCode];
}

- (BOOL)isBelowIphone_5 {
    int code = [self deviceCode];
    return code < 5;
}

- (BOOL)isBelowIphone_6 {
    int code = [self deviceCode];
    return code < 7;
}


- (CGSize)maxPhotoSize {
    return CGSizeMake(1080, 1920);
}


/**
 获取原比例的情况下图片的尺寸
 
 @param imageInfo 图片的图片信息
 @return 原比例下图片的分辨率
 */
- (CGSize )originalImageSizeWithInfo:(AliyunCompositionInfo *)imageInfo{
    UIImage *image = [UIImage imageWithContentsOfFile:imageInfo.sourcePath];
    return image.size;
}


/**
 原比例下对size的处理
 
 @param info 媒体资源
 */
- (void)handleOriginalSizeWithInfo:(AliyunCompositionInfo *)info{
    if (info.type == AliyunCompositionInfoTypePhoto) {
        //获取原比例的图片尺寸
        CGSize size = [self originalImageSizeWithInfo:info];
        CGFloat ratio = size.width / size.height;
        if (ratio > 0) {
            CGFloat height = _compositionConfig.outputSize.width / ratio;
            _compositionConfig.outputSize =  CGSizeMake(_compositionConfig.outputSize.width, height);
        }
        
    }else{
        //获取原比例的视频尺寸
        CGSize size = CGSizeZero;
        if (info.asset) {
            size = [info.asset avAssetNaturalSize];
        }else if (info.phAsset){//单帧GIF应该取phAsset
            size = CGSizeMake(info.phAsset.pixelWidth, info.phAsset.pixelHeight);
        }else{
            NSLog(@"#Wrong:视频信息为nil");
        }
        
        CGFloat ratio = size.width / size.height;
        if (ratio > 0) {
            CGFloat height = _compositionConfig.outputSize.width / ratio;
            _compositionConfig.outputSize =  CGSizeMake(_compositionConfig.outputSize.width, height);
        }
        
    }
    _compositionConfig.outputSize = [_compositionConfig fixedSize];
    
    
}

-(void)dealloc {
    NSLog(@"--------------compositionViewController dealloc-----------");
}
@end
