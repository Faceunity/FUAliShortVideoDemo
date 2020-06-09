//
//  QUEditViewController.m
//  AliyunVideo
//
//  Created by Vienta on 2017/3/6.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//
#import <AssetsLibrary/AssetsLibrary.h>
#include <OpenGLES/ES3/gl.h>
#include <OpenGLES/ES3/glext.h>
#import <sys/utsname.h>

#import "AlivcDefine.h"
#import "AliyunEditViewController.h"
#import <AliyunVideoSDKPro/AVAsset+AliyunSDKInfo.h>
#import <AliyunVideoSDKPro/AliyunAlphaAction.h>
#import <AliyunVideoSDKPro/AliyunAudioRecorder.h>
#import <AliyunVideoSDKPro/AliyunCustomAction.h>
#import <AliyunVideoSDKPro/AliyunEditor.h>
#import <AliyunVideoSDKPro/AliyunEffectMusic.h>
#import <AliyunVideoSDKPro/AliyunErrorCode.h>
#import <AliyunVideoSDKPro/AliyunIPasterRender.h>
#import <AliyunVideoSDKPro/AliyunImporter.h>
#import <AliyunVideoSDKPro/AliyunNativeParser.h>
#import <AliyunVideoSDKPro/AliyunPasterManager.h>
#import <AliyunVideoSDKPro/AliyunRotateRepeatAction.h>
#import <AliyunVideoSDKPro/AliyunClip.h>
#import <AliyunVideoSDKPro/AliyunPasterBaseView.h>

//工具类相关
#import "AVC_ShortVideo_Config.h"
#import "MBProgressHUD+AlivcHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "NSString+AlivcHelper.h"
#import "UIView+AlivcHelper.h"

//公用类相关
#import "AliyunDBHelper.h"
#import "AliyunEffectMoreViewController.h"
#import "AliyunPathManager.h"
#import "AliyunResourceFontDownload.h"
#import "AliyunTimelineItem.h"
#import "AliyunTimelineMediaInfo.h"
#import "AliyunTimelineView.h"

//涂鸦相关
#import "AliyunPaintingEditView.h"
#import <AliyunVideoSDKPro/AliyunICanvasView.h>

//转场相关
#import "AliyunEffectTransitionView.h"
#import "AliyunTransitionCover.h"
#import "AliyunTransitonStatusRetention.h"
#import <AliyunVideoSDKPro/AliyunTransitionEffectCircle.h>
#import <AliyunVideoSDKPro/AliyunTransitionEffectFade.h>
#import <AliyunVideoSDKPro/AliyunTransitionEffectPolygon.h>
#import <AliyunVideoSDKPro/AliyunTransitionEffectShuffer.h>
#import <AliyunVideoSDKPro/AliyunTransitionEffectTranslate.h>

//动图相关
#import "AlivcPasterManager.h"
#import "AliyunEditButtonsView.h"
#import "AliyunEditZoneView.h"
#import "AliyunEffectCaptionShowView.h"
#import "AliyunEffectFontInfo.h"
#import "AliyunPasterControllerCopy.h"
#import "AliyunPasterShowView.h"
#import "AliyunPasterTextInputView.h"
#import "AliyunPasterView.h"
#import "AliyunTabController.h"

//音效相关
#import "AlivcAudioEffectView.h"

//其它
#import "AVAsset+VideoInfo.h"
#import "AliAssetImageGenerator.h"
#import "AlivcCoverImageSelectedView.h"
#import "AlivcSpecialEffectView.h"
#import "AliyunCompressManager.h"
#import "AliyunCustomFilter.h"
#import "AliyunEffectFilterView.h"
#import "AliyunEffectMVView.h"
#import "AliyunEffectTimeFilterView.h"
#import "AliyunMusicPickViewController.h"

//#import "AliyunPublishViewController.h"
//#import "AlivcExportViewController.h"

//底部UI适配
#import "AlivcEditItemManager.h"
#import "AlivcEditItemModel.h"
#import "AliyunSubtitleActionItem.h"
#import "AliyunPasterController+ActionType.h"
#import "AlivcRegulatorView.h"

@class AliyunPasterBottomBaseView;

//用户操作事件，目前特效里长按特效和缩略图滑动互斥，长按特效优先
typedef NS_ENUM(NSInteger, AliyunEditUserEvent) {
    AliyunEditUserEvent_None,             //当前用户无操作
    AliyunEditUserEvent_Effect_LongPress, //特效长按
    AliyunEditUserEvent_Effect_Slider,    //特效缩略图滑动
};

typedef enum : NSUInteger {
    AlivcEditVCStatus_Normal = 0, //播放或者暂停状态 - 非编辑状态
    AlivcEditVCStatus_Edit,       //编辑状态
    
} AlivcEditVCStatus;

typedef struct _AliyunPasterRange {
    CGFloat startTime;
    CGFloat duration;
} AliyunPasterRange;

typedef enum : NSUInteger {
    AliyunEditSubtitleTypeSubtitle = 0,
    AliyunEditSubtitleTypeCaption
} AliyunEditSubtitleType;

const CGFloat PASTER_MIN_DURANTION = 0.1; //动图最小持续时长

// TODO:此类需再抽一层,否则会太庞大
@interface AliyunEditViewController () <
AliyunIExporterCallback, AliyunIPlayerCallback, AliyunICanvasViewDelegate,
AliyunPaintingEditViewDelegate, AliyunMusicPickViewControllerDelegate,
AliyunPasterBottomBaseViewDelegate, AliyunEffectCaptionShowViewDelegate,
AliyunEffectTransitionViewDelegate, AlivcSpecialEffectViewDelegate ,AlivcAudioEffectViewDelegate,AlivcCoverImageSelectedViewDelegate,AliyunEffectTimeFilterDelegate>

@property(nonatomic, strong) UIView *movieView;
@property(nonatomic, strong) AliyunTimelineView *currentTimelineView;
@property(nonatomic, strong) AliyunEditButtonsView *editButtonsView;
@property(nonatomic, strong) AliyunTabController *tabController;
@property(nonatomic, strong) UIButton *backgroundTouchButton;
@property(nonatomic, strong) UILabel *currentTimeLabel;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UIView *playButtonConView;

@property(nonatomic, strong) AliyunPasterManager *pasterManager;
//动图编辑的空间 响应用户对动图的操作的事件
@property(nonatomic, strong) AliyunEditZoneView *editZoneView;
@property(nonatomic, strong) AliyunEditor *editor;
@property(nonatomic, strong) id<AliyunIPlayer> player;
@property(nonatomic, strong) id<AliyunIExporter> exporter;
@property(nonatomic, strong) id<AliyunIClipConstructor> clipConstructor;
//涂鸦用户画的图片
@property(nonatomic, strong) AliyunEffectImage *paintImage;
@property (nonatomic, assign) BOOL hasUesedintelligentFilter;

@property (nonatomic, strong) AliyunEffectFilterInfo *intelligentFilter;
//MV弹出的菜单
@property(nonatomic, strong) AliyunEffectMVView *mvView;
//滤镜弹出的菜单
@property(nonatomic, strong) AliyunEffectFilterView *filterView;
//特效滤镜弹出的菜单
@property(nonatomic, strong) AlivcSpecialEffectView *specialFilterView;
//时间特效弹出的菜单
@property(nonatomic, strong) AliyunEffectTimeFilterView *timeFilterView;
//动图弹出的菜单
@property(nonatomic, strong) AliyunPasterShowView *pasterShowView;
//字幕弹出的菜单
@property(nonatomic, strong) AliyunEffectCaptionShowView *captionShowView;
//转场弹出的菜单
@property(nonatomic, strong) AliyunEffectTransitionView *transitionView;
//音效弹出的菜单
@property(nonatomic, strong) AlivcAudioEffectView *effectSoundsView;
//fe
@property(nonatomic, strong) AlivcCoverImageSelectedView *coverSelectedView;


/**
 退后台前是否正在播放
 */
@property (nonatomic, assign) BOOL isPlaying;

/**
 用户操作的记录
 */
@property(nonatomic, assign) AliyunEditUserEvent userAction;

///**
// MV更多界面的控制器
// */
//@property(nonatomic, strong) UINavigationController *mvMoreVC;
///**
// 动图更多界面的控制器
// */
//@property(nonatomic, strong) UINavigationController *pasterMoreVC;
///**
// 字幕更多界面的控制器
// */
//@property(nonatomic, strong) UINavigationController *captionMoreVC;

/**
 当前编辑中的动图类型
 */
@property(nonatomic, assign) AliyunPasterEffectType currentEditPasterType;

/**
 保存的时间特效
 */
@property(nonatomic, strong) AliyunEffectTimeFilter *storeTimeFilter;

/**
 当前的时间特效
 */
@property(nonatomic, strong) AliyunEffectTimeFilter *currentTimeFilter;
//涂鸦画板
@property(nonatomic, strong) AliyunICanvasView *paintView;

/**
 涂鸦view
 */
@property(nonatomic, strong) AliyunPaintingEditView *paintShowView;

//动图相关
/**
 记录编辑状态下，上个添加的动图
 
 */
@property(nonatomic, strong) AliyunPasterController *lastPasterController;

/**
 记录上次编辑状态添加的所有动图集合
 
 */
@property(nonatomic, strong) NSMutableArray *pasterInfoCopyArr;

/**
 记录本次进入编辑状态添加的所有动图集合
 
 */
@property(nonatomic, strong)NSMutableArray<AliyunPasterController *> *currentPasterControllers;

/**
 动图特殊处理管理器
 */
@property(nonatomic, strong) AlivcPasterManager *alivcPasterManager;

/**
 封面图
 */
@property(nonatomic, strong, nullable) UIImage *coverImage;

@property(nonatomic, strong) AliyunDBHelper *dbHelper;

@property(nonatomic, assign) BOOL isExporting;
@property(nonatomic, assign) BOOL isPublish;
@property(nonatomic, assign) BOOL isAddMV;
@property(nonatomic, assign) BOOL isBackground;

/**
 是否是编辑时间的拖动动作
 */
@property(nonatomic, assign) BOOL isEidtTuchAction;

@property(nonatomic, assign) CGSize outputSize;
@property(nonatomic, strong) AliyunCustomFilter *filter;
@property(nonatomic, strong) UIButton *staticImageButton;
// 倒播相关
@property(nonatomic, strong) AliyunNativeParser *parser;
@property(nonatomic, assign) BOOL invertAvailable; // 视频是否满足倒播条件
@property(nonatomic, strong) AliyunCompressManager *compressManager;
//动效滤镜
@property(nonatomic, strong) NSMutableArray *animationFilters;

/**
 保存的动态特效
 */
@property(nonatomic, strong) NSMutableArray *storeAnimationFilters;
@property(nonatomic, strong) UIButton *saveButton; //保存

@property(nonatomic, strong) UIButton *cancelButton; //取消

@property(nonatomic, strong) UIButton *backButton; //返回按钮

@property(nonatomic, strong) UIButton *publishButton; //发布按钮

@property(nonatomic, assign) AlivcEditVCStatus vcStatus;  //界面状态
@property(nonatomic, strong) AliyunMusicPickModel *music; //之前应用的音乐
@property(nonatomic, assign) NSInteger tab; //之前应用的音乐的所属
@property(nonatomic, strong) AliyunEffectMvGroup *mvGroup; //之前应用的mv

/**
 当前控制器是否可见
 */
@property(nonatomic, assign) BOOL isAppear;

/**
 保存转场状态
 */
@property(nonatomic, strong) AliyunTransitonStatusRetention *transitionRetention;


/**
 需要移除的动图集合
 主要解决这样场景下的一个BUG：跳转到资源管理界面，editor被stopEditor，然后字幕资源被删除，已经添加了这个字幕资源的字幕气泡或者动图要删除掉，但是editor已经被stopEditor就会导致crash，所以先声明一个数组保存需要删除的动图资源，回到编辑界面重新开始stratEditor后把这些需要删除的动图字幕给删除掉
 */
@property(nonatomic, strong) NSMutableArray<AliyunPasterController *> *willRemovePasters;



/**
 记录纯字幕特效状态，用来提示倒播不支持字幕特效，SDK修复倒播不兼容字幕特效的BUG后
 删除此值及提示逻辑
 */
@property(nonatomic, assign) TextActionType textActionType;

@property(nonatomic, assign) CGSize inputOutputSize;

@property(nonatomic,assign) CGFloat currentPlaytime;

@property(nonatomic,strong) AliyunEffectFilter *curEffect;

@end

@implementation AliyunEditViewController {
    AliyunPasterTextInputView *_currentTextInputView; //当前字幕输入框
    AliyunEditSouceClickType _editSouceClickType;     //当前的编辑类型
    BOOL _prePlaying; //是：播放中，否：不在播放中
    BOOL _tryResumeWhenBack; //本界面的基础上跳转其他界面，回来的时候，尝试继续播放
    BOOL _haveStaticImage;
    AliyunEffectStaticImage *_staticImage;
    AliyunEffectFilter *_processAnimationFilter;
    AliyunTimelineFilterItem *_processAnimationFilterItem;
    
    //    TextActionType _tmpActionType; //选择的字幕特效
    
    
    AliyunAudioEffectType lastAudioEffectType;//上次设置的音效
}

#pragma mark - System
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBaseData];
    [self addSubviews];
    [self addNotificationBeforeSdk];
    [self initSDKAbout];
    [self addNotifications];
    [self addWatermarkAndEnd];
}

- (void)dealloc {
    [_editor stopEdit];
    //    [self removeNotifications];
    //    _mvMoreVC = nil;
    //    _pasterMoreVC = nil;
    //    _captionMoreVC = nil;
    NSLog(@"~~~~~~%s delloc", __PRETTY_FUNCTION__);
}

/**
 设置初始值
 */
