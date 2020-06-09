//
//  AliyunUploadViewController.m
//  qusdk
//
//  Created by Worthy on 2017/11/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunUploadViewController.h"
#import "AVC_ShortVideo_Config.h"
#import "AlivcShortVideoUploadManager.h"
#import "AliyunPublishTopView.h"
#import <AVFoundation/AVFoundation.h>
#import "AFNetworking.h"

@interface AliyunUploadViewController () <AliyunPublishTopViewDelegate,
                                          AlivcShortVideoUploadManagerDelegate>
@property(nonatomic, strong) AliyunPublishTopView *topView;
@property(nonatomic, strong) UIProgressView *progressView;
@property(nonatomic, strong) UIView *playView;
@property(nonatomic, strong) UIScrollView *playScrollView; //针对9：16增加滑动视图，解决由于顶部navbar视频显示不全问题
@property(nonatomic, strong) UILabel *uploadLabel;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) AVPlayer *player;
@property(nonatomic, strong) AVPlayerItem *playerItem;
@property(nonatomic, strong) AVPlayerLayer *playerLayer;
@property(nonatomic, strong) AlivcShortVideoUploadManager *uploadManager;
@property(nonatomic, assign) BOOL finished;
@end

@implementation AliyunUploadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [self setupPlayer];
    [self startUpload];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)setupSubviews {
  self.topView = [[AliyunPublishTopView alloc]
      initWithFrame:CGRectMake(0, 0, ScreenWidth, StatusBarHeight + 44)];
  self.topView.nameLabel.text = NSLocalizedString(@"我的视频" , nil);
  self.topView.delegate = self;
  self.topView.finishButton.hidden = YES;
  [self.topView.cancelButton setImage:[AliyunImage imageNamed:@"cancel"]
                             forState:UIControlStateNormal];
  [self.topView.cancelButton setTitle:nil forState:UIControlStateNormal];
  [self.view addSubview:self.topView];
  self.view.backgroundColor = [AliyunIConfig config].backgroundColor;

  self.playScrollView = [[UIScrollView alloc]
      initWithFrame:CGRectMake(0, StatusBarHeight + 44, ScreenWidth,
                               ScreenHeight - StatusBarHeight - 44)];
  self.playScrollView.contentSize = CGSizeMake(
      ScreenWidth, ScreenWidth * _videoSize.height / _videoSize.width);
  self.playScrollView.showsHorizontalScrollIndicator = NO;
  [self.view addSubview:self.playScrollView];

  self.playView =
      [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth,
                                               ScreenWidth * _videoSize.height /
                                                   _videoSize.width)];
  [self.playScrollView addSubview:self.playView];

  self.progressView = [[UIProgressView alloc]
      initWithFrame:CGRectMake(0, StatusBarHeight + 44, ScreenWidth, 4)];
  self.progressView.backgroundColor = rgba(0, 0, 0, 0.6);
  self.progressView.progressTintColor =
      [AliyunIConfig config].timelineTintColor;
  [self.view addSubview:self.progressView];

  self.uploadLabel = [[UILabel alloc]
      initWithFrame:CGRectMake((ScreenWidth - 140) / 2,
                               StatusBarHeight + 44 + 24, 140, 32)];
  self.uploadLabel.backgroundColor = rgba(35, 42, 66, 0.5);
  self.uploadLabel.layer.cornerRadius = 2;
  self.uploadLabel.layer.masksToBounds = YES;
  self.uploadLabel.textColor = [UIColor whiteColor];
  [self.uploadLabel setFont:[UIFont systemFontOfSize:14]];
  self.uploadLabel.textAlignment = NSTextAlignmentCenter;
  self.uploadLabel.hidden = YES;
  [self.view addSubview:self.uploadLabel];

  self.titleLabel = [[UILabel alloc]
      initWithFrame:CGRectMake(20,
                               StatusBarHeight + 44 +
                                   (ScreenWidth * _videoSize.height /
                                    _videoSize.width),
                               ScreenWidth - 40, 40)];
  self.titleLabel.text = _videoTitle;
  self.titleLabel.textColor = [UIColor whiteColor];
  [self.titleLabel setFont:[UIFont systemFontOfSize:12]];
  [self.view addSubview:self.titleLabel];
}


