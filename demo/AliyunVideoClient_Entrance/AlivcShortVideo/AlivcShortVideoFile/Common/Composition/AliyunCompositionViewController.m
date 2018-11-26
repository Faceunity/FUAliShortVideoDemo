//
//  QUCompositionViewController.m
//  AliyunVideo
//
//  Created by Worthy on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunCompositionViewController.h"
#import "AliyunImportHeaderView.h"
#import "AliyunAlbumViewController.h"
#import "AliyunCompositionCell.h"
#import "AliyunCompositionPickView.h"
#import "AliyunPhotoLibraryManager.h"
#import "AliyunCompositionInfo.h"
#import "AliyunPathManager.h"
#import "AVAsset+VideoInfo.h"
#import "AliyunCompressManager.h"
#import <AliyunVideoSDKPro/AliyunImporter.h>
#import "MBProgressHUD.h"
#import "AliyunMediator.h"
#import <sys/utsname.h>
#import <AliyunVideoSDKPro/AliyunNativeParser.h>
#import "AVAsset+VideoInfo.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcShortVideoRoute.h"

@interface AliyunCompositionViewController () <AliyunImportHeaderViewDelegate, AliyunCompositionPickViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) AliyunImportHeaderView *headerView;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) AliyunCompositionPickView *pickView;
@property (nonatomic, strong) NSArray<AliyunAssetModel *> *libraryDataArray;
@property (nonatomic, strong) AliyunCompositionInfo *cropCompositionInfo;
@property (nonatomic, strong) AliyunCompressManager *manager;
@property (nonatomic, strong) AliyunNativeParser *parser;

@end

@implementation AliyunCompositionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (!self.isOriginal) {
        //保证分辨率为正偶数
        _compositionConfig.outputSize = [_compositionConfig fixedSize];
    }
    [self setupSubviews];
    

    [AliyunPathManager clearDir:[AliyunPathManager compositionRootDir]];
    
    [[AliyunPhotoLibraryManager sharedManager] requestAuthorization:^(BOOL authorization) {
        if (authorization) {
            VideoDurationRange duration = {2, 300};
            BOOL videoOnly = self.compositionConfig.videoOnly;
            
            [[AliyunPhotoLibraryManager sharedManager] getCameraRollAssetWithallowPickingVideo:YES allowPickingImage:!videoOnly durationRange:duration completion:^(NSArray<AliyunAssetModel *> *models, NSInteger videoCount) {
                _libraryDataArray = models;
                [_collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }];
        }
    }];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
}

- (void)fetchImages {
    [_libraryDataArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(AliyunAssetModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [[AliyunPhotoLibraryManager sharedManager] getPhotoWithAsset:obj.asset thumbnailImage:YES photoWidth:200 completion:^(UIImage *photo, NSDictionary *info) {
            obj.thumbnailImage = photo;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.collectionView reloadData];
            });
        }];
    }];
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
    self.headerView = [[AliyunImportHeaderView alloc] initWithFrame:CGRectMake(0, top, ScreenWidth, 64)];
    self.headerView.delegate = self;
    [self.headerView setTitle:NSLocalizedString(@"video_film_composition", nil)];
    [self.view addSubview:self.headerView];

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat w = (ScreenWidth - (4 * 3))/ 4.0;
    layout.itemSize = CGSizeMake(w, w);
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 3;
    self.collectionView = [[UICollectionView alloc] initWithFrame:
                           CGRectMake(0, 64+top, ScreenWidth, ScreenHeight-64-140-SafeBottom-top) collectionViewLayout:layout];
    self.collectionView.backgroundColor = RGBToColor(35, 42, 66);
    [self.collectionView registerClass:[AliyunCompositionCell class] forCellWithReuseIdentifier:@"AliyunCompositionCell"];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    self.pickView = [[AliyunCompositionPickView alloc] initWithFrame:CGRectMake(0, ScreenHeight-140-SafeBottom, ScreenWidth, 140)];
    self.pickView.delegate = self;
    [self.view addSubview:self.pickView];
}


#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _libraryDataArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    AliyunCompositionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunCompositionCell" forIndexPath:indexPath];
    AliyunAssetModel *model = _libraryDataArray[indexPath.row];
    cell.labelDuration.text = model.timeLength;
    cell.labelDuration.hidden = model.type == 0;
    if (model.thumbnailImage) {
        cell.imageView.image = model.thumbnailImage;
    } else {
        [[AliyunPhotoLibraryManager sharedManager] getPhotoWithAsset:model.asset thumbnailImage:YES photoWidth:80 completion:^(UIImage *photo, NSDictionary *info) {
            model.thumbnailImage = photo;
            dispatch_async(dispatch_get_main_queue(), ^{
                AliyunCompositionCell *cell2 = (AliyunCompositionCell *)[collectionView cellForItemAtIndexPath:indexPath];
                if (!photo) {
                    return;
                }
                cell2.imageView.image = photo;
                [collectionView reloadItemsAtIndexPaths:@[indexPath]];
            });
        }];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunAssetModel *asset = _libraryDataArray[indexPath.row];
    [self addAssetToPickView:asset];
}

