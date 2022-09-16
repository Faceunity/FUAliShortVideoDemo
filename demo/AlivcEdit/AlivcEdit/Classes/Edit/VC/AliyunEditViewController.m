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
#import "AliyunEffectFontManager.h"
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
#import "AlivcRollCaptionView.h"
#import "AliyunRollCaptionWordsController.h"
#import <AliyunVideoSDKPro/AliyunRollCaptionItemStyle.h>
#import "AliyunVideoAugmentationView.h"
#import "AliyunLutFilterView.h"

//#import "AliyunPublishViewController.h"
//#import "AlivcExportViewController.h"

//底部UI适配
#import "AlivcEditItemManager.h"
#import "AlivcEditItemModel.h"
#import "AliyunSubtitleActionItem.h"
#import "AliyunPasterController+ActionType.h"
#import "AlivcRegulatorView.h"

#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>
#import "UIView+OPLayout.h"
#import "AliyunDraftConfig.h"
#import <AliyunVideoSDKPro/AliyunEditor+Draft.h>
#import <FURenderKit/FURenderKit.h>
#import <FURenderKit/FUGLContext.h>
#import <FURenderKit/FURenderer.h>
#import "FUDemoManager.h"




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
AliyunPasterBottomBaseViewDelegate, AliyunEffectCaptionShowViewDelegate, AliyunVideoAugmentationViewDelegate,
AliyunEffectTransitionViewDelegate, AlivcSpecialEffectViewDelegate ,AlivcAudioEffectViewDelegate,AlivcCoverImageSelectedViewDelegate,AliyunEffectTimeFilterDelegate,AlivcRollCaptionViewDelegate,AliyunLutFilterViewDelegate,AliyunIRenderCallback>

@property(nonatomic, strong) UIView *movieView;
@property(nonatomic, strong) AliyunTimelineView *currentTimelineView;
@property(nonatomic, strong) AliyunEditButtonsView *editButtonsView;
@property(nonatomic, strong) AliyunTabController *tabController;
@property(nonatomic, strong) AliyunTabController *gifTabController;

@property(nonatomic, strong) UIButton *backgroundTouchButton;
@property(nonatomic, strong) UILabel *currentTimeLabel;
@property(nonatomic, strong) UIButton *playButton;
@property(nonatomic, strong) UIView *playButtonConView;

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
@property(nonatomic, assign) BOOL hasInitMVViewSelected;
@property(nonatomic, strong) AliyunEffectMVView *mvView;
//滤镜弹出的菜单
@property(nonatomic, strong) AliyunEffectFilterView *filterView;

//lut滤镜弹出的菜单
@property(nonatomic, strong) AliyunLutFilterView *lutFilterView;

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
//视频增强弹出的菜单
@property(nonatomic, strong) AliyunVideoAugmentationView *videoAugmentationView;
//fe
@property(nonatomic, strong) AlivcCoverImageSelectedView *coverSelectedView;

@property(nonatomic, strong) AlivcRollCaptionView *rollCaptionView;
@property(nonatomic,assign) BOOL isRollCaptionType;

@property(nonatomic, strong) FUDemoManager *demoManager;


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
@property(nonatomic, strong) AliyunRenderBaseController *lastPasterController;


@property(nonatomic, strong) AliyunRenderBaseController *beforeEditController;


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
@property(nonatomic,strong) NSMutableArray<AliyunRenderBaseController*> *curRenderList;

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
        
    
    AliyunAudioEffectType lastAudioEffectType;//上次设置的音效
    
    NSMutableDictionary *_videoAugmentationValues;
}

#pragma mark - System
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initBaseData];
    [self addSubviews];
    
//    CGFloat safeAreaBottom = 0;
//    if (@available(iOS 11.0, *)) {
//        safeAreaBottom = [UIApplication sharedApplication].delegate.window.safeAreaInsets.bottom;
//    }
//
//    self.demoManager = [[FUDemoManager alloc] initWithTargetController:self originY:CGRectGetHeight(self.view.frame) - FUBottomBarHeight - safeAreaBottom - 180];
    
    
    
    [self addNotificationBeforeSdk];
    [self initSDKAbout];
    [self addNotifications];
    [self addWatermarkAndEnd];
    [self setDenoise];
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
            param.codecType = AliyunVideoCodecOpenh264;
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
    self.editor.renderCallback = self;
    
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
//    self.pasterManager = [self.editor getPasterManager];
//    self.pasterManager.displaySize = self.editZoneView.bounds.size;
//    self.pasterManager.outputSize = _outputSize;
//    self.pasterManager.previewRenderSize = [self.editor getPreviewRenderSize];
//    self.pasterManager.delegate = (id)self;
    //    [self.editor startEdit];
    //    [self play];
}

/**
 添加水印和片尾
 */
- (void)addWatermarkAndEnd {
    AlivcOutputProductType productType = kAlivcProductType;
    if (productType != AlivcOutputProductTypeSmartVideo) {
        NSString *watermarkPath = [AlivcImage pathOfImageName:@"watermark.png"];
        
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
        tailWatermark.displaySize = _outputSize;
        tailWatermark.frame = CGRectMake(_outputSize.width / 2 - 84 / 2,
                                         _outputSize.height / 2 - 60 / 2, 84, 60);
        tailWatermark.endTime = 2;
        [self.editor setTailWaterMark:tailWatermark];
    }
}

- (void)setDenoise {
    [self.editor setMainStreamsAudioDenoise:_config.denoise];
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
    if (_isRollCaptionType) {
        return;
    }
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
    int ret = [self.editor startEdit];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
        return;
    }
    
    [self play];
    [self resourceDeleteAction];
    //如果是合拍 则播放原音
    if (self.isMixedVideo) {
        [self.editor setAudioMixWeight:0];
    }
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (_isRollCaptionType) {
        return;
    }
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
    
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];

    
    //重置_captionShowView
    [_captionShowView removeFromSuperview];
    _captionShowView = nil;
    
    
    //重置_pasterShowView
    [_pasterShowView removeFromSuperview];
    _pasterShowView = nil;
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (_isRollCaptionType) {
        return;
    }
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
        
        //草稿恢复
        NSArray<AliyunRenderBaseController *> *list = [self.editor.getStickerManager getAllController];
        for (AliyunRenderBaseController *vc in list) {
            [self addPasterToTimeline:vc];
        }
    }
    return _pasterShowView;
}
//字幕
- (AliyunEffectCaptionShowView *)captionShowView {
    if (!_captionShowView) {
        _captionShowView = [[AliyunEffectCaptionShowView alloc]
                            initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 140+SafeBottom)];
        _captionShowView.delegate = self;
        _captionShowView.fontDelegate = self;
        [_captionShowView setupSubViews];
        [self.view addSubview:_captionShowView];
        _captionShowView.timeLineView = [self getOneTimeLineView];
        
        //草稿恢复
        NSArray<AliyunRenderBaseController *> *list = [self.editor.getStickerManager getAllController];
        for (AliyunRenderBaseController *vc in list) {
            [self addPasterToTimeline:vc];
        }
    }
    return _captionShowView;
}
// MV
- (AliyunEffectMVView *)mvView {
    if (!_mvView) {
        _mvView = [[AliyunEffectMVView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 180)];
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
        [_filterView addVisualEffect];
        [self.view addSubview:_filterView];
        
        _filterView.delegate = (id<AliyunEffectFilter2ViewDelegate>)self;

        for (AEPEffectFilterTrack *effect in _editor.getEditorProject.timeline.effectTracks) {
            if ([effect isKindOfClass:AEPEffectFilterTrack.class]) {
                [_filterView updateSelectedFilterWithResource:effect.source.path];
                break;
            }
        }
    }
    return _filterView;
}

//lut滤镜
- (AliyunLutFilterView *)lutFilterView {
    if (!_lutFilterView) {
        _lutFilterView = [[AliyunLutFilterView alloc]
                       initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 220)];
        [_lutFilterView addVisualEffect];
        [self.view addSubview:_lutFilterView];
        
        _lutFilterView.delegate = self;

        for (AEPEffectFilterTrack *effect in _editor.getEditorProject.timeline.effectTracks) {
            
            if ([effect isKindOfClass:AEPEffectLutFilterTrack.class]) {
                
                AEPEffectLutFilterTrack *track = effect;
                [_lutFilterView updateSelectedFilterWithResource:track.source.path insensity:track.intensity];
                break;
            }
        }
    }
    return _lutFilterView;
}

