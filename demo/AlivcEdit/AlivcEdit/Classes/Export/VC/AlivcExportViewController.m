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
#import <AliyunVideoSDKPro/AliyunVodPublishManager.h>
#import "AliyunPublishTopView.h"
#import "AliyunUploadViewController.h"
#import "QUProgressView.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "NSString+AlivcHelper.h"

@interface AlivcExportViewController () <
AliyunPublishTopViewDelegate, AliyunIExporterCallback, UITextFieldDelegate>
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) AliyunPublishTopView *topView;
@property(nonatomic, strong) UITextField *titleView;
@property(nonatomic, strong) UIImageView *backgroundView;
@property(nonatomic, strong) UIImageView *coverImageView;
@property(nonatomic, strong) UIButton *pickButton;
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) AliyunPublishProgressView *publishProgressView;

@property(nonatomic, assign) BOOL finished;
@property(nonatomic, assign) BOOL failed;
@property(nonatomic, strong) UIImage *image;

@property(nonatomic, strong) AliyunVodPublishManager *publishManager;

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
    _canPopError = YES;
    _errorReExportCount = 0;
    [self exportVideo];
}

- (AliyunVodPublishManager *)publishManager{
    if (!_publishManager) {
        _publishManager =[[AliyunVodPublishManager alloc]init];
        _publishManager.exportCallback = self;
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
   int result = [self.publishManager exportWithTaskPath:_taskPath outputPath:_config.outputPath];
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

- (void)pickButtonClicked {
    __weak typeof(self)weakSelf = self;
    AliyunCoverPickViewController *vc = [AliyunCoverPickViewController new];
    vc.outputSize = _outputSize;
    vc.videoPath = _config.outputPath;
    vc.finishHandler = ^(UIImage *image) {
        weakSelf.image = image;
        weakSelf.coverImageView.image = image;
        weakSelf.backgroundView.image = image;
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

//发布
- (void)finishButtonClicked {
    if (!_finished) {

        [self showAlertWithTitle:[@"提示" localString] message:[@"请等待合成完成" localString]];
        return;
    }
    if (_titleView.text.length > 20) {
        [self showAlertWithTitle:[@"提示" localString] message:[@"视频描述太长" localString]];
        return;
    }
    
    NSString *coverPath = [_taskPath stringByAppendingPathComponent:@"cover.png"];
    NSData *data = UIImagePNGRepresentation(_image);
    [data writeToFile:coverPath atomically:YES];
    AliyunUploadViewController *vc = [[AliyunUploadViewController alloc] init];
    vc.videoPath = _config.outputPath;
    vc.coverImagePath = coverPath;
    vc.videoSize = _outputSize;
    vc.videoTitle = _titleView.text;
    [self.navigationController pushViewController:vc animated:YES];
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
    [self.publishProgressView markAsFailed];

    [self showAlertWithTitle:[@"合成失败" localString] message:[NSString stringWithFormat:@"Error Code:%d",
                                                  errorCode]];
}

- (void)exporterDidEnd:(NSString *)outputPath {
    _finished = YES;
    _progressView.hidden = YES;
    _topView.finishButton.enabled = YES;
    _image = [self thumbnailWithVideoPath:_config.outputPath
                               outputSize:_outputSize];
    [_publishProgressView markAsFinihed];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:[NSURL fileURLWithPath:_config.outputPath] completionBlock:^(NSURL *assetURL, NSError *error) {
         NSLog(@"视频已保存到相册");
     }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       self->_coverImageView.image = _image;
                       self->_backgroundView.image = _image;
                       self->_coverImageView.hidden = NO;
                       self->_publishProgressView.hidden = YES;
                   });
    if (self.finishBlock) {
        self.finishBlock(outputPath);
    }
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
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

@end