- (void)initBaseData {
    Class c = NSClassFromString(@"AliyunEffectPrestoreManager");
    NSObject *prestore = (NSObject *)[[c alloc] init];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    [prestore performSelector:@selector(insertInitialData)];
#pragma clang diagnostic pop
    
    // 校验视频分辨率，如果首段视频是横屏录制，则outputSize的width和height互换
    _inputOutputSize = _config.outputSize;
    _outputSize = [_config fixedSize];
    _config.outputSize = _outputSize;
    //    if(kAlivcProductType == AlivcOutputProductTypeSmartVideo) {
    //        if ([_config mediaRatio] == AliyunMediaRatio9To16) {
    //            _config.cutMode = AliyunMediaCutModeScaleAspectCut;
    //        }else{
    //            _config.cutMode = AliyunMediaCutModeScaleAspectFill;
    //        }
    //    }
    // 单视频接入编辑页面，生成一个新的taskPath
    if (!_taskPath) {
        _taskPath = [[AliyunPathManager compositionRootDir] stringByAppendingPathComponent:[AliyunPathManager randomString]];
        AliyunImporter *importer =[[AliyunImporter alloc] initWithPath:_taskPath outputSize:_outputSize];
        AliyunVideoParam *param = [[AliyunVideoParam alloc] init];
        param.fps = _config.fps;
        param.gop = _config.gop;
        param.videoQuality = (AliyunVideoQuality)_config.videoQuality;
        if (_config.cutMode == AliyunMediaCutModeScaleAspectCut) {
            param.scaleMode = AliyunScaleModeFit;
        } else {
            param.scaleMode = AliyunScaleModeFill;
        }
        // 编码模式
        if (_config.encodeMode ==  AliyunEncodeModeHardH264) {
            param.codecType = AliyunVideoCodecHardware;
        }else if(_config.encodeMode == AliyunEncodeModeSoftFFmpeg) {
            param.codecType = AliyunVideoCodecFFmpeg;
        }
        
        [importer setVideoParam:param];
        AliyunClip *clip = [[AliyunClip alloc] initWithVideoPath:_videoPath animDuration:0];
        [importer addMediaClip:clip];
        [importer generateProjectConfigure];
        NSLog(@"---------->clip.duration:%f",clip.duration);
        _config.outputPath = [[_taskPath stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
    }
    _tryResumeWhenBack = NO;
    
    //防size异常奔溃处理
    if (_outputSize.height == 0 || _outputSize.width == 0) {
        _outputSize.width = 720;
        _outputSize.height = 1280;
        NSAssert(false, @"调试的时候崩溃,_outputSize分辨率异常处理");
    }
    //默认的ui配置
    if (!_uiConfig) {
        _uiConfig = [[AlivcEditUIConfig alloc] init];
    }
}

/**
 添加各种视图
 */
- (void)addSubviews {
    self.view.backgroundColor = [UIColor blackColor];
    //播放视图
    CGFloat factor = _outputSize.height / _outputSize.width;
    
    self.movieView = [[UIView alloc]initWithFrame:CGRectMake(0, 44 + ScreenWidth / 8 + SafeTop, ScreenWidth, ScreenWidth * factor)];
    
    [self p_setMovieViewFrameToPlayStatus];
    self.movieView.backgroundColor =
    [[UIColor brownColor] colorWithAlphaComponent:.3];
    [self.view addSubview:self.movieView];
    
    //返回按钮
    CGFloat y = SafeTop;
    if (IS_IPHONEX) {
        y = SafeTop;
    }
    [self.view addSubview:self.backButton];
    
    self.backButton.frame = CGRectMake(10, y, 44, 27);
    
    //发布按钮
    [self.view addSubview:self.publishButton];
    
    self.publishButton.frame  =  CGRectMake(ScreenWidth - 58 -10, y, 58, 27);
    
    self.currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake((ScreenWidth-60)/2, IS_IPHONEX?(SafeTop-9):1, 60, 12)];
    self.currentTimeLabel.backgroundColor = [UIColor colorWithWhite:0 alpha:0.35];
    self.currentTimeLabel.layer.cornerRadius = 4;
    self.currentTimeLabel.layer.masksToBounds = YES;
    self.currentTimeLabel.textColor = [UIColor whiteColor];
    self.currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    self.currentTimeLabel.font = [UIFont systemFontOfSize:11];
    //    self.currentTimeLabel.center = CGPointMake(ScreenWidth / 2,self.currentTimelineView.frame.origin.y + CGRectGetHeight(self.currentTimelineView.bounds) + 6);
    [self.view addSubview:self.currentTimeLabel];
    
    NSArray *editModels = [AlivcEditItemManager defaultModelsWithUIConfig:_uiConfig];
    self.editButtonsView = [[AliyunEditButtonsView alloc] initWithModels:editModels];
    self.editButtonsView.frame =
    CGRectMake(0, ScreenHeight - 70 - SafeBottom, ScreenWidth, 70);
    [self.view addSubview:self.editButtonsView];
    self.editButtonsView.delegate = (id)self;
    [self.view addSubview:self.playButton];
}

/**
 初始化sdk相关
 */
- (void)initSDKAbout {
    // editor
    self.editor = [[AliyunEditor alloc] initWithPath:_taskPath
                                             preview:self.movieView];
    self.editor.delegate = (id)self;
    // player
    self.player = [self.editor getPlayer];
    // exporter
    self.exporter = [self.editor getExporter];
    // constructor
    self.clipConstructor = [self.editor getClipConstructor];
    
    // setup pasterEditZoneView
    self.editZoneView =
    [[AliyunEditZoneView alloc] initWithFrame:self.movieView.bounds];
    self.editZoneView.delegate = (id)self;
    [self.movieView addSubview:self.editZoneView];
    
    // setup pasterManager
    self.pasterManager = [self.editor getPasterManager];
    self.pasterManager.displaySize = self.editZoneView.bounds.size;
    self.pasterManager.outputSize = _outputSize;
    self.pasterManager.previewRenderSize = [self.editor getPreviewRenderSize];
    self.pasterManager.delegate = (id)self;
    //    [self.editor startEdit];
    //    [self play];
}

/**
 添加水印和片尾
 */
- (void)addWatermarkAndEnd {
    AlivcOutputProductType productType = kAlivcProductType;
    if (productType != AlivcOutputProductTypeSmartVideo) {
        NSString *watermarkPath = [AlivcImage pathOfImageName:@"watermark"];
        
        AliyunEffectImage *watermark =
        [[AliyunEffectImage alloc] initWithFile:watermarkPath];
        CGFloat x = 8;
        CGFloat y = 8;
        if ([_config mediaRatio] == AliyunMediaRatio9To16) {
            x = 8;
            y = CGRectGetMaxY(self.backButton.frame) + 8;
        }
        CGFloat outsizex = x / ScreenWidth * _outputSize.width;
        CGFloat outsizey = y / ScreenHeight * _outputSize.height;
        watermark.frame = CGRectMake(outsizex, outsizey, 42, 30);
        [self.editor setWaterMark:watermark];
         
        
    }
    
    if (_config.hasEnd && productType != AlivcOutputProductTypeSmartVideo) {
        NSString *watermarkPath = [[NSBundle mainBundle] pathForResource:@"tail" ofType:@"png"];
        AliyunEffectImage *tailWatermark = [[AliyunEffectImage alloc] initWithFile:watermarkPath];
        tailWatermark.frame = CGRectMake(_outputSize.width / 2 - 84 / 2,
                                         _outputSize.height / 2 - 60 / 2, 84, 60);
        tailWatermark.endTime = 2;
        [self.editor setTailWaterMark:tailWatermark];
    }
}

/**
 初始化一个timeLineView
 
 @return timeLineView
 */
- (AliyunTimelineView *)getOneTimeLineView {
    NSArray *clips = [self.clipConstructor mediaClips];
    NSMutableArray *mediaInfos = [[NSMutableArray alloc] init];
    for (int idx = 0; idx < [clips count]; idx++) {
        AliyunClip *clip = clips[idx];
        AliyunTimelineMediaInfo *mediaInfo = [[AliyunTimelineMediaInfo alloc] init];
        mediaInfo.mediaType = (AliyunTimelineMediaInfoType)clip.mediaType;
        mediaInfo.path = clip.src;
        mediaInfo.duration = clip.duration;
        mediaInfo.startTime = clip.startTime;
        [mediaInfos addObject:mediaInfo];
    }
    //缩略图
    AliyunTimelineView *timeLineView = [[AliyunTimelineView alloc]
                                        initWithFrame:CGRectMake(0, 0, ScreenWidth, 32)];
    timeLineView.backgroundColor = [UIColor whiteColor];
    timeLineView.delegate = (id)self;
    [timeLineView setMediaClips:mediaInfos segment:8.0 photosPersegent:8];
    timeLineView.actualDuration = [self.player getStreamDuration];
    return timeLineView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.isAppear = YES;
    [[UIApplication sharedApplication]setStatusBarHidden:YES];
    //为了让导航条播放时长匹配，必须在这里设置时长
    self.currentTimelineView.actualDuration = [self.player getStreamDuration];
    if (_tryResumeWhenBack) {
        if (!_prePlaying) {
            [self resume];
        }
    }
    //从发布合成界面返回重新开始编辑并播放
    [self.editor startEdit];
    [self play];
    [self resourceDeleteAction];
    //如果是合拍 则播放原音
    if (self.isMixedVideo) {
        [self.editor setAudioMixWeight:0];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.isAppear = NO;
    [self pause];
    _tryResumeWhenBack = YES;
    self.filter = nil;
    if ([self.navigationController
         respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    };
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    //停止编辑
    [self.editor stopEdit];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (BOOL)shouldAutorotate {
    return NO;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}


- (void)didReceiveMemoryWarning {
    NSLog(@"mem warning");
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - Getter
- (UIButton *)playButton {
    if (!_playButton) {
        CGFloat height = 32;
        CGFloat width = 120;
        _playButton =[[UIButton alloc] initWithFrame:CGRectMake(0, 0, width, height)];
        [_playButton setImage:_uiConfig.pauseImage forState:UIControlStateNormal];
        [_playButton setImage:_uiConfig.playImage forState:UIControlStateSelected];
        [_playButton setAdjustsImageWhenHighlighted:NO];
        [_playButton addTarget:self
                        action:@selector(playControlClick:)
              forControlEvents:UIControlEventTouchUpInside];
        [_playButton setTitle:NSLocalizedString(@"暂停播放", nil)  forState:UIControlStateNormal];
        [_playButton setTitle:NSLocalizedString(@"播放全片", nil) forState:UIControlStateSelected];
        [_playButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [_playButton setBackgroundColor:[UIColor colorWithRed:0
                                                        green:0
                                                         blue:0
                                                        alpha:0.5]];
        _playButton.layer.cornerRadius = height / 2;
        CGFloat cy = ScreenHeight - 125 - 2 * SafeTop;
        CGFloat cxBeside = width / 2 - height / 2;
        CGFloat cx = ScreenWidth - cxBeside;
        _playButton.center = CGPointMake(cx, cy);
        [_playButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 16)];
        [_playButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        _playButton.clipsToBounds = YES;
    }
    return _playButton;
}

- (UIButton *)staticImageButton {
    if (!_staticImageButton) {
        _staticImageButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _staticImageButton.frame = CGRectMake(ScreenWidth - 120, 120, 100, 40);
        [_staticImageButton addTarget:self
                               action:@selector(staticImageButtonTapped:)
                     forControlEvents:UIControlEventTouchUpInside];
        [_staticImageButton setTitle:NSLocalizedString(@"静态贴图", nil) forState:UIControlStateNormal];
    }
    return _staticImageButton;
}
//动图
- (AliyunPasterShowView *)pasterShowView {
    if (!_pasterShowView) {
        _pasterShowView = [[AliyunPasterShowView alloc]
                           initWithFrame:(CGRectMake(0, ScreenHeight, ScreenWidth, 200+SafeBottom))];
        _pasterShowView.delegate = self;
        [_pasterShowView setupSubViews];
        [self.view addSubview:_pasterShowView];
        _pasterShowView.timeLineView = [self getOneTimeLineView];
    }
    return _pasterShowView;
}
//字幕
- (AliyunEffectCaptionShowView *)captionShowView {
    if (!_captionShowView) {
        _captionShowView = [[AliyunEffectCaptionShowView alloc]
                            initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 200+SafeBottom)];
        _captionShowView.delegate = self;
        _captionShowView.fontDelegate = self;
        [_captionShowView setupSubViews];
        [self.view addSubview:_captionShowView];
        _captionShowView.timeLineView = [self getOneTimeLineView];
    }
    return _captionShowView;
}
// MV
- (AliyunEffectMVView *)mvView {
    if (!_mvView) {
        _mvView = [[AliyunEffectMVView alloc]
                   initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 180)];
        _mvView.delegate = (id<AliyunEffectFilterViewDelegate>)self;
        [self.view addSubview:_mvView];
    }
    return _mvView;
}
//滤镜
- (AliyunEffectFilterView *)filterView {
    if (!_filterView) {
        _filterView = [[AliyunEffectFilterView alloc]
                       initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 180)];
        _filterView.delegate = (id<AliyunEffectFilter2ViewDelegate>)self;
        [self.view addSubview:_filterView];
        [_filterView addVisualEffect];
    }
    return _filterView;
}
//特效
- (AlivcSpecialEffectView *)specialFilterView {
    if (!_specialFilterView) {
        _specialFilterView = [[AlivcSpecialEffectView alloc]
                              initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 264+SafeBottom)];
        _specialFilterView.delegate = (id<AlivcSpecialEffectViewDelegate>)self;
        [self.view addSubview:_specialFilterView];
        [_specialFilterView addVisualEffect];
        _specialFilterView.timelineView = [self getOneTimeLineView];
        
        __weak typeof(self) weakSelf = self;
        _specialFilterView.didChangeEffectFinish = ^(AliyunEffectFilter *effect) {
            weakSelf.curEffect = effect;
//            [weakSelf.editor updateAnimationFilter:weakSelf.curEffect];
        };
    }
    return _specialFilterView;
}
//变速（时间特效）
- (AliyunEffectTimeFilterView *)timeFilterView {
    if (!_timeFilterView) {
        _timeFilterView = [[AliyunEffectTimeFilterView alloc]
                           initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 220)];
        _timeFilterView.delegate = self;
        [self.view addSubview:_timeFilterView];
        _timeFilterView.timelineView = [self getOneTimeLineView];
    }
    
    return _timeFilterView;
}
//涂鸦
- (AliyunPaintingEditView *)paintShowView {
    if (!_paintShowView) {
        _paintShowView = [[AliyunPaintingEditView alloc]
                          initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 185)];
        _paintShowView.delegate = self;
        [_paintShowView showInView:self.view animation:YES];
        self.paintView.frame = self.editZoneView.bounds;
    }
    return _paintShowView;
}

- (AlivcAudioEffectView *)effectSoundsView{
    if (!_effectSoundsView) {
        _effectSoundsView = [[AlivcAudioEffectView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 185)];
        _effectSoundsView.delegate =self;
        _effectSoundsView.hidden =YES;
        [self.view addSubview:_effectSoundsView];
    }
    return _effectSoundsView;
}


- (AliyunICanvasView *)paintView {
    if (!_paintView) {
        AliyunIPaint *paint =[[AliyunIPaint alloc]initWithLineWidth:SizeWidth(5.0) lineColor:[UIColor whiteColor]];
        _paintView = [[AliyunICanvasView alloc]initWithFrame:CGRectMake(0, 0, self.movieView.frame.size.width,self.movieView.frame.size.height) paint:paint];
        _paintView.delegate = self;
        _paintView.backgroundColor = [UIColor clearColor];
    }
    return _paintView;
}
//转场
- (AliyunEffectTransitionView *)transitionView {
    if (!_transitionView) {
        NSMutableArray *images = [[NSMutableArray alloc] init];
        NSArray *clips = [self.clipConstructor mediaClips];
        for (int idx = 0; idx < clips.count; idx++) {
            AliyunClip *clip = [clips objectAtIndex:idx];
            if (clip.mediaType == AliyunClipImage) {
                UIImage *image = [UIImage imageWithContentsOfFile:clip.src];
                [images addObject:image];
            } else if (clip.mediaType == AliyunClipGif) {
                UIImage *image = [UIImage imageWithContentsOfFile:clip.src];
                [images addObject:image];
            } else {
                UIImage *image = [AliAssetImageGenerator
                                  thumbnailImageForVideo:[NSURL fileURLWithPath:clip.src]
                                  atTime:0.001];
                [images addObject:image];
            }
        }
        _transitionView = [[AliyunEffectTransitionView alloc]
                           initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 244+SafeBottom)
                           delegate:self];
        __weak typeof(self) weakSelf = self;
        [_transitionView
         setupDataSourceClips:images
         blockHandle:^(NSArray<AliyunTransitionCover *> *covers,
                       NSArray<AliyunTransitionIcon *> *icons) {
             weakSelf.transitionRetention.transitionCovers = [[NSArray alloc] initWithArray:covers copyItems:YES];
             weakSelf.transitionRetention.transitionIcons = [[NSArray alloc] initWithArray:icons copyItems:YES];
         }];
        
        _transitionView.didChangeEffectFinish = ^(AliyunTransitionEffect *effect,int idx) {
            [weakSelf.editor updateTransition:effect atIndex:idx];
        };

        //初始化转场状态管理控制器
        [self.transitionRetention initTransitionInfo:(int)clips.count];
        [self.view addSubview:_transitionView];
    }
    return _transitionView;
}

//封面选择
- (AlivcCoverImageSelectedView *)coverSelectedView {
    if (!_coverSelectedView) {
        _coverSelectedView = [[AlivcCoverImageSelectedView alloc]
                              initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 120)];
        _coverSelectedView.timelineView = [self getOneTimeLineView];
        _coverSelectedView.delegate = self;
        [self.view addSubview:_coverSelectedView];
    }
    return _coverSelectedView;
}

- (AlivcPasterManager *)alivcPasterManager {
    if (!_alivcPasterManager) {
        _alivcPasterManager = [[AlivcPasterManager alloc] init];
    }
    return _alivcPasterManager;
}

- (AliyunDBHelper *)dbHelper {
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
        [_dbHelper openResourceDBSuccess:nil failure:nil];
    }
    return _dbHelper;
}

- (NSMutableArray *)animationFilters {
    if (!_animationFilters) {
        _animationFilters = [[NSMutableArray alloc] init];
    }
    return _animationFilters;
}

- (NSMutableArray *)storeAnimationFilters {
    if (!_storeAnimationFilters) {
        _storeAnimationFilters = [[NSMutableArray alloc] init];
    }
    return _storeAnimationFilters;
}

- (AliyunTabController *)tabController {
    if (!_tabController) {
        _tabController = [[AliyunTabController alloc] init];
        _tabController.delegate = (id)self;
    }
    return _tabController;
}


- (UIButton *)saveButton {
    if (!_saveButton) {
        _saveButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_saveButton setTitle:[@"保存" localString] forState:UIControlStateNormal];
        [_saveButton setTitle:[@"保存" localString]
                     forState:UIControlStateSelected];
        [_saveButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
        [_saveButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateSelected];
        [_saveButton addTarget:self
                        action:@selector(apply)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _saveButton;
}

- (UIButton *)cancelButton {
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_cancelButton setTitle:[@"取消" localString]
                       forState:UIControlStateNormal];
        [_cancelButton setTitle:[@"取消" localString]
                       forState:UIControlStateSelected];
        [_cancelButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateNormal];
        [_cancelButton setTitleColor:[UIColor whiteColor]
                            forState:UIControlStateSelected];
        [_cancelButton addTarget:self
                          action:@selector(cancel)
                forControlEvents:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UIButton *)backButton {
    if (!_backButton) {
        _backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_backButton setImage:[AlivcImage imageNamed:@"avcBackIcon"] forState:UIControlStateNormal];
        [_backButton setImage:[AlivcImage imageNamed:@"avcBackIcon"] forState:UIControlStateSelected];
        [_backButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateNormal];
        [_backButton setTitleColor:[UIColor whiteColor]
                          forState:UIControlStateSelected];
        [_backButton setBackgroundColor:[UIColor clearColor]];
        [_backButton addTarget:self
                        action:@selector(back)
              forControlEvents:UIControlEventTouchUpInside];
    }
    return _backButton;
}

- (UIButton *)publishButton {
    if (!_publishButton) {
        _publishButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _publishButton.backgroundColor = [UIColor clearColor];
        [_publishButton setTitle:[@"下一步" localString] forState:UIControlStateNormal];
        _publishButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [_publishButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        UIColor *bgColor_enable =  [UIColor colorWithRed:252/255.0 green:68/255.0 blue:72/255.0 alpha:1/1.0];
        [_publishButton setBackgroundColor:bgColor_enable];
        [_publishButton addTarget:self action:@selector(publish) forControlEvents:UIControlEventTouchUpInside];
        _publishButton.layer.cornerRadius = 2;
    }
    return _publishButton;
}

- (NSMutableArray<AliyunPasterController *> *)currentPasterControllers {
    if (!_currentPasterControllers) {
        _currentPasterControllers = [NSMutableArray arrayWithCapacity:10];
    }
    return _currentPasterControllers;
}

- (AliyunTransitonStatusRetention *)transitionRetention {
    if (!_transitionRetention) {
        _transitionRetention = [[AliyunTransitonStatusRetention alloc] init];
    }
    return _transitionRetention;
}

- (NSMutableArray *)pasterInfoCopyArr {
    if (!_pasterInfoCopyArr) {
        _pasterInfoCopyArr = [NSMutableArray arrayWithCapacity:8];
    }
    return _pasterInfoCopyArr;
}

- (NSMutableArray <AliyunPasterController *> *)willRemovePasters{
    if (!_willRemovePasters) {
        _willRemovePasters =[[NSMutableArray alloc]initWithCapacity:10];
    }
    return _willRemovePasters;
}

#pragma mark - ButtonAction
- (void)staticImageButtonTapped:(id)sender {
    if (_haveStaticImage == NO) {
        _haveStaticImage = YES;
        _staticImage = [[AliyunEffectStaticImage alloc] init];
        NSString *path = [AlivcImage pathOfImageName:@"yuanhao8"];
        
        _staticImage.startTime = 5;
        _staticImage.endTime = 10;
        _staticImage.path = path;
        
        CGSize displaySize = self.editZoneView.bounds.size;
        CGFloat scale = [[UIScreen mainScreen] scale];
        _staticImage.displaySize = CGSizeMake(displaySize.width * scale,
                                              displaySize.height * scale); // displaySize需要进行scale换算
        _staticImage.frame = CGRectMake(_staticImage.displaySize.width / 2 - 200,
                                        _staticImage.displaySize.height / 2 - 200,
                                        400, 400); //图片自身宽高
        [self.editor applyStaticImage:_staticImage];
    } else {
        _haveStaticImage = NO;
        [self.editor removeStaticImage:_staticImage];
    }
}

- (void)playControlClick:(UIButton *)sender {
    _isEidtTuchAction = NO;
    [self playButtonTouchedHandle];
}

/**
 取消按钮点击响应
 1.不应用特效 - 去除预览中的特效
 2.退出编辑模式
 */
- (void)cancel {
    if (_editSouceClickType == AliyunEditSouceClickTypePaster ||
        _editSouceClickType == AliyunEditSouceClickTypeCaption) {
        [self.editZoneView.currentPasterView removeFromSuperview];
        self.editZoneView.currentPasterView = nil;
        if (_lastPasterController) {
            //            [self.pasterManager
            //            deletePasterController:_lastPasterController];
            [self.pasterManager removePasterController:_lastPasterController];
        }
    }
    if (_editSouceClickType == AliyunEditSouceClickTypeCaption) {
        AliyunPasterController *parsterControl = [self.pasterManager getCurrentEditPasterController];
        
        [self removePasterFromTimeline:parsterControl];
    }
    
    // 2
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}

/**
 保存按钮点击响应
 1.应用特效
 2.退出编辑模式
 */
- (void)apply {
    // 2
    if (_editSouceClickType == AliyunEditSouceClickTypePaster ||
        _editSouceClickType == AliyunEditSouceClickTypeCaption) {
        [self forceFinishLastEditPasterView];
    }
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}

/**
 返回
 */
- (void)back {
    [self.player stop];
    _transitionRetention = nil;
    _config.outputSize = _inputOutputSize;
    [self.navigationController popViewControllerAnimated:YES];
}

- (UIImage *)featchFirstFrame {
    NSArray *clips = [self.clipConstructor mediaClips];
    AliyunClip *firstClip = clips.firstObject;
    if (firstClip) {
        AliAssetInfo *info = [[AliAssetInfo alloc] init];
        info.path = firstClip.src;
        info.duration = firstClip.duration;
        info.animDuration = 0;
        info.startTime = firstClip.startTime;
        if (firstClip.mediaType == AliyunClipVideo) {
            info.type = AliAssetInfoTypeVideo;
        } else {
            info.type = AliAssetInfoTypeImage;
        }
        UIImage *image = [info captureImageAtTime:0 outputSize:_outputSize];
        return image;
    }
    return nil;
}

/**
 发布
 */
- (void)publish {
    [self forceFinishLastEditPasterView];
    if (self.isExporting){
        return;
    }
    [self.player stop];
    [self.editor stopEdit];
    AlivcOutputProductType productType = kAlivcProductType;
    if (productType == AlivcOutputProductTypeSmartVideo) {
        Class AlivcPublishQuViewControl = NSClassFromString(@"AlivcPublishQuViewControl");
        UIViewController *targetVC = [[AlivcPublishQuViewControl alloc]init];
        if (!self.coverImage) {
            self.coverImage = [self featchFirstFrame];
        }
        [targetVC setValue:self.coverImage forKey:@"coverImage"];
        [targetVC setValue:_taskPath forKey:@"taskPath"];
        [targetVC setValue:_config forKey:@"config"];
        [self.navigationController pushViewController:targetVC animated:YES];
    } else {
        
        Class viewControllerClass = NSClassFromString(@"AlivcExportViewController");
        UIViewController * controller = [[viewControllerClass alloc]init];
        if (!controller) {
            
            UIAlertController *alertController = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"提示", nil) message:NSLocalizedString(@"当前未集成上传发布功能", nil) preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"确定" , nil) style:UIAlertActionStyleCancel handler:nil];
            
            [alertController addAction:cancelAction];
            
            [self presentViewController:alertController animated:YES completion:nil];
            
        }else {
            
            [controller  setValue:_taskPath forKey:@"taskPath"];
            [controller  setValue:_config forKey:@"config"];
            [controller  setValue:[NSValue valueWithCGSize:_config.outputSize] forKey:@"outputSize"];
            [controller  setValue:_currentTimelineView.coverImage forKey:@"backgroundImage"];
            [controller  setValue:_finishBlock forKey:@"finishBlock"];
            
            [self.navigationController pushViewController:controller animated:YES];
        }
        
        
    }
}