- (void)reloadLibrarydWithAlbumModel:(AliyunAlbumModel *)model {
    [self.headerView setTitle:model.albumName];
    [[AliyunPhotoLibraryManager sharedManager] getAssetsFromFetchResult:model.fetchResult allowPickingVideo:YES allowPickingImage:YES completion:^(NSArray<AliyunAssetModel *> *models) {
        _libraryDataArray = models;
        [self.collectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }];
}

#pragma mark - pick view

-(void)addAssetToPickView:(AliyunAssetModel *)asset {
    NSString *filename = [asset.asset valueForKey:@"filename"];
    if (asset.type == AliyunAssetModelMediaTypeVideo && ![self validateVideo:filename]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"nonsupport_video_type_composition", nil) message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"video_affirm_common", nil) otherButtonTitles:nil, nil];
        [alert show];
        return;
    }
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    //
    if (asset.type == AliyunAssetModelMediaTypeVideo) {
        [[AliyunPhotoLibraryManager sharedManager] getVideoWithAsset:asset.asset completion:^(AVAsset *avAsset, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                AliyunCompositionInfo *info = [[AliyunCompositionInfo alloc] init];
                info.duration = asset.assetDuration;
                AVURLAsset *urlAsset = (AVURLAsset *)avAsset;
                info.asset = urlAsset;
                info.sourcePath = [urlAsset.URL path];
                info.thumbnailImage = asset.thumbnailImage;
                info.type = AliyunCompositionInfoTypeVideo;
                [self.pickView addCompositionInfo:info];
            });
        }];
    } else if (asset.type == AliyunAssetModelMediaTypePhotoGif) {
        NSString *root = [AliyunPathManager compositionRootDir];
        NSString *path = [[root stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"gif"];
        
        [[AliyunPhotoLibraryManager sharedManager] saveGifWithAsset:asset.asset maxSize:[self maxPhotoSize] outputPath:path completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                _parser = [[AliyunNativeParser alloc] initWithPath:path];
                CGFloat duration = [[_parser getValueForKey:ALIYUN_VIDEO_DURATION] integerValue]/1000000.0f;
                NSInteger frameCount = [_parser getVideoFrameCount];
                if (frameCount == 1) {
                    //单帧gif转图片，其余按照原先的类型处理
                    AliyunCompositionInfo *info = [[AliyunCompositionInfo alloc] init];
                    info.phAsset = asset.asset;
                    info.thumbnailImage = asset.thumbnailImage;
                    info.duration = 3;//图片默认3秒
                    info.type = AliyunCompositionInfoTypePhoto;
                    info.sourcePath = path;
                    [self.pickView addCompositionInfo:info];
                }else{
                    AliyunCompositionInfo *cinfo = [[AliyunCompositionInfo alloc] init];
                    cinfo.phAsset = asset.asset;
                    cinfo.duration = duration;
                    cinfo.type = AliyunCompositionInfoTypeGif;
                    cinfo.sourcePath = path;
                    cinfo.thumbnailImage = asset.thumbnailImage;
                    [self.pickView addCompositionInfo:cinfo];
                }
                
            });
        }];
    }else {
        NSString *tmpPhotoPath = [[[AliyunPathManager compositionRootDir] stringByAppendingPathComponent:[AliyunPathManager randomString] ] stringByAppendingPathExtension:@"jpg"];
        [[AliyunPhotoLibraryManager sharedManager] savePhotoWithAsset:asset.asset maxSize:[self maxPhotoSize] outputPath:tmpPhotoPath completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
                AliyunCompositionInfo *info = [[AliyunCompositionInfo alloc] init];
                info.phAsset = asset.asset;
                info.thumbnailImage = asset.thumbnailImage;
                info.duration = 3;//图片默认3秒
                info.type = AliyunCompositionInfoTypePhoto;
                info.sourcePath = tmpPhotoPath;
                [self.pickView addCompositionInfo:info];
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
    
    albumViewController.selectBlock = ^(AliyunAlbumModel *albumModel) {
        [self reloadLibrarydWithAlbumModel:albumModel];
    };
    [self.navigationController pushViewController:albumViewController animated:NO];
}

#pragma mark - AliyunCompositionPickViewDelegate

-(void)pickViewDidSelectCompositionInfo:(AliyunCompositionInfo *)info {
    if (info.type == AliyunCompositionInfoTypeGif || [[info.sourcePath.pathExtension lowercaseString] isEqualToString:@"gif"]) {
        [MBProgressHUD showMessage:@"暂时不支持gif文件裁剪" inView:self.view];
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
    config.bitrate = _compositionConfig.bitrate;
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
    
    [self compressVideoIfNeededWithAssets:assets completion:^(BOOL failed){
        if (failed) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [hud hideAnimated:YES];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"视频格式不支持" message:nil delegate:nil cancelButtonTitle:NSLocalizedString(@"video_affirm_common", nil) otherButtonTitles:nil, nil];
                [alert show];
            });
            return;
        }
        
        
        NSString *editDir = [AliyunPathManager compositionRootDir];
        NSString *taskPath = [editDir stringByAppendingPathComponent:[AliyunPathManager randomString]];
        
        AliyunImporter *importor = [[AliyunImporter alloc] initWithPath:taskPath outputSize:_compositionConfig.outputSize];
        // add paths
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
        }
        // set video param
        AliyunVideoParam *param = [[AliyunVideoParam alloc] init];
        param.fps = _compositionConfig.fps;
        param.gop = _compositionConfig.gop;
        param.bitrate = _compositionConfig.bitrate;
        param.videoQuality = (AliyunVideoQuality)_compositionConfig.videoQuality;
        if (_compositionConfig.cutMode == AliyunMediaCutModeScaleAspectCut) {
            param.scaleMode = AliyunScaleModeFit;
        }else{
            param.scaleMode = AliyunScaleModeFill;
        }
        
        [importor setVideoParam:param];
        // generate config
        [importor generateProjectConfigure];
        // output path
        _compositionConfig.outputPath = [[taskPath stringByAppendingPathComponent:[AliyunPathManager randomString]]stringByAppendingPathExtension:@"mp4"];
        // edit view controller
        [[AlivcShortVideoRoute shared]registerEditVideoPath:nil];
        [[AlivcShortVideoRoute shared]registerEditMediasPath:taskPath];
        [[AlivcShortVideoRoute shared]registerMediaConfig:_compositionConfig];
        UIViewController *editVC = [[AlivcShortVideoRoute shared]alivcViewControllerWithType:AlivcViewControlEdit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            [self.navigationController pushViewController:editVC animated:YES];
        });
    }];
    
}

