//
//  AliyunPublishViewController.m
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AlivcExportViewController.h"
#import "AVC_ShortVideo_Config.h"
#import "AliyunCoverPickViewController.h"
#import "AliyunPublishProgressView.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import <AliyunVideoSDKPro/AliyunVodPublishManager.h>
#import "AliyunPublishTopView.h"
#import "AliyunUploadViewController.h"
#import "QUProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+AlivcHelper.h"
#import "AlivcTemplateResourceManager.h"
#import "AlivcTemplateBuilderViewController.h"
#import "ElapsedTimeMeasurer.h"
#import "AliyunSVideoApi.h"
#import "AliVideoClientUser.h"
#import "MBProgressHUD+AlivcHelper.h"
#import <VODUpload/VODUploadClient.h>

@interface AlivcExportViewController () <
AliyunPublishTopViewDelegate, AliyunIExporterCallback, AliyunIVodUploadCallback, UploadStreamFileInfoDelegate, AliyunPublishProgressViewDelegate, UITextFieldDelegate>
@property(nonatomic, strong) ElapsedTimeMeasurer *elapsedTimeMeasurer;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) AliyunPublishTopView *topView;
@property(nonatomic, strong) UITextField *titleView;
@property(nonatomic, strong) UIImageView *backgroundView;
@property(nonatomic, strong) UIImageView *coverImageView;
@property(nonatomic, strong) UIButton *pickButton;
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) AliyunPublishProgressView *publishProgressView;
@property(nonatomic, strong) UIButton *templateBuildButton;

@property(nonatomic, assign) BOOL finished;
@property(nonatomic, assign) BOOL failed;

@property(nonatomic, weak) MBProgressHUD *coverUploading;
@property(nonatomic, strong) AliyunVodPublishManager *publishManager;
@property(nonatomic, strong) UploadStreamFileInfo *streamFileInfo;
@property(nonatomic, copy) NSString *coverImageUrl;
@property(nonatomic, copy) NSString *coverImageUploadAuth;
@property(nonatomic, copy) NSString *coverImageUploadAddress;
@property(nonatomic, copy) NSString *videoId;
/**
 能否显示错误：YES：能， NO：不能
 因为退后台之后，重新进来，此时报错是第一次合成报错，u退后台导致的错误那就不显示错误，
 */
@property(nonatomic, assign) BOOL canPopError;

/**
 出现特定错误，重新合成的次数
 */
@property(nonatomic, assign) NSInteger errorReExportCount;
@end

@implementation AlivcExportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addNotifications];
    [self setupSubviews];
    _titleView.text = _draft.title;
    _canPopError = YES;
    _errorReExportCount = 0;
    _elapsedTimeMeasurer = [ElapsedTimeMeasurer new];
}

