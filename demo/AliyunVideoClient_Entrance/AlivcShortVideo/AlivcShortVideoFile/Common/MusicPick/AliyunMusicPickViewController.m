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
#import "MBProgressHUD.h"
#import "AVC_ShortVideo_Config.h"
#import <AFNetworking.h>
#import "AliyunResourceDownloadManager.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectInfo.h"
#import "AliyunEffectModelTransManager.h"
#import "AliyunDBHelper.h"
#import "UIView+AlivcHelper.h"
#import "MBProgressHUD+AlivcHelper.h"
@interface AliyunMusicPickViewController () <UITableViewDelegate, UITableViewDataSource, AliyunMusicPickHeaderViewDelegate, AliyunMusicPickCellDelegate, AliyunMusicPickTopViewDelegate, AliyunMusicPickTabViewDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) AliyunMusicPickTopView *topView;
@property (nonatomic, strong) AliyunMusicPickTabView *tabView;
@property (nonatomic, strong) NSMutableArray *musics; //当前展示的音乐 远程或者本地
@property (nonatomic, strong) NSMutableArray *remoteMusics; //远程的音乐列表
@property (nonatomic, strong) NSMutableArray *iTunesMusics; //本地的音乐列表
@property (nonatomic, strong) NSMutableArray *downloadingMusics;
@property (nonatomic, assign) NSInteger selectedSection;
@property (nonatomic, strong) AVPlayer *player;
//@property (nonatomic, strong) AVURLAsset *asset;
//@property (nonatomic, strong) AliyunCrop *musicCrop;
@property (nonatomic, assign) CGFloat startTime;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;
@property (nonatomic, weak) UILabel *bottomLabel;
@property (nonatomic, strong)AliyunResourceDownloadManager *downloadManager;
/**
 之前应用的远程音乐 - 用于左右切换设置原先的值
 */
@property (nonatomic, strong) AliyunMusicPickModel *selectedMusic_remote;
/**
 之前应用的本地音乐 - 用于左右切换设置原先的值
 */
@property (nonatomic, strong) AliyunMusicPickModel *selectedMusic_local;

@end

@implementation AliyunMusicPickViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupSubviews];
    [self addNotification];
    self.player = [[AVPlayer alloc] init];
    self.musics = [NSMutableArray array];
    self.remoteMusics = [[NSMutableArray alloc]init];
    self.iTunesMusics = [[NSMutableArray alloc] init];
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
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

-(void)dealloc {
    [self removeNotification];
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
    self.topView.frame = CGRectMake(0, SafeTop, ScreenWidth, 44);
    self.tableView.frame = CGRectMake(0, 88+SafeTop, ScreenWidth, ScreenHeight - 88-SafeTop-SafeBottom-30);
}

- (void)setupSubviews {
//    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
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
    [self.view addSubview:self.tableView];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight-30-SafeBottom, ScreenWidth, 30)];
    label.text = @"由虾米音乐提供服务";
    label.font = [UIFont systemFontOfSize:12];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    [self.view addSubview:label];
    self.bottomLabel = label;
}


/**
 1.从工程加载数据源列表
 2.本地数据库找到音乐，赋值工程加载的资源列表
 */
- (void)fetchRemoteMusic {
    if (self.remoteMusics.count > 0) {
        [self.musics removeAllObjects];
        for (AliyunMusicPickModel *model in self.remoteMusics) {
            [self.musics addObject:model];
        }
        [self.tableView reloadData];
        [self setDefaultValue];
        return;
    }
    [self.musics removeAllObjects];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
        model.name = @"无音乐";
        model.artist = @"V.A.";
        [self.musics addObject:model];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"music" ofType:@"json"];
        // 将文件数据化
        NSData *data = [[NSData alloc] initWithContentsOfFile:path];
        // 对数据进行JSON格式化并返回字典形式
        NSArray *dictionaryArray = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
        
        for (NSInteger i = 0; i < dictionaryArray.count;i++) {
            NSDictionary *dict = dictionaryArray[i];
            AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
            [model setValuesForKeysWithDictionary:dict];
            model.downloadProgress = 0;
            model.isDBContain = NO;
            [self.musics addObject:model];
        }
        
        
        [self.dbHelper queryMusicResourceWithEffecInfoType:AliyunEffectTypeMusic success:^(NSArray *infoModelArray) {
            for (AliyunEffectResourceModel *resourceModel in infoModelArray) {
                
                NSString *name = [NSString stringWithFormat:@"%ld-%@", (long)resourceModel.eid, resourceModel.name];
                NSString *path = [[[resourceModel storageFullPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", name]] stringByAppendingPathComponent:[resourceModel.url.lastPathComponent componentsSeparatedByString:@"?"][0]];
                AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
                for (AliyunMusicPickModel *musicModel in self.musics) {
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
            
        } failure:^(NSError *error) {
            
        }];
        
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setDefaultValue];
            NSLog(@"音乐下载测试 - 远程音乐--------");
            [self.remoteMusics removeAllObjects];
            for (NSInteger index = 0; index < self.musics.count; index++) {
                AliyunMusicPickModel *model = self.musics[index];
                NSLog(@"音乐下载测试：%@ - 下标%ld - modeld key:%ld",model.name,(long)index,(long)model.keyId);
                NSLog(@"\n");
                [self.remoteMusics addObject:model];
            }
            [self.tableView reloadData];
            
        });
    });
}

