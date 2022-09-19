//
//  AlivcPhotoPickerViewController.m
//  Pods
//
//  Created by mengyehao on 2021/11/10.
//

#import "AlivcPhotoPickerViewController.h"
#import "AliyunImportHeaderView.h"
#import "AliyunAlbumViewController.h"
#import "AliyunCompositionCell.h"
#import "AliyunCompositionPickView.h"

#import "AliyunPhotoLibraryManager.h"
#import "AlivcPhotoPathManager.h"
#import "AliyunCompositionInfo.h"

#import "MBProgressHUDHelper.h"
#import "AlivcPhotoPickerBundle.h"
#import "AlivcPhotoPicker.h"
#import "AliyunIConfig.h"



@interface AlivcPhotoPickerViewController ()<AliyunImportHeaderViewDelegate, AliyunCompositionPickViewDelegate,UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, weak) AliyunImportHeaderView *headerView;
@property (nonatomic, weak) UICollectionView *collectionView;
@property (nonatomic, weak) AliyunCompositionPickView *pickView;
@property (nonatomic, strong) NSArray<AliyunAssetModel *> *libraryDataArray;
@property (nonatomic, strong) AliyunCompositionInfo *cropCompositionInfo;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@end

@implementation AlivcPhotoPickerViewController

- (void)dealloc
{
    
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.clipsToBounds =YES;
        _allowPickingImage = YES;
        _allowPickingVideo = YES;
        _timeRange = (AlivcVideoDurationRange){0, 0};
    }
    return self;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupSDKUI];
    
    [self setupSubviews];
       
    [self fetchPhotoData];
    
}

- (void)setupSDKUI {
    
    AliyunIConfig *config = [[AliyunIConfig alloc] init];
    
    config.backgroundColor = P_RGBToColor(35, 42, 66);
    config.timelineBackgroundCollor = P_RGBToColor(35, 42, 66);
    config.timelineDeleteColor = [UIColor redColor];
    config.timelineTintColor = P_RGBToColor(239, 75, 129);
    config.durationLabelTextColor = [UIColor redColor];
    config.hiddenDurationLabel = NO;
    config.hiddenFlashButton = NO;
    config.hiddenBeautyButton = NO;
    config.hiddenCameraButton = NO;
    config.hiddenImportButton = NO;
    config.hiddenDeleteButton = NO;
    config.hiddenFinishButton = NO;
    config.recordOnePart = NO;

    config.recordType = AliyunIRecordActionTypeClick;
    config.filterBundleName = nil;
    config.showCameraButton = NO;
    
    [AliyunIConfig setConfig:config];
}


- (void)setupSubviews {
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = P_RGBToColor(35, 42, 66);
    CGFloat top =  P_IS_IPHONEX ? 24 : 0;
    AliyunImportHeaderView *headerView = [[AliyunImportHeaderView alloc] initWithFrame:CGRectMake(0, top, P_ScreenWidth, 64)];
    self.headerView = headerView;
    self.headerView.delegate = self;
    [self.headerView setTitle:NSLocalizedString(@"相机胶卷", nil)];
    [self.view addSubview:self.headerView];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    CGFloat w = (P_ScreenWidth - (4 * 3))/ 4.0;
    layout.itemSize = CGSizeMake(w, w);
    layout.minimumLineSpacing = 3;
    layout.minimumInteritemSpacing = 3;
    UICollectionView *collectionView = [[UICollectionView alloc] initWithFrame:
    CGRectMake(0, 64+top, P_ScreenWidth, P_ScreenHeight-64-140-P_SafeBottom-top) collectionViewLayout:layout];
    self.collectionView = collectionView;
    self.collectionView.backgroundColor = P_RGBToColor(35, 42, 66);
    [self.collectionView registerClass:[AliyunCompositionCell class] forCellWithReuseIdentifier:@"AliyunCompositionCell"];
    self.collectionView.alwaysBounceVertical = YES;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    AliyunCompositionPickView *pickView = [[AliyunCompositionPickView alloc] initWithFrame:CGRectMake(0, P_ScreenHeight-140-P_SafeBottom, P_ScreenWidth, 140)];
    self.pickView = pickView;
    self.pickView.delegate = self;
    [self.view addSubview:self.pickView];
}