#pragma mark - Notification

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resourceDeleteNoti:) name:AliyunEffectResourceDeleteNotification object:nil];
    
}

- (void)addNotificationBeforeSdk {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActiveBeforeSDK) name:UIApplicationWillResignActiveNotification object:nil];
}

//- (void)removeNotifications {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

#pragma mark - Notification Action
//资源删除通知
- (void)resourceDeleteNoti:(NSNotification *)noti {
    NSArray *deleteResourcePaths = noti.object;
    NSString *deleteResourcePathStr = deleteResourcePaths.firstObject;
    NSArray *paths = [deleteResourcePathStr componentsSeparatedByString:@"/"];
    NSString *contrastStr = [NSString string];
    for (int i = 0; i < paths.count; i++) { // 13
        if (i >= paths.count - 7 && i < paths.count - 2) {
            contrastStr = [NSString stringWithFormat:@"%@/%@", contrastStr, paths[i]];
        }
    }
    NSArray *pasterList = [self.pasterManager getAllPasterControllers];
    //倒序删除
    for (int i = (int)pasterList.count - 1; i >= 0; i--) {
        AliyunPasterController *controller = [pasterList objectAtIndex:i];
        if ([[controller getIconPath] containsString:contrastStr]) {
            NSLog(@"删除动图");
            //            [self deletePasterController:controller isEditing:NO];
            [self.willRemovePasters addObject:controller];
        }
    }
    AliyunEffectResourceModel *model = noti.userInfo[@"deleteModel"];
    if (model.effectType == AliyunEffectTypeMV) {
        if (self.mvView.selectIndex == 0) {
            
        } else if (self.mvView.selectedEffect.eid == model.eid) {
            [self didSelectEffectMVNone];
            self.mvView.selectedEffect = nil;
            self.mvView.selectIndex = 0;
            
        } else {
            if ([noti.userInfo[@"deleteIndex"] intValue] > self.mvView.selectIndex) {
                self.mvView.selectIndex--;
            } else {
                self.mvView.selectIndex++;
            }
        }
        
        [self.mvView reloadDataWithEffectTypeWithDelete:AliyunEffectTypeMV];
    }
}
-(void)resourceDeleteAction{
    for (AliyunPasterController *controller in self.willRemovePasters) {
        [self deletePasterController:controller isEditing:NO];
    }
    [self.willRemovePasters removeAllObjects];
}

- (void)applicationDidBecomeActive {
    if (self.isAppear) {
        NSLog(@"程序进入前台");
        if (self.isExporting) {
            [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
            self.isExporting = NO;
        }
        if (self.vcStatus == AlivcEditVCStatus_Edit) { //编辑状态下，app进入前台，手动同步播放器播放进度到缩略图。
            int ret = [self.player seek:self.currentPlaytime];
            
            NSLog(@"当前时间===ret  %d, time %f",ret, self.currentPlaytime);
        }
        
        if (_isPlaying) {
            [self.player resume];
        }
        [self updateUIAndDataWhenPlayStatusChanged];
        self.isBackground = NO;
    }
    self.playButton.enabled = YES;
}

- (void)applicationWillResignActive {
    if (self.isAppear) {
        self.isBackground = YES;
        // 特效正在添加过程中
        if (_processAnimationFilter &&
            _editSouceClickType == AliyunEditSouceClickTypeEffect) {
            [self.specialFilterView specialFilterReset];
            [self pause];
        }
        //        [self forceFinishLastEditPasterView];
        [self destroyInputView];
        
        if (_tabController) {
            [self.tabController dismissPresentTabContainerView];
        }
        // app退到后台前先停止滑动，否则播放器状态在特定情境下会出现异常
        [self.currentTimelineView stopSlid];
        NSLog(@"\n ++++>程序挂起!");
    }
}


- (void)applicationWillResignActiveBeforeSDK {
    if (_currentEditPasterType == AliyunPasterEffectTypeCaption)
    {//如果是字幕气泡
        [self cancelButtonClicked];
    }
    
    [self forceFinishLastEditPasterView];
    if(_isPlaying == [self.player isPlaying]) {
        [self.player pause];
    }
    self.currentPlaytime = [self.player getCurrentStreamTime];
    NSLog(@"currentPlaytime===%f",[self.player getCurrentStreamTime]);
    
}
#pragma mark - Common Method

#pragma mark贴图相关操作
//删除单个动图
- (void)deletePasterController:(AliyunPasterController *)paster isEditing:(BOOL)isEditing{
    if (paster && isEditing) {
        //编辑状态下要关闭pasterView的编辑态
        AliyunPasterView *pasterView = (AliyunPasterView *)paster.pasterView;
        [pasterView.delegate eventPasterViewClosed:pasterView];
        pasterView.editStatus = NO;
        [pasterView removeFromSuperview];
        [self.pasterManager removePasterController:paster];
    }else if (paster){//动图非编辑态直接删除
        [self.pasterManager removePasterController:paster];
    }
}

#pragma mark - Play Manager

/**
 播放暂停按钮事件处理
 */
- (void)playButtonTouchedHandle {
    if (self.player.isPlaying) {
        [self pause];
    } else {
        [self resume];
    }
}

/**
 尝试播放视频
 */
- (void)play {
    if (self.player.isPlaying) {
        NSLog(@"短视频编辑播放器测试:当前播放器正在播放状态,不调用play");
    } else {
        int returnValue = [self.player play];
        NSLog(@"短视频编辑播放器测试:调用了play接口");
        if (returnValue == 0) {
            NSLog(@"短视频编辑播放器测试:play返回0成功");
        } else {
            //            [MBProgressHUD showMessage:[NSString
            //            stringWithFormat:@"播放错误,错误码:%d",returnValue]
            //            inView:self.view];
        }
        [self updateUIAndDataWhenPlayStatusChanged];
    }
}

/**
 尝试继续播放视频
 */
- (void)resume {
    if (self.player.isPlaying) {
        NSLog(@"短视频编辑播放器测试:当前播放器正在播放状态,不调用resume");
    } else {
        int returnValue = [self.player resume];
        NSLog(@"短视频编辑播放器测试:调用了resume接口");
        if (returnValue == 0) {
            [self forceFinishLastEditPasterView];
            NSLog(@"短视频编辑播放器测试:resume返回0成功");
        } else {
            [self.player play];
            //            [MBProgressHUD showMessage:[NSString
            //            stringWithFormat:@"继续播放错误,错误码:%d",returnValue]
            //            inView:self.view];
            NSLog(@"短视频编辑播放器测试:！！！！继续播放错误,错误码:%d",
                  returnValue);
        }
    }
    [self updateUIAndDataWhenPlayStatusChanged];
}

-(void)replay{
    [self.player replay];
    [self updateUIAndDataWhenPlayStatusChanged];
}

/**
 尝试暂停视频
 */
- (void)pause {
    if (self.player.isPlaying) {
        int returnValue = [self.player pause];
        NSLog(@"短视频编辑播放器测试:调用了pause接口");
        if (returnValue == 0) {
            NSLog(@"短视频编辑播放器测试:pause返回0成功");
        } else {
            //            [MBProgressHUD showMessage:[NSString
            //            stringWithFormat:@"暂停错误,错误码:%d",returnValue]
            //            inView:self.view];
            NSLog(@"短视频编辑播放器测试:！！！！暂停错误,错误码:%d", returnValue);
        }
        
    } else {
        NSLog(@"短视频编辑播放器测试:当前播放器不是播放状态,不调用pause");
    }
    [self updateUIAndDataWhenPlayStatusChanged];
}

/**
 更新UI当状态改变的时候，播放的状态下是暂停按钮，其余都是播放按钮
 */
- (void)updateUIAndDataWhenPlayStatusChanged {
    if (self.player.isPlaying) {
        [self.playButton setSelected:NO];
        _prePlaying = YES;
    } else {
        [self.playButton setSelected:YES];
        _prePlaying = NO;
    }
}

#pragma mark - Common Method - UI

/**
 进入编辑模式 - 本方法只适配UI,其余数据的初始值设置等，请在各自的方法里处理
 
 @param type 动作类型
 */
- (void)enterEditWithActionType:(AliyunEditSouceClickType)type
            animationCompletion:(void (^__nullable)(BOOL finished))completion {
    self.editButtonsView.userInteractionEnabled = NO;
    NSLog(@"多点测试:%lu", (unsigned long)type);
    NSLog(@"多点测试:底部按钮失效");
    _editSouceClickType = type;
    _vcStatus = AlivcEditVCStatus_Edit;
    if (_lastPasterController) {
        _lastPasterController = nil;
    }
    CGFloat animationTime = 0.2f;
    BOOL canEditFrame = [self isEditFrameType:type];
    if (canEditFrame) {
        [self p_changeUIToEnterEditFrameModeCompletionHandle:completion];
        [self pause];
        //每次进入编辑模式，同步播放器进度到timelineView
        [self.currentTimelineView setActualDuration:[self.player
                                                     getStreamDuration]];
        CGFloat time = [self.player getCurrentStreamTime];
        [self.currentTimelineView seekToTime:time];
    } else {
        [self p_presentBackgroundButton];
    }
    UIView *view = [self editViewWithType:type];
    if (view) {
        [self p_showEffectView:view duration:animationTime];
    }
    //播放按钮位置
    CGPoint current = self.playButton.center;
    current.y = ScreenHeight - 250 - SafeTop * 2;
    self.playButton.center = current;
}

/**
 退出编辑模式
 
 @param type 编辑类型
 */
- (void)quitEditWithActionType:(AliyunEditSouceClickType)type
              CompletionHandle:(void (^__nullable)(BOOL finished))completion {
    _vcStatus = AlivcEditVCStatus_Normal;
    _lastPasterController = nil;
    _isEidtTuchAction = NO;
    
    CGFloat animationTime = 0.2f;
    UIView *view = [self editViewWithType:type];
    if (view) {
        [self p_dismissEffectView:view
                         duration:animationTime
                 CompletionHandle:completion];
    }
    
    BOOL canEditFrame = [self isEditFrameType:type];
    if (canEditFrame) {
        [self p_changeUIToQuitEditFrameMode];
        [self resume];
    } else {
        [self p_dismissBackgroundButton];
    }
    if (_currentTextInputView) {
        [self textInputViewEditCompleted];
    }
    
    //播放按钮位置
    CGPoint current = self.playButton.center;
    current.y = ScreenHeight - 125 - SafeTop * 2;
    self.playButton.center = current;
}

/**
 根据编辑类型判断这个编辑类型是否能对视频逐帧操作,局部处理
 能的类型整理：
 //音乐 AliyunEditSouceClickTypeMusic
 //动图 AliyunEditSouceClickTypePaster
 //字幕 AliyunEditSouceClickTypeSubtitle
 //特效 AliyunEditSouceClickTypeEffect
 //时间特效 AliyunEditSouceClickTypeTimeFilter
 @param type 类型
 @return 能：YES，不能：NO
 */
- (BOOL)isEditFrameType:(AliyunEditSouceClickType)type {
    if (type == AliyunEditSouceClickTypeMusic ||
        type == AliyunEditSouceClickTypePaster ||
        type == AliyunEditSouceClickTypeCaption ||
        type == AliyunEditSouceClickTypeEffect ||
        type == AliyunEditSouceClickTypeTimeFilter ||
        type == AliyunEditSouceClickTypeTranslation ||
        type == AliyunEditSouceClickTypePaint ||
        type == AliyunEditSouceClickTypeCover) {
        return YES;
    }
    return NO;
}

/**
 根据编辑类型返回具体要编辑的当前视图的编辑控件视图
 
 @param type 编辑类型
 @return 编辑控件视图
 */
- (UIView *__nullable)editViewWithType:(AliyunEditSouceClickType)type {
    switch (type) {
        case AliyunEditSouceClickTypeFilter:
            return self.filterView;
            break;
        case AliyunEditSouceClickTypeMusic:
            return nil;
            break;
        case AliyunEditSouceClickTypePaster:
            return self.pasterShowView;
            break;
        case AliyunEditSouceClickTypeCaption:
            return self.captionShowView;
            break;
        case AliyunEditSouceClickTypeMV:
            return self.mvView;
            break;
        case AliyunEditSouceClickTypeEffect:
            return self.specialFilterView;
            break;
        case AliyunEditSouceClickTypeTimeFilter:
            return self.timeFilterView;
            break;
        case AliyunEditSouceClickTypeTranslation:
            return self.transitionView;
            break;
        case AliyunEditSouceClickTypePaint:
            return self.paintShowView;
            break;
        case AliyunEditSouceClickTypeEffectSound:
            return self.effectSoundsView;
            break;
        case AliyunEditSouceClickTypeCover:
            return self.coverSelectedView;
            break;
        default:
            break;
    }
    return nil;
}

#pragma mark - Common Method - Other

- (void)presentAliyunEffectMoreControllerWithAliyunEffectType:(AliyunEffectType)effectType
                                                   completion:(void (^)(AliyunEffectInfo *selectEffect))completion
{
    //    if (!self.mvMoreVC) {
    AliyunEffectMoreViewController *effectMoreVC = [[AliyunEffectMoreViewController alloc]
                                                    initWithEffectType:effectType];
    effectMoreVC.effectMoreCallback = ^(AliyunEffectInfo *info) {
        completion(info);
    };
    UINavigationController *effecNC = [[UINavigationController alloc]
                                       initWithRootViewController:effectMoreVC];
    //        self.mvMoreVC = effecNC;
    //    }
    if(@available(iOS 13.0, *)) {
        effecNC.modalPresentationStyle = UIModalPresentationFullScreen;
        [effectMoreVC.view setBackgroundColor:[UIColor blackColor]];
    }
    [self presentViewController:effecNC animated:YES completion:nil];
    //    if (effectType == AliyunEffectTypeMV) {
    //        if (!self.mvMoreVC) {
    //            AliyunEffectMoreViewController *effectMoreVC = [[AliyunEffectMoreViewController alloc]
    //                                                            initWithEffectType:effectType];
    //            effectMoreVC.effectMoreCallback = ^(AliyunEffectInfo *info) {
    //                completion(info);
    //            };
    //            UINavigationController *effecNC = [[UINavigationController alloc]
    //                                               initWithRootViewController:effectMoreVC];
    //            self.mvMoreVC = effecNC;
    //        }
    //
    //        [self presentViewController:self.mvMoreVC animated:YES completion:nil];
    //    } else if (effectType == AliyunEffectTypePaster) {
    //        if (!self.pasterMoreVC) {
    //            AliyunEffectMoreViewController *effectMoreVC = [[AliyunEffectMoreViewController alloc]initWithEffectType:effectType];
    //            effectMoreVC.effectMoreCallback = ^(AliyunEffectInfo *info) {
    //                completion(info);
    //            };
    //            UINavigationController *effecNC = [[UINavigationController alloc]
    //                                               initWithRootViewController:effectMoreVC];
    //            self.pasterMoreVC = effecNC;
    //        }
    //
    //        [self presentViewController:self.pasterMoreVC animated:YES completion:nil];
    //    } else if (effectType == AliyunEffectTypeCaption) {
    //        if (!self.captionMoreVC) {
    //            AliyunEffectMoreViewController *effectMoreVC =[[AliyunEffectMoreViewController alloc]initWithEffectType:effectType];
    //            effectMoreVC.effectMoreCallback = ^(AliyunEffectInfo *info) {
    //                completion(info);
    //            };
    //            UINavigationController *effecNC = [[UINavigationController alloc]
    //                                               initWithRootViewController:effectMoreVC];
    //            self.captionMoreVC = effecNC;
    //        }
    //
    //        [self presentViewController:self.captionMoreVC animated:YES completion:nil];
    //    }
}

- (void)cancelExport {
    self.isExporting = NO;
    [self.exporter cancelExport];
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
    [self.player resume];
}

- (void)backgroundTouchButtonClicked:(id)sender {
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}

- (void)destroyInputView {
    [_currentTextInputView removeFromSuperview];
    _currentTextInputView = nil;
}
//使一个动图进入编辑状态
- (void)makePasterControllerBecomeEditStatus:(AliyunPasterController *)pasterController {
    self.editZoneView.currentPasterView =(AliyunPasterView *)[pasterController pasterView];
    
    //内部刷新_pasterTextView的属性
    [self.editZoneView.currentPasterView setTextColor:self.editZoneView.currentPasterView.textColor];
    [self.editZoneView.currentPasterView setTextFontName:self.editZoneView.currentPasterView.textFontName];
    
    [pasterController editWillStart];
    self.editZoneView.currentPasterView.editStatus = YES;
    [self editPasterItemBy:pasterController]; // TimelineView联动
    NSString *fontName = self.editZoneView.currentPasterView.textFontName;
    [[NSUserDefaults standardUserDefaults] setObject:fontName forKey:AlivcEditPlayerPasterFontName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
//使一个动图完成编辑（CopyPasterController专用）
- (void)addPasterViewToDisplayAndRenderWithCopyPasterController:(AliyunPasterController *)pasterController pasterFontId:(NSInteger)fontId {
    AliyunPasterView *pasterView = [[AliyunPasterView alloc] initWithPasterController:pasterController];
    pasterView.delegate = (id)pasterController;
    pasterView.actionTarget = (id)self;
    
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformMakeRotation(-pasterController.pasterRotate);
    pasterView.layer.affineTransform = t;
    
    [pasterController setPasterView:pasterView];
    [self.editZoneView addSubview:pasterView];
    
    if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
        [pasterController editCompletedWithImage:[pasterView textImage]];
        [self animateWithObject:pasterController animation:[pasterController tempActionType]];
    } else if (pasterController.pasterType == AliyunPasterEffectTypeNormal) {
        [pasterController editCompleted];
    } else {
        [pasterController editCompletedWithImage:[pasterView textImage]];
    }
}
//使一个动图完成编辑
- (void)addPasterViewToDisplayAndRender:
(AliyunPasterController *)pasterController
                           pasterFontId:(NSInteger)fontId {
    AliyunPasterView *pasterView =[[AliyunPasterView alloc] initWithPasterController:pasterController];
    
    if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
        pasterView.textColor = [_currentTextInputView getTextColor];
        pasterView.textFontName = [_currentTextInputView fontName];
        pasterController.subtitleFontName = pasterView.textFontName;
        pasterController.subtitleStroke = pasterView.textColor.isStroke;
        pasterController.subtitleColor = [pasterView contentColor];
        pasterController.subtitleStrokeColor = [pasterView strokeColor];
        pasterController.subtitleBackgroundColor = [UIColor clearColor];
    }
    if (pasterController.pasterType == AliyunPasterEffectTypeCaption) {
        UIColor *textColor = pasterController.subtitleColor;
        UIColor *textStokeColor = pasterController.subtitleStrokeColor;
        BOOL stroke = pasterController.subtitleStroke;
        AliyunColor *color = [[AliyunColor alloc] initWithColor:textColor
                                                    strokeColor:textStokeColor
                                                          stoke:stroke];
        pasterView.textColor = color;
        AliyunEffectFontInfo *fontInfo = (AliyunEffectFontInfo *)[self.dbHelper
                                                                  queryEffectInfoWithEffectType:1
                                                                  effctId:fontId];
        
        if (fontInfo == nil) {
            pasterView.textFontName = AlivcSystemFontName;
            pasterController.subtitleFontName = AlivcSystemFontName;
            AliyunResourceFontDownload *download =[[AliyunResourceFontDownload alloc] init];
            [download downloadFontWithFontId:fontId
                                    progress:nil
                                  completion:^(AliyunEffectResourceModel *newModel, NSError *error) {
                if (!error) {
                    pasterView.textFontName = newModel.fontName;
                    pasterController.subtitleFontName = newModel.fontName;
                }
            }];
        } else {
            pasterView.textFontName = fontInfo.fontName;
            pasterController.subtitleFontName = fontInfo.fontName;
        }
    }
    pasterView.delegate = (id)pasterController;
    pasterView.actionTarget = (id)self;
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformMakeRotation(pasterController.pasterRotate);
    pasterView.layer.affineTransform = t;
    [pasterController setPasterView:pasterView];
    [self.editZoneView addSubview:pasterView];
    if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
        [pasterController editCompletedWithImage:[pasterView textImage]];
    } else if (pasterController.pasterType == AliyunPasterEffectTypeNormal) {
        [pasterController editCompleted];
    } else {
        [pasterController editCompletedWithImage:[pasterView textImage]];
    }
}
//计算动图效果初始范围
- (AliyunPasterRange)calculatePasterStartTimeWithDuration:(CGFloat)duration {
    
    NSLog(@"getCurrentTime:%f", [self.player getCurrentTime]);
    NSLog(@"getCurrentStreamTime:%f", [self.player getCurrentStreamTime]);
    
    AliyunPasterRange pasterRange;
    CGFloat safeTime = [self.player getStreamDuration] - [self.player getCurrentStreamTime];
    if (safeTime < PASTER_MIN_DURANTION) { //如果初始范围小于0.1，则初始化为0.1
        pasterRange.duration = PASTER_MIN_DURANTION;
        pasterRange.startTime =[self.player getCurrentStreamTime] - PASTER_MIN_DURANTION;
    } else if (safeTime <= duration) { //默认动画的播放时间超过总视频长
        pasterRange.duration = safeTime;
        pasterRange.startTime = [self.player getCurrentStreamTime];
    } else { //默认动画时间未超出总视频
        pasterRange.duration = duration;
        pasterRange.startTime = [self.player getCurrentStreamTime];
    }
    NSLog(@"=======safeTime:%f", safeTime);
    return pasterRange;
}