- (void)setDefaultValue{
    for (AliyunMusicPickModel *model in self.musics) {
        NSInteger index = [self.musics indexOfObject:model];
        NSLog(@"音乐下载测试：%@ - 下标%ld - modeld key:%ld",model.name,(long)index,(long)model.keyId);
        NSLog(@"\n");
        if (self.selectedMusic_remote && [model.musicId isEqualToString:self.selectedMusic_remote.musicId] && model.isDBContain) {
            //默认的初始值
            self.selectedSection = index;
            model.expand = YES;
            _startTime = 0;
            [self playCurrentItem];
        }
    }
}

- (void)setLocalDefaultValue{
    for (AliyunMusicPickModel *model in self.musics) {
        NSInteger index = [self.musics indexOfObject:model];
        if (self.selectedMusic_local && [self.selectedMusic_local.name isEqualToString:model.name]&&(index != 0)) {
            //默认的初始值
            self.selectedSection = index;
            model.expand = YES;
            _startTime = 0;
            [self playCurrentItem];
        }
    }
}

- (void)fetchItunesMusic {
    [self.musics removeAllObjects];
    if (self.iTunesMusics.count) {

        for (AliyunMusicPickModel *model in self.iTunesMusics) {
            [self.musics addObject:model];
        }
        [self.tableView reloadData];
        [self setLocalDefaultValue];
        
    }else{
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            AliyunMusicPickModel *model = [[AliyunMusicPickModel alloc] init];
            model.name = @"无音乐";
            model.artist = @"V.A.";
            [self.musics addObject:model];
            //获得query，用于请求本地歌曲集合
            MPMediaQuery *query = [MPMediaQuery songsQuery];
            //循环获取得到query获得的集合
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
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
                    //                NSArray *filePathArray = [toString componentsSeparatedByString:@"Documents/"];
                    //                NSString *relativePath = [@"Documents/" stringByAppendingPathComponent:filePathArray.lastObject];
                    model.name = name;
                    model.path = toString;
                    model.artist = artist;
                    model.duration = duration;
                    // 若拷贝音乐已经存在 则执行下一条拷贝
                    if ([[NSFileManager defaultManager] fileExistsAtPath:baseString]) {
                        [self.musics addObject:model];
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [self.tableView reloadData];
                        });
                    }else {
                        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                        [[NSFileManager defaultManager] createDirectoryAtPath:baseString withIntermediateDirectories:YES attributes:nil error:nil];
                        NSURL *toURL = [NSURL fileURLWithPath:toString];
                        AliyunLibraryMusicImport* import = [[AliyunLibraryMusicImport alloc] init];
                        [import importAsset:url toURL:toURL completionBlock:^(AliyunLibraryMusicImport* import) {
                            [self.musics addObject:model];
                            dispatch_semaphore_signal(semaphore);
                            dispatch_async(dispatch_get_main_queue(), ^{
                                [self.tableView reloadData];
                            });
                        }];
                    }
                }
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [self setLocalDefaultValue];
                [[MBProgressHUD HUDForView:self.view] hideAnimated:YES];
                [self.tableView reloadData];
                self.iTunesMusics = [NSMutableArray arrayWithArray:self.musics];
            });
            
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

- (void)removeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)playerItemDidReachEnd {
    [self playCurrentItem];
}

#pragma mark - player

