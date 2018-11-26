//
//  AlivcShortVideoPlayViewControler.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/8/27.
//  Copyright © 2018年 Alibaba. All rights reserved.
//
/**
 * 1.请求好数据，初始化好实例，设置好封面
 * 2.滑动切换view，老的stop和，新的play
 * 3.判断是否要请求资源，判断是否要移动相关实例的位置与对应的frame。
 * 4.根据3的判断执行对应的代码
 * 备注：预加载视频资源（数据请求），预加载播放视频的个数，这是2个概念，可在vc中自己配置
 */

#import "AlivcShortVideoPlayViewControler.h"
#import <AliyunVodPlayerSDK/AliyunVodPlayerSDK.h>
#import "AlivcAppServer.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AlivcVideoPlayManager.h"
#import "AlivcVideoPlayListModel.h"
#import "AlivcPlayContainerView.h"
#import "AlivcMaskView.h"
#import "AlivcUserInfoViewController.h"

#import "AliyunMediator.h"
#import "AliyunMediaConfig.h"
#import "AliyunCompositionViewController.h"
#import "AliyunMagicCameraViewController.h"

NS_ASSUME_NONNULL_BEGIN

#pragma mark - 配置秒播方案的一些数据
static NSInteger kPreviousCount = 1; //当前播放界面（player实例）之前的界面（player实例）保留个数，应对用户下滑秒开
static NSInteger kNextCount = 1; //当前播放界面（player实例）之后的界面（player实例）预加载的个数，应对用户上滑秒开
static CGFloat kMinPanSpeed = 16.0f; //判断滑动的最小速度，小于这个数值，认定用户取消滑动
static NSInteger kPageCount = 10; //分页查询每次查询的个数
static NSInteger kCountLess_mustQurryMoreData = 3; //当前播放的视频，播放资源列表剩余的个数，如果小于这个数，则后台去请求最新的播放资源列表数据

static NSString *defaultVidString = @"6e783360c811449d8692b2117acc9212";

static CGFloat kAnimationTime = 0.26; //滑动一个完整的视频需要的时间 - 秒

static CGFloat maskButtonContainWidth = 60; //弹层button容器视图的宽
static CGFloat maskButtonContainHeight = 80; //弹层button容器视图的高

@interface AlivcShortVideoPlayViewControler ()<AliyunVodPlayerDelegate>

#pragma mark - data

@property (nonatomic, strong, nullable) NSString *accessKeyId;

@property (nonatomic, strong, nullable) NSString *accessKeySecret;

@property (nonatomic, strong, nullable) NSString *securityToken;




/**
 播放界面容器视图数组
 */
@property (nonatomic, strong) NSArray <AlivcPlayContainerView *>*playContainerList;

/**
 播放数据源列表 - 如果能在外面加载好，首次播放会更快，因为工具包的模块化的一些限制，我这里不做实现
 */
@property (nonatomic, strong) NSMutableArray <AlivcVideoPlayListModel *>*videoList;

/**
 当前正在播放的容器视图
 */
@property (nonatomic, assign) AlivcPlayContainerView *currentPlayContainer;

/**
 是否加载过图片
 */
@property (nonatomic, assign) BOOL haveQuerryImageWhenFirstEnter;




#pragma mark - UI

/**
 视频按钮
 */
@property (nonatomic, strong) UIButton *videoButton;

/**
 拍摄按钮，中间的加号按钮
 */
@property (nonatomic, strong) UIButton *shootButton;

/**
 我 - 按钮
 */
@property (nonatomic, strong) UIButton *meButton;

///**
// 更多按钮
// */
//@property (nonatomic, strong) UIButton *moreButton;
//
///**
// 头像
// */
//@property (nonatomic, strong) UIButton *userButton;

/**
 选择效果
 */
@property (nonatomic, strong) UIView *lineView;

/**
 手势视图
 */
@property (nonatomic, strong) UIView *gestureView;

/**
 点击中间按钮弹出的蒙版
 */
@property (nonatomic, strong) AlivcMaskView *maskView;


/**
 弹层模式下的拍摄按钮
 */
@property (nonatomic, strong) UIButton *maskShootButton;

/**
 弹层模式下的拍摄容器视图
 */
@property (nonatomic, strong) UIView *maskShootView;


/**
 弹层模式下的编辑
 */
@property (nonatomic, strong) UIButton *maskEditButton;

/**
 弹层模式下的编辑容器视图
 */
@property (nonatomic, strong) UIView *maskEditView;


@end

@implementation AlivcShortVideoPlayViewControler


#pragma mark - System

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initConfig];
    [self configBaseUI];
    [self configBaseData];
    [self addGesture];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.currentPlayContainer.vodPlayer) {
        [self.currentPlayContainer.vodPlayer stop];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    if (self.currentPlayContainer.vodPlayer && !self.maskView.superview) {
//        [self.currentPlayContainer.vodPlayer replay];
    }
}

- (void)dealloc{
    NSLog(@"AlivcShortVideoPlayViewControler被销毁");
    for (AlivcPlayContainerView *conView in self.playContainerList) {
        if (conView.vodPlayer) {
            [conView.vodPlayer releasePlayer];
        }
    }
}



#pragma mark - Getter

