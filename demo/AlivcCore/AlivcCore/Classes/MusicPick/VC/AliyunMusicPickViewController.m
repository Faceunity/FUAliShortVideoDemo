//
//  AliyunMusicPickViewController.m
//  qusdk
//
//  Created by Worthy on 2017/6/7.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//      

#import "AliyunMusicPickViewController.h"
#import "AliyunMusicPickHeaderView.h"
#import "AliyunMusicPickCell.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAsset+VideoInfo.h"
#import "AliyunMusicPickTopView.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AliyunLibraryMusicImport.h"
#import "AliyunPathManager.h"
#import "AliyunMusicPickTabView.h"
#import "AlivcUIConfig.h"
//#import <AliyunVideoSDKPro/AliyunNativeParser.h>
//#import <AliyunVideoSDKPro/AliyunCrop.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import "AVC_ShortVideo_Config.h"
//#import <AFNetworking.h>
#import "AliyunResourceDownloadManager.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectInfo.h"
#import "AliyunEffectModelTransManager.h"
#import "AliyunDBHelper.h"
#import "UIView+AlivcHelper.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AliyunResourceRequestManager.h"
#import "AlivcWebViewController.h"
#import <AliyunVideoSDKPro/AliyunNativeParser.h>

//缓存远程音乐的文件路径
#define tmpMusicPath [NSTemporaryDirectory() stringByAppendingString:@"tmpMusicPath"]
#define tmpLoacalMusicPath [NSTemporaryDirectory() stringByAppendingString:@"tmpLocalMusicPath"]
//缓存page文件的路径
#define tmpPagePath [NSTemporaryDirectory() stringByAppendingString:@"tmpPagePath"]

@interface AliyunMusicPickViewController () <UITableViewDelegate, UITableViewDataSource, AliyunMusicPickHeaderViewDelegate, AliyunMusicPickCellDelegate, AliyunMusicPickTopViewDelegate,AliyunMusicPickTabViewDelegate,UITextViewDelegate>
{
    AliyunMusicPickModel *_selectedMusic;
}
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AliyunMusicPickTopView *topView;
@property (nonatomic, strong) AliyunMusicPickTabView *tabView;
//@property (nonatomic, strong) NSMutableArray *musics; //当前展示的音乐 远程或者本地
@property (nonatomic, strong) NSMutableArray *remoteMusics; //远程的音乐列表
@property (nonatomic, strong) NSMutableArray *iTunesMusics; //本地的音乐列表
@property (nonatomic, strong) NSMutableArray *downloadingMusics;
@property (nonatomic, assign) NSInteger selectedSection;
@property (nonatomic, assign) NSInteger selectedSection_remote;
@property (nonatomic, assign) NSInteger selectedSection_local;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, assign) NSInteger startTime; //单位是毫秒
@property (nonatomic, strong) AliyunDBHelper *dbHelper;
@property (nonatomic, weak) UITextView *bottomTextView;
@property (nonatomic, strong)AliyunResourceDownloadManager *downloadManager;


@property (nonatomic, assign) NSInteger selectedTab;


/**
 之前应用的远程音乐 - 用于左右切换设置原先的值
 */
@property (nonatomic, strong) AliyunMusicPickModel *selectedMusic_remote;
/**
 之前应用的本地音乐 - 用于左右切换设置原先的值
 */
@property (nonatomic, strong) AliyunMusicPickModel *selectedMusic_local;

@property (nonatomic, strong) AliyunPage *page;

@property (nonatomic, assign) BOOL isLoading; //是否正在加载

@property (nonatomic, weak) UIActivityIndicatorView *indicatorView;//loading指示器

@property (nonatomic, strong) UIView *emptyTableViewHeader;

@property (nonatomic, strong) UISearchController *searchC;

@end

@implementation AliyunMusicPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setupSubviews];
    [self addNotification];
    
    //如果有选中的音乐 则恢复历史状态
    if(self.selectedMusic){
        [self restoreRemoteMusic];
    }
    //初始化
    self.downloadingMusics = [NSMutableArray array];
    self.downloadManager = [[AliyunResourceDownloadManager alloc]init];
    
    if (!_duration) {
        _duration = 8;
    }
    [self updateSelectedMusic];
    [self.tabView setSelectedTab:self.selectedTab];
    // 弹出本地音乐权限提示框
    [MPMediaQuery songsQuery];
    
    
}



- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (self.player) {
        [self.player pause];
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        self.player = nil;
    }
    if (self.downloadManager) {
        self.downloadManager = nil;
    }
    //缓存当时的数组
    [self storeMusic];
}


-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.view bringSubviewToFront:self.bottomTextView];
    //更新选中的音乐
    [self updateSelectedMusic];
    //    [self.tabView setSelectedTab:self.selectedTab];
}
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)dealloc {
    //    [self removeNotification];
    if (self.player) {
        [self.player pause];
        [self.player.currentItem cancelPendingSeeks];
        [self.player.currentItem.asset cancelLoading];
        self.player = nil;
    }
    if (self.downloadManager) {
        self.downloadManager = nil;
    }
}

/**
 还原历史数据
 */
- (void)restoreRemoteMusic {
    self.remoteMusics = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpMusicPath];
    self.page = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpPagePath];
    
    self.iTunesMusics = [NSKeyedUnarchiver unarchiveObjectWithFile:tmpLoacalMusicPath];
}

/**
 存储历史数据
 */
- (void)storeMusic {
    for (AliyunMusicPickModel *model  in self.remoteMusics) {
        model.expand = NO;
    }
    [NSKeyedArchiver archiveRootObject:self.remoteMusics toFile:tmpMusicPath];
    [NSKeyedArchiver archiveRootObject:self.page toFile:tmpPagePath];
    
    for (AliyunMusicPickModel *model  in self.iTunesMusics) {
        model.expand = NO;
    }
    [NSKeyedArchiver archiveRootObject:self.iTunesMusics toFile:tmpLoacalMusicPath];
    
}

/**
 更新本地，远程选择的音乐
 */
- (void)updateSelectedMusic{
    if (self.selectedTab == 0) {
        self.selectedMusic_remote = self.selectedMusic;
    }else{
        self.selectedMusic_local = self.selectedMusic;
    }
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
-(void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat offsetY = 0;
    if (self.searchC.isActive) {
        offsetY = 44 + 56;
    }
    CGFloat topViewY = SafeTop - offsetY;
    self.topView.frame = CGRectMake(0, topViewY, ScreenWidth, 44);
    self.tabView.frame = CGRectMake(0, 44 + topViewY, ScreenWidth, 44);
    CGFloat tableY = 88 + SafeTop - offsetY;
    self.tableView.frame = CGRectMake(0, tableY, ScreenWidth, self.view.bounds.size.height  - 30 - tableY-SafeAreaBottom);
}

- (void)setupSubviews {
    
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    self.view.backgroundColor = [UIColor whiteColor];
    UIImageView *imageView = [[UIImageView alloc]initWithImage:[AlivcImage imageNamed:@"shortVideo_musicBackground"]];
    imageView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    //    imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:imageView];
    
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = CGRectMake(0, 0, ScreenWidth, ScreenHeight);
    [self.view addSubview:blurEffectView];
    
    self.topView = [[AliyunMusicPickTopView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44)];
    self.topView.delegate = self;
    [self.view addSubview:self.topView];
    
    self.tabView = [[AliyunMusicPickTabView alloc] initWithFrame:CGRectMake(0, 44+SafeTop, ScreenWidth, 44)];
    self.tabView.delegate = self;
    [self.view addSubview:self.tabView];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero];
    [self.tableView registerClass:[AliyunMusicPickCell class] forCellReuseIdentifier:@"AliyunMusicPickCell"];
    [self.tableView registerClass:[AliyunMusicPickHeaderView class] forHeaderFooterViewReuseIdentifier:@"AliyunMusicPickHeaderView"];
    [self.tableView registerClass:[UITableViewHeaderFooterView class] forHeaderFooterViewReuseIdentifier:@"UITableViewHeaderFooterView"];
    
    
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorColor = [UIColor grayColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
    //设置footerView
    UIView *loadingView= [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 40)];
    UIActivityIndicatorView *indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    [loadingView addSubview:indicatorView];
    indicatorView.center = CGPointMake(ScreenWidth * 0.5, 20);
    self.indicatorView = indicatorView;
    self.tableView.tableFooterView = loadingView;
    
    [self.view addSubview:self.tableView];
    
    UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, ScreenHeight-30-SafeAreaBottom, ScreenWidth, 30)];
    [self.view addSubview:textView];
    self.bottomTextView = textView;
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:NSLocalizedString(@"Provided by Taihe Music DMH  How to get", nil) attributes:@{
        NSForegroundColorAttributeName:[UIColor whiteColor],
        NSFontAttributeName:[UIFont systemFontOfSize:12]
    }];
    [attributedString addAttributes:@{
        NSLinkAttributeName:@"click://",
        NSUnderlineStyleAttributeName:@(1)
    } range:[[attributedString string] rangeOfString:NSLocalizedString(@"How to get", nil)]];
    
    
    self.bottomTextView.attributedText = attributedString;
    self.bottomTextView.linkTextAttributes = @{NSForegroundColorAttributeName:[AlivcUIConfig shared].kAVCThemeColor};
    self.bottomTextView.backgroundColor = [UIColor clearColor];
    self.bottomTextView.textAlignment = NSTextAlignmentCenter;
    self.bottomTextView.delegate = self;
    self.bottomTextView.editable = NO;        //必须禁止输入，否则点击将弹出输入键盘
    self.bottomTextView.scrollEnabled = NO;
    
}