- (void)playCurrentItem {
    if (_selectedSection < self.musics.count) {
        AliyunMusicPickModel *model = self.musics[_selectedSection];
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
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    AVMutableComposition *mutableComposition = [AVMutableComposition    composition]; // Create the video composition track.
    AVMutableCompositionTrack *mutableCompositionAudioTrack =    [mutableComposition addMutableTrackWithMediaType:AVMediaTypeAudio    preferredTrackID:kCMPersistentTrackID_Invalid];
    NSArray *array = [asset tracksWithMediaType:AVMediaTypeAudio];
    if (array.count > 0) {
        AVAssetTrack *audioTrack = array[0];
        CMTime startTime = CMTimeMake(1000*start, 1000);
        CMTime stopTime = CMTimeMake(1000*(start+duration), 1000);
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
        if (section == _selectedSection) {
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
        [cell configureMusicDuration:model.duration pageDuration:_duration];
        NSLog(@"展开的音乐时长：%f",model.duration);
    }
    
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat sectionHeaderHeight = 64;
    if (scrollView.contentOffset.y<=sectionHeaderHeight&&scrollView.contentOffset.y>=0) {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    } else if (scrollView.contentOffset.y>=sectionHeaderHeight) {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
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
            [MBProgressHUD showMessage:@"同时下载个数超出限制" inView:self.view];
            return;
        }
        //防止重复下载
        for (AliyunMusicPickModel *downloadingModel in self.downloadingMusics) {
            if (downloadingModel.keyId == model.keyId) {
                [MBProgressHUD showMessage:@"此音乐正在下载,请耐心等待" inView:self.view];
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
        [[AFHTTPSessionManager manager] GET:@"https://demo-vod.cn-shanghai.aliyuncs.com/voddemo/XiamiApiMltpMusicPlayinfo" parameters:params progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            
            AliyunEffectResourceModel *resourceModel = [[AliyunEffectResourceModel alloc] init];
            resourceModel.eid = model.keyId;
            resourceModel.name = model.name;
            resourceModel.url = responseObject[@"result"][@"result_obj"][@"listen_file_url"];
            resourceModel.effectType = AliyunEffectTypeMusic;
            NSLog(@"%@",responseObject[@"result"][@"result_obj"][@"listen_file_url"]);
            
            AliyunResourceDownloadTask *downLoadTask = [[AliyunResourceDownloadTask alloc] initWithModel:resourceModel];
            _downloadManager = [[AliyunResourceDownloadManager alloc] init]; //重新创建，适配多任务下载
//            view.userInteractionEnabled = NO;
            
            __block AliyunMusicPickHeaderView *weakView = view;
            __block AliyunMusicPickViewController *weakSelf = self;
            [_downloadManager addDownloadTask:downLoadTask progress:^(CGFloat progress) {

                //更新UI
                model.downloadProgress = progress;
                [weakView downloadProgress:progress];
                
            } completionHandler:^(AliyunEffectResourceModel *newModel, NSError *error) {
//                weakView.userInteractionEnabled = YES;
                
                if (error) {
                    [MBProgressHUD showMessage:@"网络不给力" inView:weakSelf.view];
                    [weakView updateDownloadViewWithFinish:YES];
                    [weakSelf.downloadingMusics removeAllObjects]; //错误的时候有时找不到具体是哪个音乐的错误
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
//                    [_delegate didSelectEffectMV:(AliyunEffectMvGroup *)mvNewModel];
                   

                }
            }];
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
             NSLog(@"%@",error);
            [MBProgressHUD showMessage:@"网络不给力" inView:self.view];
            [self.downloadingMusics removeAllObjects]; //错误的时候有时找不到具体是哪个音乐的错误
        }];
    
    }else{
        [self handle:view];
    }
}

- (void)handle:(AliyunMusicPickHeaderView *)view{
    if (!(_selectedSection < self.musics.count)) {
        return;
    }
    if (_selectedSection >= 0 && view.tag != _selectedSection) {
        // OLD
        AliyunMusicPickModel *model = self.musics[_selectedSection];
        model.expand = NO;
        if (_selectedSection > 0) {
            //            NSIndexPath *indexPath = [NSIndexPath indexPathForItem:0 inSection:_selectedSection];
            //            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView reloadData];
        }
        AliyunMusicPickHeaderView *headerView = (AliyunMusicPickHeaderView *)[self.tableView headerViewForSection:_selectedSection];
        [headerView shouldExpand:NO];
    }
    if (view.tag != _selectedSection) {
        // NEW
        _selectedSection = view.tag;
        AliyunMusicPickModel *model = self.musics[_selectedSection];
        
        if (_selectedSection > 0) {
            model.expand = YES;
            [self.tableView reloadData];
        }else {
            [self.player pause];
        }
        AliyunMusicPickHeaderView *headerView = (AliyunMusicPickHeaderView *)[self.tableView headerViewForSection:_selectedSection];
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
    AliyunMusicPickModel *model = self.musics[_selectedSection];
    _startTime = startTime;
    model.startTime = startTime;
    [self playCurrentItem];
}


#pragma mark - top view delegate

-(void)cancelButtonClicked {
    [self.navigationController popViewControllerAnimated:YES];
    [self.delegate didCancelPick];
}

-(void)finishButtonClicked {
    
    
    [self.player pause];
   
    
    AliyunMusicPickModel *model = self.musics[_selectedSection];
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
        [self.delegate didSelectMusic:model tab:self.selectedTab];
    
//    }
    
}

#pragma mark - tab view delegate

-(void)didSelectTab:(NSInteger)tab {
    self.selectedSection = 0;
    self.selectedTab = tab;
    [self.player pause];
    if (tab == 1) {
        [self fetchItunesMusic];
        self.bottomLabel.hidden = YES;
    }else {
        [self fetchRemoteMusic];
        self.bottomLabel.hidden = NO;
    }
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

@end