- (void)fetchPhotoData {
    __weak typeof(self)weakSelf =self;
    [[AliyunPhotoLibraryManager sharedManager] requestAuthorization:^(BOOL authorization) {
        if (authorization) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[AliyunPhotoLibraryManager sharedManager] getCameraRollAssetWithallowPickingVideo:weakSelf.allowPickingVideo allowPickingImage:weakSelf.allowPickingImage durationRange:(VideoDurationRange){self.timeRange.min,self.timeRange.max} completion:^(NSArray<AliyunAssetModel *> *models, NSInteger videoCount) {
                    weakSelf.libraryDataArray = models;
                    [weakSelf.collectionView reloadData];
                    
                }];
            });
        }
    }];
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
        [MBProgressHUDHelper showMessage:NSLocalizedString(@"文件已损坏", nil) inView:self.view];
        return;
    }
    
    if (self.maxSelectCount > 0) {
        if (self.maxSelectCount <= [self.pickView getPickedAssets].count) {
            [MBProgressHUDHelper showMessage:NSLocalizedString(@"已达到最大选择个数", nil) inView:self.view];
            return;
        }
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


- (NSTimeInterval)gifImageDeleyTime:(CGImageSourceRef)imageSource index:(NSInteger)index {
    NSTimeInterval duration = 0;
    CFDictionaryRef imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, index, NULL);
    if (imageProperties) {
        CFDictionaryRef gifProperties;
        BOOL result = CFDictionaryGetValueIfPresent(imageProperties, kCGImagePropertyGIFDictionary, (const void **)&gifProperties);
        if (result) {
            const void *durationValue;
            if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFUnclampedDelayTime, &durationValue)) {
                duration = [(__bridge NSNumber *)durationValue doubleValue];
                if (duration < 0) {
                    if (CFDictionaryGetValueIfPresent(gifProperties, kCGImagePropertyGIFDelayTime, &durationValue)) {
                        duration = [(__bridge NSNumber *)durationValue doubleValue];
                    }
                }
            }
        }
    }
 
    return duration;
}