- (void)setupPlayer {
  NSURL *videoUrl = [NSURL fileURLWithPath:_videoPath];
  _playerItem = [[AVPlayerItem alloc] initWithURL:videoUrl];
  _player = [AVPlayer playerWithPlayerItem:_playerItem];
  _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];

  _playerLayer.frame = self.playView.bounds;
  [self.playView.layer addSublayer:_playerLayer];
  [self addObserver:self
         forKeyPath:@"_playerItem.status"
            options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld
            context:nil];

  _player.actionAtItemEnd = AVPlayerActionAtItemEndNone;
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(playerItemDidReachEnd:)
             name:AVPlayerItemDidPlayToEndTimeNotification
           object:_playerItem];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(appWillEnterForeground:)
             name:UIApplicationWillEnterForegroundNotification
           object:nil];
  [[NSNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(appDidEnterBackground:)
             name:UIApplicationDidEnterBackgroundNotification
           object:nil];
}

- (void)viewDidLayoutSubviews {
  [super viewDidLayoutSubviews];
  _playerLayer.frame = self.playView.bounds;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
}

- (void)dealloc {
    [self removeObserver:self forKeyPath:@"_playerItem.status"];
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[AFNetworkReachabilityManager sharedManager] stopMonitoring];
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:nil];
    NSLog(@"~~~~~~%s delloc", __PRETTY_FUNCTION__);
}
- (BOOL)shouldAutorotate {
  return NO;
}
#pragma mark - notification

- (void)playerItemDidReachEnd:(NSNotification *)notification {
  AVPlayerItem *p = [notification object];
  [p seekToTime:kCMTimeZero];
}

- (void)appWillEnterForeground:(id)sender {
    [self.uploadManager resumeUpload];
    [_player play];
}

- (void)appDidEnterBackground:(id)sender {
    [self.uploadManager pauseUpload];
    [_player pause];
}

#pragma mark - observe

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSKeyValueChangeKey, id> *)change
                       context:(void *)context {
  if ([keyPath isEqualToString:@"_playerItem.status"]) {
    AVPlayerItemStatus status = _playerItem.status;
    if (status == AVPlayerItemStatusReadyToPlay) {
      [_player play];
    }
  }
}

#pragma mark - top view delegate

- (void)cancelButtonClicked {
  if (!_finished) {
//    UIAlertView *alert =
//        [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"正在上传视频，确定要放弃上传吗" , nil)
//                                   message:nil
//                                  delegate:self
//                         cancelButtonTitle:NSLocalizedString(@"取消上传" , nil)
//                         otherButtonTitles:NSLocalizedString(@"继续上传" , nil), nil];
//    alert.tag = 101;
//    [alert show];
      
       __weak typeof(self) weakSelf = self;
      UIAlertController *alertController =[UIAlertController alertControllerWithTitle:NSLocalizedString(@"正在上传视频，确定要放弃上传吗" , nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
         UIAlertAction *action1 =[UIAlertAction actionWithTitle:NSLocalizedString(@"取消上传" , nil) style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
              [weakSelf.uploadManager cancelUpload];
              [weakSelf.navigationController popToRootViewControllerAnimated:YES];
         }];
         UIAlertAction *action2 =[UIAlertAction actionWithTitle:NSLocalizedString(@"继续上传" , nil) style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
              if (weakSelf.uploadManager.currentStatus >1) {
                            [weakSelf.uploadManager startUpload];
                        }
         }];
         [alertController addAction:action1];
         [alertController addAction:action2];
         [self presentViewController:alertController animated:YES completion:nil];
      
      
      
  } else {
    [self.navigationController popToRootViewControllerAnimated:YES];
  }
}