- (UIButton *)videoButton{
    if (!_videoButton) {
        _videoButton = [[UIButton alloc]init];
        [_videoButton setImage:[AlivcImage imageNamed:@"alivc_svHome_icon"] forState:UIControlStateNormal];
        [_videoButton addTarget:self action:@selector(videoButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoButton;
}

- (UIButton *)shootButton{
    if (!_shootButton) {
        _shootButton = [[UIButton alloc]init];
        [_shootButton setImage:[AlivcImage imageNamed:@"alivc_svHome_add"] forState:UIControlStateNormal];
        [_shootButton setImage:[AlivcImage imageNamed:@"alivc_svHome_addClose"] forState:UIControlStateSelected];
        [_shootButton addTarget:self action:@selector(shootButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shootButton;
}

- (UIButton *)meButton{
    if (!_meButton) {
        _meButton = [[UIButton alloc]init];
        [_meButton setImage:[AlivcImage imageNamed:@"alivc_svHome_me"] forState:UIControlStateNormal];
        [_meButton addTarget:self action:@selector(meButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _meButton;
}

- (UIView *)gestureView{
    if (!_gestureView) {
        _gestureView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _gestureView.backgroundColor = [UIColor clearColor];
    }
    return _gestureView;
}

- (AlivcMaskView *)maskView{
    if (!_maskView) {
        _maskView = [[AlivcMaskView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
        _maskView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    }
    return _maskView;
}

- (UIButton *)maskShootButton{
    if (!_maskShootButton) {
        _maskShootButton = [[UIButton alloc]init];
        [_maskShootButton setImage:[AlivcImage imageNamed:@"alivc_svHome_shoot"] forState:UIControlStateNormal];
        [_maskShootButton setImage:[AlivcImage imageNamed:@"alivc_svHome_shoot"] forState:UIControlStateSelected];
        [_maskShootButton addTarget:self action:@selector(maskShoot) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskShootButton;
}

- (UIView *)maskShootView{
    if (!_maskShootView) {
        
        _maskShootView = [[UIView alloc]init];
        _maskShootView.frame = CGRectMake(0, 0, maskButtonContainWidth, maskButtonContainHeight);
        UILabel *label = [[UILabel alloc]init];
        label.text = @"视频拍摄";
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        label.font = [UIFont systemFontOfSize:15];
        [_maskShootView addSubview:label];
        label.center = CGPointMake(maskButtonContainWidth/2, 4 + label.frame.size.height / 2);
        
        [_maskShootView addSubview:self.maskShootButton];
        self.maskShootButton.frame = CGRectMake(0, 0, maskButtonContainWidth, maskButtonContainHeight);
        self.maskShootButton.imageEdgeInsets = UIEdgeInsetsMake(label.frame.size.height + 8, 0, 0, 0);
    }
    return _maskShootView;
}


- (UIButton *)maskEditButton{
    if (!_maskEditButton) {
        _maskEditButton = [[UIButton alloc]init];
        [_maskEditButton setImage:[AlivcImage imageNamed:@"alivc_svHome_edit"] forState:UIControlStateNormal];
        [_maskEditButton setImage:[AlivcImage imageNamed:@"alivc_svHome_edit"] forState:UIControlStateSelected];
        [_maskEditButton addTarget:self action:@selector(maskEdit) forControlEvents:UIControlEventTouchUpInside];
    }
    return _maskEditButton;
}

- (UIView *)maskEditView{
    if (!_maskEditView) {
        
        _maskEditView = [[UIView alloc]init];
        _maskEditView.frame = CGRectMake(0, 0, maskButtonContainWidth, maskButtonContainHeight);
        UILabel *label = [[UILabel alloc]init];
        label.text = @"视频编辑";
        label.font = [UIFont systemFontOfSize:15];
        label.textColor = [UIColor whiteColor];
        [label sizeToFit];
        [_maskEditView addSubview:label];
        label.center = CGPointMake(maskButtonContainWidth/2, 4 + label.frame.size.height / 2);
        
        [_maskEditView addSubview:self.maskEditButton];
        self.maskEditButton.frame = CGRectMake(0, 0, maskButtonContainWidth, maskButtonContainHeight);
        self.maskEditButton.imageEdgeInsets = UIEdgeInsetsMake(label.frame.size.height + 8, 0, 0, 0);
    }
    return _maskEditView;
}

//- (UIButton *)moreButton{
//    if (!_moreButton) {
//        _moreButton = [[UIButton alloc]init];
//        [_moreButton setTitle:@"..." forState:UIControlStateNormal];
//        [_moreButton addTarget:self action:@selector(moreButtonToued) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _moreButton;
//}
//
//- (UIButton *)userButton{
//    if (!_userButton) {
//        _userButton = [[UIButton alloc]init];
//        [_userButton setTitle:@"头像" forState:UIControlStateNormal];
//        [_userButton addTarget:self action:@selector(userButtonTouched) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _userButton;
//}


- (UIView *)lineView{
    if (!_lineView) {
        _lineView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 20, 2)];
        _lineView.backgroundColor = [AlivcUIConfig shared].kAVCThemeColor;
    }
    return _lineView;
}

#pragma mark - init

/**
 初始化播放器,播放器的容器view等
 */
- (void)initConfig{
    NSInteger allCount = kNextCount + kPreviousCount + 1;
    NSMutableArray *tempViews = [[NSMutableArray alloc]init];
    
    for (NSInteger i = 0;i < allCount; i++) {
        AliyunVodPlayer *player = [[AliyunVodPlayer alloc]init];
        player.delegate = self;
        player.autoPlay = NO;
        player.circlePlay = YES;
        
        AlivcPlayContainerView *conView = [[AlivcPlayContainerView alloc]initWithPlayer:player];
        [conView addSubview:player.playerView];
        player.playerView.frame = conView.bounds;

        
        CGRect conFrame = conView.frame;
        conFrame.origin.y = i * ScreenHeight;
        conView.frame  = [self newFrameWithHandleFrame:conFrame];
        [conView bringSubviewToFront:conView.coverImageView];
        [self.view addSubview:conView];
        if (i % 2 == 0) {
            conView.backgroundColor = [UIColor redColor];
        }else{
            conView.backgroundColor = [UIColor blueColor];
        }
//        conView.alpha = 0.1 * i + 0.2;
        
        [tempViews addObject:conView];
    }
    self.playContainerList = (NSArray *)tempViews;
}

/**
 初始化界面
 */
- (void)configBaseUI{
    
    self.view.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.gestureView];
    //返回按钮
    UIButton *backButton = [[UIButton alloc]init];
    [backButton addTarget:self action:@selector(backButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    [backButton setImage:[AlivcImage imageNamed:@"avcBackIcon"] forState:UIControlStateNormal];
    [backButton sizeToFit];
    backButton.center = CGPointMake(8 + backButton.frame.size.width / 2, 20 + 22);
    [self.view addSubview:backButton];
    
//    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 50)];
//    bottomView.center = CGPointMake(ScreenWidth / 2, ScreenHeight - bottomView.frame.size.height / 2);
//    bottomView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
//    [self.view addSubview:bottomView];
    
    CGFloat beside = 16;
    CGFloat cy = ScreenHeight - 30;
    
    [self.videoButton sizeToFit];
    self.videoButton.center = CGPointMake(beside + self.videoButton.frame.size.width / 2, cy);
    [self.view addSubview:self.videoButton];
    
    [self.shootButton sizeToFit];
    self.shootButton.center = CGPointMake(ScreenWidth / 2, cy - 6);
    [self.view addSubview:self.shootButton];
    
    [self.meButton sizeToFit];
    self.meButton.center = CGPointMake(ScreenWidth - beside - self.meButton.frame.size.width / 2, cy);
    [self.view addSubview:self.meButton];
    
//    [self.moreButton sizeToFit];
//    self.moreButton.center = CGPointMake(self.meButton.center.x, ScreenHeight - bottomView.frame.size.height - 8 - self.moreButton.frame.size.height / 2);
//    [self.view addSubview:self.moreButton];
//
//    [self.userButton sizeToFit];
//    self.userButton.center = CGPointMake(self.moreButton.center.x, self.moreButton.center.y - 8 - self.userButton.frame.size.height / 2);
//    [self.view addSubview:self.userButton];
    
    [self.view addSubview:self.lineView];
    self.lineView.center = CGPointMake(self.videoButton.center.x, CGRectGetMaxY(self.videoButton.frame) + 3);
}

/**
 初始化数据
 */
- (void)configBaseData{
    _haveQuerryImageWhenFirstEnter = NO;
    [self configBaseDataSuccess:^{
        
        for(NSInteger i = 0; i < self.playContainerList.count; i ++){
            if (i < self.videoList.count) {
                AlivcVideoPlayListModel *model = self.videoList[i];
                AlivcPlayContainerView *conView = self.playContainerList[i];
                [conView setVideoModel:model];
                if (i == 0) {
                    self.currentPlayContainer = conView;
                    [self prepareWithPlayer:conView.vodPlayer model:model];
                }
            }else{
                NSLog(@"预加载的个数超过了视频资源本身的个数");
            }
        }
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self doQuerryImageWhenFirstEnter];
        });
    }];
}

/**
 第一次进入的图片预加载,保证只执行一次
 */
- (void)doQuerryImageWhenFirstEnter{
    if (_haveQuerryImageWhenFirstEnter) {
        return;
    }
    if (self.playContainerList.count == 0) {
        return;
    }
    _haveQuerryImageWhenFirstEnter = YES;
    for (NSInteger i = 1; i < self.playContainerList.count; i++) {
        AlivcPlayContainerView *conView = self.playContainerList[i];
        if (conView.videoModel) {
            [self prepareWithPlayer:conView.vodPlayer model:conView.videoModel];
        }
    }
    
}

#pragma mark - Data Manager
- (void)configBaseDataSuccess:(void(^)(void))success{
    
    
    [AlivcAppServer getStsDataWithVid:defaultVidString sucess:^(NSString *accessKeyId, NSString *accessKeySecret, NSString *securityToken) {
        
        _accessKeyId = accessKeyId;
        _accessKeySecret = accessKeySecret;
        _securityToken = securityToken;
        [AlivcVideoPlayManager requestPlayListVodPlayWithAccessKeyId:accessKeyId accessSecret:accessKeySecret securityToken:securityToken cateId:@"872354889" pageNo:1 pageCount:kPageCount sucess:^(NSArray *ary, long total) {
            AlivcVideoPlayListModel *model = ary.firstObject;
            if ([model isKindOfClass:[AlivcVideoPlayListModel class]]) {
                self.videoList = [[NSMutableArray alloc]initWithArray:ary];
            }
            
            //赋值
            for(AlivcVideoPlayListModel *itemModel in self.videoList){
                itemModel.stsAccessKeyId = accessKeyId;
                itemModel.stsAccessSecret = accessKeySecret;
                itemModel.stsSecurityToken = securityToken;
            }
            if (success) {
                success();
            }
        } failure:^(NSString *errString) {
            //
        }];

        

    } failure:^(NSString *errorString) {
        [MBProgressHUD showMessage:errorString inView:self.view];
    }];
}
/**
 请求播放的视频列表
 
 @param index 开始的index 从1开始，不是从0开始
 @param count 数量
 */
- (void)querryVideoDataWithStartIndex:(NSInteger )index count:(NSInteger )count{
    if (self.accessKeyId && self.accessKeySecret && self.securityToken) {
        [AlivcVideoPlayManager requestPlayListVodPlayWithAccessKeyId:self.accessKeyId accessSecret:self.accessKeySecret securityToken:(NSString *)self.securityToken cateId:@"" pageNo:index pageCount:count sucess:^(NSArray *ary, long total) {
            AlivcVideoPlayListModel *model = ary.firstObject;
            if ([model isKindOfClass:[AlivcVideoPlayListModel class]]) {
                //赋值
                for(AlivcVideoPlayListModel *itemModel in ary){
                    itemModel.stsAccessKeyId = self.accessKeyId;
                    itemModel.stsAccessSecret = self.accessKeySecret;
                    itemModel.stsSecurityToken = self.securityToken;
                }
                if (self.videoList) {
                    [self.videoList addObjectsFromArray:ary];
                }else{
                    self.videoList = [[NSMutableArray alloc]initWithArray:ary];
                }
                
                
            }
        } failure:^(NSString *errString) {
            //
        }];
    }else{
        [self configBaseData];
    }
    
}

#pragma mark - Public Method

/**
 进入弹层状态，拍摄还是编辑
 */
-(void)enterShootOrEdit{
    
    self.shootButton.selected = YES;
    
    [self.view addSubview:self.maskView];
    CGPoint mainCenter = self.shootButton.center;
    [self.view bringSubviewToFront:self.shootButton];
    
    CGFloat beside = 16; //按钮右边距距离中心的距离;
    
    //记录目标大小
    CGRect targetShootFrame = CGRectMake(0, 0, maskButtonContainWidth, maskButtonContainHeight);
    CGFloat targetY = mainCenter.y - 42 - targetShootFrame.size.height;
    targetShootFrame.origin = CGPointMake(ScreenWidth / 2 - beside - targetShootFrame.size.width, targetY);
    
    CGRect targetEditFrame = CGRectMake(0, 0, maskButtonContainWidth, maskButtonContainWidth);
    targetEditFrame.origin = CGPointMake(ScreenWidth / 2 + beside, targetY);
    
    //设置初始状态
    self.maskShootView.frame = CGRectMake(0, 0, 1, 1);
    self.maskShootView.center = mainCenter;
    
    self.maskEditView.frame = CGRectMake(0, 0, 1, 1);
    self.maskEditView.center = mainCenter;
    
    [self.maskView addSubview:self.maskShootView];
    [self.maskView addSubview:self.maskEditView];
    self.maskView.alpha = 0;
    
    [UIView animateWithDuration:0.26 animations:^{
        self.maskShootView.frame = targetShootFrame;
        self.maskEditView.frame = targetEditFrame;
        self.maskView.alpha = 1;
    } completion:^(BOOL finished) {
        
        [self.currentPlayContainer.vodPlayer pause];
    }];
    
}

/**
 退出弹层状态，
 */
- (void)quitShootOrEdit{
    
    self.shootButton.selected = NO;
    CGPoint mainCenter = self.shootButton.center;
    CGRect targetFrame = CGRectMake(mainCenter.x, mainCenter.y, 1, 1);
    
    [UIView animateWithDuration:0.26 animations:^{
        self.maskShootView.frame = targetFrame;
        self.maskEditView.frame = targetFrame;
        self.maskView.alpha = 0;
    } completion:^(BOOL finished) {
        if (finished) {
            [self.maskShootView removeFromSuperview];
            [self.maskEditView removeFromSuperview];
            [self.maskView removeFromSuperview];
            if (self.currentPlayContainer.vodPlayer.playerState == AliyunVodPlayerStatePause) {
                [self.currentPlayContainer.vodPlayer resume];
            }else{
                [self.currentPlayContainer.vodPlayer replay];
            }
            
        }
    }];
}

#pragma mark - UI Config When UP Down

/**
 根据vodPlayer找到存放它的对应的容器视图

 @param vodPlayer 播放器实例
 @return 容器视图
 */
- (AlivcPlayContainerView *__nullable)containerViewWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
    //找到对应的conView
    AlivcPlayContainerView *updateConView = nil;
    for(AlivcPlayContainerView *view in self.playContainerList){
        if (view.vodPlayer == vodPlayer) {
            updateConView = view;
            break;
        }
    }
    return updateConView;
}

/**
 返回containerView的下一个视图

 @param containerView 播放内容视图
 @return 播放内容视图的下一个视图
 */
- (AlivcPlayContainerView *__nullable)nextViewToView:(AlivcPlayContainerView *)containerView{
    AlivcPlayContainerView *nextView = nil;
    for(AlivcPlayContainerView *view in self.playContainerList){
        if (view == containerView) {
            NSInteger index = [self.playContainerList indexOfObject:view];
            NSInteger nextIndex = index + 1;
            if (nextIndex < self.playContainerList.count) {
                nextView = self.playContainerList[nextIndex];
            }
            break;
        }
    }
    return nextView;
}

/**
 返回containerView的上一个视图
 
 @param containerView 播放内容视图
 @return 播放内容视图的上一个视图
 */
- (AlivcPlayContainerView *__nullable)previousViewToView:(AlivcPlayContainerView *)containerView{
    AlivcPlayContainerView *previousView = nil;
    for(AlivcPlayContainerView *view in self.playContainerList){
        if (view == containerView) {
            NSInteger index = [self.playContainerList indexOfObject:view];
            NSInteger pIndex = index - 1;
            if (pIndex > -1) {
                previousView = self.playContainerList[pIndex];
            }
            break;
        }
    }
    return previousView;
}

/**
 更新封面图

 @param vodPlayer 对应的播放器实例
 */
- (void)updateCoverImageWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
    AlivcPlayContainerView *updateConView = [self containerViewWithVodPlayer:vodPlayer];
    if (updateConView) {
        updateConView.coverImageView.hidden = NO;
        NSLog(@"封面测试 显示封面:%@",vodPlayer);
        AliyunVodPlayerVideo *info = [vodPlayer getAliyunMediaInfo];
        updateConView.coverImageView.contentMode = UIViewContentModeScaleAspectFit;
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            NSData *data = [NSData dataWithContentsOfURL:[NSURL URLWithString:info.coverUrl]];
            dispatch_async(dispatch_get_main_queue(), ^{
                UIImage *image = [UIImage imageWithData:data];
                [updateConView setCoverImage:image];
                NSLog(@"封面测试 封面下载完成，赋值,此时如果已经隐藏掉了，就算了，因为图片数据的加载是异步的，这时候视频有可能已经开始播放了:%@",vodPlayer);
            });
        });
    }
    
}

/**
 隐藏封面图

 @param vodPlayer 播放器实例
 */
- (void)hideCoverImageWithVodPlayer:(AliyunVodPlayer *)vodPlayer{
    AlivcPlayContainerView *updateConView = [self containerViewWithVodPlayer:vodPlayer];
    if (updateConView) {
        updateConView.coverImageView.hidden = YES;
        NSLog(@"封面测试 隐藏封面:%@",vodPlayer);
    }
}

/**
 取消滑动,各view归位
 */
- (void)cancelPan{
    
    [UIView animateWithDuration:kAnimationTime animations:^{
        self.currentPlayContainer.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
        AlivcPlayContainerView *preView = [self previousViewToView:self.currentPlayContainer];
        AlivcPlayContainerView *nextView = [self nextViewToView:self.currentPlayContainer];
        preView.frame = CGRectMake(0, -1 * ScreenHeight, ScreenWidth, ScreenHeight);
        nextView.frame = CGRectMake(0, ScreenHeight, ScreenWidth, ScreenHeight);
    }];
}


/**
 view向上移动一屏

 @param containerView containerView
 */
- (void)upView:(AlivcPlayContainerView *)containerView{
    CGRect frame = containerView.frame;
    frame.origin.y -= ScreenHeight;
    containerView.frame = frame;
}

/**
 view向下移动一屏
 
 @param containerView containerView
 */
- (void)downView:(AlivcPlayContainerView *)containerView{
    CGRect frame = containerView.frame;
    frame.origin.y += ScreenHeight;
    containerView.frame = frame;
}


/**
  view向上移动一屏

 @param containerView containerView
 @param completion 完成后的动作
 */
- (void)animtaionUpView:(AlivcPlayContainerView *)containerView completion:(void (^)(BOOL finished))completion{
    CGRect frame = containerView.frame;
    frame.origin.y = -1 * ScreenHeight;
    [UIView animateWithDuration:kAnimationTime animations:^{
        containerView.frame = frame;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
    
}

/**
 view在当前的屏幕

 @param containerView containView
 @param completion 完成后的动作
 */
- (void)animtaionCurrentView:(AlivcPlayContainerView *)containerView completion:(void (^)(BOOL finished))completion{
    CGRect frame = containerView.frame;
    frame.origin.y = 0;
    [UIView animateWithDuration:kAnimationTime animations:^{
        containerView.frame = frame;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        
    }];
    
}


/**
  view向下移动一屏

 @param containerView containerView
 @param completion 完成后的动作
 */
- (void)animationDownView:(AlivcPlayContainerView *)containerView completion:(void (^)(BOOL finished))completion{
    CGRect frame = containerView.frame;
    frame.origin.y = ScreenHeight;
    [UIView animateWithDuration:kAnimationTime animations:^{
        containerView.frame = frame;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
    }];
}



#pragma mark - Play Manager

/**
 播放上一个视频
 */
- (void)playPrevious{
    AlivcPlayContainerView *previousView = [self previousViewToView:self.currentPlayContainer];
    if (previousView) {
        [self.currentPlayContainer.vodPlayer stop];
        [self.currentPlayContainer setPreCoverImageWhenStop];
        [self animationDownView:self.currentPlayContainer completion:^(BOOL finished) {
            //
        }];
        
        if (previousView.vodPlayer.playerState == AliyunVodPlayerStatePrepared) {
            [previousView.vodPlayer start];
        }else{
            [self prepareWithPlayer:previousView.vodPlayer model:previousView.videoModel];
        }
        self.currentPlayContainer = previousView;
        [self animtaionCurrentView:self.currentPlayContainer completion:^(BOOL finished) {
            //
        }];
        
        [self managePreloadingSourceWhenPlayPrevious];
    }else{
        NSInteger currentModelIndex = [self.videoList indexOfObject:self.currentPlayContainer.videoModel];
        if (currentModelIndex == 0) {
            [self cancelPan];
            [MBProgressHUD showMessage:@"已经是第一个视频了" inView:self.view];
        }else{
            NSAssert(false, @"往下滑动逻辑处理有漏洞");
        }
        
    }
}

/**
 播放下一个视频
 */
- (void)playNext{
    
    AlivcPlayContainerView *nextPlayerView = [self nextViewToView:self.currentPlayContainer];
    if (nextPlayerView) {
        [self.currentPlayContainer.vodPlayer stop];
        [self.currentPlayContainer setPreCoverImageWhenStop];
        NSLog(@"AlivcShortVideoPlayViewControler:%@调用了stop",self.currentPlayContainer.vodPlayer);
        [self animtaionUpView:self.currentPlayContainer completion:^(BOOL finished) {
            
        }];
        //下一个视频的处理
        if (nextPlayerView.vodPlayer.playerState == AliyunVodPlayerStatePrepared) {
            [nextPlayerView.vodPlayer start];
        }else{
            [self prepareWithPlayer:nextPlayerView.vodPlayer model:nextPlayerView.videoModel];
        }
        self.currentPlayContainer = nextPlayerView;
        NSLog(@"AlivcShortVideoPlayViewControler:%@调用了prepare",self.currentPlayContainer.vodPlayer);
        [self animtaionCurrentView:self.currentPlayContainer completion:^(BOOL finished) {
            //
        }];
        
        [self managePreloadingSourceWhenPlayNext];
        
        //
        [self tryQuerryNewPlayVideo];
        
        
    }else{
        NSInteger modelIndex = [self.videoList indexOfObject:self.currentPlayContainer.videoModel];
        if (modelIndex == self.videoList.count - 1) {
            [self cancelPan];
            [MBProgressHUD showMessage:@"已经是最后一个视频了" inView:self.view];
        }else{
            NSAssert(false, @"往上滑动逻辑处理有漏洞");
        }
       
    }
}


- (void)prepareWithPlayer:(AliyunVodPlayer *)player model:(AlivcVideoPlayListModel *)model{
    [player prepareWithVid:model.videoId accessKeyId:model.stsAccessKeyId accessKeySecret:model.stsAccessSecret securityToken:model.stsSecurityToken];
}

/**
 根据情况判断是否要去请求新的资源
 */
- (void)tryQuerryNewPlayVideo{
    
    NSInteger currentIndexInSouce = [self.videoList indexOfObject:self.currentPlayContainer.videoModel];
    NSInteger lessCount = self.videoList.count - currentIndexInSouce - 1; //剩余个数
    if (lessCount < kCountLess_mustQurryMoreData) {
        NSInteger currentPageNo = self.videoList.count / kPageCount;
//        NSInteger yushu = self.videoList.count % kPageCount; //理论上不可能产生余数
        NSInteger newPageNo = currentPageNo + 1;
        [self querryVideoDataWithStartIndex:newPageNo count:kPageCount];

    }
    
}

/**
 向上滑动的时候管理预加载资源
 */
- (void)managePreloadingSourceWhenPlayNext{
    //1.出现上划的情况
    //实际的在当前播放视图上面的资源数
    NSInteger upCount = 100000;
    
    //当前播放视图在预加载资源列表中的位置
    NSInteger currentIndex = [self.playContainerList indexOfObject:self.currentPlayContainer];
    
    upCount = currentIndex;
    
    if (upCount > kPreviousCount) {
        NSInteger count = upCount - kPreviousCount;
        if (count == 1) {
            
            //如果kNextCount为1，则lastView为currentPlayContainer，理解不了也没事
            AlivcPlayContainerView *lastView = self.playContainerList.lastObject;
            
            NSInteger lastModelIndex =  [self.videoList indexOfObject:lastView.videoModel];
            NSInteger targetModelIndex = lastModelIndex + 1;
            if (targetModelIndex < self.videoList.count) {
                AlivcPlayContainerView *firstView = self.playContainerList.firstObject;
                
                //设置播放资源
                [firstView clearData];
                AlivcVideoPlayListModel *model = self.videoList[targetModelIndex];
                [firstView setVideoModel:model];
                [self prepareWithPlayer:firstView.vodPlayer model:model];//预加载图片
                
                //调整在列表中位置
                NSMutableArray *temp = [NSMutableArray arrayWithArray:self.playContainerList];
                [temp removeObject:firstView];
                [temp addObject:firstView];
                self.playContainerList = (NSArray *)temp;
                
                //调整在视图中的位置
                CGRect frame = firstView.frame;
                frame.origin.y = ScreenHeight;
                firstView.frame = frame;
            }else{
                NSLog(@"无更多的资源可供播放，放弃预加载资源的调整");
            }
          
        }else{
            NSAssert(false, @"不会出现这种情况，如果有，可能是滑动太快了");
        }
    }else{
        NSLog(@"没有超出，一般在刚开始滑动的时候出现");
    }
    
}

/**
 向下滑动的时候管理预加载资源
 */
- (void)managePreloadingSourceWhenPlayPrevious{
    //实际的在当前播放视图下面的资源数
    NSInteger downCount = 100000;
    
    //当前播放视图在预加载资源列表中的位置
    NSInteger currentIndex = [self.playContainerList indexOfObject:self.currentPlayContainer];
    
    downCount = self.playContainerList.count - 1 - currentIndex;
    
    if (downCount > kNextCount) {
        NSInteger count = downCount - kNextCount;
        if (count == 1) {
            //如果kPreviousCount为1，则firtView为currentPlayContainer
            AlivcPlayContainerView *firtView = self.playContainerList.firstObject;
            NSInteger firstModelIndex = [self.videoList indexOfObject:firtView.videoModel];
            NSInteger targetModelIndex = firstModelIndex - 1;
            if (targetModelIndex > 0 || targetModelIndex == 0) {
                AlivcVideoPlayListModel *targetModel = self.videoList[targetModelIndex];
                
                //设置播放资源，预加载图片
                AlivcPlayContainerView *lastView = self.playContainerList.lastObject;
                [lastView clearData];
                [lastView setVideoModel:targetModel];
                [self prepareWithPlayer:lastView.vodPlayer model:targetModel];
                NSLog(@"资源调整前的位置\n");
                [self testPrintLocation];
                //调整在列表中的位置
                NSMutableArray *temp = [[NSMutableArray alloc]initWithArray:self.playContainerList];
                [temp removeObject:lastView];
                [temp insertObject:lastView atIndex:0];
                self.playContainerList = (NSArray *)temp;
                NSLog(@"资源调整后的位置\n");
                [self testPrintLocation];
                //调整在视图中的位置
                CGRect frame = lastView.frame;
                frame.origin.y = -1 * ScreenHeight;
                lastView.frame = frame;
            }else{
                NSLog(@"无更多的资源可供播放，放弃预加载资源的调整");
            }
         
        }else{
            NSAssert(false, @"不可能出现这种情况，如果有，查看是否异步的操作等导致预加载资源异常");
        }
    }else{
        NSLog(@"从最底部往上滑的时候会出现当前情况");
    }
}

- (void)testPrintLocation{
    for (int i = 0; i < self.playContainerList.count; i++) {
        NSLog(@"位置:%d 指针:%@",i,self.playContainerList[i]);
    }
}


#pragma mark - ButtonAction

- (void)backButtonTouched{
    [self.navigationController popViewControllerAnimated:YES];
}

/**
 视频按钮点击
 */
- (void)videoButtonTouched:(UIButton *)button{
    [UIView animateWithDuration:0.2 animations:^{
        self.lineView.center = CGPointMake(button.center.x, CGRectGetMaxY(button.frame) + 3);
    }];
}

/**
 拍摄按钮点击
 */
- (void)shootButtonTouched:(UIButton *)button{
    if (button.selected) {
        [self quitShootOrEdit];
        
    }else{
        [self enterShootOrEdit];
        
    }
    
}

/**
 我按钮点击
 */
- (void)meButtonTouched:(UIButton *)button{
    [UIView animateWithDuration:0.2 animations:^{
        self.lineView.center = CGPointMake(button.center.x, CGRectGetMaxY(button.frame) + 3);
    }];
    AlivcUserInfoViewController *targetVC = [[AlivcUserInfoViewController alloc]init];
    [self.navigationController pushViewController:targetVC animated:YES];
    
}

/**
 更多按钮点击
 */
- (void)moreButtonToued{
    
}

/**
 用户头像点击
 */
- (void)userButtonTouched{
    
}


/**
 拍摄视频
 */
- (void)maskShoot{
    AliyunMediaConfig *defauleMedia = [AliyunMediaConfig defaultConfig];
    defauleMedia.minDuration = 2;
    defauleMedia.maxDuration = 15;
    AliyunMagicCameraViewController *record = [[AliyunMagicCameraViewController alloc] init];
    record.quVideo = defauleMedia;
    [self.navigationController pushViewController:record animated:YES];
}


/**
 编辑视频
 */
- (void)maskEdit{
    AliyunMediaConfig *defauleMedia = [AliyunMediaConfig defaultConfig];
    UIViewController *vc = [[AliyunMediator shared] editModule];
    [vc setValue:defauleMedia forKey:@"compositionConfig"];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - Gesture

/**
 添加手势
 */
- (void)addGesture{
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]init];
    tapGesture.numberOfTapsRequired = 1;
    [tapGesture addTarget:self action:@selector(tap)];
    [self.gestureView addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc]init];
    [panGesture addTarget:self action:@selector(handlePanGesture:)];
    [self.gestureView addGestureRecognizer:panGesture];
    
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture{
    
    UIView *touchView = panGesture.view;
    if (touchView == self.view) {
        NSLog(@"手势测试:view");
    }
    if (touchView == self.maskView) {
        NSLog(@"手势测试:maskView");
    }
    if (touchView == self.gestureView) {
        NSLog(@"手势测试:gestureView");
    }
    
    CGPoint panSpeed = [panGesture velocityInView:self.view];//拖动速度
    CGPoint translationPoint = [panGesture translationInView:self.view]; //相对偏移量
    switch (panGesture.state) {
        case UIGestureRecognizerStatePossible:
            NSLog(@"panGestureStatus:UIGestureRecognizerStatePossible");
            
            break;
        case UIGestureRecognizerStateBegan:
            NSLog(@"panGestureStatus:UIGestureRecognizerStateBegan 速度%f",panSpeed.y);
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"panGestureStatus:UIGestureRecognizerStateChanged 速度%f",panSpeed.y);
            [self changedToCommitTranslation:translationPoint];
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"panGestureStatus:UIGestureRecognizerStateEnded 速度%f",panSpeed.y);
            if (fabs(panSpeed.y) < kMinPanSpeed) {
                [self cancelPan];
            }else{
                [self endToCommitTranslation:translationPoint];
            }
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"panGestureStatus:UIGestureRecognizerStateCancelled 位置%f",panSpeed.y);
            [self cancelPan];
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"panGestureStatus:UIGestureRecognizerStateFailed 位置%f",panSpeed.y);
            break;

            
        default:
            break;
    }
    
}

/**
 手势改变中的处理，主要是view的位置变化
 当前播放的视图变化
 @param translation 相对位移
 */
- (void)changedToCommitTranslation:(CGPoint )translation{
    CGRect currentFrame = self.currentPlayContainer.frame;
    currentFrame.origin.y = 0 + translation.y;
    
    AlivcPlayContainerView *previousView = [self previousViewToView:self.currentPlayContainer];
    CGRect previousFrame = previousView.frame;
    previousFrame.origin.y = ScreenHeight * -1 + translation.y;
    
    AlivcPlayContainerView *nextView = [self nextViewToView:self.currentPlayContainer];
    CGRect nextFrame = nextView.frame;
    nextFrame.origin.y = ScreenHeight + translation.y;
    
    //边界值处理
    self.currentPlayContainer.frame = [self newFrameWithHandleFrame:currentFrame];
    previousView.frame = [self newFrameWithHandleFrame:previousFrame];
    nextView.frame = [self newFrameWithHandleFrame:nextFrame];
}

/**
 边界值处理，上+ 中 + 下，最多在这3个屏幕之中，保证view不会超出此范围

 @param frame 被处理的frame
 */
- (CGRect )newFrameWithHandleFrame:(CGRect )frame{
    if(frame.origin.y < ScreenHeight * -1){
        frame.origin.y = ScreenHeight * -1;
    }
    
    if (frame.origin.y > ScreenHeight) {
        frame.origin.y = ScreenHeight;
    }
    return frame;
}

/**
 *   手势结束的时候处理,判断滑动方向，播放上一个视频或者下一个视频
 *
 *  @param translation translation description
 */
- (void)endToCommitTranslation:(CGPoint )translation
{
    
    CGFloat absX = fabs(translation.x);
    CGFloat absY = fabs(translation.y);
    
    // 设置滑动有效距离
    if (MAX(absX, absY) < 10)
        return;
    
    
    if (absX > absY ) {
        
        if (translation.x<0) {
            
            //向左滑动
            NSLog(@"pan向左滑动");
        }else{
            
            //向右滑动
            NSLog(@"pan向右滑动");
        }
        
    } else if (absY > absX) {
        if (translation.y<0) {
            //向上滑动
            NSLog(@"pan向上滑动");
            [self panUp];
        }else{
            //向下滑动
            NSLog(@"pan向下滑动");
            [self panDown];
        }
    }
    
    
}

- (void)tap{
//    switch (self.aliPlayer.playerState) {
//        case AliyunVodPlayerStatePlay:
//            [self.aliPlayer pause];
//            break;
//        case AliyunVodPlayerStateStop:
//            [self.aliPlayer start];
//            break;
//        case AliyunVodPlayerStatePause:
//            [self.aliPlayer resume];
//            break;
//        default:
//            break;
//    }
}

- (void)panUp{
    [self playNext];
}

- (void)panDown{
    [self playPrevious];
}


#pragma mark - Translation Manager


#pragma mark - Delegate


#pragma mark - AliyunVodPlayerDelegate

/**
 * 功能：播放事件协议方法,主要内容 AliyunVodPlayerEventPrepareDone状态下，此时获取到播放视频数据（时长、当前播放数据、视频宽高等）
 * 参数：event 视频事件
 */
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer onEventCallback:(AliyunVodPlayerEvent)event{
    NSLog(@"AlivcShortVideoPlayViewControler EventCallBack:vodPlayer:%@ event:%lu",vodPlayer,(unsigned long)event);
    switch (event) {
        case AliyunVodPlayerEventPrepareDone:{
            [self updateCoverImageWithVodPlayer:vodPlayer];
            if (self.currentPlayContainer) {
                AlivcPlayContainerView *thisView = [self containerViewWithVodPlayer:vodPlayer];
                if (thisView == self.currentPlayContainer) {
                    [self.currentPlayContainer.vodPlayer start];
                }
                //如果是第一个视频，尝试加载预加载资源的图片
                NSInteger index = [self.playContainerList indexOfObject:self.currentPlayContainer];
                if (index == 0) {
                    [self doQuerryImageWhenFirstEnter];
                }
            }
            
        }
            
            
            break;
        case AliyunVodPlayerEventFirstFrame:
            [self hideCoverImageWithVodPlayer:vodPlayer];
            break;
        default:
            break;
    }
}

/**
 * 功能：播放器播放时发生错误时，回调信息
 * 参数：errorModel 播放器报错时提供的错误信息对象
 */
- (void)vodPlayer:(AliyunVodPlayer *)vodPlayer playBackErrorModel:(AliyunPlayerVideoErrorModel *)errorModel{
    NSLog(@"error:%@",errorModel.errorMsg);
}







#pragma mark - ViewDelegate



@end

NS_ASSUME_NONNULL_END