/**
 1.从工程加载数据源列表
 2.本地数据库找到音乐，赋值工程加载的资源列表
 */
- (void)fetchRemoteMusic {
    //没有更多数据
    if (!self.page.hasMore) {
        return;
    }
    //首页清空数据
    if (self.page.currentPageNo == 1) {
        _remoteMusics = nil;
    }
    self.isLoading = YES;
    self.indicatorView.hidden = NO;
    [self.indicatorView startAnimating];
    __weak typeof(self) weakSelf = self;
    NSMutableArray *tmpMusic = [self musics];
    [AliyunResourceRequestManager fetchMusicWithPage:weakSelf.page success:^(NSArray<AliyunMusicPickModel *> *musicList) {
        [tmpMusic addObjectsFromArray:musicList];
        //查询数据库
        [weakSelf.dbHelper queryMusicResourceWithEffecInfoType:AliyunEffectTypeMusic success:^(NSArray *infoModelArray) {
            for (AliyunEffectResourceModel *resourceModel in infoModelArray) {
                
                NSString *name = [NSString stringWithFormat:@"%ld-%@", (long)resourceModel.eid, resourceModel.name];
                NSString *path = [[[resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", name]] stringByAppendingPathComponent:[resourceModel.url.lastPathComponent componentsSeparatedByString:@"?"][0]];
                AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
                for (AliyunMusicPickModel *musicModel in tmpMusic) {
                    if ([musicModel.name isEqualToString: resourceModel.name] && [musicModel.artist isEqualToString:resourceModel.cnName]) {
                        musicModel.name = resourceModel.name;
                        musicModel.artist = resourceModel.cnName;
                        musicModel.path = path;
                        musicModel.downloadProgress = 1;
                        musicModel.duration = [asset avAssetVideoTrackDuration];
                        if (musicModel.duration < 0) {
                            musicModel.isDBContain = NO;//异常的数据，重新下载
                        }else{
                            musicModel.isDBContain = YES;
                        }
                        break;
                    }
                }
            }
            //播放上次选中的歌曲
            [weakSelf.tableView reloadData];
            weakSelf.isLoading = NO;
            [weakSelf.indicatorView stopAnimating];
            
        } failure:^(NSError *error) {
            weakSelf.isLoading = NO;
            [weakSelf.indicatorView stopAnimating];
        }];
    } failure:^(NSString *errorStr) {
        [MBProgressHUD showMessage:[@"aliyun_network_not_connect" localString] inView:weakSelf.view];
        weakSelf.isLoading = NO;
        [weakSelf.indicatorView stopAnimating];
    }];
}


/**
 根据传入的选中的音乐 获取选中音乐的位置
 更新tableview的选中位置
 */
- (void)setDefaultValue{
    for (AliyunMusicPickModel *model in self.musics) {
        if (self.selectedMusic_remote && [model.musicId isEqualToString:self.selectedMusic_remote.musicId] && model.isDBContain) {
            NSInteger index = [self.musics indexOfObject:model];
            //默认的初始值
            self.selectedSection = index;
            model.expand = YES;
            _startTime = self.selectedMusic.startTime;
            model.startTime = _startTime;
            [self playCurrentItem];
            //移动到选中的位置
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tableView reloadData];
                if (index < self.musics.count) {
                          //刷新完成
                          NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
                          [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                }
            });
            break;
        }
    }
}

- (void)setLocalDefaultValue{
    for (AliyunMusicPickModel *model in self.iTunesMusics) {
        NSInteger index = [self.iTunesMusics indexOfObject:model];
        if (self.selectedMusic_local && [self.selectedMusic_local.name isEqualToString:model.name]&&(index != 0)) {
            //默认的初始值
            self.selectedSection = index;
            model.expand = YES;
            _startTime = self.selectedMusic.startTime;
            model.startTime = _startTime;
            [self playCurrentItem];
            //移动到选中的位置
            dispatch_async(dispatch_get_main_queue(), ^{
                                         //刷新完成
                                      NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:index];
                                         [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                                     });
            
            
            break;
        }
    }
}

- (void)fetchItunesMusic {
    if (self.iTunesMusics.count > 1) {
        [self.tableView reloadData];
        [self setLocalDefaultValue];
    }else{
        __weak typeof(self) weakSelf = self;
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        [self.tableView reloadData]; 
        //获得query，用于请求本地歌曲集合
        MPMediaQuery *query = [MPMediaQuery songsQuery];
        //循环获取得到query获得的集合
        dispatch_group_t group = dispatch_group_create();
        for (MPMediaItemCollection *conllection in query.collections) {
            //MPMediaItem为歌曲项，包含歌曲信息
            for (MPMediaItem *item in conllection.items) {
                AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
                NSString *name = [item valueForProperty:MPMediaItemPropertyTitle];
                NSString *uid = [item valueForProperty:MPMediaItemPropertyPersistentID];
                NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
                NSString *artist = [item valueForKey:MPMediaItemPropertyArtist];
                float duration = [[item valueForKey:MPMediaItemPropertyPlaybackDuration] floatValue];
                NSString *baseString = [[[AliyunPathManager createResourceDir] stringByAppendingPathComponent:@"musicRes"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", uid, name]];
                if (!url) {
                    break;
                }
                if (!url.pathExtension) {
                    break;
                }
                NSString *toString = [[baseString stringByAppendingPathComponent:@"music"] stringByAppendingPathExtension:url.pathExtension];
                
                model.name = name;
                model.path = toString;
                model.artist = artist;
                model.duration = duration;
                if ([[NSFileManager defaultManager] fileExistsAtPath:baseString]) {
                    [[NSFileManager defaultManager] removeItemAtPath:baseString error:nil];
                }
                dispatch_group_enter(group);
                [[NSFileManager defaultManager] createDirectoryAtPath:baseString withIntermediateDirectories:YES attributes:nil error:nil];
                NSURL *toURL = [NSURL fileURLWithPath:toString];
                AliyunLibraryMusicImport* import = [[AliyunLibraryMusicImport alloc] init];
                [import importAsset:url toURL:toURL completionBlock:^(AliyunLibraryMusicImport* import) {
                    
                    
                    //不支持的音乐不添加
                    AliyunNativeParser *parser = [[AliyunNativeParser alloc] initWithPath:toString];
                    NSString *codec = [parser getAudioCodec];
                    //codec 返回值是unknown的情况
                    if (codec && [codec hasSuffix:@"unk"]) {
                        return;
                    }
                    [weakSelf.iTunesMusics addObject:model];
                    dispatch_group_leave(group);
                }];
            }
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            if (!self.selectedMusic_local) {
                self.selectedMusic = self.iTunesMusics.firstObject;
            }
            [self setLocalDefaultValue];
            [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
            [self.tableView reloadData];
            self.iTunesMusics = [NSMutableArray arrayWithArray:self.iTunesMusics];
        });
         
        
    }
}


#pragma mark - notification

- (void)addNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
}

- (void)becomeActive{
    [self playCurrentItem];
    
}

- (void)resignActive{
    [self.player pause];
}

//- (void)removeNotification {
//    [[NSNotificationCenter defaultCenter] removeObserver:self];
//}

- (void)playerItemDidReachEnd {
    [self playCurrentItem];
}

#pragma mark - player;

- (void)playCurrentItem {
    
    if (self.selectedSection < self.musics.count) {
        AliyunMusicPickModel *model = [self.musics[self.selectedSection] copy];
        model.startTime = _startTime;
        model.duration = _duration;
        AVMutableComposition *composition = [self generateMusicWithPath:model.path start:_startTime duration:_duration];
        [self.player replaceCurrentItemWithPlayerItem:[AVPlayerItem playerItemWithAsset:composition]];
        [self.player play];
        self.selectedMusic = model;
        [self updateSelectedMusic];
    }
}

-(AVMutableComposition *)generateMusicWithPath:(NSString *)path start:(float)start duration:(float)duration {
    if (!path) {
        return nil;
    }
    NSLog(@"开始时间======%f",start);
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    AVMutableComposition *mutableComposition = [AVMutableComposition composition]; // Create the video composition track.
    AVMutableCompositionTrack *mutableCompositionAudioTrack =[mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *array = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (array.count > 0) {
        AVAssetTrack *audioTrack = array[0];
        CMTime startTime = CMTimeMake(start, 1000);
        CMTime stopTime = CMTimeMake((start+duration*1000), 1000);
        //    CMTimeRange range = CMTimeRangeMake(kCMTimeZero, CMTimeSubtract(stopTime, startTime));
        CMTimeRange exportTimeRange = CMTimeRangeFromTimeToTime(startTime,stopTime);
        [mutableCompositionAudioTrack insertTimeRange:exportTimeRange ofTrack:audioTrack atTime:kCMTimeZero error:nil];
    }
    
    return mutableComposition;
}

#pragma mark - table view delegate

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 54;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 104;
}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.5;
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section{
    if ([view isMemberOfClass:[UITableViewHeaderFooterView class]]) {
        ((UITableViewHeaderFooterView *)view).backgroundView.backgroundColor = [UIColor clearColor];
    }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    AliyunMusicPickModel *mode = self.musics[section];
    if(mode.expand){
        return 1;
    }else {
        return 0;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return self.musics.count;
}


-(UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UITableViewHeaderFooterView *view = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"UITableViewHeaderFooterView"];
    view.backgroundColor = [UIColor redColor];
    view.contentView.backgroundColor = [UIColor grayColor];
    view.backgroundView.backgroundColor = [UIColor clearColor];
    view.alpha = 1;
    return view;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    AliyunMusicPickHeaderView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:@"AliyunMusicPickHeaderView"];
    //    AliyunMusicPickHeaderView *header = [[AliyunMusicPickHeaderView alloc]init];
    if (section < self.musics.count) {
        AliyunMusicPickModel *model = self.musics[section];
        header.tag = section;
        
        header.delegate = self;
        if (section == self.selectedSection) {
            [header shouldExpand:YES];
        }else {
            [header shouldExpand:NO];
        }
        [header configWithModel:model];
        NSLog(@"音乐下载测试-cell展示-%@-%ld",model.name,(long)section);
    }
    
    return header;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    AliyunMusicPickCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AliyunMusicPickCell"];
    cell.delegate = self;
    if (indexPath.section < self.musics.count) {
        AliyunMusicPickModel *model = self.musics[indexPath.section];
        [cell configureMusicDuration:model.duration pageDuration:_duration startTime:_startTime];
        NSLog(@"展开的音乐时长：%f",model.duration);
    }
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    AliyunMusicPickCell *musicCell = (AliyunMusicPickCell *)cell;
    [musicCell stopScroll];
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    CGFloat sectionHeaderHeight = 64;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
    //当滑动快到底的时候 开始加载下一页
    CGFloat contentSizeHeight = scrollView.contentSize.height;
    CGFloat contentOffsetY = scrollView.contentOffset.y;
    CGFloat scrollViewHeight = scrollView.frame.size.height;
    
    
    if(contentSizeHeight - contentOffsetY - scrollViewHeight < 150) {
        if (!self.isLoading && self.selectedTab == 0) {
            [self loadMoreMusic];
        }
    }
}


- (void)loadMoreMusic{
    [self.page next];
    [self fetchRemoteMusic];
}
#pragma mark - header view delegate

-(void)didSelectHeader:(AliyunMusicPickHeaderView *)view {
    
    if (self.selectedTab == 0) {
        
        AliyunMusicPickModel *model = self.musics[view.tag];
        if (model.isDBContain||view.tag == 0) {
            [self handle:view];
            return;
        }
        //同时不能超过3个
        if(self.downloadingMusics.count > 3){
            [MBProgressHUD showMessage:NSLocalizedString(@"同时下载个数超出限制", nil) inView:self.view];
            return;
        }
        //防止重复下载
        for (AliyunMusicPickModel *downloadingModel in self.downloadingMusics) {
            if (downloadingModel.keyId == model.keyId) {
                [MBProgressHUD showMessage:NSLocalizedString(NSLocalizedString(@"此音乐正在下载,请耐心等待" , nil) , nil) inView:self.view];
                return;
            }
        }
        [self.downloadingMusics addObject:model];
        //添加下载视图
        [view updateDownloadViewWithFinish:NO];
        NSLog(@"音乐下载测试点击:%@---%ld",model.name,(long)view.tag);
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"BusinessType"] = @"vodsdk";
        params[@"TerminalType"] = @"pc";
        params[@"DeviceModel"] = @"iPhone9,2";
        params[@"UUID"] = @"59ECA-4193-4695-94DD-7E1247288";
        params[@"AppVersion"] = @"1.0.0";
        
        NSString *playInfoGetString = [NSString stringWithFormat:@"{\"music_id\":\"%@\"}",model.musicId];
        params[@"play_info_get"] = playInfoGetString;
        
        __block AliyunMusicPickHeaderView *weakView = view;
        __block AliyunMusicPickViewController *weakSelf = self;
        //这里请求播放地址
        [AliyunResourceRequestManager fetchMusicPlayUrl:model.musicId success:^(NSString *playPath, NSString *expireTime) {
            model.path = playPath;
            
            AliyunEffectResourceModel *resourceModel = [[AliyunEffectResourceModel alloc] init];
            resourceModel.eid = model.keyId;
            resourceModel.name = model.name;
            resourceModel.url = model.path;
            //            resourceModel.url = responseObject[@"result"][@"result_obj"][@"listen_file_url"];
            resourceModel.effectType = AliyunEffectTypeMusic;
            //            NSLog(@"%@",responseObject[@"result"][@"result_obj"][@"listen_file_url"]);
            
            AliyunResourceDownloadTask *downLoadTask = [[AliyunResourceDownloadTask alloc] initWithModel:resourceModel];
            self->_downloadManager = [[AliyunResourceDownloadManager alloc] init]; //重新创建，适配多任务下载
            //            view.userInteractionEnabled = NO;
            
            
            [self->_downloadManager addDownloadTask:downLoadTask progress:^(CGFloat progress) {
                
                //更新UI
                model.downloadProgress = progress;
                [weakView downloadProgress:progress];
                
            } completionHandler:^(AliyunEffectResourceModel *newModel, NSError *error) {
                //                weakView.userInteractionEnabled = YES;
                if (error.code == -2009) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"同时下载个数超出限制" , nil) inView:weakSelf.view];
                    return;
                }
                if (error) {
                    [MBProgressHUD showMessage:NSLocalizedString(@"网络不给力" , nil) inView:weakSelf.view];
                    [weakView updateDownloadViewWithFinish:YES];
                    [weakSelf.downloadingMusics enumerateObjectsUsingBlock:^(id _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        //删除错误的model
                        AliyunMusicPickModel *model_del =(AliyunMusicPickModel *)obj;
                        if (model_del.keyId == model.keyId) {
                            *stop = YES;
                            [weakSelf.downloadingMusics removeObject:model_del];
                        }
                    }];
                    //                    [weakSelf.downloadingMusics removeAllObjects]; //错误的时候有时找不到具体是哪个音乐的错误
                } else {
                    newModel.isDBContain = YES;
                    newModel.effectType = AliyunEffectTypeMusic;
                    //根据newModel的值找到之前对应下载的音乐
                    AliyunMusicPickModel *doneModel = nil;
                    for (AliyunMusicPickModel *itemModel in weakSelf.musics) {
                        if (itemModel.keyId == newModel.eid) {
                            //更新数据
                            doneModel = itemModel;
                            newModel.cnName = doneModel.artist;
                            [weakSelf.dbHelper insertDataWithEffectResourceModel:newModel];
                            
                            doneModel.isDBContain = newModel.isDBContain;
                            doneModel.downloadProgress = 1;
                            NSString *name = [NSString stringWithFormat:@"%ld-%@", (long)newModel.eid, newModel.name];
                            NSString *path = [[[newModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", name]] stringByAppendingPathComponent:[newModel.url.lastPathComponent componentsSeparatedByString:@"?"][0]];
                            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
                            doneModel.path = path;
                            doneModel.duration = [asset avAssetVideoTrackDuration];
                            NSInteger index = [weakSelf.musics indexOfObject:itemModel];
                            weakView.tag = index;
                            [weakView updateDownloadViewWithFinish:YES];
                            [weakSelf.downloadingMusics removeObject:doneModel];
                            //更新UI
                            [weakSelf handle:weakView];
                            
                            NSLog(@"音乐下载测试:%@,---%ld",doneModel.name,(long)view.tag);
                            break;
                        }
                    }
                }
            }];
            
        } failure:^(NSString *errorStr) {
            [MBProgressHUD showMessage:NSLocalizedString(@"网络不给力" , nil) inView:weakSelf.view];
        }];
        
    }else{
        [self handle:view];
    }
}