- (AliyunVodPublishManager *)publishManager{
    if (!_publishManager) {
        _publishManager =[[AliyunVodPublishManager alloc]init];
        _publishManager.exportCallback = self;
        _publishManager.uploadCallback = self;
    }
    return _publishManager;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

//开始合成
- (void)exportVideo{
    [_elapsedTimeMeasurer begin];
   int result = [self.publishManager exportWithTaskPath:_taskPath outputPath:_outputPath];
    if (result != 0) {
        [self showAlertWithTitle:[@"合成失败" localString] message:[@"合成失败,请返回重试" localString]];
    }
}
//继续合成
- (void)resumeExportVideo{
    int result = [self.publishManager resumeExport];
    if (result != 0) {
        [self showAlertWithTitle:[@"合成失败" localString] message:[@"合成失败,请返回重试" localString]];
    }
}

- (void)showAlertWithTitle:(NSString *)title message:(NSString *)message{
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertController *alertController =[UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action =[UIAlertAction actionWithTitle:[@"确定" localString] style:UIAlertActionStyleDefault handler:nil];
        [alertController addAction:action];
        [self presentViewController:alertController animated:YES completion:nil];
    });
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotate {
    return NO;
}

//- (void)dealloc {
//    [self removeNotifications];
//    NSLog(@"~~~~~~%s delloc", __PRETTY_FUNCTION__);
//}

- (void)setupSubviews {
    self.containerView = [[UIView alloc]
                          initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    [self.view addSubview:self.containerView];
    // top
    self.topView = [[AliyunPublishTopView alloc]
                    initWithFrame:CGRectMake(0, 0, ScreenWidth, StatusBarHeight + 44)];
    self.topView.nameLabel.hidden = YES;
    [self.topView.cancelButton setImage:[AlivcImage imageNamed:@"back"]
                               forState:UIControlStateNormal];
    [self.topView.cancelButton setTitle:nil forState:UIControlStateNormal];
    [self.topView.finishButton setTitle:NSLocalizedString(@"发布" , nil) forState:UIControlStateNormal];
    _topView.finishButton.enabled = NO;
    self.topView.delegate = self;
    [self.containerView addSubview:self.topView];
    
    // middle
    self.backgroundView =
    [[UIImageView alloc] initWithFrame:CGRectMake(0, StatusBarHeight + 44,
                                                  ScreenWidth, ScreenWidth)];
    self.backgroundView.image = self.backgroundImage;
    self.backgroundView.userInteractionEnabled = YES;
    [self.containerView addSubview:self.backgroundView];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
    UIVisualEffectView *effectView =
    [[UIVisualEffectView alloc] initWithEffect:effect];
    [self.backgroundView addSubview:effectView];
    effectView.frame = CGRectMake(0, 0, ScreenWidth, ScreenWidth);
    
    // pick
    CGFloat length = ScreenWidth * 3 / 4.0f;
    CGFloat ratio = _outputSize.width / _outputSize.height;
    CGFloat coverWidth, coverHeight = 0;
    if (ratio > 1) {
        coverWidth = length;
        coverHeight = coverWidth / ratio;
    } else {
        coverHeight = length;
        coverWidth = length * ratio;
    }
    self.coverImageView = [[UIImageView alloc]
                           initWithFrame:CGRectMake(0, 0, coverWidth, coverHeight)];
    self.coverImageView.center = CGPointMake(ScreenWidth / 2, ScreenWidth / 2);
    self.coverImageView.userInteractionEnabled = YES;
    self.coverImageView.image = self.coverImage;
    [effectView.contentView addSubview:self.coverImageView];
    
    self.pickButton =
    [[UIButton alloc] initWithFrame:CGRectMake((coverWidth - 120) / 2,
                                               coverHeight - 46, 120, 36)];
    self.pickButton.backgroundColor = rgba(0, 0, 0, 0.5);
    self.pickButton.layer.cornerRadius = 2;
    self.pickButton.layer.masksToBounds = YES;
    [self.pickButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
    NSMutableAttributedString *attributedString =
    [[NSMutableAttributedString alloc] init];
    
    NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
    textAttachment.image = [AliyunImage imageNamed:@"icon_cover"];
    NSAttributedString *attrStringWithImage =
    [NSAttributedString attributedStringWithAttachment:textAttachment];
    [attributedString appendAttributedString:attrStringWithImage];
    
    NSAttributedString *appendString = [[NSAttributedString alloc]
                                        initWithString:NSLocalizedString(@"选择封面", nil)
                                        attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    [attributedString appendAttributedString:appendString];
    
    [self.pickButton setAttributedTitle:attributedString
                               forState:UIControlStateNormal];
    [self.pickButton.titleLabel setFont:[UIFont systemFontOfSize:12]];
    [self.pickButton addTarget:self
                        action:@selector(pickButtonClicked)
              forControlEvents:UIControlEventTouchUpInside];
    [self.coverImageView addSubview:self.pickButton];
    self.coverImageView.hidden = YES;
    // progress
    self.publishProgressView = [[AliyunPublishProgressView alloc]
                                initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenWidth)];
    self.publishProgressView.delegate = self;
    [effectView.contentView addSubview:self.publishProgressView];
    self.progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 4)];
    self.progressView.backgroundColor = rgba(0, 0, 0, 0.6);
    self.progressView.progressTintColor = [AliyunIConfig config].timelineTintColor;
    effectView.userInteractionEnabled = YES;
    [effectView.contentView addSubview:self.progressView];
    
    // bottom
    self.titleView = [[UITextField alloc]
                      initWithFrame:CGRectMake(20, StatusBarHeight + 44 + ScreenWidth,
                                               ScreenWidth - 40, 54)];
    self.titleView.attributedPlaceholder = [[NSAttributedString alloc]
                                            initWithString:NSLocalizedString(@"你可以在合成中添加视频描述...", nil)
                                            attributes:@{
                                                         NSForegroundColorAttributeName : rgba(188, 190, 197, 1)
                                                         }];
    self.titleView.tintColor = [AliyunIConfig config].timelineTintColor;
    ;
    self.titleView.textColor = [UIColor whiteColor];
    [self.titleView setFont:[UIFont systemFontOfSize:14]];
    self.titleView.returnKeyType = UIReturnKeyDone;
    self.titleView.delegate = self;
    self.titleView.backgroundColor = [AliyunIConfig config].backgroundColor;
    [self.containerView addSubview:self.titleView];
    
    UIView *line = [[UIView alloc]
                    initWithFrame:CGRectMake(20, StatusBarHeight + 44 + ScreenWidth + 52,
                                             ScreenWidth - 40, 1)];
    line.backgroundColor = rgba(90, 98, 120, 1);
    [self.containerView addSubview:line];
    UILabel *label = [[UILabel alloc]
                      initWithFrame:CGRectMake(20, StatusBarHeight + 44 + ScreenWidth + 52 + 4,
                                               ScreenWidth - 40, 14)];
    label.textColor = rgba(110, 118, 139, 1);
    label.text = [@"countoflimit" localString];
    label.font = [UIFont systemFontOfSize:10];
    [self.containerView addSubview:label];
    
    
    UIButton *templateBuildButton = [[UIButton alloc] initWithFrame:CGRectMake((ScreenWidth - 100) / 2.0, CGRectGetMaxY(label.frame) + 44, 100, 32)];
    [templateBuildButton setTitle:@"保存为模板" forState:UIControlStateNormal];
    [templateBuildButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    templateBuildButton.backgroundColor = [UIColor systemPinkColor];
    templateBuildButton.layer.cornerRadius = 6;
    templateBuildButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [templateBuildButton addTarget:self action:@selector(onTemplateBuildButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.templateBuildButton = templateBuildButton;
    self.templateBuildButton.hidden = YES;
    [self.containerView addSubview:templateBuildButton];
    
    // vc
    self.view.backgroundColor = [AliyunIConfig config].backgroundColor;
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

#pragma mark - notification

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}

//- (void)removeNotifications {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect end = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration =
    [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    CGFloat containerHeight = StatusBarHeight + 44 + ScreenWidth + 52 + 22;
    
    CGFloat offset = ScreenHeight - CGRectGetHeight(end) - containerHeight;
    if (offset < 0) {
        [UIView animateWithDuration:duration
                         animations:^{
                             self->_containerView.frame =
                             CGRectMake(0, offset, ScreenWidth, ScreenHeight);
                         }];
    }
}

- (void)keyboardWillHide:(NSNotification *)note {
    CGFloat duration =
    [note.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    [UIView animateWithDuration:duration
                     animations:^{
                         self->_containerView.frame =
                         CGRectMake(0, 0, ScreenWidth, ScreenHeight);
                     }];
}

- (void)applicationWillResignActive {
    _canPopError = NO;
    [self.publishManager pauseExport];
}

- (void)applicationDidBecomeActive {
    if (!_finished && !_failed) {
        [self resumeExportVideo];
    }
}

#pragma mark - action

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [_titleView resignFirstResponder];
}

- (void) updateCoverImageFileIfNeed {
    NSString *coverImgPath = self.coverPath;
    if (![NSFileManager.defaultManager fileExistsAtPath:coverImgPath] || !_coverImage) {
        return;
    }
    NSData *data = UIImagePNGRepresentation(_coverImage);
    [data writeToFile:coverImgPath atomically:YES];
}

- (void) uploadCoverImageIfNeed {
    if (self.coverImageUrl.length > 0) {
        [self startUploadCover];
    }
}

- (void)pickButtonClicked {
    __weak typeof(self)weakSelf = self;
    AliyunCoverPickViewController *vc = [AliyunCoverPickViewController new];
    vc.outputSize = _outputSize;
    vc.videoPath = _outputPath;
    vc.finishHandler = ^(UIImage *image) {
        weakSelf.coverImage = image;
        [weakSelf updateCoverImageFileIfNeed];
        [weakSelf uploadCoverImageIfNeed];
        weakSelf.coverImageView.image = image;
        weakSelf.backgroundView.image = image;
        [weakSelf.draft updateCover:image];
    };
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - util

- (UIImage *)thumbnailWithVideoPath:(NSString *)videoPath
                         outputSize:(CGSize)outputSize {
    AVURLAsset *asset =
    [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    AVAssetImageGenerator *_generator =
    [[AVAssetImageGenerator alloc] initWithAsset:asset];
    _generator.maximumSize = outputSize;
    _generator.appliesPreferredTrackTransform = YES;
    _generator.requestedTimeToleranceAfter = kCMTimeZero;
    _generator.requestedTimeToleranceBefore = kCMTimeZero;
    CMTime time = CMTimeMake(0 * 1000, 1000);
    CGImageRef image = [_generator copyCGImageAtTime:time
                                          actualTime:NULL
                                               error:nil];
    UIImage *picture = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return picture;
}

#pragma mark - top view delegate

- (void)cancelButtonClicked {
//    __weak typeof(self)weakSelf = self;
    if (!_finished && !_failed) {
//        UIAlertController *alertController =[UIAlertController alertControllerWithTitle:[@"提示" localString] message:[@"返回编辑后将不再合成" localString] preferredStyle:UIAlertControllerStyleAlert];
//        UIAlertAction *action =[UIAlertAction actionWithTitle:[@"go_ahead_compose" localString] style:UIAlertActionStyleDefault handler:nil];
//
//        UIAlertAction *action2 =[UIAlertAction actionWithTitle:[@"取消合成" localString] style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
//            [weakSelf.publishManager cancelExport];
//            [weakSelf.navigationController popViewControllerAnimated:YES];
//        }];
//        [alertController addAction:action];
//        [alertController addAction:action2];
//        [self presentViewController:alertController animated:YES completion:nil];
         [self.publishManager cancelExport];
         [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (NSString *) videoTitle {
    NSString *title = _titleView.text;
    if (title.length == 0) {
        title = @"未命名";
    }
    if (title.length > 20) {
        title = [title substringToIndex:20];
    }
    return title;
}

- (NSString *) coverPath {
    return [_taskPath stringByAppendingPathComponent:@"cover.png"];
}

//发布
- (void)finishButtonClicked {
    if (!_finished) {
        [self showAlertWithTitle:[@"提示" localString] message:[@"请等待合成完成" localString]];
        return;
    }
    
    NSString *coverPath = self.coverPath;
    NSData *data = UIImagePNGRepresentation(_coverImage);
    [data writeToFile:coverPath atomically:YES];
    
    AliyunUploadViewController *vc = [[AliyunUploadViewController alloc] init];
    vc.videoPath = _outputPath;
    vc.coverImagePath = coverPath;
    vc.videoSize = self.outputSize;
    vc.videoTitle = self.videoTitle;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onTemplateBuildButtonClicked:(UIButton *)sender {
    
    NSString *taskPath = [[AlivcTemplateResourceManager builtTemplatePath] stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
    AliyunTemplateBuilder *builder = [AliyunTemplateBuilder build:taskPath editorTaskPath:_taskPath];
    if (builder) {
        // update title
        [builder updateTitle:_titleView.text];
        
        // update cover url
        NSString *coverPath = [_taskPath stringByAppendingPathComponent:@"template_cover.png"];
        NSData *data = UIImagePNGRepresentation(_coverImage);
        [data writeToFile:coverPath atomically:YES];
        [builder updateCover:coverPath];
        
        // update preview with remote url
        [builder updatePreviewVideo:_outputPath];
        
        // save all
        [builder save];
        
        AlivcTemplateBuilderViewController *vc = [[AlivcTemplateBuilderViewController alloc] initWithEditorTaskPath:taskPath isOpen:YES];
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    [self showAlertWithTitle:@"" message:@"保存失败"];

}

#pragma mark - export callback
- (void)exportProgress:(float)progress {
    [self.progressView setProgress:progress];
    [self.publishProgressView setProgress:progress];
}

- (void)exporterDidCancel {
    NSLog(@"export cancel");
    //合成结束，开启侧滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)exporterDidStart {
    //开始合成禁用侧滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)exportError:(int)errorCode {
    NSLog(@"export error");
    if (errorCode == 268447759 && _canPopError == NO) {
        //退后台导致的上一次错误 - 重新开始合成
        if (_errorReExportCount > 5) {
            [self showExportError:errorCode];
        } else {
            [self.publishManager cancelExport];
            [self exportVideo];
            _canPopError = YES;
            _errorReExportCount++;
        }
        return;
    }
    [self.publishManager cancelExport];
    [self showExportError:errorCode];
    //合成结束，开启侧滑返回
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)showExportError:(int)errorCode {
    //正常合成失败
    _failed = YES;
    [self.publishProgressView markAsExportFailed];

    [self showAlertWithTitle:[@"合成失败" localString] message:[NSString stringWithFormat:@"Error Code:%d",
                                                  errorCode]];
}

- (void) onFinish {
    _progressView.hidden = YES;
    _topView.finishButton.enabled = YES;
    
    if (_coverImage == nil) {
        _coverImage = [self thumbnailWithVideoPath:_outputPath outputSize:_outputSize];
    }
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:_outputPath] completionBlock:^(NSURL *assetURL, NSError *error) {
        NSLog(@"视频已保存到相册");
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        self->_coverImageView.image = _coverImage;
        self->_backgroundView.image = _coverImage;
        self->_coverImageView.hidden = NO;
        self->_publishProgressView.hidden = YES;
    });
    if (self.finishBlock) {
        self.finishBlock(_outputPath);
    }
    self.templateBuildButton.hidden = NO;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}

- (void)exporterDidEnd:(NSString *)outputPath {
    [_elapsedTimeMeasurer endShowToast];
    NSAssert([outputPath isEqualToString:_outputPath], @"export to wrong output path!");
    _finished = YES;
    [_publishProgressView markAsExportFinihed];
    if (!_publishProgressView.exportAndUpload) {
        [self onFinish];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)refreshVideo{
    __weak AlivcExportViewController *weakSelf = self;
    [AliyunSVideoApi refreshVideoUploadAuthWithToken:[AliVideoClientUser shared].token videoId:self.videoId handler:^(NSString *uploadAddress, NSString *uploadAuth, NSError *error) {
        [weakSelf runInMainThread:^(AlivcExportViewController *strongSelf) {
            if (error) {
                [strongSelf showAlertWithTitle:@"更新视频授权失败" message:error.description];
                strongSelf.publishProgressView.exportAndUpload = NO;
                [strongSelf exportVideo];
                return;
            }
            
            [strongSelf.publishManager refreshWithUploadAuth:uploadAuth];
        }];
    }];
}

- (void) runInMainThread:(void(^)(AlivcExportViewController *strongSelf))cb {
    __weak AlivcExportViewController *weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        AlivcExportViewController *strongSelf = weakSelf;
        if (!strongSelf) {
            return;
        }
        if (cb) {
            cb(strongSelf);
        }
    });
}

// MARK: - UploadStreamFileInfoDelegate
- (void) onUploadStreamFileInfo:(UploadStreamFileInfo *)fileInfo sizeChange:(NSUInteger)size {
    [self runInMainThread:^(AlivcExportViewController *strongSelf) {
        strongSelf.publishProgressView.totalSize = size;
    }];
}

- (void) onUploadStreamFileInfo:(UploadStreamFileInfo *)fileInfo uploadProgress:(NSUInteger)uploadSize {
    [self runInMainThread:^(AlivcExportViewController *strongSelf) {
        strongSelf.publishProgressView.uploadedSize = uploadSize;
    }];
}

- (void) onUploadFinish:(BOOL)isSuccess errMsg:(NSString *)errMsg {
    if (_publishProgressView.exportAndUpload) {
        if (isSuccess) {
            [_publishProgressView markAsUploadFinished];
            if (self.coverImageUrl.length > 0) {
                [self startUploadCover];
            }
        } else {
            [_publishProgressView markAsUploadFail];
            self.coverImageUrl = nil;
            self.coverImageUploadAuth = nil;
            self.coverImageUploadAddress = nil;
            self.videoId = nil;
            [self showAlertWithTitle:@"合成时上传失败" message:errMsg];
        }
        
        if (_finished) {
            [self onFinish];
        } else {
            _publishProgressView.exportAndUpload = NO;
        }
    }
}

// MARK: - AliyunIVodUploadCallback
- (void)publishManagerUploadSuccess:(AliyunVodPublishManager *)manager {
    [self runInMainThread:^(AlivcExportViewController *strongSelf) {
        if (strongSelf.publishManager.uploadState == AliyunVodUploadImage) {
            [strongSelf.coverUploading replaceSuccessMessage:@"上传封面成功"];
            [strongSelf.coverUploading hideAnimated:YES afterDelay:2.0];
            strongSelf.coverUploading = nil;
            return;
        }
        
        [strongSelf onUploadFinish:YES errMsg:nil];
    }];
}

- (void)publishManager:(AliyunVodPublishManager *)manager uploadFailedWithCode:(NSString *)code message:(NSString *)message {
    [self runInMainThread:^(AlivcExportViewController *strongSelf) {
        if (strongSelf.publishManager.uploadState == AliyunVodUploadImage) {
            [strongSelf.coverUploading replaceWarningMessage:@"上传封面失败"];
            [strongSelf.coverUploading hideAnimated:YES afterDelay:3.0];
            strongSelf.coverUploading = nil;
            return;
        }
        
        [strongSelf onUploadFinish:NO errMsg:message];
    }];
}

- (void)publishManager:(AliyunVodPublishManager *)manager uploadProgressWithUploadedSize:(long long)uploadedSize totalSize:(long long)totalSize {}

- (void)publishManagerUploadTokenExpired:(AliyunVodPublishManager *)manager {
    [self runInMainThread:^(AlivcExportViewController *strongSelf) {
        if (manager.uploadState == AliyunVodUploadImage) {
            [strongSelf.coverUploading replaceWarningMessage:@"封面授权过期，上传封面失败"];
            [strongSelf.coverUploading hideAnimated:YES afterDelay:3];
            strongSelf.coverUploading = nil;
        } else {
            if (strongSelf.videoId) {
                [strongSelf refreshVideo];
            } else {
                [strongSelf startUploadVideo];
            }
        }
    }];
}

- (void)publishManagerUploadRetry:(AliyunVodPublishManager *)manager {
    NSLog(@"上传重试");
}

- (void)publishManagerUploadRetryResume:(AliyunVodPublishManager *)manager {
    NSLog(@"上传继续重试");
}

// MARK: - AliyunPublishProgressViewDelegate
- (void) onAliyunPublishProgressViewDidExport:(AliyunPublishProgressView *)view {
    [self exportVideo];
    view.exportAndUpload = NO;
}

- (void) onAliyunPublishProgressViewDidExportAndUpload:(AliyunPublishProgressView *)view {
    NSError *error = nil;
    UploadStreamFileInfo *info = [self.publishManager exportToStreamFileWithTaskPath:_taskPath outputPath:_outputPath error:&error];
    if (error) {
        [self showAlertWithTitle:@"导出失败" message:[NSString stringWithFormat:@"错误码：%ld", error.code]];
        return;
    }
    self.streamFileInfo = info;
    self.streamFileInfo.delegate = self;
    view.exportAndUpload = YES;
    [self fetchVideoAuthAndUpload];
}

- (void) fetchVideoAuthAndUpload {
    NSString *coverPath = self.coverPath;
    __weak AlivcExportViewController *weakSelf = self;
    [AliyunSVideoApi getImageUploadAuthWithToken:AliVideoClientUser.shared.token
                                           title:self.videoTitle
                                        filePath:coverPath
                                            tags:nil
                                         handler:^(NSString *imgUploadAddress, NSString *imgUploadAuth, NSString *imageURL, NSString *imageId, NSError *error) {
        if (error) {
            [weakSelf runInMainThread:^(AlivcExportViewController *strongSelf) {
                [strongSelf onUploadFinish:NO errMsg:@"获取封面上传凭证失败，请稍后再发布"];
            }];
            return;
        }
        
        [weakSelf runInMainThread:^(AlivcExportViewController *strongSelf) {
            strongSelf.coverImageUrl = imageURL;
            strongSelf.coverImageUploadAuth = imgUploadAuth;
            strongSelf.coverImageUploadAddress = imgUploadAddress;
            [strongSelf startUploadVideo];
        }];
    }];
}

- (void) startUploadCover {
    NSString *coverUrl = self.coverImageUrl;
    if (coverUrl.length == 0) {
        [self showAlertWithTitle:@"上传封面失败" message:@"没有视频关联的封面凭证，请重新发布视频"];
        return;
    }
    
    if (!_coverUploading) {
        _coverUploading = [MBProgressHUD showMessage:@"封面上传中..." alwaysInView:self.view];
    }
    
    NSString *coverPath = self.coverPath;
    if (![NSFileManager.defaultManager fileExistsAtPath:coverPath]) {
        NSData *data = UIImagePNGRepresentation(_coverImage);
        [data writeToFile:coverPath atomically:YES];
    }
    
    [self.publishManager uploadImageWithPath:coverPath uploadAddress:self.coverImageUploadAddress uploadAuth:self.coverImageUploadAuth];
}

- (void) startUploadVideo {
    __weak AlivcExportViewController *weakSelf = self;
    [AliyunSVideoApi getVideoUploadAuthWithWithToken:AliVideoClientUser.shared.token
                                               title:self.videoTitle
                                            filePath:_outputPath
                                            coverURL:self.coverImageUrl
                                                desc:nil
                                                tags:nil
                                             handler:^(NSString *uploadAddress, NSString *uploadAuth, NSString *videoId, NSError *error) {
        [weakSelf runInMainThread:^(AlivcExportViewController *strongSelf) {
            if (error) {
                [strongSelf onUploadFinish:NO errMsg:@"获取视频上传凭证失败，请稍后再发布"];
                return;
            }
            
            strongSelf.videoId = videoId;
            [strongSelf.publishManager uploadStreamFile:strongSelf.streamFileInfo
                                          uploadAddress:uploadAddress
                                             uploadAuth:uploadAuth];
        }];
    }];
}

@end