/**
 更新画图区域
 */
- (void)updateDrawRect:(CGRect)drawRect {
    self.paintView.frame =
    CGRectMake(drawRect.origin.x, drawRect.origin.y + SafeTop,
               drawRect.size.width, drawRect.size.height - 120);
}

#pragma mark - Private Methods
/**
 底部功能按钮点击之后，展示具体的对应的功能view
 
 @param view 具体的编辑视图
 @param duration 动画展示所需的时间
 */
- (void)p_showEffectView:(UIView *)view duration:(CGFloat)duration {
    view.hidden = NO;
    [self.view bringSubviewToFront:view];
    [UIView animateWithDuration:duration
                     animations:^{
        CGRect f = view.frame;
        f.origin.y = ScreenHeight - CGRectGetHeight(f);
        view.frame = f;
    } completion:^(BOOL finished) {
        if (finished) {
            self.editButtonsView.userInteractionEnabled = YES;
            NSLog(@"多点测试:底部按钮可以点击");
        }
    }];
}

/**
 展示具体的对应的功能view消失
 
 @param view 具体的编辑视图
 @param duration 动画展示所需的时间
 */
- (void)p_dismissEffectView:(UIView *)view
                   duration:(CGFloat)duration
           CompletionHandle:(void (^__nullable)(BOOL finished))completion {
    [UIView animateWithDuration:duration
                     animations:^{
        CGRect f = view.frame;
        f.origin.y = ScreenHeight;
        view.frame = f;
    } completion:^(BOOL finished) {
        if (completion) {
            completion(finished);
        }
        view.hidden = YES;
    }];
}

/**
 让界面进入能编辑视频帧的模式
 */
- (void)p_changeUIToEnterEditFrameModeCompletionHandle:(void (^__nullable)(BOOL finished))completion {
    [self.saveButton sizeToFit];
    [self.cancelButton sizeToFit];
    self.backButton.hidden = YES;
    self.publishButton.hidden = YES;
    CGRect editFrame = [self editStatusFrameMovieView];
    
    [UIView animateWithDuration:0.2
                     animations:^{
        self.movieView.frame = editFrame;
        self.editZoneView.frame = self.movieView.bounds;
    } completion:^(BOOL finished) {
        self.pasterManager.displaySize = editFrame.size;
        //修正由于编辑区域变化引起的精度偏差从而导致动图位置偏移的BUG,如果pasterManager.displaySize一直没变则不需要进行此处理
        //        [self.alivcPasterManager
        //            correctedPasterFrameAtEditStatusWithPasterManager:self.pasterManager
        //                                                withEditFrame:editFrame];
        if (completion) {
            completion(finished);
        }
    }];
}

/**
 界面退出编辑模式
 */
- (void)p_changeUIToQuitEditFrameMode {
    [self.saveButton removeFromSuperview];
    [self.cancelButton removeFromSuperview];
    self.backButton.hidden = NO;
    self.publishButton.hidden = NO;
    [self p_setMovieViewFrameToPlayStatusWithAnimation];
}

/**
 编辑模式下的frame大小
 
 @return 编辑模式下的frame大小
 */
- (CGRect)editStatusFrameMovieView {
    CGFloat yToTop = SafeTop + 8;
    
    UIView *editView = [self editViewWithType:_editSouceClickType];
    CGFloat mHeight = ScreenHeight - editView.frame.size.height - yToTop - 2;
    CGFloat factor = _outputSize.width / _outputSize.height;
    CGFloat mWidth = factor * mHeight;
    if (mWidth > ScreenWidth) {
        mWidth = ScreenWidth;
        mHeight = 1 / factor * mWidth;
    }
    CGFloat mx = (ScreenWidth - mWidth) / 2;
    CGFloat my = yToTop;
    return CGRectMake(mx, my, ceilf(mWidth), ceilf(mHeight));
}

/**
 播放视图正常的frame
 
 @return 播放视图正常的frame
 */
//- (CGRect)playStatusFrameMovieView {
//    CGFloat factor = _outputSize.height / _outputSize.width;
//    CGFloat y = ScreenWidth / 8 + SafeTop;
//    //适配不同比例下的播放视图摆放位置
//    if (factor < 1 || factor == 1) {
//        y = self.view.center.y - ScreenWidth * factor / 2;
//    }
//    CGRect targetFrame;
//    if ([_config mediaRatio] == AliyunMediaRatio9To16) {
//        //9:16填充屏幕
//        targetFrame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
//    } else {
//        targetFrame  = CGRectMake(0, y, ScreenWidth, ScreenWidth * factor);
//    }
//
//
//    self.pasterManager.outputSize = targetFrame.size;
//    return targetFrame;
//}
- (CGRect)playStatusFrameMovieView {
    CGFloat factor = _outputSize.height / _outputSize.width;
    CGFloat y = ScreenWidth / 8 + SafeTop;
    if ([_config mediaRatio] == AliyunMediaRatio9To16) {
        if (IS_IPHONEX) {
            CGFloat width = ScreenHeight / factor;
            return CGRectMake(-(width - ScreenWidth)*0.5, 0, width ,ScreenHeight);
        } else {
            y = 0;
        }
    }
    //适配不同比例下的播放视图摆放位置
    if (factor < 1 || factor == 1) {
        y = self.view.center.y - ScreenWidth * factor / 2;
    }
    CGRect targetFrame = CGRectMake(0, y, ScreenWidth, ScreenWidth * factor);
    self.pasterManager.outputSize = targetFrame.size;
    return targetFrame;
}
/**
 让播放视图回归正常的大小
 */
- (void)p_setMovieViewFrameToPlayStatus {
    
    self.movieView.frame = [self playStatusFrameMovieView];
    
}
/**
 让播放视图回归正常的大小-以动画的形式
 */
- (void)p_setMovieViewFrameToPlayStatusWithAnimation {
    CGRect targetFrame = [self playStatusFrameMovieView];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.2
                     animations:^{
                         self.movieView.frame = targetFrame;
                         self.editZoneView.frame = self.movieView.bounds;
                     } completion:^(BOOL finished) {
                         if (finished) {
                             // vvvv 恢复在非编辑状态时的displaySize
                             self.pasterManager.displaySize = self.editZoneView.bounds.size;
                             //修正由于编辑区域变化引起的精度偏差从而导致动图位置偏移的BUG,如果pasterManager.displaySize一直没变则不需要进行此处理
                             //          [self.alivcPasterManager
                             //              correctedPasterFrameAtPreviewStatusWithPasterManager:
                             //                  self.pasterManager];
                             if (self->_tabController) {
                                 self->_tabController = nil;
                             }
                             if (self.paintView) {
                                 self.paintView.frame = self.movieView.frame;
                             }
                         }
                     }];
}

/**
 添加背景按钮
 */
- (void)p_presentBackgroundButton {
    [self p_dismissBackgroundButton];
    self.backgroundTouchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.backgroundTouchButton.frame = self.view.bounds;
    self.backgroundTouchButton.backgroundColor = [UIColor clearColor];
    [self.backgroundTouchButton addTarget:self
                                   action:@selector(backgroundTouchButtonClicked:)
                         forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.backgroundTouchButton];
    [self.view bringSubviewToFront:self.playButton];
}

/**
 让背景按钮消失
 */
- (void)p_dismissBackgroundButton {
    [self.backgroundTouchButton removeFromSuperview];
    self.backgroundTouchButton = nil;
}

#pragma mark - AliyunIPlayerCallback

- (void)playerDidStart {
    NSLog(@"play start");
}

- (void)playerDidEnd {
    
    if (_processAnimationFilter) { //如果当前有正在添加的动效滤镜 则pause
        //        [self.player replay];
        [self updateUIAndDataWhenPlayStatusChanged];
        _processAnimationFilter.endTime = [self.player getDuration];
        _processAnimationFilter.streamEndTime = [self.player getStreamDuration];
        
        [self.specialFilterView endLongPress];
    } else {
        if (!self.isExporting) {
            [self.player replay];
            [self updateUIAndDataWhenPlayStatusChanged];
            self.isExporting = NO;
            //            [self forceFinishLastEditPasterView];
        }
    }
}

- (void)playProgress:(double)playSec streamProgress:(double)streamSec {
    if (!_isEidtTuchAction) {
        // 1.添加动图并且调整遮罩层时，_isEidtTuchAction 为YES为了保持缩略条不动。
        // 2.添加动图时，如果遮罩层在动，那么对于缩略图来说，他不能动，因为如果2者同时动的话，用户体验不好，所有有这个判断
        [self.currentTimelineView seekToTime:streamSec];
    }
    self.currentTimeLabel.text = [self stringFromTimeInterval:streamSec];
    //    NSLog(@"playSec%f   ------
    //    streamSec%f",(float)playSec,(float)streamSec);
}

- (void)seekDidEnd {
    NSLog(@"seek end");
}

- (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger ti = (NSInteger)interval;
    NSInteger seconds = ti % 60;
    NSInteger minutes = (ti / 60) % 60;
    NSInteger hours = (ti / 3600);
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld", (long)hours,
            (long)minutes, (long)seconds];
}

- (void)playError:(int)errorCode {
    NSLog(@"playError:%d,%x", errorCode, errorCode);
    NSString *errString = [NSString stringWithFormat:@"%@:%ld", [@"播放错误,错误码" localString],(long)errorCode];
    //    UIAlertView *alert = [[UIAlertView alloc]
    //                          initWithTitle:errString
    //                          message:nil
    //                          delegate:nil
    //                          cancelButtonTitle:NSLocalizedString(@"video_affirm_common", nil)
    //                          otherButtonTitles:nil, nil];
    //    [alert show];
    
    [MBProgressHUD showWarningMessage:errString inView:self.view];
    
    if (errorCode == ALIVC_FRAMEWORK_MEDIA_POOL_CACHE_DATA_SIZE_OVERFLOW) {
        [self play];
    }
}

- (int)customRender:(int)srcTexture size:(CGSize)size {
    // 自定义滤镜渲染
    //    if (!self.filter) {
    //        self.filter = [[AliyunCustomFilter alloc] initWithSize:size];
    //    }
    //    return [self.filter render:srcTexture size:size];
    return srcTexture;
}

#pragma mark - AliyunIExporterCallback

- (void)exporterDidStart {
    NSLog(@"TestLog, %@:%@", @"log_edit_start_time",
          @([NSDate date].timeIntervalSince1970));
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeDeterminate;
    hud.removeFromSuperViewOnHide = YES;
    [hud.button setTitle:NSLocalizedString(@"cancel_camera_import", nil)
                forState:UIControlStateNormal];
    [hud.button addTarget:self
                   action:@selector(cancelExport)
         forControlEvents:UIControlEventTouchUpInside];
    hud.label.text = NSLocalizedString(@"video_is_exporting_edit", nil);
    self.navigationController.interactivePopGestureRecognizer.enabled = NO;
}

- (void)exporterDidEnd:(NSString *)outputPath {
    
    NSLog(@"TestLog, %@:%@", @"log_edit_complete_time",@([NSDate date].timeIntervalSince1970));
    
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (self.isExporting) {
        self.isExporting = NO;
        
        NSURL *outputPathURL = [NSURL fileURLWithPath:_config.outputPath];
        AVAsset *as = [AVAsset assetWithURL:outputPathURL];
        CGSize size = [as aliyunNaturalSize];
        CGFloat videoDuration = [as aliyunVideoDuration];
        float frameRate = [as aliyunFrameRate];
        float bitRate = [as aliyunBitrate];
        float estimatedKeyframeInterval = [as aliyunEstimatedKeyframeInterval];
        
        NSLog(@"TestLog, %@:%@", @"log_output_resolution",
              NSStringFromCGSize(size));
        NSLog(@"TestLog, %@:%@", @"log_video_duration", @(videoDuration));
        NSLog(@"TestLog, %@:%@", @"log_frame_rate", @(frameRate));
        NSLog(@"TestLog, %@:%@", @"log_bit_rate", @(bitRate));
        NSLog(@"TestLog, %@:%@", @"log_i_frame_interval",@(estimatedKeyframeInterval));
        
        ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
        [library writeVideoAtPathToSavedPhotosAlbum:outputPathURL completionBlock:^(NSURL *assetURL, NSError *error) {
            /* process assetURL */
            if (!error) {
                //                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle: NSLocalizedString(@"video_exporting_finish_edit", nil) message:NSLocalizedString(@"video_local_save_edit",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                //                 [alert show];
                [MBProgressHUD showWarningMessage:NSLocalizedString(@"video_local_save_edit",nil) inView:self.view];
            } else {
                //                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"video_exporting_finish_fail_edit",nil) message:NSLocalizedString(@"video_exporting_check_autho",nil) delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
                //                 [alert show];
                [MBProgressHUD showWarningMessage:NSLocalizedString(@"video_exporting_check_autho",nil) inView:self.view];
            }
        }];
    }
    [self play];
}

- (void)exporterDidCancel {
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    [self resume];
}

- (void)exportProgress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        MBProgressHUD *hub = [MBProgressHUD HUDForView:self.view];
        hub.progress = progress;
    });
}