- (void)handle:(AliyunMusicPickHeaderView *)view{
    if (!(view.tag < self.musics.count && self.selectedSection < self.musics.count)) {
        return;
    }
    if (view.tag != self.selectedSection) {
        //Old
        if (self.selectedSection >= 0) {
            AliyunMusicPickModel *model = self.musics[self.selectedSection];
            model.expand = NO;
            AliyunMusicPickHeaderView *headerView = (AliyunMusicPickHeaderView *)[self.tableView headerViewForSection:self.selectedSection];
            [headerView shouldExpand:NO];
            if (self.selectedSection > 0) {
                [self.tableView reloadData];
            }
        }
        // NEW
        self.selectedSection = view.tag;
        AliyunMusicPickModel *model = self.musics[self.selectedSection];
        if (self.selectedSection > 0) {
            model.expand = YES;
            [self.tableView reloadData];
        }else {
            [self.player pause];
        }
        
        AliyunMusicPickHeaderView *headerView = (AliyunMusicPickHeaderView *)[self.tableView headerViewForSection:self.selectedSection];
        [headerView shouldExpand:YES];
        
        _startTime = 0;
        [self playCurrentItem];
    }
}
- (AliyunDBHelper *)dbHelper {
    
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
    }
    return _dbHelper;
}

#pragma mark - cell delegate

