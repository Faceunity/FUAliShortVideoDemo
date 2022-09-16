//
//  AlivcTemplateBuilderViewController.m
//  AlivcEdit
//
//  Created by Bingo on 2021/11/30.
//

#import "AlivcTemplateBuilderViewController.h"
#import "AlivcPlayManager.h"
#import "AlivcPlayTimeView.h"
#import "AlivcTemplateNodeListView.h"
#import "AlivcTemplateResourceManager.h"
#import "AliyunCompositionInfo.h"
#import "AlivcPhotoPickerViewController.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

@protocol AlivcTemplateBuilderContentCellDelegate <NSObject>

- (void)onLockContentChanged:(AliyunTemplateModifyContent *)modifyContent;

@end

@interface AlivcTemplateBuilderContentCell : UICollectionViewCell

@property (nonatomic, strong) AliyunTemplateModifyContent *modifyContent;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UISwitch *lockView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, weak) id<AlivcTemplateBuilderContentCellDelegate> delegate;
@end

@implementation AlivcTemplateBuilderContentCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetHeight(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds))];
        coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        coverView.contentMode = UIViewContentModeScaleAspectFill;
        coverView.clipsToBounds = YES;
        [self.contentView addSubview:coverView];
        self.coverView = coverView;
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:self.coverView.bounds];
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.font = [UIFont systemFontOfSize:16];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.numberOfLines = 0;
        infoLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        [self.coverView addSubview:infoLabel];
        self.infoLabel = infoLabel;
        
        UISwitch *lockView = [[UISwitch alloc] initWithFrame:CGRectMake(0, 0, 48, 48)];
        lockView.center = CGPointMake(CGRectGetWidth(self.contentView.bounds) - 12 - CGRectGetWidth(lockView.frame) / 2, CGRectGetMidY(self.contentView.bounds));
        [lockView addTarget:self action:@selector(onSwitchChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:lockView];
        self.lockView = lockView;
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(self.coverView.frame) + 12, 0, CGRectGetMaxX(lockView.frame) - CGRectGetMaxX(self.coverView.frame) - 12 - 12, CGRectGetHeight(self.contentView.bounds))];
        descLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        descLabel.font = [UIFont systemFontOfSize:12];
        [self.contentView addSubview:descLabel];
        self.descLabel = descLabel;
    }
    return self;
}

- (void)updateModifyContent:(AliyunTemplateModifyContent *)modifyContent {
    self.modifyContent = modifyContent;
    
    if ([self.modifyContent.content isKindOfClass:AEPBaseVideoTrackClip.class]) {
        AEPBaseVideoTrackClip *clip = self.modifyContent.content;
        NSString *path = clip.source.path;
        UIImage *cover = nil;
        if (clip.source.type == AEPSourceType_Video) {
            cover = [self thumbnailWithVideoPath:path outputSize:CGSizeMake(200, 200) startTime:clip.timelineIn];
        }
        else if (clip.source.type == AEPSourceType_Image) {
            cover = [UIImage imageWithContentsOfFile:path];
        }
        self.coverView.image = cover;
        self.descLabel.text = [NSString stringWithFormat:@"%@: StartTime:%.0f, Duration:%.0f",self.modifyContent.nodeKey, clip.timelineIn, clip.clipDuration];
    }
    else {
        AEPCaptionBaseTrack *track = self.modifyContent.content;
        if ([track isKindOfClass:AEPCaptionBaseTrack.class]) {
            self.infoLabel.text = track.text;
        }
        else {
            self.infoLabel.text = nil;
        }
        self.coverView.image = nil;
        self.descLabel.text = [NSString stringWithFormat:@"%@: StartTime:%.0f, Duration:%.0f",self.modifyContent.nodeKey, track.timelineIn, track.timelineOut - track.timelineIn];
    }
    
    self.lockView.on = self.modifyContent.lockContent;
}

- (void)onSwitchChanged:(UISwitch *)sw {
    
    self.modifyContent.lockContent = self.lockView.on;
    if ([self.delegate respondsToSelector:@selector(onLockContentChanged:)]) {
        [self.delegate onLockContentChanged:self.modifyContent];
    }
}

- (UIImage *)thumbnailWithVideoPath:(NSString *)videoPath outputSize:(CGSize)outputSize startTime:(NSTimeInterval)startTime {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    AVAssetImageGenerator *_generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    _generator.maximumSize = outputSize;
    _generator.appliesPreferredTrackTransform = YES;
    _generator.requestedTimeToleranceAfter = kCMTimeZero;
    _generator.requestedTimeToleranceBefore = kCMTimeZero;
    CMTime time = CMTimeMake(startTime * 1000, 1000);
    CGImageRef image = [_generator copyCGImageAtTime:time
                                          actualTime:NULL
                                               error:nil];
    UIImage *picture = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return picture;
}

@end

@interface AlivcTemplateBuilderViewController () <UICollectionViewDataSource, UICollectionViewDelegate, AlivcTemplateBuilderContentCellDelegate>