- (void)exportError:(int)errorCode {
    NSLog(@"exportError:%d,%x", errorCode, errorCode);
    [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    if (self.isBackground) {
        //        self.editorError = YES;
    } else {
        [self play];
    }
}

#pragma mark - AliyunTimelineView相关 -
- (void)addAnimationFilterToTimeline:(AliyunEffectFilter *)animationFilter {
    AliyunTimelineFilterItem *filterItem = [[AliyunTimelineFilterItem alloc] init];
    NSLog(@"边缘特效:%f--%f", animationFilter.streamStartTime, animationFilter.streamEndTime);
    if ([self.editor getTimeFilter] == 3) { //倒放
        if (animationFilter.streamEndTime == [self.player getDuration]) {
            // 倒放时的边界条件的判断
            filterItem.startTime = 0;
            filterItem.endTime = animationFilter.streamStartTime;
        } else {
            filterItem.startTime = animationFilter.streamEndTime;
            filterItem.endTime = animationFilter.streamStartTime;
        }
    } else {
        filterItem.startTime = animationFilter.streamStartTime;
        filterItem.endTime = animationFilter.streamEndTime;
    }
    NSLog(@"特效结束时间%f--%f", filterItem.startTime, filterItem.endTime);
    
    filterItem.displayColor = [self generateColor];
    filterItem.obj = animationFilter;
    [self.currentTimelineView addTimelineFilterItem:filterItem];
}

- (void)updateAnimationFilterToTimeline:(AliyunEffectFilter *)animationFilter {
    if (_processAnimationFilterItem == NULL) {
        _processAnimationFilterItem = [[AliyunTimelineFilterItem alloc] init];
    }
    
    if ([self.editor getTimeFilter] == 3) { //倒放
        _processAnimationFilterItem.startTime = animationFilter.streamStartTime;
        _processAnimationFilterItem.endTime = animationFilter.streamEndTime;
        
    } else {
        _processAnimationFilterItem.startTime = animationFilter.streamStartTime;
        
        _processAnimationFilterItem.endTime = animationFilter.streamEndTime;
    }
    _processAnimationFilterItem.displayColor =
    [self generateColor];
    
    [self.currentTimelineView updateTimelineFilterItems:_processAnimationFilterItem];
}

- (void)removeAnimationFilterFromTimeline:(AliyunTimelineFilterItem *)animationFilterItem {
    [self.currentTimelineView removeTimelineFilterItem:animationFilterItem];
}

- (void)removeLastAnimtionFilterItemFromTimeLineView {
    [self.currentTimelineView removeLastFilterItemFromTimeline];
}

- (void)addPasterToTimeline:(AliyunPasterController *)pasterController {
    AliyunTimelineItem *timeline = [[AliyunTimelineItem alloc] init];
    timeline.startTime = pasterController.pasterStartTime;
    timeline.endTime = pasterController.pasterEndTime;
    timeline.obj = pasterController;
    timeline.minDuration = pasterController.pasterMinDuration;
    if (pasterController.pasterType == AliyunPasterEffectTypeNormal) {
        [self.pasterShowView.timeLineView addTimelineItem:timeline];
    } else {
        [self.captionShowView.timeLineView addTimelineItem:timeline];
    }
}

- (void)removePasterFromTimeline:(AliyunPasterController *)pasterController {
    if (pasterController.pasterType == AliyunPasterEffectTypeNormal) {
        AliyunTimelineItem *timeline = [self.pasterShowView.timeLineView getTimelineItemWithOjb:pasterController];
        [self.pasterShowView.timeLineView removeTimelineItem:timeline];
    } else {
        AliyunTimelineItem *timeline = [self.captionShowView.timeLineView getTimelineItemWithOjb:pasterController];
        [self.captionShowView.timeLineView removeTimelineItem:timeline];
    }
}

- (void)editPasterItemBy:(AliyunPasterController *)pasterController {
    AliyunTimelineItem *timeline =
    [self.currentTimelineView getTimelineItemWithOjb:pasterController];
    if (pasterController.pasterType == AliyunPasterEffectTypeNormal) {
        [self.pasterShowView.timeLineView editTimelineItem:timeline];
    } else {
        [self.captionShowView.timeLineView editTimelineItem:timeline];
    }
}

- (void)editPasterItemComplete {
    [self.currentTimelineView editTimelineComplete];
}

//TODO 添加特效后，颜色需调整，待与产品沟通
- (UIColor *)generateColor{
    int idx = self.animationFilters.count%5;
    UIColor *color = nil;
    switch (idx) {
        case 0:
            color = [UIColor colorWithRed:254.0 / 255
            green:160.0 / 255
             blue:29.0 / 255
                                    alpha:0.9];
            break;
        case 1:
            color = [UIColor colorWithRed:98.0 / 255
            green:182.0 / 255
             blue:254.0 / 255
            alpha:0.9];
            break;
        case 2:
            color = [UIColor colorWithRed:220.0 / 255
            green:92.0 / 255
             blue:179.0 / 255
            alpha:0.9];
            break;
        case 3:
            color = [UIColor colorWithRed:243.0 / 255
            green:92.0 / 255
             blue:75.0 / 255
            alpha:0.9];
            break;
        case 4:
            color = [UIColor colorWithRed:251.0 / 255
            green:222.0 / 255
             blue:56.0 / 255
            alpha:0.9];
            break;
        default:
            color = [UIColor colorWithRed:243.0 / 255
            green:92.0 / 255
             blue:175.0 / 255
            alpha:0.9];
            break;
    }
    return color;
}

#pragma mark - AliyunPasterManagerDelegate -
//某个动图即将被删除
- (void)pasterManagerWillDeletePasterController:(AliyunPasterController *)pasterController {
    [self removePasterFromTimeline:pasterController]; //与timelineView联动
}

#pragma mark - AliyunTimelineViewDelegate -
//动图效果开始时间、结束时间调整
- (void)timelineDraggingTimelineItem:(AliyunTimelineItem *)item {
    NSLog(@"timelineDraggingTimelineItem");
    [[self.pasterManager getAllPasterControllers] enumerateObjectsUsingBlock:^(AliyunPasterController *pasterController, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([pasterController isEqual:item.obj]) {
            pasterController.pasterStartTime = item.startTime;
            pasterController.pasterEndTime = item.endTime;
            pasterController.pasterMinDuration = item.endTime - item.startTime;
            pasterController.pasterDuration = item.endTime - item.startTime;
            *stop = YES;
        }
    }];
}

//时间轴拖动事件
- (void)timelineBeginDragging {
    
    [self forceFinishLastEditPasterView];
    //    NSLog(@"timelineBeginDragging");
    self.userAction = AliyunEditUserEvent_Effect_Slider;
}

- (void)timelineDraggingAtTime:(CGFloat)time {
    [self.player seek:time];
    self.currentTimeLabel.text = [self stringFromTimeInterval:time];
    NSLog(@"短视频编辑播放器测试::预览视图更新%.2f",time);
    [self updateUIAndDataWhenPlayStatusChanged];
}

- (void)timelineEndDraggingAndDecelerate:(CGFloat)time {
    _isEidtTuchAction = NO;
    
    [self.player seek:time];
    if (_prePlaying) {
        [self resume];
    }
    //    NSLog(@"短视频编辑播放器测试:结束滑动预览视图更新%.2f",time);
    self.userAction = AliyunEditUserEvent_None;
}

- (void)timelineEditDraggingAtTime:(CGFloat)time {
    _isEidtTuchAction = YES;
    [self.player seek:time];
    //    NSLog(@"timelineEditDraggingAtTime");
}

#pragma mark - AliyunPasterViewActionTarget -
- (void)oneClick:(id)obj {
    //    [self p_presentBackgroundButton];
    AliyunPasterView *pasterView = (AliyunPasterView *)obj;
    AliyunPasterController *pasterController =
    (AliyunPasterController *)pasterView.delegate;
    [pasterController editDidStart];
    _currentEditPasterType = pasterController.pasterType;
    
    int maxCharacterCount = 0;
    if (pasterController.pasterType == AliyunPasterEffectTypeCaption) {
        maxCharacterCount = 20;
    }else if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle){
        maxCharacterCount = 180;//跟安卓统一为90个字 180字节
    }
    AliyunPasterTextInputView *inputView = [AliyunPasterTextInputView
                                            createPasterTextInputViewWithText:[pasterController subtitle]
                                            textColor:pasterView.textColor
                                            fontName:pasterView.textFontName
                                            maxCharacterCount:maxCharacterCount];
    NSLog(@"~~~~~~>createPasterTextInputViewWithText:%@",pasterView.textFontName);
    inputView.maxWidth = CGRectGetWidth(self.movieView.bounds);
    [inputView viewFit];
    [self.view addSubview:inputView];
    inputView.delegate = (id)self;
    inputView.center = CGPointMake(CGRectGetMidX(self.view.bounds),
                                   CGRectGetMidY(self.view.bounds) - 50);
    [inputView setTextAnimationType:pasterController.tempActionType];
    _currentTextInputView = inputView;
}

//删除动图
- (void)deleteEndPaster {
    self.editZoneView.currentPasterView.editStatus = NO;
    self.editZoneView.currentPasterView = nil;
}

- (void)clickAnimation {
    NSLog(@"点击了动画按钮");
    NSArray *tabItems =  @[
               @(TabBarItemTypePasterAnimation)
           ];
    CGFloat hieght = 216;
    
    AliyunPasterController *editPasterController =
         (AliyunPasterController *)self.editZoneView.currentPasterView.delegate;
    [self.tabController setFontEffectDefault:editPasterController.tempActionType];
    
    [self.tabController presentTabContainerViewInSuperView:self.view
                                                    height:hieght
                                                  duration:0.2
                                                  tabItems:tabItems];
  
    
    
}
#pragma mark - AliyunEditZoneViewDelegate -
// EditZoneView的点击事件
- (void)currentTouchPoint:(CGPoint)point {
    if (_vcStatus == AlivcEditVCStatus_Normal) {
        return;
    }
    if (self.editZoneView
        .currentPasterView) { //如果当前有正在编辑的动图，且点击的位置正好在动图上
        BOOL hitSubview =[self.editZoneView.currentPasterView touchPoint:point
                                                                fromView:self.editZoneView];
        if (hitSubview == YES) {
            return;
        }
    }
    AliyunPasterController *pasterController =
    [self.pasterManager touchPoint:point
                            atTime:[self.player getCurrentStreamTime]];
    
    if (pasterController) { //如果当前点击位置上存在一个动图
        if (_editSouceClickType != AliyunEditSouceClickTypePaster &&
            _editSouceClickType != AliyunEditSouceClickTypeCaption) {
            return; //不是动图和字幕不响应点击事件
        }
        if (pasterController.pasterType == AliyunPasterEffectTypeNormal &&
            _editSouceClickType != AliyunEditSouceClickTypePaster) {
            //当前是字幕的编辑状态，点击到的是动图，不响应点击事件
            return;
        } else if ((pasterController.pasterType == AliyunPasterEffectTypeCaption ||
                    pasterController.pasterType == AliyunPasterEffectTypeSubtitle) &&
                   _editSouceClickType != AliyunEditSouceClickTypeCaption) {
            //当前是动图的编辑状态，点击到的是字幕，不响应点击事件
            return;
        }
        [self pause];
        AliyunPasterView *pasterView =(AliyunPasterView *)[pasterController pasterView];
        if (pasterView) { //当前点击的位置有动图
            //逻辑：将上次有编辑的动图完成，让该次选择的动图进入编辑状态
            [self forceFinishLastEditPasterView];
            [self makePasterControllerBecomeEditStatus:pasterController];
        }
        //动图进入编辑状态，停止缩略图的滑动
        [self.currentTimelineView stopSlid];
    } else { //如果当前点击位置上不存在动图
        self.editZoneView.currentPasterView.editStatus = NO;
        [self forceFinishLastEditPasterView];
    }
}

//强制将上次正在编辑的动图进入编辑完成状态 - cm
- (void)forceFinishLastEditPasterView {
   
    if (!self.editZoneView.currentPasterView) {
        return;
    }
    
    [self.tabController dismissPresentTabContainerView];
    
    AliyunPasterController *editPasterController =
    (AliyunPasterController *)self.editZoneView.currentPasterView.delegate;
    self.editZoneView.currentPasterView.editStatus = NO;
    if (editPasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
        [editPasterController
         editCompletedWithImage:[self.editZoneView.currentPasterView textImage]];
        [self animateWithObject:editPasterController animation:[editPasterController tempActionType]];
    } else if (editPasterController.pasterType == AliyunPasterEffectTypeNormal) {
       
        [editPasterController editCompleted];
         [self animateWithObject:editPasterController animation:[editPasterController tempActionType]];
    } else {
        [editPasterController
         editCompletedWithImage:[self.editZoneView.currentPasterView textImage]];
        [self animateWithObject:editPasterController animation:[editPasterController tempActionType]];
    }
    [self editPasterItemComplete];
    self.editZoneView.currentPasterView = nil;
    // 产品要求 动图需要一直放在涂鸦下面，所以每次加新动图，需要重新加一次涂鸦
    if (self.paintImage) {
        [self.editor removePaint:self.paintImage];
        [self.editor applyPaint:self.paintImage];
    }
}

- (void)mv:(CGPoint)fp to:(CGPoint)tp {
    if (self.editZoneView.currentPasterView) {
        [self.editZoneView.currentPasterView touchMoveFromPoint:fp to:tp];
    }
}

- (void)touchEnd {
    if (self.editZoneView.currentPasterView) {
        [self.editZoneView.currentPasterView touchEnd];
    }
}

#pragma mark - AliyunTabControllerDelegate -
- (void)completeButtonClicked {
    [self.editZoneView setEditStatus:YES];
    self.playButton.enabled = YES;
    if (_currentTextInputView) {
        [_currentTextInputView shouldHiddenKeyboard];
        if (_currentEditPasterType == AliyunPasterEffectTypeSubtitle &&
            [_currentTextInputView getText].length <= 0) { //如果是纯文字模式，并且文字输入为空的情况下直接销毁输入框
            [self destroyInputView];
        } else {
            [self textInputViewEditCompleted];
        }
    }
}

- (void)pasterActionCompleteButtonClicked:(TextActionType)actionType {
    
    AliyunPasterController *editPasterController =
    (AliyunPasterController *)self.editZoneView.currentPasterView.delegate;
    
    [editPasterController setTempActionType:actionType];
    
}

- (void)cancelButtonClicked {
    [self.editZoneView setEditStatus:YES];
    self.playButton.enabled = YES;
    [_currentTextInputView shouldHiddenKeyboard];
    [self destroyInputView];
    //    if (_currentEditPasterType == AliyunPasterEffectTypeCaption)
    //    {//如果是字幕气泡
    AliyunPasterController *editPasterController = [self.pasterManager getCurrentEditPasterController];
    if(editPasterController) {
        [self makePasterControllerBecomeEditStatus:editPasterController];
    }
    //    }
}

- (void)keyboardShouldHidden {
    [_currentTextInputView shouldHiddenKeyboard];
}

- (void)keyboardShouldAppear {
    [_currentTextInputView shouldAppearKeyboard];
}

- (void)textColorChanged:(AliyunColor *)color {
    [_currentTextInputView setFilterTextColor:color];
}

- (void)textFontChanged:(NSString *)fontName {
    [_currentTextInputView setFontName:fontName];
}

//字体动画切换
- (void)textActionType:(TextActionType)actionType {
    if ([self.editor getTimeFilter] != 3 || actionType == TextActionTypeNull ||
        actionType == TextActionTypeClear) { //倒播
        [_currentTextInputView setTextAnimationType:actionType];
    } else {
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
        //        message:@"倒播时不支持添加字幕动画效果" delegate:nil
        //        cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]; [alert show];
        [MBProgressHUD showMessage:NSLocalizedString(@"倒播时不支持添加字幕动画效果", nil) inView:self.view];
    }
}

- (void)textStrokeColorClear {
    [_currentTextInputView removeStrokeColor];
}

#pragma mark - AliyunPasterTextInputViewDelegate -

- (void)keyboardFrameChanged:(CGRect)rect animateDuration:(CGFloat)duration {
    NSArray *tabItems;
    if (self.currentEditPasterType == AliyunPasterEffectTypeSubtitle) {
        tabItems = @[
            @(TabBarItemTypeKeboard), @(TabBarItemTypeColor), @(TabBarItemTypeFont),
            @(TabBarItemTypeAnimation)
        ];
    } else {
        tabItems = @[
            @(TabBarItemTypeKeboard), @(TabBarItemTypeColor), @(TabBarItemTypeFont),@(TabBarItemTypeAnimation)
        ];
    }
    CGFloat hieght = rect.size.height;
    hieght = (hieght < 216 ? 216 : hieght);
    [self.tabController presentTabContainerViewInSuperView:self.view
                                                    height:hieght
                                                  duration:duration
                                                  tabItems:tabItems];
//    if (self.currentEditPasterType == AliyunPasterEffectTypeSubtitle) {
        
        //        NSInteger actionType = [self.alivcPasterManager getAlivcSubtitleAnimateTypeWithPasterController:[self.pasterManager getCurrentEditPasterController]];
        AliyunPasterController *pasterController =  [self.pasterManager getCurrentEditPasterController];
        NSInteger actionType = [pasterController tempActionType];
        NSLog(@"%ld==========%ld",(long)pasterController.actionType,pasterController.tempActionType);
        actionType = (actionType < 0 ? 0 : actionType);
        [self.tabController setFontEffectDefault:actionType];
//    }
    [self.editZoneView setEditStatus:NO];
    self.playButton.enabled = NO;
}

- (void)editWillFinish:(CGRect)inputviewFrame
                  text:(NSString *)text
              fontName:(NSString *)fontName {
    //    [self backgroundTouchButtonClicked:nil];
    [self textInputViewEditCompleted];
}

#pragma mark - 底部视图响应以及各视图代理

#pragma mark - AliyunEditButtonsViewDelegate - 底部容器视图

//滤镜
- (void)filterButtonClicked:(AliyunEditMaterialType)type {
    [self enterEditWithActionType:AliyunEditSouceClickTypeFilter animationCompletion:nil];
    
    if (!self.hasUesedintelligentFilter) {
        self.hasUesedintelligentFilter = YES;
        if (self.intelligentFilter) {
            AliyunEffectFilter *filter = [[AliyunEffectFilter alloc]
                                          initWithFile:[self.intelligentFilter localFilterResourcePath]];
            [self.editor applyFilter:filter];
            [self.filterView updateSelectedFilter:self.intelligentFilter];
            NSString *message = [NSString stringWithFormat:@"%@%@%@",[@"已为你智能推荐" localString],self.intelligentFilter.filterTypeName,[@"滤镜" localString]];
            [MBProgressHUD showMessage:message  inView:self.view];
        }
    }
}

//音乐
- (void)musicButtonClicked {
    
    if (self.isMixedVideo) {
        [MBProgressHUD showMessage:[@"合拍视频无法添加背景音乐" localString]  inView:self.view];
        return;
    }
    AliyunMusicPickViewController *vc =
    [[AliyunMusicPickViewController alloc] init];
    vc.duration = [self.player getDuration];
    [vc setSelectedMusic: self.music type:self.tab];
    vc.delegate = self;
    [self.navigationController pushViewController:vc animated:YES];
}

//动图
- (void)pasterButtonClicked {
    self.currentTimelineView = self.pasterShowView.timeLineView;
    _currentEditPasterType = AliyunPasterEffectTypeNormal;
    [self enterEditWithActionType:AliyunEditSouceClickTypePaster
              animationCompletion:nil];
    [self.pasterShowView fetchPasterGroupDataWithCurrentShowGroup:nil];
    
}