-(void)didSelectStartTime:(CGFloat)startTime {
    //    AliyunMusicPickModel *model = self.musics[_selectedSection];
    _startTime = startTime;
    //    model.startTime = startTime;
    [self playCurrentItem];
}


#pragma mark - top view delegate

-(void)cancelButtonClicked {
    [self.player pause];
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didCancelPick)]) {
        [self.delegate didCancelPick];
    }
}

-(void)finishButtonClicked {
    
    
    [self.player pause];
    
    
    //    AliyunMusicPickModel *model = self.musics[_selectedSection];
    AliyunMusicPickModel *model = self.selectedMusic;
    model.duration = _duration;
    //     配音功能只支持aac格式，mp3格式的音乐需要转码
    //     建议使用aac格式的音乐资源
    //    AliyunNativeParser *parser = [[AliyunNativeParser alloc] initWithPath:model.path];
    //    NSString *format = [parser getValueForKey:ALIYUN_AUDIO_CODEC];
    //    if ([format isEqualToString:@"mp3"]) {
    //        _musicCrop = [[AliyunCrop alloc] initWithDelegate:self];
    //        NSString *outputPath = [[AliyunPathManager createMagicRecordDir] stringByAppendingPathComponent:[model.path lastPathComponent]];
    //        _musicCrop.inputPath = model.path;
    //        _musicCrop.outputPath = outputPath;
    //        _musicCrop.startTime = model.startTime;
    //        _musicCrop.endTime = model.duration + model.startTime;
    //        model.path = outputPath;
    //        [_musicCrop startCrop];
    //        QUMBProgressHUD *hud = [QUMBProgressHUD showHUDAddedTo:self.view animated:YES];
    //    }else {
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectMusic:tab:)]) {
        [self.delegate didSelectMusic:model tab:self.selectedTab];
    }
    
    
    //    }
    
}