//翻转字幕
- (AlivcRollCaptionView *)rollCaptionView{
    if (!_rollCaptionView) {
        _rollCaptionView = [[AlivcRollCaptionView alloc]
                            initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 120+SafeBottom)];
        _rollCaptionView.delegate = self;
        [self.view addSubview:_rollCaptionView];
    }
    return _rollCaptionView;
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
        
        for (AEPEffectAnimationFilterTrack *effect in _editor.getEditorProject.timeline.effectTracks) {
            if ([effect isKindOfClass:AEPEffectAnimationFilterTrack.class]) {
                [self.animationFilters addObject:effect.editorEffect];
                [self addAnimationFilter:effect.editorEffect toTimeline:_specialFilterView.timelineView];
            }
        }

        __weak typeof(self) weakSelf = self;
        _specialFilterView.didChangeEffectFinish = ^(AliyunEffectFilter *effect) {
            weakSelf.curEffect = effect;
//            [weakSelf.editor updateAnimationFilter:weakSelf.curEffect];
        };
    }
    return _specialFilterView;
}

//变速（时间特效）
- (AEPEffectTimeTrack *) currentTimeFilterFromProject
{
    for (AEPEffectTimeTrack *track in _editor.getEditorProject.timeline.effectTracks) {
        if ([track isKindOfClass:AEPEffectTimeTrack.class]) {
            return track;
        }
    }
    return nil;
}

static void s_selectTimeFilter(AliyunEffectTimeFilterView *view, AEPEffectTimeTrack *timeTrack)
{
    switch (timeTrack.timeType) {
        case AEPEffectTimeType_Speed: {
            if (timeTrack.timeParam > 1.0) {
                [view selectMomentFast];
            } else {
                [view selectMomentSlow];
            }
            break;
        }
        case AEPEffectTimeType_Repeat: {
            [view selectRepeat];
            break;
        }
        case AEPEffectTimeType_Invert: {
            [view selectInvert];
            break;
        }
        default:
            break;
    }
}

- (AliyunEffectTimeFilterView *)timeFilterView {
    if (!_timeFilterView) {
        _timeFilterView = [[AliyunEffectTimeFilterView alloc] initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 220)];
        _timeFilterView.delegate = self;
        [self.view addSubview:_timeFilterView];
        _timeFilterView.timelineView = [self getOneTimeLineView];
        
        AEPEffectTimeTrack *timeEffect = self.currentTimeFilterFromProject;
        if (timeEffect) {
            s_selectTimeFilter(_timeFilterView, timeEffect);
            AliyunEffectTimeFilter *curTimeFilter = timeEffect.editorEffect;
            self.currentTimeFilter = curTimeFilter;
            AliyunTimelineTimeFilterItem *item = [AliyunTimelineTimeFilterItem new];
            item.startTime = curTimeFilter.startTime;
            item.endTime = curTimeFilter.endTime;
            [_timeFilterView.timelineView removeAllTimelineTimeFilterItem];
            [_timeFilterView.timelineView addTimelineTimeFilterItem:item];
        }
    }
    
    return _timeFilterView;
}
//涂鸦
- (AliyunPaintingEditView *)paintShowView {
    if (!_paintShowView) {
        _paintShowView = [[AliyunPaintingEditView alloc]
                          initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 185)];
        _paintShowView.delegate = self;
        __weak AliyunPaintingEditView *weakShowView = _paintShowView;
        NSArray<AliyunICanvasLineData *> *lines = self.editor.getEditorProject.timeline.paintTrack.linesData;
        [_paintShowView showInView:self.view animation:YES completion:^{
            if (lines.count > 0) {
                weakShowView.widthSelectView.currentWidth = lines.lastObject.lineWidth;
                weakShowView.widthSelectView.widthtTagColor = lines.lastObject.lineColor;
            }
        }];
        self.paintView.frame = self.editZoneView.bounds;
    }
    return _paintShowView;
}

- (AlivcEffectSoundType) currentEffectSoundType
{
    for (AEPVideoTrack *vTrack in _editor.getEditorProject.timeline.videoTracks) {
        for (AEPVideoTrackClip *clip in vTrack.clipList) {
            AEPAudioEffect *audio = clip.audioEffect;
            if (audio) {
                return [self getProjectType:audio.effectType];
            }
        }
    }
    
    return AlivcEffectSoundTypeClear;
}

- (AlivcAudioEffectView *)effectSoundsView{
    if (!_effectSoundsView) {
        _effectSoundsView = [[AlivcAudioEffectView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 185)];
        _effectSoundsView.delegate =self;
        _effectSoundsView.hidden =YES;
        [self.view addSubview:_effectSoundsView];
        
        _effectSoundsView.selectedType = self.currentEffectSoundType;
    }
    return _effectSoundsView;
}

- (AliyunVideoAugmentationView *)videoAugmentationView {
    if (!_videoAugmentationView) {
        _videoAugmentationView = [[AliyunVideoAugmentationView alloc]initWithFrame:CGRectMake(0, ScreenHeight, ScreenWidth, 185)];
        _videoAugmentationView.delegate =self;
        _videoAugmentationView.hidden =YES;
        [self.view addSubview:_videoAugmentationView];
    }
    return _videoAugmentationView;
}


- (AliyunICanvasView *)paintView {
    if (!_paintView) {
        AliyunIPaint *paint =[[AliyunIPaint alloc]initWithLineWidth:SizeWidth(5.0) lineColor:[UIColor whiteColor]];
        _paintView = [[AliyunICanvasView alloc]initWithFrame:CGRectMake(0, 0, self.movieView.frame.size.width,self.movieView.frame.size.height) paint:paint];
        _paintView.delegate = self;
        _paintView.backgroundColor = [UIColor clearColor];
        if (_editor.getEditorProject.timeline.paintTrack) {
            _paintView.lines = _editor.getEditorProject.timeline.paintTrack.linesData;
        }
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
        [_transitionView reloadSelectedForClips:_editor.getEditorProject.timeline.videoTracks.firstObject.clipList];
        
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
        _tabController = [[AliyunTabController alloc] initWithSuperView:self.view needInputView:YES];
        _tabController.delegate = (id)self;
    }
    return _tabController;
}

- (AliyunTabController *)gifTabController {
    if (!_gifTabController) {
        _gifTabController = [[AliyunTabController alloc] initWithSuperView:self.view needInputView:NO];
        _gifTabController.delegate = (id)self;
    }
    return _gifTabController;
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
        
        [self removePasterFromTimeline:self.editZoneView.currentPasterView.pasterController];
        [self.editor.getStickerManager remove:self.editZoneView.currentPasterView.pasterController];
        [self resetCurrentPasterView];
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
        [self resetCurrentPasterView];
        [self forceFinishLastEditPasterView];
    }
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}

static NSString * s_currentTime()
{
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormat stringFromDate:NSDate.date];
}

- (AliyunDraft *) saveToDraft {
    if (self.editor.getEditorProject.title.length == 0) {
        return [self.editor saveToDraft:AliyunDraftConfig.Shared.localManager.originMgr withTitle:s_currentTime()];
    }
    return [self.editor saveToDraft:AliyunDraftConfig.Shared.localManager.originMgr];
}

/**
 返回
 */