//字幕
- (void)subtitleButtonClicked {
    self.currentTimelineView = self.captionShowView.timeLineView;
    _currentEditPasterType = AliyunPasterEffectTypeCaption;
    [self enterEditWithActionType:AliyunEditSouceClickTypeCaption
              animationCompletion:nil];
    [self.captionShowView fetchCaptionGroupDataWithCurrentShowGroup:nil];
}

// mv
- (void)mvButtonClicked:(AliyunEditMaterialType)type {
    [self enterEditWithActionType:AliyunEditSouceClickTypeMV animationCompletion:nil];
    [self.mvView reloadDataWithEffectType:type];
}

-(void)soundButtonClicked{
    if (self.hasRecordMusic) {
        [MBProgressHUD showMessage:[@"没有原音，无法添加音效" localString] inView:self.view];
        NSLog(@"音效-->没有原音，无法添加音效");
    }else{
        [self enterEditWithActionType:AliyunEditSouceClickTypeEffectSound animationCompletion:nil];
        NSLog(@"音效");
    }
    
}

//特效
- (void)effectButtonClicked {
    self.currentTimelineView = self.specialFilterView.timelineView;
    [self enterEditWithActionType:AliyunEditSouceClickTypeEffect
              animationCompletion:nil];
}

//时间特效
- (void)timeButtonClicked {
    AliyunClip *clip = self.clipConstructor.mediaClips[0];
    if (self.clipConstructor.mediaClips.count > 1 || clip.mediaType == 1) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.mode = MBProgressHUDModeText;
        hud.label.text = [@"多段视频或图片不支持时间特效" localString];
        hud.backgroundView.style = MBProgressHUDBackgroundStyleSolidColor;
        hud.bezelView.color = rgba(0, 0, 0, 0.7);
        hud.label.textColor = [UIColor whiteColor];
        hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
        [hud hideAnimated:YES afterDelay:1.5f];
        return;
    }
    self.currentTimelineView = self.timeFilterView.timelineView;
    [self enterEditWithActionType:AliyunEditSouceClickTypeTimeFilter animationCompletion:nil];
}

//转场
- (void)translationButtonCliked {
    if ([self.clipConstructor mediaClips].count < 2) {
        [MBProgressHUD showMessage:[@"一段视频无法添加转场" localString] inView:self.view];
        return;
    }
    
    if (!self.transitionRetention.isFirstEdit) {
        //如果不是第一次编辑转场则获取上次转场状态
        NSMutableArray *copyIcons = [[NSMutableArray alloc]
                                     initWithArray:_transitionRetention.transitionIcons
                                     copyItems:YES];
        
        NSMutableArray *copyCovers = [[NSMutableArray alloc]
                                      initWithArray:_transitionRetention.transitionCovers
                                      copyItems:YES];
        [self.transitionView setIcons:copyIcons];
        [self.transitionView setCovers:copyCovers];
        //分组选择器idex
        [self.transitionView updateGroupSelector];
    }
    [self enterEditWithActionType:AliyunEditSouceClickTypeTranslation
              animationCompletion:nil];
}

//涂鸦
- (void)paintButtonClicked {
    [self.editor removePaint:self.paintImage];
    __weak typeof(self) weakSelf = self;
    [self enterEditWithActionType:AliyunEditSouceClickTypePaint animationCompletion:^(BOOL finished) {
        if (finished) {
            weakSelf.pasterManager.displaySize =     weakSelf.editZoneView.bounds.size;
            if (weakSelf.paintView) {
                weakSelf.paintView.frame = weakSelf.editZoneView.bounds;
            }
            [weakSelf.editZoneView addSubview:weakSelf.paintView]; //添加画布
        }
    }];
    [self updateDrawRect:self.movieView.frame];
}


//封面选择
- (void)coverButtonClicked {
    self.playButton.hidden = YES;
    self.currentTimelineView = self.coverSelectedView.timelineView;
    [self enterEditWithActionType:AliyunEditSouceClickTypeCover
              animationCompletion:^(BOOL finished){
        
    }];
}

#pragma mark - AliyunEffectFilter2ViewDelegate - 滤镜

- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter {
    AliyunEffectFilter *filter2 = [[AliyunEffectFilter alloc]
                                   initWithFile:[filter localFilterResourcePath]];
    [self.editor applyFilter:filter2];
}
#pragma mark - AliyunEffectFilterViewDelegate - MV
- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup {
    NSString *str = [mvGroup localResoucePathWithVideoRatio:(AliyunEffectMVRatio)[_config mediaRatio]];
    [self pause];
    [self.editor removeMusics];
    [self.editor applyMV:[[AliyunEffectMV alloc] initWithFile:str]];
    
    self.mvGroup = mvGroup;
    
    if (!mvGroup) {
        //如果之前存在音乐的，播放此音乐
        if (![self.music.name isEqualToString:NSLocalizedString(@"无音乐" , nil)] && self.music.path) {
            [self didSelectMusic:self.music tab:self.tab];
        }else{
            //如果录制的时候选择了音乐 播放的时候 没有选择mv 则播放原来的音乐
            if(self.hasRecordMusic) {
                [self.editor setAudioMixWeight:0];
            }
        }
    }else{
        //如果录制的时候选择了音乐 播放的时候 选择mv 则播放mv的音乐
        if (self.hasRecordMusic) {
            [self.editor setAudioMixWeight:100];
        }
    }
    
    //如果是合拍 不播放mv音乐
    if (self.isMixedVideo) {
        [self.editor setAudioMixWeight:0];
    }
    [self play];
}

// 删除正在播放的MV时调用
- (void)didSelectEffectMVNone {
    
    [self.editor removeMusics];
    [self.editor applyMV:[[AliyunEffectMV alloc] initWithFile:nil]];
    self.mvGroup = nil;
    //如果之前存在音乐的，播放原来的音乐
    if (![self.music.name isEqualToString:NSLocalizedString(@"无音乐" , nil)] && self.music.path) {
        [self didSelectMusic:self.music tab:self.tab];
    }
}
- (void)didSelectEffectMoreMv {
    __weak typeof(self) weakSelf = self;
    [self presentAliyunEffectMoreControllerWithAliyunEffectType:AliyunEffectTypeMV completion:^(AliyunEffectInfo *selectEffect) {
        if (selectEffect) {
            weakSelf.mvView.selectedEffect = selectEffect;
        }
        [weakSelf.mvView reloadDataWithEffectType:AliyunEffectTypeMV];
    }];
}
#pragma mark - AlivcSpecialEffectViewDelegate
/**
 应用滤镜特效的效果
 */
- (void)applyButtonClick {
    
    [self.storeAnimationFilters removeAllObjects];
    self.storeAnimationFilters = [self.animationFilters mutableCopy];
    [self apply];
}

/**
 取消滤镜特效的效果
 */
- (void)noApplyButtonClick {
    [self cancel];
    if (_editSouceClickType == AliyunEditSouceClickTypeEffect) {
        for (int i = 0; i < self.animationFilters.count; i++) {
            int res = [self.editor removeAnimationFilter:self.animationFilters[i]];
            NSLog(@"------->点叉，删除：%d",res);
        }
        [self.animationFilters removeAllObjects];
        [self.currentTimelineView removeAllFilterItemFromTimeline];
        
        for (int i = 0; i < self.storeAnimationFilters.count; i++) {
            AliyunEffectFilter *filter = self.storeAnimationFilters[i];
//            AliyunEffectFilter *newFilter =[[AliyunEffectFilter alloc] initWithFile:filter.path];
//            newFilter.effectConfig = filter.effectConfig;
//            newFilter.streamEndTime = filter.streamEndTime;
//            newFilter.streamStartTime = filter.streamStartTime;
//            newFilter.startTime = filter.startTime;
//            newFilter.endTime = filter.endTime;
            [self.editor applyAnimationFilter:filter];
            [self addAnimationFilterToTimeline:filter];
            [self.animationFilters addObject:filter];
        }
        [self.storeAnimationFilters removeAllObjects];
        self.storeAnimationFilters = [self.animationFilters mutableCopy];
    }
}

//长按开始时，由于结束时间未定，先将结束时间设置为较长的时间
//!!!注意这里的实现方式!!!
- (void)didBeganLongPressEffectFilter:(AliyunEffectFilterInfo *)animtinoFilterInfo {
    if (self.userAction == AliyunEditUserEvent_Effect_Slider) {
        return;
    }
    self.userAction = AliyunEditUserEvent_Effect_LongPress;
    self.currentTimelineView.userInteractionEnabled = NO;
    
    float currentSec = [self.player getCurrentTime];
    float currentStreamSec = [self.player getCurrentStreamTime];
    
    AliyunEffectFilter *preFilter = [self.animationFilters lastObject];
    if (fabsf(currentSec - preFilter.endTime) < 0.2) {
        currentSec = preFilter.endTime;
    }
    
    if (fabsf(currentStreamSec - preFilter.streamEndTime) < 0.2) {
        currentStreamSec = preFilter.streamEndTime;
    }
    
    if (currentStreamSec == [self.player getStreamDuration]) {
        currentStreamSec = currentStreamSec - 0.001;
    }
    
    if (!_prePlaying) {
        [self resume];
    }
    
    float videoDuration = [self.player getDuration];
    if ([self.editor getTimeFilter] != 3 && currentSec >= videoDuration) {
        currentSec = 0;
        currentStreamSec = 0;
    }
    AliyunEffectFilter *animationFilter = [[AliyunEffectFilter alloc] initWithFile:[animtinoFilterInfo localFilterResourcePath]];
    if (_curEffect &&_curEffect.effectConfig) {
        animationFilter.effectConfig = [_curEffect.effectConfig copy];
    }
    animationFilter.startTime = currentSec;
    animationFilter.endTime = [self.player getDuration];
    animationFilter.streamStartTime = currentStreamSec;
    if ([self.editor getTimeFilter] == 3) {
        if (animationFilter.streamStartTime == 0) {
            currentStreamSec = [self.player getDuration];
            currentSec = 0;
            animationFilter.startTime = currentSec;
            animationFilter.streamStartTime = [self.player getStreamDuration] - 0.01;
        }
        animationFilter.streamEndTime = 0;
        
    } else {
        animationFilter.streamEndTime = [self.player getStreamDuration];
    }
    
    [self.animationFilters addObject:animationFilter];
    int a = [self.editor applyAnimationFilter:animationFilter];
    
    _processAnimationFilter = [[AliyunEffectFilter alloc]initWithFile:[animtinoFilterInfo localFilterResourcePath]];
    _processAnimationFilter.startTime = currentSec;
    _processAnimationFilter.endTime = currentSec;
    _processAnimationFilter.streamStartTime = currentStreamSec;
    _processAnimationFilter.streamEndTime = currentStreamSec;
    if (_curEffect &&_curEffect.effectConfig) {
        _processAnimationFilter.effectConfig = [_curEffect.effectConfig copy];
    }

    [self updateAnimationFilterToTimeline:_processAnimationFilter];
    NSLog(@"长按开始时间：%f--%f--%f--%f--%d", animationFilter.startTime, animationFilter.endTime, animationFilter.streamStartTime, animationFilter.streamEndTime, a);
    
}

//手势结束后，将当前正在编辑的特效滤镜删掉，重新加一个
//这时动效滤镜的开始和结束时间都确定了
- (void)didEndLongPress {
    
    self.userAction = AliyunEditUserEvent_None;
    self.currentTimelineView.userInteractionEnabled = YES;
    
    if (_processAnimationFilter == NULL) { //当前没有正在添加的动效滤镜 则不操作
        return;
    }
    float pendTime = _processAnimationFilter.endTime;
    float psEndTime = _processAnimationFilter.streamEndTime;
    float pStartTime = _processAnimationFilter.startTime;
    float psStartTime = _processAnimationFilter.streamStartTime;
    [self pause];
    [self removeAnimationFilterFromTimeline:_processAnimationFilterItem];
    _processAnimationFilterItem = NULL;
    _processAnimationFilter = NULL;
    
    AliyunEffectFilter *currentFilter = [self.animationFilters lastObject];
    if (!currentFilter) {
        return;
    }
    
    if ([self.editor getTimeFilter] == 3) { //倒放
        currentFilter.startTime = psEndTime;
        currentFilter.streamStartTime = psStartTime;
        currentFilter.streamEndTime = psEndTime;
        currentFilter.endTime = psStartTime;
        
    } else {
        currentFilter.endTime = pendTime;
        currentFilter.streamEndTime = psEndTime;
        currentFilter.streamStartTime = psStartTime;
        currentFilter.startTime = pStartTime;
    }
    // 更新缩略图
    [self addAnimationFilterToTimeline:currentFilter];
    // 更新特效效果
    [self.editor updateAnimationFilter:currentFilter];
    
    NSLog(@"长按结束时间：%f--%f--%f--%f", pStartTime, pendTime, psStartTime, psEndTime);
}

- (void)didRevokeButtonClick {
    if (self.animationFilters.count) {
        AliyunEffectFilter *currentFilter = [self.animationFilters lastObject];
        // 特效回删 , 光标和画面回到光标起点
        [self.currentTimelineView seekToTime:currentFilter.streamStartTime];
        [self.player seek:currentFilter.streamStartTime];
        self.currentTimeLabel.text =[self stringFromTimeInterval:currentFilter.streamStartTime];
        
        int res =[self.editor removeAnimationFilter:currentFilter];
        NSLog(@"------------->res:%d",res);
        [self.animationFilters removeLastObject];
        // TODO:这里删除
        [self removeLastAnimtionFilterItemFromTimeLineView];
        [self updateUIAndDataWhenPlayStatusChanged];
    }
}

//长按进行时 更新
- (void)didTouchingProgress {
    
    if (_processAnimationFilter) {
        if ([self.editor getTimeFilter] == 3) { //倒放
            _processAnimationFilter.endTime = [self.player getCurrentTime];
            _processAnimationFilter.streamEndTime = [self.player getCurrentStreamTime];
            NSLog(@"长按倒放进行中:%f,%f", _processAnimationFilter.startTime, _processAnimationFilter.endTime);
            //            if (_processAnimationFilter.endTime <
            //            _processAnimationFilter.startTime) {
            //                NSLog(@"长按倒放结束时间小于开始时间，数据异常");
            //                return;
            //            }
            [self updateAnimationFilterToTimeline:_processAnimationFilter];
        } else {
            // new
            _processAnimationFilter.endTime = [self.player getCurrentTime];
            _processAnimationFilter.streamEndTime =[self.player getCurrentStreamTime];
            NSLog(@"长按进行中:%f,%f", _processAnimationFilter.startTime, _processAnimationFilter.endTime);
            if (_processAnimationFilter.endTime < _processAnimationFilter.startTime ||
                _processAnimationFilter.endTime > [self.player getDuration]) {
                NSLog(@"长按结束时间小于开始时间，数据异常");
                return;
            }
            [self updateAnimationFilterToTimeline:_processAnimationFilter];
        }
    }
}

- (void)didShowMore {
    __weak typeof(self) weakSelf = self;
    [self presentAliyunEffectMoreControllerWithAliyunEffectType: AliyunEffectTypeSpecialFilter completion:^(AliyunEffectInfo *selectEffect) {
        [weakSelf.specialFilterView fetchEffectGroupDataWithCurrentShowGroup:selectEffect];
    }];
}

-(void)didShowRegulatorView:(AliyunEffectFilterInfo *)animtinoFilterInfo isEnable:(BOOL)isEnable{
    _curEffect = nil;
    AliyunEffectFilter *animationFilter = [[AliyunEffectFilter alloc] initWithFile:[animtinoFilterInfo localFilterResourcePath]];
    
    //添加调节器显示
    NSArray *paramList = [AlivcRegulatorView getSliderParams:animationFilter.effectConfig];
    if (paramList.count>0) {
        //显示参数调节器
        [self.specialFilterView showRegulatorView:animationFilter paramList:paramList isEnable:isEnable];
    }else{
        [self.specialFilterView showRegulatorView:nil paramList:nil isEnable:isEnable];
    }
}

-(void)clearEffectByPath:(NSString*)path{
    for (int i=0;i<self.animationFilters.count;i++) {
        AliyunEffectFilter *filter = [self.animationFilters objectAtIndex:i];
        if ([filter.path containsString:path]) {
            int res =[self.editor removeAnimationFilter:filter];
           [self.animationFilters removeObject:filter];
            i--;
        }
    }
    
    //清除已经缓存特效
    for (int i=0;i<self.storeAnimationFilters.count;i++) {
        AliyunEffectFilter *filter = [self.storeAnimationFilters objectAtIndex:i];
        if ([filter.path containsString:path]) {
           [self.storeAnimationFilters removeObject:filter];
            i--;
        }
    }

    [self.specialFilterView.timelineView removeFilterItemFormTimelineBy:path];
    [self updateUIAndDataWhenPlayStatusChanged];
}

#pragma mark - AliyunMusicPickViewControllerDelegate - 音乐 新

- (void)didSelectMusic:(AliyunMusicPickModel *)music tab:(NSInteger)tab {
    if ([music.name isEqualToString:NSLocalizedString(@"无音乐" , nil)] || !music.path) {
        [self.editor removeMusics];
        //无音乐就是静音
        if (self.hasRecordMusic) {
            [self.editor setAudioMixWeight:100];
        }
        //尝试播放之前的mv
        if (self.mvGroup) {
            dispatch_after(
                           dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)),
                           dispatch_get_main_queue(), ^{
                [self didSelectEffectMV:self.mvGroup];
            });
        }
    } else {
        //如果录制的时候有音乐 编辑的时候重新音乐 则播放新的音乐
        if (self.hasRecordMusic) {
            [self.editor setAudioMixWeight:100];
            //            [self.editor setMainStreamsAudioWeight:0];
        }
        if (self.mvGroup) {
            NSString *str = [self.mvGroup localResoucePathWithVideoRatio:(AliyunEffectMVRatio)[_config mediaRatio]];
            [self pause];
            [self.editor removeMusics];
            AliyunEffectMV *mv = [[AliyunEffectMV alloc] initWithFile:str];
            mv.disableAudio = YES;
            [self.editor applyMV:mv];
            [self play];
        }
        [self.editor removeMusics];
        AliyunEffectMusic *effectMusic =[[AliyunEffectMusic alloc] initWithFile:music.path];
        effectMusic.startTime = music.startTime * 0.001;
        effectMusic.duration = music.duration;
        [self.editor applyMusic:effectMusic];
    }
    self.music = music;
    self.tab = tab;
    [self resume];
}