#pragma mark - tab view delegate

-(void)didSelectTab:(NSInteger)tab {
    self.selectedTab = tab;
    [self.player pause];
    //tableview 滑动到初始位置
    self.tableView.contentOffset = CGPointMake(0, 0);
    if (tab == 1) {
        [self fetchItunesMusic];
        self.bottomTextView.hidden = YES;
        self.indicatorView.hidden = YES;
    }else {
        //判断是不是搜索模式
        if (self.musics.count <= 1) {
            //第一次进入页面请求首页数据
            [self fetchRemoteMusic];
            [self.tableView reloadData];
        }else{
            
            //第二次加载缓存数据
            [self setDefaultValue];
            
            [self.tableView reloadData];
            
            
            
        }
        
        self.bottomTextView.hidden = NO;
    }
}
#pragma mark UITextVeiwDelegate

- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange {
    if ([[URL scheme] isEqualToString:@"click"]) {
        [self gotoIntroduce];
        return NO;
    }
    return YES;
}
- (BOOL)textView:(UITextView *)textView shouldInteractWithURL:(NSURL *)URL inRange:(NSRange)characterRange interaction:(UITextItemInteraction)interaction NS_AVAILABLE_IOS(10_0){
    if ([[URL scheme] isEqualToString:@"click"]) {
        [self gotoIntroduce];
        return NO;
    }
    return YES;
}