- (void)finishButtonClicked {
}

#pragma mark -alert view delegate

//- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
//    if (alertView.tag == 101) {
//        if (buttonIndex == 0) {
//            [_uploadManager cancelUpload];
//            [self.navigationController popToRootViewControllerAnimated:YES];
//        }else{
//            if (_uploadManager.currentStatus >1) {
//                [_uploadManager startUpload];
//            }
//        }
//    }
//}

#pragma mark - AlivcShortVideoUploadManagerDelegate
- (void)uploadManager:(AlivcShortVideoUploadManager *)manager updateProgress:(CGFloat)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self->_progressView setProgress:progress];
        [self updateUploadLabelWithProgress:progress];
    });
}

- (void)uploadManager:(AlivcShortVideoUploadManager *)manager uploadStatusChangedTo:(AlivcUploadStatus)newStatus {
    switch (newStatus) {
        case AlivcUploadStatusFailure: {
            dispatch_async(dispatch_get_main_queue(), ^{
                self->_progressView.hidden = YES;
                self->_uploadLabel.hidden = YES;
//                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"上传失败" , nil)
//                                                                message:nil
//                                                               delegate:self
//                                                      cancelButtonTitle:nil
//                                                      otherButtonTitles:NSLocalizedString(@"确定" , nil), nil];
//                [alert show];
                
                 
                     UIAlertController *alertController =[UIAlertController alertControllerWithTitle:NSLocalizedString(@"上传失败" , nil) message:nil preferredStyle:UIAlertControllerStyleAlert];
                        
                UIAlertAction *action =[UIAlertAction actionWithTitle:NSLocalizedString(@"确定" , nil) style:UIAlertActionStyleDefault handler:nil];
                        [alertController addAction:action];
                
                        [self presentViewController:alertController animated:YES completion:nil];
                
                
            });
        } break;
        case AlivcUploadStatusSuccess: {
            _finished = YES;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),dispatch_get_main_queue(), ^{
                self->_progressView.hidden = YES;
                self->_uploadLabel.hidden = YES;
                           });
        } break;
        default:
            break;
    }
}

#pragma mark - util

- (void)updateUploadLabelWithProgress:(CGFloat)progress {
    if (progress < 0) {
        return;
    }
    if (progress < 1) {
        self.uploadLabel.text = [NSString stringWithFormat:@"%@ %d%%", NSLocalizedString(@"正在上传", nil) ,(int)(progress * 100)];
    } else {
        NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"视频上传成功", nil)];
        NSTextAttachment *textAttachment = [[NSTextAttachment alloc] init];
        textAttachment.image = [AliyunImage imageNamed:@"icon_upload_success"];
        NSAttributedString *attrStringWithImage = [NSAttributedString attributedStringWithAttachment:textAttachment];
        [attributedString replaceCharactersInRange:NSMakeRange(0, 1) withAttributedString:attrStringWithImage];
        self.uploadLabel.attributedText = attributedString;
    }
    _progressView.hidden = NO;
    _uploadLabel.hidden = NO;
}

- (void)startUpload{
    AliyunUploadSVideoInfo *info = [AliyunUploadSVideoInfo new];
    info.title = @"test video";
    info.desc = self.videoTitle;
    _uploadManager = [AlivcShortVideoUploadManager shared];
    [_uploadManager setCoverImagePath:_coverImagePath videoInfo:info videoPath:_videoPath];
    _uploadManager.managerDelegate = self;
    [_uploadManager startUpload];
    [self startNetworketingMonitoring];
}

- (void)startNetworketingMonitoring{
    __weak typeof(self)weakSelf = self;
    [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if ((status != AFNetworkReachabilityStatusNotReachable) && (weakSelf.uploadManager.currentStatus>1)) {
            [weakSelf.uploadManager startUpload];
        }
    }];
    [[AFNetworkReachabilityManager sharedManager] startMonitoring];
}

@end