- (void)didCancelPick {
    //    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - AliyunEffectMusicViewDelegate - 音乐

- (void)musicViewDidUpdateMute:(BOOL)mute {
    [self.editor setMute:mute];
}

- (void)musicViewDidUpdateAudioMixWeight:(float)weight {
    [self.editor setAudioMixWeight:weight * 100];
}

- (void)musicViewDidUpdateMusic:(NSString *)path
                      startTime:(CGFloat)startTime
                       duration:(CGFloat)duration
                    streamStart:(CGFloat)streamStart
                 streamDuration:(CGFloat)streamDuration {
    AliyunEffectMusic *music = [[AliyunEffectMusic alloc] initWithFile:path];
    music.startTime = startTime;
    music.duration = duration;
    music.streamStartTime = streamStart * [_player getStreamDuration];
    music.streamDuration = streamDuration * [_player getStreamDuration];
    [self.editor removeMVMusic];
    [self.editor removeMusics];
    [self.editor applyMusic:music];
    [self resume];
    [self.playButton setSelected:NO];
}

#pragma mark - AliyunPasterShowViewDelegate - 贴图、字幕气泡
//选择一个贴图、字幕气泡
- (void)pasterBottomView:(AliyunPasterBottomBaseView *)bottomView didSelectedPasterModel:(AliyunEffectPasterInfo *)pasterInfo {
    if (self.userAction == AliyunEditUserEvent_Effect_Slider) {
        return;
    }
    //判断资源是否存在 config.json
    NSString *configJson = [NSString stringWithFormat:@"%@/%@/config.json",NSHomeDirectory(),pasterInfo.resourcePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:configJson]) {
        return;
    }
    
    AliyunPasterController *editPasterController =
    (AliyunPasterController *)self.editZoneView.currentPasterView.delegate;
    [self pause];
    
    //    动图在编辑状态下另外点击动图执行替换操作，else执行添加操作，业务需求
    BOOL editStaut = self.editZoneView.currentPasterView.editStatus;
    if (editStaut && editPasterController) {
        [self deletePasterController:editPasterController isEditing:YES];
    } else {
        [self forceFinishLastEditPasterView];
    }
    AliyunPasterRange range = [self calculatePasterStartTimeWithDuration:[pasterInfo defaultDuration]];
    AliyunPasterController *pasterController = [self.pasterManager addPaster:pasterInfo.resourcePath startTime:range.startTime
                                                                    duration:range.duration];
    pasterController.pasterMinDuration = range.duration;
    pasterController.pasterDuration = range.duration;
    self.currentEditPasterType = pasterController.pasterType;
    [self addPasterViewToDisplayAndRender:pasterController
                             pasterFontId:[pasterInfo.fontId integerValue]];
    [self addPasterToTimeline:pasterController];
    [self makePasterControllerBecomeEditStatus:pasterController];
    [self.currentPasterControllers addObject:pasterController];
    _lastPasterController = pasterController;
}
//贴图、字幕气泡取消
- (void)pasterBottomViewCancel:(AliyunPasterBottomBaseView *)bottomView {
    AliyunPasterController *editPasterController =
    (AliyunPasterController *)self.editZoneView.currentPasterView.delegate;
    //如果当前有正在编辑的动图则强制完成编辑
    if (editPasterController) {
        [self forceFinishLastEditPasterView];
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        NSArray *pasterArr = [self.pasterManager getAllPasterControllers];
        //倒序遍历删除本次操作类型的动图或者字幕，然后根据记录重新添加上次确认添加的动图或者字幕,由于目前SDK不支持撤销功能，所以暂时只能通过这种方式来实现本次操作的撤销功能
        __weak typeof(self) weakSelf = self;
        [pasterArr enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            AliyunPasterController *pasterVC = (AliyunPasterController *)obj;
            
            if ((pasterVC.pasterType == AliyunPasterEffectTypeNormal && weakSelf.currentEditPasterType == AliyunPasterTypeNormal)
                || (pasterVC.pasterType != AliyunPasterEffectTypeNormal && weakSelf.currentEditPasterType != AliyunPasterTypeNormal)) {
                [weakSelf.pasterManager removePasterController:pasterVC];
            }
        }];
        [self batchAddPasterWithPasterControllers:self.pasterInfoCopyArr]; //批量添加
        
        //恢复动画
        for (AliyunPasterController *pasterController in [self.pasterManager getAllPasterControllers]) {
//            if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
                [pasterController setActionType:pasterController.tempActionType];
                NSLog(@"%ld==========%ld",(long)pasterController.actionType,pasterController.tempActionType);
                [self animateWithObject:pasterController animation:pasterController.actionType];
//            }
        }
        [weakSelf.currentPasterControllers removeAllObjects];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
        });
    });
    
}
//批量添加贴图、字幕气泡
- (void)batchAddPasterWithPasterControllers:(NSMutableArray<AliyunPasterControllerCopy *> *)pasterInfo {
    for (AliyunPasterControllerCopy *pasterCopy in pasterInfo) { //只添加本次操作的类型
        if ((pasterCopy.pasterType == AliyunPasterEffectTypeNormal && _currentEditPasterType == AliyunPasterTypeNormal) ||
            (pasterCopy.pasterType != AliyunPasterEffectTypeNormal && _currentEditPasterType != AliyunPasterTypeNormal)) {
            double dutation = pasterCopy.pasterEndTime - pasterCopy.pasterStartTime;
            //检验即将添加的本地动图资源是否存在
            if (![self.alivcPasterManager checkResourceIsExistence:pasterCopy.resoucePath]) {
                //如果动图资源不存在，则不添加并且移除动图信息，跳出本次循环
                [pasterInfo removeObject:pasterCopy];
                break;
            }
            AliyunPasterController *pasterController = [self.pasterManager addPaster:pasterCopy.resoucePath startTime:pasterCopy.pasterStartTime duration:dutation];
            [pasterCopy setPropertysInPasterController:pasterController];
            dispatch_sync(dispatch_get_main_queue(), ^{
                [self addPasterViewToDisplayAndRenderWithCopyPasterController:pasterController pasterFontId:-2];
                [self addPasterToTimeline:pasterController];
                [self editPasterItemComplete];
                self.editZoneView.currentPasterView = nil;
            });
            
        }
    }
    // 产品要求 动图需要一直放在涂鸦下面，所以每次加新动图，需要重新加一次涂鸦
    if (self.paintImage) {
        [self.editor removePaint:self.paintImage];
        [self.editor applyPaint:self.paintImage];
    }
}
//贴图、字幕气泡确认
- (void)pasterBottomViewApply:(AliyunPasterBottomBaseView *)bottomView {
    [self forceFinishLastEditPasterView];
    //设置动画
    for (AliyunPasterController *pasterController in [self.pasterManager getAllPasterControllers]) {
        if (pasterController.pasterType == AliyunPasterEffectTypeSubtitle) {
            NSLog(@"%ld==========%ld",(long)pasterController.actionType,pasterController.tempActionType);
            [pasterController setActionType:pasterController.tempActionType];
            NSLog(@"%ld==========%ld",(long)pasterController.actionType,pasterController.tempActionType);
        }
    }
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
    //点击确认时保存本次添加的动图或者字幕气泡，用来实现下次进入编辑状态点击取消进行撤销逻辑
    [self copyPasterControllers:[self.pasterManager getAllPasterControllers]];
    [self.currentPasterControllers removeAllObjects];
    _lastPasterController = nil;
}
//深copy本次确认添加的动图
- (void)copyPasterControllers:(NSArray *)pasterControllers {
    [self.pasterInfoCopyArr removeAllObjects];
    for (AliyunPasterController *control in pasterControllers) {
        AliyunPasterControllerCopy *controlCopy =[[[AliyunPasterControllerCopy alloc] init] copyPropertysForPasterController:control];
        [self.pasterInfoCopyArr addObject:controlCopy];
        NSLog(@"%ld-----%ld",(long)controlCopy.actionType,(long)controlCopy.tempActionType);
    }
}
//更多
- (void)pasterBottomViewMore:(AliyunPasterBottomBaseView *)bottomView {
    [self forceFinishLastEditPasterView];
    __weak typeof(self) weakSelf = self;
    if (bottomView == self.pasterShowView) { //动画
        [self presentAliyunEffectMoreControllerWithAliyunEffectType:AliyunEffectTypePaster completion:^(AliyunEffectInfo *selectEffect) {
            [weakSelf.pasterShowView fetchPasterGroupDataWithCurrentShowGroup:(AliyunEffectPasterGroup *)selectEffect];
        }];
    } else if (bottomView == self.captionShowView) { //字幕贴图
        [self presentAliyunEffectMoreControllerWithAliyunEffectType: AliyunEffectTypeCaption completion:^(AliyunEffectInfo *selectEffect) {
            [weakSelf.captionShowView fetchCaptionGroupDataWithCurrentShowGroup:(AliyunEffectCaptionGroup *) selectEffect];
        }];
    }
}

#pragma mark - AliyunEffectCaptionShowViewDelegate - 字幕
//添加一个纯字幕
- (void)onClickFontWithFontInfo:(AliyunEffectFontInfo *)font {
    if (self.userAction == AliyunEditUserEvent_Effect_Slider) {
        return;
    }
    [self pause];
    [self.playButton setSelected:YES];
    self.currentEditPasterType = AliyunPasterEffectTypeSubtitle;
    [self forceFinishLastEditPasterView];
    AliyunPasterTextInputView *textInputView =
    [AliyunPasterTextInputView createPasterTextInputView];
    textInputView.maxWidth = CGRectGetWidth(self.movieView.bounds);
    textInputView.fontName = font.fontName;
    [self.movieView addSubview:textInputView];
    textInputView.center = CGPointMake(CGRectGetMidX(self.movieView.bounds),
                                       CGRectGetMidY(self.movieView.bounds) - 50);
    textInputView.delegate = (id)self;
    textInputView.maxCharacterCount = 180;
    _currentTextInputView = textInputView;
    [[NSUserDefaults standardUserDefaults] setObject:font.fontName forKey:AlivcEditPlayerPasterFontName];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)onClickRemoveCaption {
    // 移除纯文字动图和字幕动图
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
    [self.pasterManager removeAllSubtitlePasterControllers];
    [self.pasterManager removeAllCaptionPasterControllers];
    _lastPasterController = nil;
}

//添加字幕动画
- (void)animateWithObject:(AliyunPasterController *)pasterController
                animation:(TextActionType)type {
    AliyunEffectPaster *effectPaster = [pasterController getEffectPaster];
    [effectPaster stopAllActions];
    // AliyunEffectPaster
//    if (pasterController.pasterType == AliyunPasterEffectTypeNormal) {
//        pasterControlle
//        return; //动图不添加动画
//    }
    _textActionType = type;
    [pasterController setTempActionType:type];
    NSLog(@"%ld==========%ld",(long)pasterController.actionType,pasterController.tempActionType);

    switch (type) {
        case TextActionTypeClear: {
            [effectPaster stopAllActions];
            _textActionType = TextActionTypeNull;
        } break;
        case TextActionTypeMoveLeft: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [pasterController pasterStartTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(CGRectGetWidth(self.movieView.frame),
                                                pasterController.pasterPosition.y);
            moveAction.toPoint = pasterController.pasterPosition;
            //            [effectPaster runAction:moveAction];
            [self.editor add:effectPaster withFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveRight: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [pasterController pasterStartTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(CGRectGetWidth(pasterController.pasterFrame) * -1,
                                                pasterController.pasterPosition.y);
            moveAction.toPoint = pasterController.pasterPosition;
            //            [effectPaster runAction:moveAction];
            [self.editor add:effectPaster withFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveTop: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [pasterController pasterStartTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(pasterController.pasterPosition.x,
                                                CGRectGetHeight(self.editZoneView.frame));
            moveAction.toPoint = pasterController.pasterPosition;
            //            [effectPaster runAction:moveAction];
            
            [self.editor add:effectPaster withFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveDown: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [pasterController pasterStartTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(pasterController.pasterPosition.x,
                                                CGRectGetHeight(pasterController.pasterFrame) * -1);
            moveAction.toPoint = pasterController.pasterPosition;
            //            [effectPaster runAction:moveAction];
            [self.editor add:effectPaster withFrameAnimation:moveAction];
        } break;
        case TextActionTypeLinerWipe: {
            AliyunCustomAction *customAction = [[AliyunCustomAction alloc] init];
            customAction.startTime = [pasterController pasterStartTime];
            customAction.duration = 1;
            customAction.fragmentShader = kLinearSwipFragmentShader;
            customAction.customUniformsMapper = @{
                @"direction" : @[ @0 ],
                @"wipeMode" : @[ @0 ],
                @"offset" : @[ @1.0, @0.0 ],
            };
            //            [effectPaster runAction:customAction];
            [self.editor add:effectPaster withFrameAnimation:customAction];
        } break;
        case TextActionTypeFade: {
            AliyunAlphaAction *alphaAction_in = [[AliyunAlphaAction alloc] init]; //淡入
            alphaAction_in.startTime = [pasterController pasterStartTime];
            alphaAction_in.duration = 0.5;
            alphaAction_in.fromAlpha = 0.2f;
            alphaAction_in.toAlpha = 1.0f;
            
            AliyunAlphaAction *alphaAction_out = [[AliyunAlphaAction alloc] init]; //淡出
            alphaAction_out.startTime = [pasterController pasterStartTime]+1;
            alphaAction_out.duration = 0.5;
            alphaAction_out.fromAlpha = 1.0f;
            alphaAction_out.toAlpha = 0.2f;
            //            [effectPaster runAction:alphaAction_in];
            //            [effectPaster runAction:alphaAction_out];
            [self.editor add:effectPaster withFrameAnimation:alphaAction_in];
            [self.editor add:effectPaster withFrameAnimation:alphaAction_out];
            
        } break;
        case TextActionTypeScale: {
            AliyunScaleAction *scaleAction = [[AliyunScaleAction alloc] init];
            scaleAction.startTime = [pasterController pasterStartTime];
            scaleAction.duration = 1;
            scaleAction.fromScale = 1.0;
            scaleAction.toScale = 0.25;
            //            [effectPaster runAction:scaleAction];
            [self.editor add:effectPaster withFrameAnimation:scaleAction];
        } break;
        default:
            break;
    }
    //    字幕特效先注释掉，保持跟安卓同步
    //    if (type <= TextActionTypeFade && type > TextActionTypeNull) {
    //        float seekTime = [pasterController pasterStartTime] - 0.5;
    //        if (seekTime < 0) {
    //            seekTime = 0;
    //        }
    //        [self.player seek:seekTime];
    //    }
}

//完成字幕编辑
- (void)textInputViewEditCompleted {
    [self.tabController dismissPresentTabContainerView];
    self.editZoneView.currentPasterView = nil;
    AliyunPasterController *editPasterController = [self.pasterManager getCurrentEditPasterController];
    
    if (editPasterController) { //当前有正在编辑的动图控制器，则更新
        AliyunPasterView *pasterView =(AliyunPasterView *)editPasterController.pasterView;
        if (editPasterController.pasterType == AliyunPasterEffectTypeSubtitle) { //纯字幕情况下需要重新设置pasterView的bounds和paster位置大小信息

            //            pasterView.bounds = _currentTextInputView.bounds;
            //            [pasterView calculateRotateButtonAngle];
            //            editPasterController.pasterFrame = pasterView.frame;
            //            editPasterController.pasterSize = pasterView.bounds.size;
        }
        pasterView.textFontName = [_currentTextInputView fontName];
        pasterView.textColor = [_currentTextInputView getTextColor];
        pasterView.text = [_currentTextInputView getText];
        editPasterController.subtitleFontName = [_currentTextInputView fontName];
        editPasterController.subtitle = pasterView.text;
        editPasterController.subtitleStroke = pasterView.textColor.isStroke;
        editPasterController.subtitleColor = [pasterView contentColor];
        editPasterController.subtitleStrokeColor = [pasterView strokeColor];
        editPasterController.subtitleBackgroundColor = [UIColor clearColor];
        [editPasterController editCompletedWithImage:[pasterView textImage]];
    } else { //当前无正在编辑的动图控制器，则新建
        
        CGRect inputViewBounds = _currentTextInputView.bounds;
        AliyunPasterRange range = [self calculatePasterStartTimeWithDuration:1];
        editPasterController =[self.pasterManager addSubtitle:[_currentTextInputView getText]
                                                       bounds:inputViewBounds
                                                    startTime:range.startTime
                                                     duration:range.duration];
        [self addPasterViewToDisplayAndRender:editPasterController pasterFontId:-1];
        [self addPasterToTimeline:editPasterController]; //加到timelineView联动
    }
    [self makePasterControllerBecomeEditStatus:editPasterController];
    [editPasterController setTempActionType:[_currentTextInputView actionType]];
    [self destroyInputView];
}

#pragma mark - AliyunEffectTimeFilterDelegate - 时间特效
/**
 应用时间特效的效果
 */
- (void)applyTimeFilterButtonClick {
    self.storeTimeFilter = self.currentTimeFilter;
    [self apply];
}

/**
 取消时间特效的效果
 */
- (void)noApplyTimeFilterButtonClick {
    [self didSelectNone];
    [self cancel];
    if (self.storeTimeFilter) {
        if (self.storeTimeFilter.type == TimeFilterTypeInvert) {
            [self didSelectInvert:nil];
        } else {
            [self.editor applyTimeFilter:self.storeTimeFilter];
            [self resume];
            AliyunTimelineTimeFilterItem *item = [AliyunTimelineTimeFilterItem new];
            item.startTime = self.storeTimeFilter.startTime;
            item.endTime = self.storeTimeFilter.endTime;
            [_currentTimelineView removeAllTimelineTimeFilterItem];
            [_currentTimelineView addTimelineTimeFilterItem:item];
        }
    }
}
- (void)didSelectNone {
    self.currentTimeFilter = nil;
    [_editor removeTimeFilter];
    [self resume];
    [_currentTimelineView removeAllTimelineTimeFilterItem];
}

- (void)didSelectMomentSlow {
    [self didSelectNone];
    AliyunEffectTimeFilter *timeFilter = [[AliyunEffectTimeFilter alloc] init];
    timeFilter.startTime = [self.player getCurrentStreamTime];
    timeFilter.endTime = timeFilter.startTime + 1;
    timeFilter.type = TimeFilterTypeSpeed;
    timeFilter.param = 0.67;
    [self.editor applyTimeFilter:timeFilter];
    self.currentTimeFilter = timeFilter;
    [self.player seek:0];
    [self resume];
    // time line
    AliyunTimelineTimeFilterItem *item = [AliyunTimelineTimeFilterItem new];
    item.startTime = timeFilter.startTime;
    item.endTime = timeFilter.endTime;
    [_currentTimelineView removeAllTimelineTimeFilterItem];
    [_currentTimelineView addTimelineTimeFilterItem:item];
}

//加速
- (void)didSelectMomentFast {
    [self didSelectNone];
    AliyunEffectTimeFilter *timeFilter = [[AliyunEffectTimeFilter alloc] init];
    timeFilter.startTime = [self.player getCurrentStreamTime];
    timeFilter.endTime = timeFilter.startTime + 1;
    timeFilter.type = TimeFilterTypeSpeed;
    timeFilter.param = 1.5;
    [self.editor applyTimeFilter:timeFilter];
    self.currentTimeFilter = timeFilter;
    //    从头开始播
    [self.player seek:0];
    [self resume];
    // time line
    AliyunTimelineTimeFilterItem *item = [AliyunTimelineTimeFilterItem new];
    item.startTime = timeFilter.startTime;
    item.endTime = timeFilter.endTime;
    [_currentTimelineView removeAllTimelineTimeFilterItem];
    [_currentTimelineView addTimelineTimeFilterItem:item];
}

//重复
- (void)didSelectRepeat {
    [self didSelectNone];
    AliyunEffectTimeFilter *timeFilter = [[AliyunEffectTimeFilter alloc] init];
    timeFilter.type = TimeFilterTypeRepeat;
    timeFilter.param = 3;
    timeFilter.startTime = [self.player getCurrentStreamTime];
    timeFilter.endTime = timeFilter.startTime + 1;
    [self.editor applyTimeFilter:timeFilter];
    self.currentTimeFilter = timeFilter;
    [self.player seek:0];
    [self resume];
    // time line
    AliyunTimelineTimeFilterItem *item = [AliyunTimelineTimeFilterItem new];
    item.startTime = timeFilter.startTime;
    item.endTime = timeFilter.endTime;
    [_currentTimelineView removeAllTimelineTimeFilterItem];
    [_currentTimelineView addTimelineTimeFilterItem:item];
}
//倒放
- (void)didSelectInvert:(void (^)(BOOL))success {
    
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    AliyunClip *clip = self.clipConstructor.mediaClips[0];
    NSString *inputPath = clip.src;
    //存在B帧要先转码，否则倒播会出现卡顿现象
    AliyunNativeParser *nativeParser =[[AliyunNativeParser alloc]initWithPath:inputPath];
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:inputPath]];
    CGFloat resolution = [asset avAssetNaturalSize].width * [asset avAssetNaturalSize].height;
    CGFloat max = [self maxVideoSize].width * [self maxVideoSize].height;
    NSLog(@"--------->frameRate:%f  GopSize:%zd",asset.frameRate,nativeParser.getGopSize);
    //分辨率过大              //fps过大                    //Gop过大
    if (resolution > max || asset.frameRate > 35 || nativeParser.getGopSize >35) {
        [self pause];
        AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:inputPath]];
        NSString *root = [AliyunPathManager compositionRootDir];
        NSString *outputPath = [[root stringByAppendingPathComponent:[AliyunPathManager randomString]] stringByAppendingPathExtension:@"mp4"];
        AliyunMediaConfig *config = [AliyunMediaConfig invertConfig];
        __weak typeof(self) weakself = self;
        self.compressManager =[[AliyunCompressManager alloc] initWithMediaConfig:config];
        [self.compressManager compressWithSourcePath:inputPath outputPath:outputPath outputSize:[asset aliyunNaturalSize] success:^{
            [self didSelectNone];
            weakself.invertAvailable = YES;
            [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
            [weakself.editor stopEdit];
            clip.src = outputPath;
            [weakself.clipConstructor updateMediaClip:clip atIndex:0];
            [weakself.editor startEdit];
            [weakself.player play]; //这里必须调用self.player的play
            //要不原始视频流时间和当前播放时间会反
            [weakself updateUIAndDataWhenPlayStatusChanged];
            [weakself invert];
            if (success) {
                success(YES);
            }
        } failure:^(int errorCode) {
            [[MBProgressHUD HUDForView:weakself.view] hideAnimated:YES];
            [weakself play];
            if (success) {
                success(NO);
            }
        }];
    } else {
        [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
        [self didSelectNone];
        [self invert];
        if (success) {
            success(YES);
        }
    }
}
//倒播支持最大分辨率设置
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


- (void)invert {
     [MBProgressHUD showMessage:NSLocalizedString(@"倒播时不支持字幕和贴图动画效果", nil) inView:self.view];
    AliyunEffectTimeFilter *timeFilter = [[AliyunEffectTimeFilter alloc] init];
    timeFilter.type = TimeFilterTypeInvert;
    self.currentTimeFilter = timeFilter;
    [self pause];
    [self.player seek:0];
    [self.editor applyTimeFilter:timeFilter];
    [self.player play];
    [self updateUIAndDataWhenPlayStatusChanged];
    // time line
    AliyunTimelineTimeFilterItem *item = [AliyunTimelineTimeFilterItem new];
    item.startTime = 0;
    item.endTime = [self.player getStreamDuration];
    [_currentTimelineView removeAllTimelineTimeFilterItem];
    [_currentTimelineView addTimelineTimeFilterItem:item];
}

#pragma mark - AliyunEffectTransitionViewDelegate - 转场
- (void)didSelectTransitionType:(TransitionType)type resoucePath:(NSString*)path index:(int)idx {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.transitionView.userInteractionEnabled = NO;
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        //这里子线程处理下让UI先走完，不然会堵塞loading框的UI进程
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.editor stopEdit];
            if (type == TransitionTypeNull) {
                [weakSelf.editor removeTransitionAtIndex:idx];
                [weakSelf.transitionView showRegulatorView:nil paramList:nil index:idx];
            } else {
                int result = -1;
                if (path.length>0) {
                    AliyunTransitionEffect *customEffect = [[AliyunTransitionEffect alloc] initWithPath:path];
                    result = [weakSelf.editor applyTransition:(AliyunTransitionEffect *)customEffect atIndex:idx];
                    NSArray *paramList = [AlivcRegulatorView getSliderParams:customEffect.effectConfig];
                    [weakSelf.transitionView showRegulatorView:customEffect paramList:paramList index:idx];
                }else{
                    [weakSelf.transitionView showRegulatorView:nil paramList:nil index:idx];
                    result = [weakSelf.editor applyTransition:(AliyunTransitionEffect *)[weakSelf getTransitionEffect:type] atIndex:idx];
                }
                NSLog(@"++++++++++\nresult:%d", result);
            }
            [weakSelf.editor startEdit];
            
            //            [weakSelf.editor prepare:AliyunEditorModePlay];
            
            float seektime = [weakSelf.player getClipStartTimeAtIndex:idx + 1];
            [weakSelf.player seek:seektime-0.7];
            [weakSelf.player play];
            [weakSelf updateUIAndDataWhenPlayStatusChanged];
            [hud hideAnimated:YES];
            weakSelf.transitionView.userInteractionEnabled = YES;
        });
    });
}