- (void)back {
    [self saveToDraft];
    
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
    AliyunDraft *draft = [self saveToDraft];
    
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
            
            UIImage *coverImage = nil;
            if (draft.cover.isLocal) {
                coverImage = [UIImage imageWithContentsOfFile:draft.cover.path];
            }
            if (!coverImage) {
                coverImage = _currentTimelineView.coverImage;
            }
            
            [controller  setValue:_taskPath forKey:@"taskPath"];
            [controller  setValue:_config.outputPath forKey:@"outputPath"];
            [controller  setValue:[NSValue valueWithCGSize:_config.outputSize] forKey:@"outputSize"];
            [controller  setValue:draft forKey:@"draft"];
            [controller  setValue:coverImage forKey:@"backgroundImage"];
            [controller  setValue:coverImage forKey:@"coverImage"];
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
        [self tabControllerCancelButtonClicked];
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
    }else if (paster){//动图非编辑态直接删除
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
    
    if (type==AliyunEditSouceClickTypeRollCaption) {
        [self.rollCaptionView showSubView:NO];
    }
    
    BOOL canEditFrame = [self isEditFrameType:type];
    if (canEditFrame) {
        [self p_changeUIToQuitEditFrameMode];
        [self resume];
    } else {
        [self p_dismissBackgroundButton];
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
        case AliyunEditSouceClickTypeLutFilter:
            return self.lutFilterView;
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
        case AliyunEditSouceClickTypeVideoAugmentation:
            return self.videoAugmentationView;
            break;
        case AliyunEditSouceClickTypeEffectSound:
            return self.effectSoundsView;
            break;
        case AliyunEditSouceClickTypeCover:
            return self.coverSelectedView;
            break;
        case AliyunEditSouceClickTypeRollCaption:
            return self.rollCaptionView;
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
    [self removePasterFromTimeline:self.editZoneView.currentPasterView.pasterController];
    [self tabControllerCancelButtonClicked];
    [self.tabController dismissPresentTabContainerView];

    
    
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
//    _currentTextInputView.pasterView = nil;
    [_currentTextInputView setText:nil];
    _currentTextInputView = nil;
}
//使一个动图进入编辑状态
- (void)makePasterControllerBecomeEditStatus:(AliyunPasterView *)pasterView {
    self.editZoneView.currentPasterView = pasterView;
    
    AliyunRenderBaseController * vc = pasterView.pasterController;
    self.editZoneView
    .currentPasterView = pasterView;
    self.editZoneView.currentPasterView.editStatus = YES;
    [self editPasterItemBy:vc]; // TimelineView联动
}

//使一个动图完成编辑
- (void)addPasterViewToDisplayAndRender:
(AliyunRenderBaseController *)pasterController
                           pasterFontId:(NSInteger)fontId {
    AliyunPasterView *pasterView =[[AliyunPasterView alloc] initWithRenderBaseController:pasterController];
    
    pasterView.pasterController = pasterController;
    pasterView.actionTarget = (id)self;
    CGAffineTransform t = CGAffineTransformIdentity;
    t = CGAffineTransformMakeRotation(-pasterController.model.rotation);
    pasterView.layer.affineTransform = t;
    [self.editZoneView addSubview:pasterView];
    pasterView.center = pasterController.model.center;
    
    [self makePasterControllerBecomeEditStatus:pasterView];

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
//        self.pasterManager.displaySize = editFrame.size;
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
    CGSize screenSize = UIScreen.mainScreen.bounds.size;
    CGFloat screenFactor = screenSize.height / screenSize.width;
    CGRect frame = CGRectZero;
    // 等比留白
    if (factor < screenFactor) {
        frame.size.width = screenSize.width;
        frame.size.height = screenSize.width * factor;
    } else {
        frame.size.height = screenSize.height;
        frame.size.width = frame.size.height / factor;
    }
    frame.origin.x = (screenSize.width - frame.size.width) * 0.5;
    frame.origin.y = (screenSize.height - frame.size.height) * 0.5;
    return frame;
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
        if ([self.editor getTimeFilter] == 3) { //倒放
            _processAnimationFilter.streamEndTime = 0;
        } else {
            _processAnimationFilter.streamEndTime = [self.player getStreamDuration];
        }
        
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
    
//    CVPixelBufferRef buffer = [[FURenderer shareRenderer] getPixelBufferFromTexture:srcTexture textureSize:size outputSize:size outputFormat:0];
////
    
    if ([FUGLContext shareGLContext].currentGLContext != [EAGLContext currentContext]) {
        [[FUGLContext shareGLContext] setCustomGLContext:[EAGLContext currentContext]];
    }
    FURenderInput *input = [[FURenderInput alloc] init];
    // 处理效果对比问题
    input.renderConfig.imageOrientation = FUImageOrientationDown;
    FUTexture tex = {srcTexture, CGSizeMake(size.width, size.height)};
    input.texture = tex;
    input.pixelBuffer = nil;

    //开启重力感应，内部会自动计算正确方向，设置fuSetDefaultRotationMode，无须外面设置
    input.renderConfig.gravityEnable = YES;
    input.renderConfig.textureTransform = CCROT0_FLIPVERTICAL;
    FURenderOutput *outPut = [[FURenderKit shareRenderKit] renderWithInput:input];
    if (outPut.texture.ID != 0) {
        return outPut.texture.ID;
    }
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
- (void)addAnimationFilter:(AliyunEffectFilter *)animationFilter toTimeline:(AliyunTimelineView *)timeline{
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
    [timeline addTimelineFilterItem:filterItem];
}

- (void)addAnimationFilterToTimeline:(AliyunEffectFilter *)animationFilter {
    [self addAnimationFilter:animationFilter toTimeline:self.currentTimelineView];
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

- (void)addPasterToTimeline:(AliyunRenderBaseController *)pasterController {
    AliyunTimelineItem *timeline = [[AliyunTimelineItem alloc] init];
    
    AliyunRenderModel *model = pasterController.model;
    
    timeline.startTime = model.startTime;
    timeline.endTime = model.startTime + model.duration;
    timeline.obj = pasterController;
    timeline.minDuration = 0.2;
    if ([pasterController isKindOfClass:[AliyunGifStickerController class]]) {
        [self.pasterShowView.timeLineView addTimelineItem:timeline];
    } else {
        [self.captionShowView.timeLineView addTimelineItem:timeline];
    }
}

- (void)removePasterFromTimeline:(AliyunRenderBaseController *)pasterController {
    if ([pasterController isKindOfClass:[AliyunGifStickerController class]]) {
        AliyunTimelineItem *timeline = [self.pasterShowView.timeLineView getTimelineItemWithOjb:pasterController];
        [self.pasterShowView.timeLineView removeTimelineItem:timeline];
    } else {
        AliyunTimelineItem *timeline = [self.captionShowView.timeLineView getTimelineItemWithOjb:pasterController];
        [self.captionShowView.timeLineView removeTimelineItem:timeline];
    }
}

- (void)editPasterItemBy:(AliyunRenderBaseController *)pasterController {
    AliyunTimelineItem *timeline =
    [self.currentTimelineView getTimelineItemWithOjb:pasterController];
    if ([pasterController isKindOfClass:[AliyunGifStickerController class]]) {
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

#pragma mark - AliyunTimelineViewDelegate -
//动图效果开始时间、结束时间调整
- (void)timelineDraggingTimelineItem:(AliyunTimelineItem *)item {
    NSLog(@"timelineDraggingTimelineItem");
    [[self.editor.getStickerManager getAllController] enumerateObjectsUsingBlock:^(AliyunRenderBaseController *pasterController, NSUInteger idx, BOOL *_Nonnull stop) {
        if ([pasterController isEqual:item.obj]) {
            pasterController.model.startTime = item.startTime;
            pasterController.model.duration = item.endTime - item.startTime;
//            pasterController.pasterMinDuration = item.endTime - item.startTime;
//            pasterController.pasterDuration = item.endTime - item.startTime;
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
   AliyunRenderBaseController * pasterController = pasterView.pasterController;
 
    if( [pasterController isKindOfClass:AliyunCaptionStickerController.class]){
        
        AliyunCaptionSticker *model = pasterController.model;
        [self  makePasterControllerBecomeEditStatus:pasterView];
        [self.tabController.textInputView setText:model.text];
        _currentTextInputView = self.tabController.textInputView;
        _currentTextInputView.delegate = self;
        [self.tabController.textInputView.textView becomeFirstResponder];
        
        int lastAnimationType = 0;
        
        if (model.getAllActionList.count) {
            NSArray<AliyunAction *> *actions = model.getAllActionList;
            lastAnimationType = [actions.lastObject sourceId].intValue;
        }
        
        if (model.getPartActionList.count) {
            lastAnimationType = [model.getPartActionList.lastObject.action sourceId].intValue;
        }
        
        [self.tabController setFontEffectDefault:lastAnimationType];
        
        [self.tabController alivcTabbarViewDidSelectedType:TabBarItemTypeKeboard];

    }
}

//删除动图
- (void)deleteEndPaster {
    
    [self removePasterFromTimeline:self.editZoneView.currentPasterView.pasterController];

    [[self.editor getStickerManager] remove:self.editZoneView.currentPasterView.pasterController];
    [self resetCurrentPasterView];
}

- (void)clickAnimation {
    NSLog(@"点击了动画按钮");
    NSArray *tabItems =  @[
               @(TabBarItemTypePasterAnimation)
           ];
    CGFloat hieght = 216;
    
    
    [self.gifTabController presentTabContainerViewInSuperView:self.view
                                                    height:hieght
                                                  duration:0.2
                                                  tabItems:tabItems];
    
    [self.gifTabController alivcTabbarViewDidSelectedType:TabBarItemTypePasterAnimation];
    
    
    
}
#pragma mark - AliyunEditZoneViewDelegate -
// EditZoneView的点击事件
- (void)currentTouchPoint:(CGPoint)point {
    if (_vcStatus == AlivcEditVCStatus_Normal) {
        return;
    }
    if (self.editZoneView.currentPasterView) { //如果当前有正在编辑的动图，且点击的位置正好在动图上
        BOOL hitSubview =[self.editZoneView.currentPasterView touchPoint:point
                                                                fromView:self.editZoneView];
        if (hitSubview == YES) {
            return;
        }
    }
    
    [self resetCurrentPasterView];

    AliyunRenderBaseController *pasterController =
    [self.editor.getStickerManager findControllerAtPoint:point
                            atTime:[self.player getCurrentStreamTime]];
    
    if (!pasterController) {
        return;
    }

    [self pause];
    
    
    [self addPasterViewToDisplayAndRender:pasterController pasterFontId:-1];
    
        //动图进入编辑状态，停止缩略图的滑动
    [self.currentTimelineView stopSlid];
}

//强制将上次正在编辑的动图进入编辑完成状态 - cm
- (void)forceFinishLastEditPasterView {

    [self resetCurrentPasterView];

    [self.currentTimelineView editTimelineComplete];
    
    // 产品要求 动图需要一直放在涂鸦下面，所以每次加新动图，需要重新加一次涂鸦
    if (self.paintImage) {
        [self.editor removePaint:self.paintImage];
        [self.editor applyPaint:self.paintImage linesData:self.paintView.lines];
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

- (void)tabControllerCompleteButtonClicked {
    [self.editZoneView setEditStatus:YES];

    AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;

    if ([caption isKindOfClass:[AliyunCaptionSticker class]]) {
        caption.text = self.tabController.textInputView.getText;
        [self.editZoneView.currentPasterView updateCaptionModel];
        
        [self animateWithObject:self.editZoneView.currentPasterView.pasterController animation:self.tabController.selectedActionType];
        
    } else if ([caption isKindOfClass:[AliyunGifSticker class]]) {
        [self animateWithObject:self.editZoneView.currentPasterView.pasterController animation:self.gifTabController.selectedActionType];
    }
    
    
    self.playButton.enabled = YES;
    [self destroyInputView];
}


- (void)tabControllerCancelButtonClicked {
    [self.editZoneView setEditStatus:YES];
    self.playButton.enabled = YES;
    [self destroyInputView];
}

- (AliyunEffectFontInfo *) confirmFontInfo:(AliyunEffectFontInfo *)fontInfo {
    if (!fontInfo || fontInfo.fontName.length == 0) {
        return nil;
    }
    
    UIFont *testFont = [UIFont fontWithName:fontInfo.fontName size:10];
    if (testFont) {
        return fontInfo;
    }
    
    NSString *fontPath = fontInfo.resourcePath;
    if (fontPath.length > 0) {
        fontPath = [NSHomeDirectory() stringByAppendingPathComponent:fontPath];
        fontPath = [fontPath stringByAppendingPathComponent:@"font.ttf"];
    }
    
    if (![NSFileManager.defaultManager fileExistsAtPath:fontPath]) {
        fontPath = [AliyunEffectFontManager.manager findFontPathWithName:fontInfo.fontName];
    }
    
    if (![NSFileManager.defaultManager fileExistsAtPath:fontPath]) {
        return nil;
    }
    
    NSString *registerFontName = [AliyunEffectFontManager.manager registerFontWithFontPath:fontPath];
    if (registerFontName.length == 0) {
        return nil;
    }
    
    testFont = [UIFont fontWithName:registerFontName size:10];
    if (testFont) {
        fontInfo.fontName = registerFontName;
        return fontInfo;
    }
    return nil;
}

- (void)tabControllerCaptionBubbleViewDidSeleted:(NSString *)path fontId:(NSInteger)fontId
{
   
    NSString *configJson = path;
    
    if (path.length > 0) {
        configJson = [NSString stringWithFormat:@"%@/%@/config.json",NSHomeDirectory(),path];
        //判断资源是否存在 config.json
        if(![[NSFileManager defaultManager] fileExistsAtPath:configJson]) {
            return;
        }
        
        configJson = [configJson stringByDeletingLastPathComponent];
    }
   
   // path.length = 0 清除
    
    
    
    AliyunCaptionStickerController *vc = self.editZoneView.currentPasterView.pasterController;
    
    AliyunCaptionSticker *caption = vc.model;
    caption.resourePath = configJson;
    
    AliyunEffectFontInfo *fontInfo = (AliyunEffectFontInfo *)[self.dbHelper queryEffectInfoWithEffectType:1 effctId:fontId];
    fontInfo = [self confirmFontInfo:fontInfo];
    
    if (fontInfo == nil) {
        __weak typeof(self) weakSelf = self;
        AliyunResourceFontDownload *download =[[AliyunResourceFontDownload alloc] init];
        [download downloadFontWithFontId:fontId progress:nil completion:^(AliyunEffectResourceModel *newModel, NSError *error) {
            if (!error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    caption.fontName = newModel.fontName;
                    [weakSelf.editZoneView.currentPasterView updateCaptionModel];
                });
            }
        }];
    } else {
        caption.fontName = fontInfo.fontName;
        [self.editZoneView.currentPasterView updateCaptionModel];
    }

    //    self.editZoneView.currentPasterView.op_width = vc.model.size.width * vc.model.scale;
    //    self.editZoneView.currentPasterView.op_height = vc.model.size.height * vc.model.scale;
}


- (void)tabControllerTextAndStrokeColor:(AliyunColor *)color
{
    AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;
    
    if(color.isBgColor){
        caption.backgroundColor = color.sA == 0 ? nil : [UIColor colorWithRed:color.tR/255.0 green:color.tG/255.0 blue:color.tB/255.0 alpha:1];
        return;
    }
    if (color.isStroke) {
        caption.outlineColor = [UIColor colorWithRed:color.sR/255.0 green:color.sG/255.0 blue:color.sB/255.0 alpha:color.sA];
    } else {
        caption.color = [UIColor colorWithRed:color.tR/255.0 green:color.tG/255.0 blue:color.tB/255.0 alpha:1];
    }
}

- (void)tabControllerStrokeWidth:(CGFloat)width
{
    AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;
    caption.outlineWidth = width;
}

- (void)tabControllerFontName:(NSString *)fontName faceType:(int)faceType
{
    AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;
    caption.fontName = fontName;
    caption.faceType = faceType;
    [self.editZoneView.currentPasterView updateCaptionModel];

}

- (void)tabControllerCaptionSeletedTabChanged:(int)seletedTab
{
//    if (seletedTab != 0) {
//        AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;
//        caption.text = self.tabController.textInputView.getText;
//        [self.editZoneView.currentPasterView updateUIFromModel];
//
//
//    }
}

- (void)tabControllerShadowColor:(UIColor *)color offset:(UIOffset)offset
{
    AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;
    caption.shadowColor = color;
    caption.shadowOffset = offset;
}

- (void)tabControllerFlowerDidSeleted:(NSString *)path
{
    AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;
    caption.fontEffectTemplatePath = path;
}

- (void)captionTextAlignmentSelected:(NSInteger)type{
    
    AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;
    caption.textAlignment = 1<<type;

}

//字体动画切换
- (void)textActionType:(TextActionType)actionType {
    if ([self.editor getTimeFilter] != 3 || actionType == TextActionTypeNull ||
        actionType == TextActionTypeClear) { //倒播
    } else {
        //        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"提示"
        //        message:@"倒播时不支持添加字幕动画效果" delegate:nil
        //        cancelButtonTitle:@"OK" otherButtonTitles:nil, nil]; [alert show];
        [MBProgressHUD showMessage:NSLocalizedString(@"倒播时不支持添加字幕动画效果", nil) inView:self.view];
    }
}


#pragma mark - AliyunPasterTextInputViewDelegate -

- (void)keyboardFrameChanged:(CGRect)rect animateDuration:(CGFloat)duration {
    NSArray *tabItems;
    if (self.currentEditPasterType == AliyunPasterEffectTypeSubtitle) {
        tabItems = @[
            @(TabBarItemTypeKeboard), @(TabBarItemTypeStyle), @(TabBarItemTypeBubble),
           @(TabBarItemTypeFlower), @(TabBarItemTypeAnimation)
        ];
    } else {
        tabItems = @[
            @(TabBarItemTypeKeboard), @(TabBarItemTypeStyle), @(TabBarItemTypeBubble),
            @(TabBarItemTypeFlower), @(TabBarItemTypeAnimation)
        ];
    }
    CGFloat hieght = rect.size.height;
    hieght = (hieght < 216 ? 216 : hieght);
    [self.tabController presentTabContainerViewInSuperView:self.view
                                                    height:hieght
                                                  duration:duration
                                                  tabItems:tabItems];

    self.playButton.enabled = NO;
    
}

- (void)textInputViewTextDidChanged
{
    
    NSString *text = _currentTextInputView.getText;
    
    if (text.length <=  0) {
        text = @"输入文本";
    }
 
    if (self.editZoneView.currentPasterView) {
        AliyunCaptionSticker *caption = self.editZoneView.currentPasterView.pasterController.model;
        caption.text = text;
        [self.editZoneView.currentPasterView updateCaptionModel];
    } else {
        [self addNewCaption:text];
    }


    
}


#pragma mark - 底部视图响应以及各视图代理

#pragma mark - AliyunEditButtonsViewDelegate - 底部容器视图

//滤镜
- (void)filterButtonClicked:(AliyunEditMaterialType)type {
    [self enterEditWithActionType:AliyunEditSouceClickTypeFilter animationCompletion:nil];
    
    if (!self.hasUesedintelligentFilter) {
        self.hasUesedintelligentFilter = YES;
        if (self.intelligentFilter) {
            [[self.editor getFilterManager] applyShadeFilterWithPath:[self.intelligentFilter localFilterResourcePath]];
            [self.filterView updateSelectedFilter:self.intelligentFilter];
            NSString *message = [NSString stringWithFormat:@"%@%@%@",[@"已为你智能推荐" localString],self.intelligentFilter.filterTypeName,[@"滤镜" localString]];
            [MBProgressHUD showMessage:message  inView:self.view];
        }
    }
}

//滤镜
- (void)lutFilterButtonClicked:(AliyunEditMaterialType)type {
    [self enterEditWithActionType:AliyunEditSouceClickTypeLutFilter animationCompletion:nil];

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
}

// mv
- (void)mvButtonClicked:(AliyunEditMaterialType)type {
    [self enterEditWithActionType:AliyunEditSouceClickTypeMV animationCompletion:nil];
    [self.mvView reloadDataWithEffectType:type];
    if (!_hasInitMVViewSelected) {
        _hasInitMVViewSelected = YES;
        for (AEPEffectMVTrack *mv in _editor.getEditorProject.timeline.effectTracks) {
            if ([mv isKindOfClass:AEPEffectMVTrack.class]) {
                self.mvGroup = [_mvView upateSelectedWithResource:mv.source.path];
            }
        }
    }
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
            if (weakSelf.paintView) {
                weakSelf.paintView.frame = weakSelf.editZoneView.bounds;
            }
            [weakSelf.editZoneView addSubview:weakSelf.paintView]; //添加画布
        }
    }];
    [self updateDrawRect:self.movieView.frame];
}

- (void)videoAugmentationButtonClicked {
    [self enterEditWithActionType:AliyunEditSouceClickTypeVideoAugmentation animationCompletion:nil];
}



//封面选择
- (void)coverButtonClicked {
    self.playButton.hidden = YES;
    self.currentTimelineView = self.coverSelectedView.timelineView;
    [self enterEditWithActionType:AliyunEditSouceClickTypeCover
              animationCompletion:^(BOOL finished){
        
    }];
}

//翻转字幕
- (void)rollCaptionClicked{
    [self enterEditWithActionType:AliyunEditSouceClickTypeRollCaption
              animationCompletion:nil];
}

#pragma mark - AliyunEffectFilter2ViewDelegate - 滤镜

- (void)didSelectEffectFilter:(AliyunEffectFilterInfo *)filter {
    if (filter.localFilterResourcePath) {
        [[self.editor getFilterManager] applyShadeFilterWithPath:filter.localFilterResourcePath];
        
    } else {
        
        NSArray *list = [[self.editor getFilterManager] getShaderFilterControllers];
        [[self.editor getFilterManager] removeFilter:list.firstObject];
    }
}
#pragma mark - AliyunEffectFilterViewDelegate - MV
- (void)didSelectEffectMV:(AliyunEffectMvGroup *)mvGroup {
    NSString *str = [mvGroup localResoucePathWithVideoRatio:(AliyunEffectMVRatio)[_config mediaRatio]];
    [self pause];
    if (mvGroup) {
        [self.editor removeMusics];
        [self.editor applyMV:[[AliyunEffectMV alloc] initWithFile:str]];
        [self.player seek:0];
    } else {
        [self.editor removeMV];
    }

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
        
        effectMusic.fadeIn = [[AliyunAudioFade alloc] init];
        effectMusic.fadeIn.shape = AliyunAudioFadeShapeLinear;
        effectMusic.fadeIn.duration = 3;
        
        effectMusic.fadeOut = [[AliyunAudioFade alloc] init];
        effectMusic.fadeOut.shape = AliyunAudioFadeShapeLinear;
        effectMusic.fadeOut.duration = 3;
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

- (void) resetCurrentPasterView
{
    self.editZoneView.currentPasterView.editStatus = NO;
    [self.editZoneView.currentPasterView removeFromSuperview];
    self.editZoneView.currentPasterView = nil;
}

#pragma mark - AliyunPasterShowViewDelegate - 动图贴图
//选择一个贴图
- (void)pasterBottomView:(AliyunPasterBottomBaseView *)bottomView didSelectedPasterModel:(AliyunEffectPasterInfo *)pasterInfo {
    if (self.userAction == AliyunEditUserEvent_Effect_Slider) {
        return;
    }
    //判断资源是否存在 config.json
    NSString *configJson = [NSString stringWithFormat:@"%@/%@/config.json",NSHomeDirectory(),pasterInfo.resourcePath];
    if(![[NSFileManager defaultManager] fileExistsAtPath:configJson]) {
        return;
    }
    
    [self pause];
    
 //动图在编辑状态下另外点击动图执行替换操作，else执行添加操作，业务需求
    
    configJson = [configJson stringByDeletingLastPathComponent];
    AliyunPasterRange range = [self calculatePasterStartTimeWithDuration:[pasterInfo defaultDuration]];

    
    BOOL editStaut = self.editZoneView.currentPasterView.editStatus;
    
    
    if (editStaut) {
        
        
        [self removePasterFromTimeline:self.editZoneView.currentPasterView.pasterController];

        [[self.editor getStickerManager] remove:self.editZoneView.currentPasterView.pasterController];

        [self resetCurrentPasterView];
    }
        
    AliyunGifStickerController *gifVC = [[self.editor getStickerManager] addGif:configJson startTime:range.startTime duration:range.duration];
    AliyunGifSticker *model = gifVC.model;
//    CGSize size = model.originSize;
//    CGFloat scale = [UIScreen mainScreen].scale;
//    model.size = CGSizeMake(size.width/scale, size.height/scale);
//    model.size = model.originSize;

    
        
    [self addPasterViewToDisplayAndRender:gifVC
                             pasterFontId:[pasterInfo.fontId integerValue]];
    
    [self addPasterToTimeline:gifVC];
    
    
}
//贴图、字幕气泡取消
- (void)pasterBottomViewCancel:(AliyunPasterBottomBaseView *)bottomView {
    
    //移除pasterview
    [self cancel];
    
    //倒序遍历删除本次操作类型的动图或者字幕，然后根据记录重新添加上次确认添加的动图或者字幕,由于目前SDK不支持撤销功能，所以暂时只能通过这种方式来实现本次操作的撤销功能
//    __weak typeof(self) weakSelf = self;
//    [self.curRenderList enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
//        AliyunRenderBaseController *pasterVC = (AliyunRenderBaseController *)obj;
//
//        [[weakSelf.editor getStickerManager] remove:pasterVC];
//        [weakSelf removePasterFromTimeline:pasterVC];
//    }];
    
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
    
}

//贴图确认
- (void)pasterBottomViewApply:(AliyunPasterBottomBaseView *)bottomView {
 
    [self apply];
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
    _lastPasterController = nil;
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
     
        }];
    }
}


#pragma mark - AliyunEffectCaptionShowViewDelegate - 字幕
//添加一个纯字幕
- (void)captionShowViewonClickAddNew {
    if (self.userAction == AliyunEditUserEvent_Effect_Slider) {
        return;
    }    
    [self pause];
    [self.playButton setSelected:YES];
    
    self.currentEditPasterType = AliyunPasterEffectTypeSubtitle;
    
    
    [self.tabController.textInputView setText:@"输入文本"];
    self.tabController.textInputView.delegate = self;
    [self.tabController.textInputView.textView becomeFirstResponder];
    _currentTextInputView = self.tabController.textInputView;
    [self addNewCaption:_currentTextInputView.getText];

}

- (void)animateWithObject:(AliyunRenderBaseController *)pasterController
                animation:(TextActionType)type
{
    
    AliyunRenderModel *model = pasterController.model;
    id<AliyunFrameAnimationProtocol> vc = pasterController;
    
    //1.移除普通动画
    if ([model isKindOfClass:[AliyunSticker class]]) {
        AliyunSticker *sticker = model;
        NSArray *tempList = [sticker getAllActionList];
        for (AliyunAction *action in tempList) {
            [vc removeFrameAnimation:action];
        }
    }
    
    //2.移除逐字动画
    if ([model isKindOfClass:[AliyunCaptionSticker class]]) {
        
        [[(AliyunCaptionSticker *)model getPartActionList] enumerateObjectsUsingBlock:^(AliyunPartAction * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            id<AliyunPartFrameAnimationProtocol> animaVC = vc;
            [animaVC removePartFrameAnimation:obj];
        }];
    }
    

    NSString *sourceId = [NSString stringWithFormat:@"%ld",type];
    
    switch (type) {
        case TextActionTypeClear: {
        } break;
        case TextActionTypeMoveLeft: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [model startTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(CGRectGetWidth(self.movieView.frame),
                                                model.center.y);
            moveAction.toPoint = model.center;
            moveAction.sourceId = sourceId;
            [vc addFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveRight: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [model startTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(model.size.width * -1,
                                                model.center.y);
            moveAction.toPoint = model.center;
            moveAction.sourceId = sourceId;
            [vc addFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveTop: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [model startTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(model.center.x,
                                                CGRectGetHeight(self.editZoneView.frame));
            moveAction.toPoint = model.center;
            moveAction.sourceId = sourceId;

            [vc addFrameAnimation:moveAction];
        } break;
        case TextActionTypeMoveDown: {
            AliyunMoveAction *moveAction = [[AliyunMoveAction alloc] init];
            moveAction.startTime = [model startTime];
            moveAction.duration = 1;
            moveAction.fromePoint = CGPointMake(model.center.x,
                                                model.size.height * -1);
            moveAction.toPoint = model.center;
            moveAction.sourceId = sourceId;
            [vc addFrameAnimation:moveAction];
        } break;
        case TextActionTypeLinerWipe: {
            AliyunWipeAction *wipe = [[AliyunWipeAction alloc] init];
            wipe.startTime = [model startTime];
            wipe.duration = 1;
            wipe.direction = AliWipeActionDirection_LeftToRight;
            wipe.wipeMode = AliWipeActionMode_Appear;
            wipe.sourceId = sourceId;

            [vc addFrameAnimation:wipe];
        } break;
        case TextActionTypeFade: {
            AliyunAlphaAction *alphaAction_in = [[AliyunAlphaAction alloc] init]; //淡入
            alphaAction_in.startTime = [model startTime];
            alphaAction_in.duration = 0.5;
            alphaAction_in.fromAlpha = 0.2f;
            alphaAction_in.toAlpha = 1.0f;
            
            AliyunAlphaAction *alphaAction_out = [[AliyunAlphaAction alloc] init]; //淡出
            alphaAction_out.startTime = model.startTime +1;
            alphaAction_out.duration = 0.5;
            alphaAction_out.fromAlpha = 1.0f;
            alphaAction_out.toAlpha = 0.2f;
            //            [effectPaster runAction:alphaAction_in];
            //            [effectPaster runAction:alphaAction_out];
            
            alphaAction_in.sourceId = sourceId;
            alphaAction_out.sourceId = sourceId;
            [vc addFrameAnimation:alphaAction_in];
            [vc addFrameAnimation:alphaAction_out];


            
        } break;
        case TextActionTypeScale: {
            AliyunScaleAction *scaleAction = [[AliyunScaleAction alloc] init];
            scaleAction.startTime =model.startTime;
            scaleAction.duration = 1;
            scaleAction.fromScale = 1.0;
            scaleAction.toScale = 0.25;
            scaleAction.sourceId = sourceId;
            [vc addFrameAnimation:scaleAction];
        } break;
            
        case TextActionTypePrinter:
        {
            float startTime = model.startTime;
            float duration = 2;
            AliyunAlphaAction *action = [[AliyunAlphaAction alloc] init];
            action.startTime = startTime;
            action.duration = duration;
            action.fillBefore = YES;
            action.animationConfig = @"0:0;0.7:1;";
            action.sourceId = sourceId;

            AliyunPartAction *partAimation = [[AliyunPartAction alloc] initWithAction:action];
            if ([vc conformsToProtocol:@protocol(AliyunPartFrameAnimationProtocol)]) {
                id<AliyunPartFrameAnimationProtocol> animaVC = vc;
                [animaVC addPartFrameAnimation:partAimation];
            }

        }
            break;
        case TextActionTypeClock:
        {
            
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunSetAction *action = [[AliyunSetAction alloc]init];
            action.subSetMode = AliyunSetActionPlayModeIndependent;
        
          //首选向左转 30度
          AliyunRotateByAction *action1 = [[AliyunRotateByAction alloc] init];
          action1.fromDegree = 0;
          action1.rotateDegree = -M_PI/6.0;
         action1.normalizedCenter = CGPointMake(0, 1);
            
          action1.startTime = startTime;
         action1.duration = duration/6;
            
            AliyunRotateByAction *action2 = [[AliyunRotateByAction alloc] init];
            action2.fromDegree = -M_PI/6.0;
            action2.rotateDegree = M_PI/3.0;
            action2.normalizedCenter = CGPointMake(0, 1);
            action2.repeatMode = 2;
            
            action2.startTime = startTime + action1.duration;
            action2.duration = duration * 2 / 6.0;

  
            action.sourceId = sourceId;
            action.subList = @[action1, action2];
            [vc addFrameAnimation:action];

        }
            break;
        case TextActionTypeBrush:
        {
            
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = AliyunSetActionPlayModeIndependent;

            //雨刷使用RotateTo的实现
            AliyunRotateToAction *lActionRotateTo1 = [AliyunRotateToAction new];
            //首选向右转 30度
            lActionRotateTo1.fromDegree = 0;
            lActionRotateTo1.toDegree = M_PI/6.0;
            lActionRotateTo1.normalizedCenter = CGPointMake(0, -1);
            lActionRotateTo1.startTime = startTime;
            lActionRotateTo1.duration = duration/6.0;
            //再向左转60，并来回转动
            AliyunRotateToAction * lActionRotateTo2 = [AliyunRotateToAction new];
            lActionRotateTo2.fromDegree = M_PI/6.0;
            lActionRotateTo2.toDegree = -M_PI/6.0;
            lActionRotateTo2.normalizedCenter = CGPointMake(0, -1);

            lActionRotateTo2.repeatMode = AliyunActionRepeatModeReverse;
            lActionRotateTo2.startTime = startTime + lActionRotateTo1.duration  ;
            lActionRotateTo2.duration = duration/3;

            action.sourceId = sourceId;
            action.subList = @[lActionRotateTo1,lActionRotateTo2];
            [vc addFrameAnimation:action];


        }
            break;
        case TextActionTypeSet_1:
        {
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = AliyunSetActionPlayModeTogether;
      
            AliyunAlphaAction *lActionFade1 = [AliyunAlphaAction new];
            lActionFade1.fromAlpha  = 0.1;
            lActionFade1.toAlpha  = 1;
            lActionFade1.startTime = startTime;
            lActionFade1.duration = duration;
            lActionFade1.fillBefore = YES;
            
            AliyunAlphaAction *lActionFade2 = [AliyunAlphaAction new];
            lActionFade2.fromAlpha  = 1;
            lActionFade2.toAlpha  =0.1;
            lActionFade2.startOffset = duration/4.0 * 3;

            lActionFade2.duration = duration/4.0;

     

            AliyunRotateByAction *lActionRotateBy1 = [AliyunRotateByAction new];
            lActionRotateBy1.fromDegree = 0;
            lActionRotateBy1.rotateDegree = M_PI * 2.0;
            lActionRotateBy1.duration = duration/2.0;
            lActionRotateBy1.fillBefore = YES;
            lActionRotateBy1.fillAfter = YES;

            AliyunScaleAction *lActionScale1 = [AliyunScaleAction new];
            lActionScale1.fromScale = 0.25;
            lActionScale1.toScale = 1.0;
            lActionScale1.duration = duration/2.0;
            lActionScale1.fillBefore = YES;
            lActionScale1.fillAfter = YES;
            action.sourceId = sourceId;
            action.subList = @[lActionFade1,lActionFade2,lActionRotateBy1,lActionScale1];
            action.startTime = startTime;
            action.duration = duration;
            [vc addFrameAnimation:action];
        }
            break;
        case TextActionTypeSet_2:
        {
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = 1;

            AliyunAlphaAction *lActionFade1 = [AliyunAlphaAction new];
            lActionFade1.fromAlpha  = 1;
            lActionFade1.toAlpha  =1;
            lActionFade1.startTime = 0.f;
            lActionFade1.duration = duration/3.0;
            lActionFade1.fillAfter = YES;
            

            
            
            AliyunRotateByAction *lActionRotateBy1 = [AliyunRotateByAction new];
            lActionRotateBy1.fromDegree = 0;
            lActionRotateBy1.rotateDegree = M_PI * 2.0;
            lActionRotateBy1.duration = duration/2.0;
            lActionRotateBy1.fillAfter = YES;


            AliyunScaleAction *lActionScale1 = [AliyunScaleAction new];
            lActionScale1.fromScale = 0.f;
            lActionScale1.toScale = 1.0;
            lActionScale1.startTime = 0.f;
            lActionScale1.duration = duration/2.0;
            lActionScale1.fillAfter = YES;

            action.subList = @[lActionFade1,lActionRotateBy1,lActionScale1];
            action.startTime = startTime;
            action.duration = duration;
            action.sourceId = sourceId;
            [vc addFrameAnimation:action];

        }
            break;
        case TextActionTypeWave:
        {
        
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunCustomAction *custom = [AliyunCustomAction new];
            
            
            NSString *dirPath =  [[NSBundle mainBundle] pathForResource:@"AnimationFrag.bundle" ofType:nil];
            
            NSString *vertexPath = [dirPath stringByAppendingPathComponent:@"wave.vert"];
            
            NSString *vertexFunc = [NSString stringWithContentsOfFile:vertexPath encoding:kCFStringEncodingUTF8 error:nil];
            
            
            NSString *fragmentPath =  [dirPath stringByAppendingPathComponent:@"wave.frag"];
            NSString *fragmentFunc = [NSString stringWithContentsOfFile:fragmentPath encoding:kCFStringEncodingUTF8 error:nil];
            
            
            custom.vertexShader = vertexFunc;
            custom.fragmentShader = fragmentFunc;
            custom.startTime = startTime;
            custom.duration = duration;
            custom.sourceId = sourceId;
            [vc addFrameAnimation:custom];

        }
            break;
        case TextActionTypeScrewUp:
        {
            float startTime = model.startTime;
            float duration = 3;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = 0;
            
            AliyunActionPartParam *lPartParam = [AliyunActionPartParam new];
            lPartParam.partMode = 0;
            lPartParam.partOverlayRadio = 0.7;
            
            AliyunPartAction *partAimation = [[AliyunPartAction alloc] initWithAction:action];
            partAimation.partParam = lPartParam;
            
            AliyunAlphaAction *lActionFade1 = [AliyunAlphaAction new];
            lActionFade1.fromAlpha  = 0.1;
            lActionFade1.toAlpha  = 1;
            lActionFade1.duration = duration/4.0;
            lActionFade1.fillBefore = YES;
            lActionFade1.fillAfter = YES;


            AliyunRotateByAction *lActionRotateBy1 = [AliyunRotateByAction new];
            lActionRotateBy1.fromDegree = 0;
            lActionRotateBy1.rotateDegree = M_PI * 2.0;
            lActionRotateBy1.duration = duration/2.0;
            lActionRotateBy1.fillBefore = YES;
            lActionRotateBy1.fillAfter = YES;
            lActionRotateBy1.repeatMode = AliyunActionRepeatModeNormal;


            AliyunMoveAction *lActionTranslate = [[AliyunMoveAction alloc]init];
            lActionTranslate.translateType = 1;
            lActionTranslate.startTime = 0;
            lActionTranslate.duration = duration;
            lActionTranslate.fromePoint = CGPointMake(model.center.x, model.center.y + 300);
            lActionTranslate.toPoint = CGPointMake(model.center.x, model.center.y);
            lActionTranslate.fillBefore = YES;


            action.fillBefore = YES;
            action.duration = duration * 3 / 4.0;
            action.startTime = startTime;
            action.subList = @[lActionFade1,lActionRotateBy1,lActionTranslate];
            
            action.sourceId = sourceId;
            if ([vc conformsToProtocol:@protocol(AliyunPartFrameAnimationProtocol)]) {
                id<AliyunPartFrameAnimationProtocol> animaVC = vc;
                [animaVC addPartFrameAnimation:partAimation];
            }

        }
            break;
        case TextActionTypeHeart:
        {
            AliyunScaleAction *lActionScale1 = [AliyunScaleAction new];

            lActionScale1.animationConfig =
            
           @"0:1.0,1.0;0.06:0.92,0.92;0.12:1.0252,1.0252;0.18:1.1775,1.1775;0.24:1.3116,1.3116;0.3:1.4128,1.4128;0.36:1.4761,1.4761;0.42:1.5,1.5;0.48:1.5,1.5;0.54:1.4727,1.4727;0.6:1.4089,1.4089;0.66:1.3093,1.3093;0.72:1.1779,1.1779;0.78:1.0283,1.0283;0.9:0.92,0.92;1.0:1.0,1.0;";


            
            lActionScale1.startTime = model.startTime;
            lActionScale1.duration = 2;
            lActionScale1.repeatMode = AliyunActionRepeatModeNormal;
            lActionScale1.sourceId = sourceId;
            [vc addFrameAnimation:lActionScale1];
        }
            break;
        case TextActionTypeCircularScan:
        {
            float startTime = model.startTime;
            float duration = 4;
            
            AliyunCustomAction *custom = [AliyunCustomAction new];
            
            NSString *dirPath =  [[NSBundle mainBundle] pathForResource:@"AnimationFrag.bundle" ofType:nil];
            
            NSString *vertexPath = [dirPath stringByAppendingPathComponent:@"round_scan.vert"];
            

            NSString *vertexFunc = [NSString stringWithContentsOfFile:vertexPath encoding:kCFStringEncodingUTF8 error:nil];
            
            
            NSString *fragmentPath = [dirPath stringByAppendingPathComponent:@"round_scan.frag"];
            NSString *fragmentFunc = [NSString stringWithContentsOfFile:fragmentPath encoding:kCFStringEncodingUTF8 error:nil];
            
            
            custom.vertexShader = vertexFunc;
            custom.fragmentShader = fragmentFunc;
            custom.startTime = startTime;
            custom.duration = duration;
            custom.sourceId = sourceId;

            [vc addFrameAnimation:custom];

        }
            break;
        case TextActionTypeWaveIn:
        {
            float startTime = model.startTime;
            float duration = model.duration;
            
            AliyunSetAction *action = [AliyunSetAction new];
            action.subSetMode = 0;
            
            
            AliyunActionPartParam *lPartParam = [AliyunActionPartParam new];
            lPartParam.partMode = AliyunActionPartParamModeSequence;
            lPartParam.partOverlayRadio = 0.6;
            
            AliyunPartAction *partAimation = [[AliyunPartAction alloc] initWithAction:action];
            partAimation.partParam = lPartParam;

            
            AliyunMoveAction *lActionTranslate = [[AliyunMoveAction alloc]init];
            lActionTranslate.translateType = 1;
            lActionTranslate.startTime = 0;
            lActionTranslate.duration = duration/2;
            lActionTranslate.fromePoint = CGPointMake(model.center.x, model.center.y);
            lActionTranslate.toPoint = CGPointMake(model.center.x, model.center.y + 300);
            lActionTranslate.fillBefore = YES;
            

            AliyunMoveAction *lActionTranslate2 = [[AliyunMoveAction alloc]init];
            lActionTranslate2.translateType = 1;
            lActionTranslate2.startOffset = duration / 2.0f;
            lActionTranslate2.duration = duration/2;
            lActionTranslate2.fromePoint = CGPointMake(model.center.x, model.center.y + 300);
            lActionTranslate2.toPoint = CGPointMake(model.center.x, model.center.y);
            lActionTranslate2.fillAfter = YES;
    
            AliyunAlphaAction *lActionFade1 = [AliyunAlphaAction new];
            lActionFade1.fromAlpha  = 0.0;
            lActionFade1.toAlpha  = 1;
            lActionFade1.startTime = 0.f;
            lActionFade1.duration = duration/4.0;
            lActionFade1.fillBefore = YES;


            action.subList = @[lActionTranslate,lActionTranslate2,lActionFade1];
            action.fillBefore = YES;
            action.fillAfter = YES;
            
            action.startTime = startTime;
            action.duration = duration;
            
            action.sourceId = sourceId;

            if ([vc conformsToProtocol:@protocol(AliyunPartFrameAnimationProtocol)]) {
                id<AliyunPartFrameAnimationProtocol> animaVC = vc;
                [animaVC addPartFrameAnimation:partAimation];
            }
        }
            break;
            
            
        default:
            break;
    }

}

- (void)addNewCaption:(NSString *)text
{
    [self forceFinishLastEditPasterView];
   
    AliyunPasterRange range = [self calculatePasterStartTimeWithDuration:1];
    AliyunCaptionStickerController *captionController = [[self.editor getStickerManager] addCaptionText:text bubblePath:nil startTime:range.startTime duration:range.duration];
    
    
    [self addPasterViewToDisplayAndRender:captionController pasterFontId:-1];
    [self addPasterToTimeline:captionController]; //加到timelineView联动
    
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
    [self.editor applyPaint:self.paintImage linesData:self.paintView.lines];
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
    [self.editor applyPaint:self.paintImage linesData:self.paintView.lines];
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
        [self.editor applyPaint:self.paintImage linesData:self.paintView.lines];
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
                         @(AlivcEffectSoundTypeDevil):@(AliyunAudioEffectBigDevil),
                         @(AlivcEffectSoundTypeDialect):@(AliyunAudioEffectDialect),
    };
    return (AliyunAudioEffectType)[dic[@(type)] integerValue];
}

-(AlivcEffectSoundType)getProjectType:(AliyunAudioEffectType)type{
    NSDictionary *dic =@{@(AliyunAudioEffectLolita):@(AlivcEffectSoundTypeLolita),
                         @(AliyunAudioEffectUncle):@(AlivcEffectSoundTypeUncle),
                         @(AliyunAudioEffectEcho):@(AlivcEffectSoundTypeEcho),
                         @(AliyunAudioEffectReverb):@(AlivcEffectSoundTypeRevert),
                         @(AliyunAudioEffectDenoise):@(AlivcEffectSoundTypeDenoise),
                         @(AliyunAudioEffectMinions):@(AlivcEffectSoundTypeMinion),
                         @(AliyunAudioEffectRobot):@(AlivcEffectSoundTypeRobot),
                         @(AliyunAudioEffectBigDevil):@(AlivcEffectSoundTypeDevil),
                         @(AliyunAudioEffectDialect):@(AlivcEffectSoundTypeDialect),
    };
    return (AlivcEffectSoundType)[dic[@(type)] integerValue];
}

#pragma mark - AliyunVideoAugmentationViewDelegate

- (void)videoAugmentationDidSelectType:(NSInteger)type value:(CGFloat)value {
    for (AliyunClip *clip in [self.editor getClipConstructor].mediaClips) {
        if (type == -1) {
            [self.editor resetVideoAugmentation:AliyunVideoAugmentationTypeBrightness streamId:clip.streamId];
            [self.editor resetVideoAugmentation:AliyunVideoAugmentationTypeContrast streamId:clip.streamId];
            [self.editor resetVideoAugmentation:AliyunVideoAugmentationTypeSaturation streamId:clip.streamId];
            [self.editor resetVideoAugmentation:AliyunVideoAugmentationTypeSharpness streamId:clip.streamId];
            [self.editor resetVideoAugmentation:AliyunVideoAugmentationTypeVignette streamId:clip.streamId];
            
            [self resetVideoAugmentationValue];
        }
        else {
            [self.editor setVideoAugmentation:(AliyunVideoAugmentationType)type value:value streamId:clip.streamId];
            [self updateVideoAugmentationValue:value forType:type];
        }
    }
}

- (float)videoAugmentationGetCurrentValue:(NSInteger)type
{
    return [self getVideoAugmentationValue:type];
}

- (NSMutableDictionary *)videoAugmentationValues {
    if (_videoAugmentationValues == nil) {
        AliyunClip *clip = [self.editor getClipConstructor].mediaClips.firstObject;
        _videoAugmentationValues = [NSMutableDictionary dictionary];
        [_videoAugmentationValues setObject:@(0.0) forKey:@(-1)]; // 重置
        [_videoAugmentationValues setObject: clip ? @(clip.brightnessValue) : @(AliyunVideoBrightnessDefaultValue) forKey:@(AliyunVideoAugmentationTypeBrightness)]; // 亮度
        [_videoAugmentationValues setObject: clip ? @(clip.contrastValue) : @(AliyunVideoContrastDefaultValue) forKey:@(AliyunVideoAugmentationTypeContrast)]; // 对比度
        [_videoAugmentationValues setObject: clip ? @(clip.saturationValue) : @(AliyunVideoSaturationDefaultValue) forKey:@(AliyunVideoAugmentationTypeSaturation)]; // 饱和度
        [_videoAugmentationValues setObject: clip ? @(clip.sharpnessValue) : @(AliyunVideoSharpnessDefaultValue) forKey:@(AliyunVideoAugmentationTypeSharpness)]; // 锐度
        [_videoAugmentationValues setObject: clip ? @(clip.vignetteValue) : @(AliyunVideoVignetteDefaultValue) forKey:@(AliyunVideoAugmentationTypeVignette)]; // 暗角
    }
    
    return _videoAugmentationValues;
}

- (void)resetVideoAugmentationValue {
    _videoAugmentationValues = nil;
}

- (float)getVideoAugmentationValue:(NSInteger)type {
    return [[[self videoAugmentationValues] objectForKey:@(type)] floatValue];
}

- (void)updateVideoAugmentationValue:(CGFloat)value forType:(NSInteger)type {
    if (type == -1) {
        [[self videoAugmentationValues] setObject:@(AliyunVideoBrightnessDefaultValue) forKey:@(AliyunVideoAugmentationTypeBrightness)];
        [[self videoAugmentationValues] setObject:@(AliyunVideoContrastDefaultValue) forKey:@(AliyunVideoAugmentationTypeContrast)];
        [[self videoAugmentationValues] setObject:@(AliyunVideoSaturationDefaultValue) forKey:@(AliyunVideoAugmentationTypeSaturation)];
        [[self videoAugmentationValues] setObject:@(AliyunVideoSharpnessDefaultValue) forKey:@(AliyunVideoAugmentationTypeSharpness)];
        [[self videoAugmentationValues] setObject:@(AliyunVideoVignetteDefaultValue) forKey:@(AliyunVideoAugmentationTypeVignette)];
    }
    else {
        [[self videoAugmentationValues] setObject:@(value) forKey:@(type)];
    }
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
    _coverImage = [self.editor screenCapture];
    if (!_coverImage) {
        _coverImage = [self screenShotView:self.movieView];
    }
    if (_coverImage) {
        [self.editor updateCover:_coverImage];
    }
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

#pragma --mark AlivcRollCaptionViewDelegate - 翻转字幕
-(void)didRollCaptionSelColor:(UIColor*)color {
    AliyunRollCaptionComposer *rollCaptionComposer = [self.editor rollCaptionComposer];
    for (AliyunRollCaptionItemStyle *stlye in self.rollCaptionView.wordList) {
        [stlye setTextColor:color];
    }
    [rollCaptionComposer updateCaptionList:self.rollCaptionView.wordList];
}

-(void)didRollCaptionSelFont:(NSString*)fontName{
    AliyunRollCaptionComposer *rollCaptionComposer = [self.editor rollCaptionComposer];
    for (AliyunRollCaptionItemStyle *stlye in self.rollCaptionView.wordList) {
        [stlye setFontName:fontName];
    }
    [rollCaptionComposer updateCaptionList:self.rollCaptionView.wordList];
}

-(void)didRollCaptionClickWordsBtn{
    AliyunRollCaptionWordsController *vc = [[AliyunRollCaptionWordsController alloc] init];
    vc.dataArr = self.rollCaptionView.wordList;
    self.isRollCaptionType = YES;
    __weak typeof(self) weakSelf = self;
    vc.didChangeWordsFinish = ^(NSArray * _Nonnull dataArr) {
        AliyunRollCaptionComposer *rollCaptionComposer = [weakSelf.editor rollCaptionComposer];
        [rollCaptionComposer updateCaptionList:dataArr];
    };
    vc.didBack = ^{
        self.isRollCaptionType = NO;
    };
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:vc animated:YES completion:nil];
}

-(void)didRollCaptionClickFinishBtn{
    
    //应用翻转字幕后 从初始位置开始播放
    [self.player seek:0];
    [self play];
    
    AliyunRollCaptionComposer *rollCaptionComposer = [self.editor rollCaptionComposer];
    [rollCaptionComposer show];
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}

-(void)didRollCaptionClickClearBtn{
    AliyunRollCaptionComposer *rollCaptionComposer = [self.editor rollCaptionComposer];
    [rollCaptionComposer reset];
    [self quitEditWithActionType:_editSouceClickType CompletionHandle:nil];
}

#pragma mark - AliyunLutFilterViewDelegate

- (void)lutFilterViewDelegateDidSelectLutFilter:(NSString *)path indensity:(float)indensity
{
    if (path.length > 0) {
        [[self.editor getFilterManager] applyLutFilterWithPath:path intensity:indensity];
    } else {
        [[self.editor getFilterManager] removeFilter:[[self.editor getFilterManager] getLutFilterControllers].firstObject];

    }
}

- (void)lutFilterViewDelegateDidUpdateIndensity:(float)indensity
{
    NSArray *list = [[self.editor getFilterManager] getLutFilterControllers];
    if (list.count) {
        
        AliyunLutFilterController *lutVC = list.firstObject;
        lutVC.model.intensity = indensity;
    }
}

@end