@property (nonatomic, copy) NSString *editorTaskPath;
@property (nonatomic, copy) NSString *templateTaskPath;
@property (nonatomic, strong) AliyunTemplateBuilder *aliyunBuilder;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *coverBtn;


@end

@implementation AlivcTemplateBuilderViewController

- (instancetype)initWithEditorTaskPath:(NSString *)editorTaskPath isOpen:(BOOL)isOpen {
    self = [super init];
    if (self) {
        _editorTaskPath = editorTaskPath;
        if (isOpen) {
            if ([editorTaskPath hasPrefix:[AlivcTemplateResourceManager builtTemplatePath]]) {
                _templateTaskPath = editorTaskPath;
            }
            else {
                return nil;
            }
        }
        if (!_templateTaskPath) {
            _templateTaskPath = [[AlivcTemplateResourceManager builtTemplatePath] stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
        }
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SafeTop, 60, 60)];
    [closeBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onCloseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    UIButton *exportBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 64 - 12, SafeTop + 10, 64, 32)];
    [exportBtn setTitle:@"保存" forState:UIControlStateNormal];
    [exportBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    exportBtn.backgroundColor = [UIColor systemPinkColor];
    exportBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [exportBtn addTarget:self action:@selector(onExportBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportBtn];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(CGRectGetWidth(self.view.bounds), 120);
    layout.minimumInteritemSpacing = 12.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 0, SafeBottom, 0);
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(closeBtn.frame), CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - CGRectGetMaxY(closeBtn.frame)) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[AlivcTemplateBuilderContentCell class] forCellWithReuseIdentifier:@"AlivcTemplateBuilderContentCell"];
    
    CGFloat height = 56;
    CGFloat width = (CGRectGetWidth(self.view.bounds) - 24 * 3) / 2;
    CGFloat top = CGRectGetMaxY(self.view.bounds) - SafeBottom - height;
    UIButton *titleBtn = [[UIButton alloc] initWithFrame:CGRectMake(24, top, width, height)];
    [titleBtn setTitle:@"更改标题" forState:UIControlStateNormal];
    [titleBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    titleBtn.backgroundColor = [UIColor systemPinkColor];
    titleBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [titleBtn addTarget:self action:@selector(onTitleBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:titleBtn];
    
    UIButton *coverBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleBtn.frame) + 24, top, width, height)];
    [coverBtn setTitle:@"更改封面" forState:UIControlStateNormal];
    [coverBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    coverBtn.backgroundColor = [UIColor systemPinkColor];
    coverBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [coverBtn addTarget:self action:@selector(onCoverBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:coverBtn];
    
    AliyunTemplateBuilder *builder = [AliyunTemplateBuilder build:self.templateTaskPath editorTaskPath:self.editorTaskPath];
    self.aliyunBuilder = builder;
    
    [coverBtn setImage:[UIImage imageWithContentsOfFile:[self.aliyunBuilder getTemplate].cover.path] forState:UIControlStateNormal];
    coverBtn.imageView.contentMode = UIViewContentModeScaleAspectFit;
    coverBtn.imageEdgeInsets = UIEdgeInsetsMake(4, 0, 4, (width - 48));
    self.coverBtn = coverBtn;
}

- (void)onCloseBtnClicked:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)onTitleBtnClicked:(UIButton *)sender {
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入文字" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
        UITextField *titleTextField = alertController.textFields.firstObject;
        if (titleTextField.text.length > 0) {
            [self.aliyunBuilder updateTitle:titleTextField.text];
        }
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.text = self.aliyunBuilder.getTemplate.title;
    }];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:true completion:nil];
    
}

- (void)onCoverBtnClicked:(UIButton *)sender {
    
    __weak typeof(self)weakSelf =self;
    AlivcPhotoPickerViewController *vc = [AlivcPhotoPickerViewController new];
    vc.maxSelectCount = 1;
    vc.allowPickingVideo = NO;
    vc.didClickNextBlock = ^(NSArray<AliyunCompositionInfo *> *infos) {
        [(UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController popViewControllerAnimated:YES];
        if (infos.count > 0) {
            AliyunCompositionInfo *info = infos.firstObject;
            
            NSString *src = info.sourcePath;
            [weakSelf.aliyunBuilder updateCover:src];
            [self.coverBtn setImage:[UIImage imageWithContentsOfFile:src] forState:UIControlStateNormal];

        }
    };
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onExportBtnClicked:(UIButton *)sender {
    
    [self.aliyunBuilder save];
    if (self.updateComplatedBlock) {
        self.updateComplatedBlock();
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)onLockContentChanged:(AliyunTemplateModifyContent *)modifyContent {
    [self.aliyunBuilder updateParam:modifyContent];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.aliyunBuilder getModifyContentList].count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlivcTemplateBuilderContentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlivcTemplateBuilderContentCell" forIndexPath:indexPath];
    AliyunTemplateModifyContent *modifyContent = [[self.aliyunBuilder getModifyContentList] objectAtIndex:indexPath.row];
    cell.delegate = self;
    [cell updateModifyContent:modifyContent];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

@end