- (void)gotoIntroduce {
    AlivcWebViewController *introduceC = [[AlivcWebViewController alloc] initWithUrl:kIntroduceUrl title:NSLocalizedString(@"Third-party capability acquisition instructions", nil)];
    [self.navigationController pushViewController:introduceC animated:YES];
}


#pragma mark - crop

//-(void)cropOnError:(int)error {
//    [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
//}
//
//-(void)cropTaskOnComplete {
//    [[QUMBProgressHUD HUDForView:self.view] hideAnimated:YES];
//    AliyunMusicPickModel *model = self.musics[_selectedSection];
//    [self.delegate didSelectMusic:model];
//}


#pragma mark - getter & setter

- (AVPlayer *)player{
    if (!_player) {
        _player = [[AVPlayer alloc] init];
    }
    return _player;
}

- (AliyunPage *)page{
    if (!_page) {
        _page = [[AliyunPage alloc] init];
    }
    return _page;
}

- (NSMutableArray *)remoteMusics {
    if (!_remoteMusics) {
        _remoteMusics = [NSMutableArray array];
        AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
        model.name = NSLocalizedString(@"无音乐" , nil);
        model.artist = @"V.A.";
        [_remoteMusics addObject:model];
    }
    return _remoteMusics;
}

- (NSMutableArray *)iTunesMusics {
    if (!_iTunesMusics) {
        _iTunesMusics = [NSMutableArray array];
        AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
        model.name = NSLocalizedString(@"无音乐" , nil);
        model.artist = @"V.A.";
        [_iTunesMusics addObject:model];
    }
    return _iTunesMusics;
}