-(void)addAssetToPickView:(AliyunAssetModel *)asset {
    NSString *filename = [asset.asset valueForKey:@"filename"];
    if (asset.type == AliyunAssetModelMediaTypeVideo && ![self validateVideo:filename]) {
        [MBProgressHUDHelper showWarningMessage:NSLocalizedString(@"nonsupport_video_type_composition", nil) inView:self.view];
        return;
    }
    [MBProgressHUDHelper showHUDAddedTo:self.view animated:YES];
    __weak typeof(self)weakSelf =self;
    //
    if (asset.type == AliyunAssetModelMediaTypeVideo) {
        [[AliyunPhotoLibraryManager sharedManager] getVideoWithAsset:asset.asset completion:^(AVAsset *avAsset, NSDictionary *info) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUDHelper hideHUDForView:weakSelf.view animated:YES];
                AliyunCompositionInfo *info = [[AliyunCompositionInfo alloc] init];
                info.duration = [weakSelf avAssetVideoTrackDurationWithAVAsset:avAsset];
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
        NSString *root = [AlivcPhotoPathManager compositionRootDir];
        NSString *path = [[root stringByAppendingPathComponent:[AlivcPhotoPathManager randomString]] stringByAppendingPathExtension:@"gif"];
        
        [[AliyunPhotoLibraryManager sharedManager] saveGifWithAsset:asset.asset maxSize:[self maxPhotoSize] outputPath:path completion:^(NSError *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUDHelper hideHUDForView:weakSelf.view animated:YES];
                
                NSData *gifData = [[NSData alloc] initWithContentsOfFile:path];
                CGImageSourceRef gifSource = CGImageSourceCreateWithData((__bridge CFDataRef)gifData, NULL);
             
                //获取其中图片源个数，即由多少帧图片组成
                size_t frameCount = CGImageSourceGetCount(gifSource);
             
                //定义数组存储拆分出来的图片
                NSMutableArray* frames = [[NSMutableArray alloc] init];
                NSTimeInterval duration = 0;
                for (size_t i= 0; i< frameCount; i++) {
             
                    //从GIF图片中取出源图片
                    CGImageRef imageRef = CGImageSourceCreateImageAtIndex(gifSource, i, NULL);
             
                    //将图片源转换成UIimageView能使用的图片源
                    UIImage* imageName = [UIImage imageWithCGImage:imageRef];
             
                    //将图片加入数组中
                    [frames addObject:imageName];
                    NSTimeInterval perduration = [self gifImageDeleyTime:gifSource index:i];
                    duration += perduration;
                    CGImageRelease(imageRef);
                }
                
                
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
        
        NSString *tempDir = [[AlivcPhotoPathManager compositionRootDir] stringByAppendingPathComponent:[AlivcPhotoPathManager randomString]];
        BOOL isDirectory = YES;
        if (![[NSFileManager defaultManager] fileExistsAtPath:tempDir isDirectory:&isDirectory]) {
           BOOL succeed = [[NSFileManager defaultManager] createDirectoryAtPath:tempDir withIntermediateDirectories:YES attributes:nil error:nil];
        }
        NSString *tmpPhotoPath = [tempDir stringByAppendingPathExtension:@"jpg"];
        
        
        [[AliyunPhotoLibraryManager sharedManager] savePhotoWithAsset:asset.asset maxSize:[self maxPhotoSize] outputPath:tmpPhotoPath completion:^(NSError *error, UIImage * _Nullable result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUDHelper hideHUDForView:weakSelf.view animated:YES];
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

- (void)headerViewDidCancel
{
    
    [self.navigationController popViewControllerAnimated:YES];
    if ([self.delegate respondsToSelector:@selector(photoPickerViewControllerDidClickCancel)]) {
        [self.delegate photoPickerViewControllerDidClickCancel];
    }
    if (self.didClickCancelBlock) {
        self.didClickCancelBlock();
    }
}

- (void)headerViewDidSelect
{
    AliyunAlbumViewController *albumViewController = [[AliyunAlbumViewController alloc] init];
    albumViewController.albumTitle = self.headerView.title;
    BOOL videoOnly = NO;
    albumViewController.videoOnly = videoOnly;
    VideoDurationRange duration = {self.timeRange.min, self.timeRange.max};
    albumViewController.videoRange = duration;
    __weak typeof(self)weakSelf =self;
    albumViewController.selectBlock = ^(AliyunAlbumModel *albumModel) {
        [weakSelf reloadLibrarydWithAlbumModel:albumModel];
    };
    [self.navigationController pushViewController:albumViewController animated:NO];
}

#pragma mark - AliyunCompositionPickViewDelegate

- (void)pickViewDidSelectCompositionInfo:(AliyunCompositionInfo *)info {

}

- (void)pickViewDidFinishWithAssets:(NSArray<AliyunCompositionInfo *> *)assets duration:(CGFloat)duration {
    
    if ([self.delegate respondsToSelector:@selector(photoPickerViewControllerDidClickNextWithAssets:)]) {
        [self.delegate photoPickerViewControllerDidClickNextWithAssets:assets];
    }
    
    if (self.didClickNextBlock) {
        self.didClickNextBlock(assets);
    }
}


#pragma mark - tool
//不支持非MP4，MOV
- (BOOL)validateVideo:(NSString *)path
{
    NSString *format = [path.pathExtension uppercaseString];
    if ([format isEqualToString:@"MP4"] || [format isEqualToString:@"MOV"] || [format isEqualToString:@"3GP"]) {
        return YES;
    }
    return NO;
}


- (CGSize)maxPhotoSize
{
    return CGSizeMake(1080, 1920);
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


- (CGFloat)avAssetVideoTrackDurationWithAVAsset:(AVAsset *)asset {
    
    if (![asset isKindOfClass:[AVAsset class]]) {
        return -1;
    }
    NSArray *videoTracks = [asset tracksWithMediaType:AVMediaTypeVideo];
    if (videoTracks.count) {
        AVAssetTrack *track = videoTracks[0];
        return CMTimeGetSeconds(CMTimeRangeGetEnd(track.timeRange));
    }
    
    NSArray *audioTracks = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (audioTracks.count) {
        AVAssetTrack *track = audioTracks[0];
        return CMTimeGetSeconds(CMTimeRangeGetEnd(track.timeRange));
    }
    
    return -1;
}


@end