#pragma mark - AliyunCropViewControllerDelegate

-(void)cropViewControllerExit {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)cropViewControllerFinish:(AliyunMediaConfig *)mediaInfo viewController:(UIViewController *)controller {
    [self.navigationController popViewControllerAnimated:YES];
    if (_cropCompositionInfo.phAsset) {//图片资源
        _cropCompositionInfo.phImage = mediaInfo.phImage;
        _cropCompositionInfo.thumbnailImage = mediaInfo.phImage;
        _cropCompositionInfo.isFromCrop = YES;
        _cropCompositionInfo.sourcePath = mediaInfo.sourcePath;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.pickView refresh];
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
            _cropCompositionInfo.thumbnailImage = image;
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.pickView refresh];
            });
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
- (void)compressVideoIfNeededWithAssets:(NSArray<AliyunCompositionInfo *> *)assets completion:(void(^)(BOOL failed))completion {
    __block BOOL failed = NO;
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
                    CGFloat max = [self maxVideoSize].width * [self maxVideoSize].height;
                    if (resolution > max || asset.frameRate > 35) {
                        NSString *outputPath = [[root stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
                        CGFloat factor = MAX(_compositionConfig.outputSize.width,_compositionConfig.outputSize.height)/MAX([asset avAssetNaturalSize].width, [asset avAssetNaturalSize].height);
                        if (factor > 1) {
                            factor = 1.0f;
                        }
                        CGSize size = [asset avAssetNaturalSize];
                        // 最终分辨率必须为偶数
                        CGFloat outputWidth = rint(size.width * factor / 2) * 2;
                        CGFloat outputHeight = rint(size.height * factor / 2) * 2;
                        CGSize outputSize = CGSizeMake(outputWidth, outputHeight);
                        [self.manager compressWithSourcePath:info.sourcePath
                                                  outputPath:outputPath
                                                  outputSize:outputSize
                                                     success:^{
                                                         info.sourcePath = outputPath;
                                                         dispatch_semaphore_signal(_semaphore);
                                                     } failure:^{
                                                         failed = YES;
                                                         dispatch_semaphore_signal(_semaphore);
                                                     }];
                        dispatch_semaphore_wait(_semaphore, DISPATCH_TIME_FOREVER);
                    }
                }
            }
        completion(failed);
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
    CGSize size = CGSizeMake(1080, 1920);
    
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone4,1"]||[deviceString isEqualToString:@"iPhone3,1"]){
        size = CGSizeMake(720, 960);
    }
    if ([deviceString isEqualToString:@"iPhone5,2"]){
        size = CGSizeMake(1080, 1080);

    }
    return size;
    
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
        CGSize size = [info.asset avAssetNaturalSize];
        CGFloat ratio = size.width / size.height;
        if (ratio > 0) {
            CGFloat height = _compositionConfig.outputSize.width / ratio;
            _compositionConfig.outputSize =  CGSizeMake(_compositionConfig.outputSize.width, height);
        }
        
    }
    
     _compositionConfig.outputSize = [_compositionConfig fixedSize];
   
    
}

@end