- (NSMutableArray *)musics {
    if (self.selectedTab == 0) {
        return self.remoteMusics;
    }else{
        return self.iTunesMusics;
    }
}

////选中的音乐
- (AliyunMusicPickModel *)selectedMusic{
    if (self.selectedTab == 0) {
        _selectedMusic = self.selectedMusic_remote ;
    }else{
        _selectedMusic = self.selectedMusic_local;
    }
    return _selectedMusic;
}


- (void)setSelectedMusic:(AliyunMusicPickModel *)selectedMusic type:(NSInteger)type {
    self.selectedTab = type;
    if (self.selectedTab == 0) {
        self.selectedMusic_remote = selectedMusic;
    }else{
        self.selectedMusic_local = selectedMusic;
    }
    _selectedMusic = selectedMusic;
}

- (void)setSelectedMusic:(AliyunMusicPickModel *)selectedMusic {
    if (self.selectedTab == 0) {
        self.selectedMusic_remote = selectedMusic;
    }else{
        self.selectedMusic_local = selectedMusic;
    }
    _selectedMusic = selectedMusic;
}

- (void)setSelectedSection:(NSInteger)selectedSection{
    if (self.selectedTab == 0) {
        self.selectedSection_remote = selectedSection;
    }else{
        self.selectedSection_local = selectedSection;
    }
}

- (NSInteger)selectedSection{
    if (self.selectedTab == 0) {
        return self.selectedSection_remote;
    }else{
        return self.selectedSection_local;
    }
}

- (UIView *)emptyTableViewHeader {
    if (!_emptyTableViewHeader) {
        _emptyTableViewHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.01)];
    }
    return _emptyTableViewHeader;
}



@end