-(void)previewTransitionIndex:(AliyunTransitionCover*)cover{
//    if (cover.transitionPath.length>0) {
//        AliyunTransitionEffect *customEffect = [[AliyunTransitionEffect alloc] initWithPath:cover.transitionPath];
//        if (cover.paramsJsonString.length>0) {
//            customEffect.paramString = cover.paramsJsonString;
//        }
//        NSArray *paramList = [AlivcRegulatorView getSliderParams:customEffect.effectConfig];
//        [self.transitionView showRegulatorView:customEffect paramList:paramList index:cover.transitionIdx];
//    }else{
//        [self.transitionView showRegulatorView:nil paramList:nil index:cover.transitionIdx];
//    }
    [self.transitionView updateRegulatorViewWithCover:cover];
    CGFloat seekTime =[self.player getClipStartTimeAtIndex:cover.transitionIdx + 1];
    [self.player seek:seekTime -0.6];
    [self.player play];
    
    [self updateUIAndDataWhenPlayStatusChanged];
}

- (void)didShowMoreTransition{
    __weak typeof(self) weakSelf = self;
    [self presentAliyunEffectMoreControllerWithAliyunEffectType: AliyunEffectTypeTransition completion:^(AliyunEffectInfo *selectEffect) {
        [weakSelf.transitionView fetchEffectGroupDataWithCurrentShowGroup:selectEffect];
    }];
}

//转场确认
- (void)applyButtonClickCovers:(NSArray<AliyunTransitionCover *> *)covers
                      andIcons:(NSArray<AliyunTransitionIcon *> *)icons
                transitionInfo:(NSDictionary *)transitionInfo {
    //深拷贝保存转场效果
    self.transitionRetention.lastTransitionInfo = [transitionInfo copy];
    self.transitionRetention.transitionCovers =
    [[NSMutableArray alloc] initWithArray:covers copyItems:YES];
    self.transitionRetention.transitionIcons =
    [[NSMutableArray alloc] initWithArray:icons copyItems:YES];
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}

//取消
- (void)transitionCancelButtonClickTransitionInfo:(NSDictionary *)transitionInfo {
    [self.editor stopEdit];
    for (int i = 0;i<self.transitionRetention.transitionCovers.count;i++) {
        AliyunTransitionCover *lastTrasition = self.transitionRetention.transitionCovers[i];
//        AliyunTransitionCover *curTrasition = transitionInfo[key];
//        if (lastTrasition.name && ![lastTrasition.name isEqualToString: curTrasition.name]) { //筛选被改变转场效果进行恢复;
        if (lastTrasition.isTransitionIdx){
//            int idx = [key intValue];
            int idx = lastTrasition.transitionIdx;
            if (lastTrasition.type == TransitionTypeNull) {
                [self.editor removeTransitionAtIndex:idx];
                if (lastTrasition.isSelect) {
                    [self.transitionView showRegulatorView:nil paramList:nil index:idx];
                }
            } else {
                if (lastTrasition.transitionPath.length>0) {
                    AliyunTransitionEffect *customEffect = [[AliyunTransitionEffect alloc] initWithPath:lastTrasition.transitionPath];
                    if (lastTrasition.paramsJsonString.length>0) {
                        customEffect.paramString = lastTrasition.paramsJsonString;
                    }
                    [self.editor applyTransition:(AliyunTransitionEffect *)customEffect atIndex:idx];
                    if (lastTrasition.isSelect) {
                        NSArray *paramList = [AlivcRegulatorView getSliderParams:customEffect.effectConfig];
                        [self.transitionView showRegulatorView:customEffect paramList:paramList index:idx];
                    }
                }else{
                    if (lastTrasition.isSelect) {
                        [self.transitionView showRegulatorView:nil paramList:nil index:idx];
                    }
                    [self.editor applyTransition:(AliyunTransitionEffect *)[self getTransitionEffect:lastTrasition.type] atIndex:idx];
                }
            }
        }
    }
    
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
    
    [self.editor startEdit];
    //    [self.editor prepare:AliyunEditorModePlay];
    [[self.editor getPlayer] play];
    [self updateUIAndDataWhenPlayStatusChanged];
}

- (void)clearRetentionByPath:(NSString*)path{
    NSMutableDictionary *transitionInfo = [NSMutableDictionary dictionaryWithCapacity:8];
    for (NSString *key in self.transitionRetention.lastTransitionInfo) {
        AliyunTransitionCover *lastTrasition = self.transitionRetention.lastTransitionInfo[key];
        AliyunTransitionCover *newCover = [lastTrasition copy];
        if ([path isEqualToString:lastTrasition.resourcePath]) {
            newCover.resourcePath = nil;
            newCover.name = nil;
            newCover.paramsJsonString = nil;
            newCover.image = [AlivcImage imageNamed:@"transition_cover_point_Sel"];
            newCover.image_Nor = [AlivcImage imageNamed:@"transition_cover_point_Nor"];
            newCover.transitionPath = nil;
        }
        [transitionInfo setValue:newCover forKey:key];
    }
    self.transitionRetention.lastTransitionInfo = [transitionInfo copy];
    
    NSMutableArray<AliyunTransitionCover*> *covers = @[].mutableCopy;
    for (AliyunTransitionCover *cover in self.transitionRetention.transitionCovers) {
        if ([path isEqualToString:cover.resourcePath]) {
            cover.resourcePath = nil;
            cover.name = nil;
            cover.paramsJsonString = nil;
            cover.image = [AlivcImage imageNamed:@"transition_cover_point_Sel"];
            cover.image_Nor = [AlivcImage imageNamed:@"transition_cover_point_Nor"];
            cover.transitionPath = nil;
        }
        [covers addObject:cover];
    }
    self.transitionRetention.transitionCovers = [[NSMutableArray alloc] initWithArray:covers copyItems:YES];
}

//获取一个转场动画effect
- (id)getTransitionEffect:(TransitionType)type {
    switch (type) {
        case TransitionTypeFade: {
            AliyunTransitionEffectFade *fade = [[AliyunTransitionEffectFade alloc] init];
            fade.overlapDuration = 1;
            return fade;
        } break;
        case TransitionTypeStar: {
            AliyunTransitionEffectPolygon *polygon = [[AliyunTransitionEffectPolygon alloc] init];
            polygon.overlapDuration = 1;
            return polygon;
        } break;
        case TransitionTypeCircle: {
            AliyunTransitionEffectCircle *circle = [[AliyunTransitionEffectCircle alloc] init];
            circle.overlapDuration = 1;
            return circle;
        } break;
        case TransitionTypeMoveUp: {
            AliyunTransitionEffectTranslate *moveUp = [[AliyunTransitionEffectTranslate alloc] init];
            moveUp.overlapDuration = 1;
            moveUp.direction = DIRECTION_TOP;
            return moveUp;
        } break;
        case TransitionTypeMoveDown: {
            AliyunTransitionEffectTranslate *moveDown = [[AliyunTransitionEffectTranslate alloc] init];
            moveDown.overlapDuration = 1;
            moveDown.direction = DIRECTION_BOTTOM;
            return moveDown;
        } break;
        case TransitionTypeMoveLeft: {
            AliyunTransitionEffectTranslate *moveLeft = [[AliyunTransitionEffectTranslate alloc] init];
            moveLeft.overlapDuration = 1;
            moveLeft.direction = DIRECTION_LEFT;
            return moveLeft;
        } break;
        case TransitionTypeMoveRight: {
            AliyunTransitionEffectTranslate *moveRight = [[AliyunTransitionEffectTranslate alloc] init];
            moveRight.overlapDuration = 1;
            moveRight.direction = DIRECTION_RIGHT;
            return moveRight;
        } break;
        case TransitionTypeShuffer: {
            AliyunTransitionEffectShuffer *shuffer = [[AliyunTransitionEffectShuffer alloc] init];
            shuffer.overlapDuration = 1;
            shuffer.lineWidth = 0.1;
            shuffer.orientation = ORIENTATION_VERTICAL;
            return shuffer;
        } break;
            
        default:
            break;
    }
    return nil;
}

#pragma mark - AliyunPaintingEditViewDelegate - 涂鸦
//视频合成的时候调用此方法
- (void)savePaitingAction {
    UIImage *paintImage = [self.paintView complete];
    NSString *paintPath = [[AliyunPathManager resourceRelativeDir]
                           stringByAppendingPathComponent:@"paintImage.png"];
    NSString *realPath =
    [NSHomeDirectory() stringByAppendingPathComponent:paintPath];
    [UIImagePNGRepresentation(paintImage) writeToFile:realPath atomically:YES];
    
    self.paintImage = [[AliyunEffectImage alloc] initWithFile:realPath];
    self.paintImage.frame = self.movieView.bounds;
    [self.editor applyPaint:self.paintImage];
    [self.playButton setHidden:NO];
    [self.paintView removeFromSuperview];
    _paintView = nil;
    if (self.paintImage) {
        self.paintImage = nil;
    }
}

//完成
- (void)onClickPaintFinishButton {
    UIImage *paintImage = [self.paintView complete];
    NSString *paintPath = [[AliyunPathManager resourceRelativeDir]
                           stringByAppendingPathComponent:@"paintImage.png"];
    NSString *realPath =
    [NSHomeDirectory() stringByAppendingPathComponent:paintPath];
    [UIImagePNGRepresentation(paintImage) writeToFile:realPath atomically:YES];
    self.paintImage = [[AliyunEffectImage alloc] initWithFile:realPath];
    self.paintImage.frame = self.movieView.bounds;
    [self.editor applyPaint:self.paintImage];
    [self.paintView removeFromSuperview];
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}
//改变画笔宽度
- (void)onClickChangePaintWidth:(NSInteger)width {
    self.paintView.paint.lineWidth = width;
}
//改变画笔颜色
- (void)onClickChangePaintColor:(UIColor *)color {
    self.paintView.paint.lineColor = color;
}
//撤销一步
- (void)onClickPaintUndoPaintButton {
    [self.paintView undo];
}
//反向撤销一步
- (void)onClickPaintRedoPaintButton {
    [self.paintView redo];
}
//取消
- (void)onClickPaintCancelButton {
    [self.paintView undoAllChanges];
    if (self.paintImage) {
        [self.editor applyPaint:self.paintImage];
    }
    [self.paintView removeFromSuperview];
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}

- (void)endDrawingWithCurrentPoint:(CGPoint)endPoint {
    NSLog(@"结束绘图");
    self.paintShowView.userInteractionEnabled = YES ;
}

- (void)startDrawingWithCurrentPoint:(CGPoint)startPoint {
    NSLog(@"开始绘图");
    self.paintShowView.userInteractionEnabled = NO;
}

#pragma mark - AlivcAudioEffectViewDelegate - 音效

-(void)AlivcAudioEffectViewDidSelectCell:(AlivcEffectSoundType)type{
    NSLog(@"选择了音效%ld",type);
    if (lastAudioEffectType) {
        [self.editor removeMainStreamsAudioEffect:lastAudioEffectType];
    }
    if (type != AlivcEffectSoundTypeClear) {
        [self.editor setMainStreamsAudioEffect:[self getSDKType:type] weight:50];
        lastAudioEffectType =[self getSDKType:type];
    }
    [self replay];
}

-(AliyunAudioEffectType)getSDKType:(AlivcEffectSoundType)type{
    NSDictionary *dic =@{@(AlivcEffectSoundTypeLolita):@(AliyunAudioEffectLolita),
                         @(AlivcEffectSoundTypeUncle):@(AliyunAudioEffectUncle),
                         @(AlivcEffectSoundTypeEcho):@(AliyunAudioEffectEcho),
                         @(AlivcEffectSoundTypeRevert):@(AliyunAudioEffectReverb),
                         @(AlivcEffectSoundTypeDenoise):@(AliyunAudioEffectDenoise),
                         @(AlivcEffectSoundTypeMinion):@(AliyunAudioEffectMinions),
                         @(AlivcEffectSoundTypeRobot):@(AliyunAudioEffectRobot),
                         @(AlivcEffectSoundTypeDevil):@(AliyunAudioEffectBigDevil)
    };
    return (AliyunAudioEffectType)[dic[@(type)] integerValue];
}

#pragma mark - AlivcCoverImageSelectedViewDelegate - 封面
- (void)cancelCoverImageSelectedView:(AlivcCoverImageSelectedView *)view {
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:^(BOOL finished) {
        self.playButton.hidden = NO;
    }];
}

- (void)applyCoverImageSelectedView:(AlivcCoverImageSelectedView *)view {
    //时间
    //    CGFloat time = [self.player getCurrentStreamTime];
    //截图
    _coverImage = [self screenShotView:self.movieView];
    NSLog(@"图片宽度%.2f,高度%.2f",_coverImage.size.width,_coverImage.size.height);
    NSLog(@"视图宽度%.2f,高度%.2f",self.movieView.frame.size.width,self.movieView.frame.size.height);
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:^(BOOL finished) {
        self.playButton.hidden = NO;
    }];
    
}

//传入需要截取的view
- (UIImage *)screenShotView:(UIView *)view {
    NSLog(@"-------->view.frame:%@",NSStringFromCGRect(view.frame));
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO,0);
    [view drawViewHierarchyInRect:view.bounds afterScreenUpdates:YES];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    return image;
}

@end
