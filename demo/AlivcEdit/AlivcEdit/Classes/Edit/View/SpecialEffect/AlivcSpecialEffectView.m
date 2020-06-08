//
//  AlivcSpecialEffectView.m
//  AliyunVideoClient_Entrance
//
//  Created by 张璠 on 2018/11/19.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcSpecialEffectView.h"
#import "AliyunEffectFilterCell.h"
#import "AliyunEffectInfo.h"
#import "AliyunDBHelper.h"
#import "AVC_ShortVideo_Config.h"
#import "AliyunTimelineView.h"
#import "AliyunEffectResourceModel.h"
#import "AlivcEditBottomHeaderView.h"
#import "NSString+AlivcHelper.h"
#import "AlivcDefine.h"
#import "AlivcGroupSelector.h"
#import "AlivcRegulatorView.h"


@interface AlivcSpecialEffectView()<AlivcGroupSelectorDelegate>
/**
 滤镜特效中的提示Label
 */
@property(nonatomic,weak) UILabel *tipLabel;

/**
 滤镜特效首次提醒按钮
 */
@property(nonatomic,weak) UIButton *firstTipButton;

/**
 滤镜特效占位view
 */
@property (nonatomic, strong) UIView *timeLinePalletView;

/**
 显示view
 */
@property (nonatomic, strong) UICollectionView *collectionView;


/**
 数据模型数组
 */
@property (nonatomic, strong) NSMutableArray *dataArray;


//原有的内置特效
@property (nonatomic, strong) NSMutableArray *defaultFilerData;

/**
 FMDB的封装类
 */
@property (nonatomic, strong) AliyunDBHelper *dbHelper;


/**
 选中特效的序号
 */
@property (nonatomic, strong) AlivcGroupSelector *groupSelector;

/**
 定时器
 */
@property (nonatomic, strong) NSTimer *schedule;

/**
 之前选中的序号
 */
@property (nonatomic, strong) NSIndexPath *preIdxPath;

/**
 长按手势
 */
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGes;

@property (nonatomic, strong) AlivcEditBottomHeaderView *headerView;

/**
 特效中选中的cell
 */
@property (nonatomic, weak) AliyunEffectFilterCell *selectCell;

@property (nonatomic,strong) AlivcRegulatorView* regulatorView;

@property (nonatomic,assign) NSInteger lastRow;

@end

@implementation AlivcSpecialEffectView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
        
        _dbHelper = [[AliyunDBHelper alloc] init];
        _dataArray = [[NSMutableArray alloc] init];
        [self addSubViews];
    }
    return self;
}

- (void)dealloc{
    [self touchEnd];
}

/**
 添加子控件
 */
- (void)addSubViews {
    [self addSubview:self.timeLinePalletView];
    UILabel *tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 117, 250, 12)];
    tipLabel.text = [@"选择位置后，长按可添加效果" localString];
    tipLabel.hidden = YES;
    tipLabel.font = [UIFont systemFontOfSize:12];
    tipLabel.textColor = [UIColor whiteColor];
    [self addSubview:tipLabel];
    self.tipLabel = tipLabel;
    
    _headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 45)];
    [_headerView setTitle:[@"滤镜" localString] icon:[AlivcImage imageNamed:@"shortVideo_fliter"]];
    [self addSubview:_headerView];
    
    __weak typeof(self)weakSelf = self;
    [_headerView bindingApplyOnClick:^{
        [weakSelf apply];
    } cancelOnClick:^{
        [weakSelf noApply];
    }];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(50, 70);
    layout.sectionInset = UIEdgeInsetsMake(5, 20, 20, 22);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcEdit.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 62.5, ScreenWidth, 102) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:bundle] forCellWithReuseIdentifier:@"AliyunEffectFilterCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:bundle] forCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell"];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self addSubview:_collectionView];
    
    
    _longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
    [_collectionView addGestureRecognizer:_longPressGes];
    
    UIButton *firstTip = [[UIButton alloc] initWithFrame:CGRectMake(20, 96, 127, 35)];
    [firstTip setTitle:[@"长按可添加效果" localString] forState:UIControlStateNormal];
    firstTip.titleEdgeInsets = UIEdgeInsetsMake(5, 0, 8, 0);
    firstTip.titleLabel.font = [UIFont systemFontOfSize:14];
    [firstTip setBackgroundImage:[self resizableImage:@"shortVideo_edit_firstTip"]  forState:UIControlStateNormal];
    firstTip.hidden = YES;
    [firstTip addTarget:self action:@selector(removeFirstTip) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:firstTip];
    self.firstTipButton = firstTip;
    [self initTitleAndTip];
    _groupSelector = [[AlivcGroupSelector alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 44-SafeBottom, CGRectGetWidth(self.bounds), 44)];
    [self addSubview:self.groupSelector];
    _groupSelector.delegate = self;
    
    _lastRow = -1;
        
    [self addNotifications];
    
    [self fetchEffectGroupDataWithCurrentShowGroup:nil];

}

- (void)addNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:AliyunEffectResourceDeleteNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reloadCollectionViews:)
                                                 name:AliyunEffectResourceDeleteNotification
                                               object:nil];
}
-(void)reloadCollectionViews:(NSNotification *)not{
    AliyunEffectResourceModel *model = not.userInfo[@"deleteModel"];
    if ([model.name isEqualToString:self.groupSelector.selectTitle]) {
        self.groupSelector.selectTitle = nil;
    }
    
    if (model.resourcePath.length>0) {
        //如果存在已经缓存，则清除
        if (self.delegate && [self.delegate respondsToSelector:@selector(clearEffectByPath:)]) {
            [self.delegate clearEffectByPath:model.resourcePath];
        }
        
        //参数调节器是否显示处理
        if(_lastRow>=0){
            AliyunEffectFilterInfo *currentAnimationFilter = _dataArray[_lastRow];
            if ([currentAnimationFilter.resourcePath containsString:model.resourcePath]) {
                [self showRegulatorView:nil paramList:nil isEnable:YES];
            }
        }
    }
    
    [self fetchEffectGroupDataWithCurrentShowGroup:nil];
}

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}


/**
 去除首次提醒，显示正常提醒
 */
- (void)removeFirstTip{
    self.tipLabel.hidden = NO;
    self.firstTipButton.hidden = YES;
}
/**
 从中间拉伸图片，不影响边缘效果
 
 @param name 图片名称
 @return 拉伸好的图片
 */
- (UIImage *)resizableImage:(NSString *)name
{
    UIImage *image = [AlivcImage imageNamed:name];
    return [image stretchableImageWithLeftCapWidth:image.size.width * 0.5 topCapHeight:image.size.height * 0.5];
}


/**
 点击应用按钮的触发方法
 */
- (void)apply{
    self.selectCell.selectedButton.hidden = YES;
    [self touchEnd];
    if (_delegate && [self.delegate respondsToSelector:@selector(applyButtonClick)]) {
        [_delegate applyButtonClick];
    }
}


/**
 点击取消按钮的触发方法
 */
- (void)noApply{
    self.selectCell.selectedButton.hidden = YES;
    [self touchEnd];
    if (_delegate && [self.delegate respondsToSelector:@selector(noApplyButtonClick)]) {
        [_delegate noApplyButtonClick];
    }
}

/**
 长按手势结束的时候调用的方法
 */
- (void)touchEnd {
    
    NSLog(@"~~~ges1:end %s", __PRETTY_FUNCTION__);
    if (_schedule) {
        if (_delegate&& [self.delegate respondsToSelector:@selector(didEndLongPress)]) {
            [_delegate didEndLongPress];
        }
        [_schedule invalidate];
        _schedule = nil;
        AliyunEffectFilterCell *preSelectCell = (AliyunEffectFilterCell *)[_collectionView cellForItemAtIndexPath:_preIdxPath];
        preSelectCell.selectedButton.hidden = YES;
    }
}


/**
 长按手势的触发方法
 
 @param ges 长按手势
 */
- (void)longPress:(UILongPressGestureRecognizer *)ges {
    CGPoint location = [ges locationInView:_collectionView];
    //移出视图，直接结束
    if (location.x < 0 || location.y < 0) {
        [self touchEnd];
        return;
    }
    
    NSIndexPath *idxPath = [_collectionView indexPathForItemAtPoint:location];
    
    AliyunEffectFilterCell *selectCell = (AliyunEffectFilterCell *)[_collectionView cellForItemAtIndexPath:idxPath];
    self.selectCell = selectCell;
    if (idxPath.row == 0) {
        //移动到撤销的时候也停止事件
        [self touchEnd];
        selectCell.selectedButton.hidden = YES;
        return;
    }
    [self removeFirstTip];
    
    if (idxPath == NULL) {
        [self touchEnd];
        selectCell.selectedButton.hidden = YES;
        return;
    }
    
    if  (_preIdxPath.row != idxPath.row) {
        [self touchEnd];
        AliyunEffectFilterCell *preSelectCell = (AliyunEffectFilterCell *)[_collectionView cellForItemAtIndexPath:_preIdxPath];
        preSelectCell.selectedButton.hidden = YES;
    }
    
    
    switch (ges.state) {
        case UIGestureRecognizerStateBegan: {
            NSLog(@"~~~ges:began %s", __PRETTY_FUNCTION__);
            _preIdxPath = idxPath;
            [selectCell.selectedButton setImage:nil forState:UIControlStateNormal];
            selectCell.selectedButton.hidden = NO;
            AliyunEffectFilterInfo *currentAnimationFilter = _dataArray[idxPath.row];
            
            if (_delegate && [self.delegate respondsToSelector:@selector(didBeganLongPressEffectFilter:)]) {
                [_delegate didBeganLongPressEffectFilter:currentAnimationFilter];
                
                [self callEiditVCRegulator:idxPath.row isEnable:NO];
            }
            [_schedule invalidate];
            _schedule = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(touchProgress) userInfo:nil repeats:YES];
            [_schedule fire];
        }
            break;
        case UIGestureRecognizerStateEnded:
            NSLog(@"~~~ges:ended %s", __PRETTY_FUNCTION__);
            selectCell.selectedButton.hidden = YES;
            [self touchEnd];
            break;
        case UIGestureRecognizerStateChanged:
            NSLog(@"~~~ges:changed");
            break;
        case UIGestureRecognizerStateCancelled:
            NSLog(@"~~~ges:cancel");
            selectCell.selectedButton.hidden = YES;
            break;
        case UIGestureRecognizerStateFailed:
            NSLog(@"~~~ges:failed");
            selectCell.selectedButton.hidden = YES;
            break;
        case UIGestureRecognizerStatePossible:
            NSLog(@"~~~ges:possible");
            selectCell.selectedButton.hidden = YES;
            break;
        default:
            NSLog(@"~~~ges:default");
            selectCell.selectedButton.hidden = YES;
            break;
    }
    [self.regulatorView setSilderEnable:selectCell.selectedButton.hidden];
}

/**
 长按过程中定时调用的代理方法（每0.1秒调用一次）
 */
- (void)touchProgress {
    
    if (_delegate && [self.delegate respondsToSelector:@selector(didTouchingProgress)]) {
        [_delegate didTouchingProgress];
    }
}



/**
 点击滤镜回删的触发方法
 */
- (void)revokeButtonClick {
    
    if (_delegate && [self.delegate respondsToSelector:@selector(didRevokeButtonClick)]) {
        [_delegate didRevokeButtonClick];
    }
}

- (void)initTitleAndTip{
    [_headerView setTitle:[@"滤镜特效" localString] icon:[AlivcImage imageNamed:@"shortVideo_edit_specialFliter"]];
    _collectionView.frame = CGRectMake(0, 130, ScreenWidth, 100);
    self.tipLabel.hidden = NO;
    if (![[NSUserDefaults standardUserDefaults] integerForKey:@"specialFilterFirst"]) {
        [[NSUserDefaults standardUserDefaults] setInteger:1 forKey:@"specialFilterFirst"];
        self.firstTipButton.hidden = NO;
        self.tipLabel.hidden = YES;
    }else{
        self.firstTipButton.hidden = YES;
        self.tipLabel.hidden = NO;
    }
    
}

- (void)fetchEffectGroupDataWithCurrentShowGroup:(AliyunEffectInfo *)group{
    [self.groupSelector.groupData removeAllObjects];
    [self.defaultFilerData removeAllObjects];
    
    //添加默认特效滤镜
    AliyunEffectInfo *orginEffect = [[AliyunEffectInfo alloc] init];
    orginEffect.name = [@"默认" localString];
    orginEffect.effectType = AliyunEffectTypeSpecialFilter;
    orginEffect.eid = 0;
    [self.groupSelector.groupData addObject:orginEffect];
    
    [self.groupSelector.groupData addObject:@"shortVideo_paster_more"];
    if (group) {
        self.groupSelector.selectTitle = group.name;
    }
    __weak typeof (self)weakSelf = self;
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    [helper queryResourceWithEffecInfoType:AliyunEffectTypeSpecialFilter success:^(NSArray *infoModelArray) {
        for (int index = 0; index < infoModelArray.count; index++) {
            AliyunEffectInfo *info = infoModelArray[index];
            
            //判断是否是内置资源包中的
            if ([info.icon isEqualToString:@"icon"]) {
                info.groupId = -1;
                [self.defaultFilerData addObject:info];
                continue;
            }
            
            if (!group && self.groupSelector.selectTitle) {//普通刷新
                if ([info.name isEqualToString:self.groupSelector.selectTitle]) {
                    [weakSelf fetchDataByGroup:info];
                }
            }else if (!group && index == infoModelArray.count - 1){// 没有指定选中的话 就展示第一条
                self.groupSelector.selectIndex = 0;
                self.groupSelector.selectTitle = info.name;
                [weakSelf fetchDataByGroup:info];
            }else if(group){
                // 判断是否是当前选中group
                if (info.eid == group.eid && [info.name isEqualToString:group.name]) {
                    [weakSelf fetchDataByGroup:info];
                    self.groupSelector.selectIndex = infoModelArray.count - index-1;
                }
            }
            [weakSelf.groupSelector.groupData insertObject:info atIndex:0];
        }
        //  当前没有任何下载group时，刷新collectionView
        if (weakSelf.groupSelector.groupData.count <= 2) {
            [weakSelf fetchDataByGroup:nil];
        }
        
        [weakSelf.groupSelector refreshData];
        
    } failure:^(NSError *error) {
        [weakSelf.groupSelector refreshData];
    }];
}

- (void)fetchDataByGroup:(AliyunEffectInfo *)group {
    
    [_dataArray removeAllObjects];
    
    AliyunEffectInfo *effctMore = [[AliyunEffectInfo alloc] init];
    effctMore.name = [@"撤销" localString];
    effctMore.eid = -1;
    effctMore.effectType = AliyunEffectTypeSpecialFilter;
    effctMore.icon = @"shortVideo_edit_backout";
    [self.dataArray insertObject:effctMore atIndex:0];
    
    if (self.groupSelector.selectIndex == -1) {
        self.groupSelector.selectIndex = 0; //默认是不选中
    }
    
    if (group.eid == 0) {
        //加载原有内置的特效
        [self.dataArray addObjectsFromArray:self.defaultFilerData];
    }else{
        //加载下载的特效
         NSString *dirPath = [NSHomeDirectory() stringByAppendingPathComponent:group.resourcePath];
        [self loadLocalEffects:dirPath isDestDir:NO];
    }
    [self.collectionView reloadData];
}

-(void)loadLocalEffects:(NSString*)basePath isDestDir:(BOOL)isDestDir{
    BOOL isDir = NO;
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isExist = [fileManger fileExistsAtPath:basePath isDirectory:&isDir];
    
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:basePath error:nil];
            if (dirArray.count>0) {
                if(isDestDir){
                    NSDictionary *i18nDic = nil;
                    NSData *data = [NSData dataWithContentsOfFile:[basePath stringByAppendingPathComponent:@"i18n.json"]];
                    if(data){
                        NSDictionary *it8dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                        i18nDic = [it8dic objectForKey:@"children"];
                    }
                    
                    for (NSString *path in dirArray) {
                        //目录下非自定义资源文件过滤掉
                        if ([path containsString:@"i18n"]) {
                            continue;
                        }
                        if (path.length>0) {
                            AliyunEffectInfo *effct = [[AliyunEffectFilterInfo alloc] init];
                            effct.effectType = AliyunEffectTypeSpecialFilter;
                            effct.isCustomLocaleLanguage = YES;
                            effct.eid = self.dataArray.count;
                            effct.nameEn = path;
                            if (i18nDic) {
                                effct.name = i18nDic[path][@"name"][@"zh_cn"];
                            }
                            effct.icon = @"icon.png";
                            effct.resourcePath = [basePath stringByAppendingPathComponent:path];
                            [self.dataArray addObject:effct];
                            
                            if (self.selectedEffect) {
                                    if (effct.eid == self.selectedEffect.eid) {
                                        self.groupSelector.selectIndex = [self.dataArray indexOfObject:effct] + 1;
                                    }
                                }
                        }
                    }
                }else{
                    //TODO 取第一个目录，目录名可以作为作为分组英文名
                    NSString *subPath = [dirArray firstObject];
                    //不是目标目录，查找下一级目录
                    [self loadLocalEffects:[basePath stringByAppendingPathComponent:subPath] isDestDir:YES];
                }
            }
        }
    }else{
        NSLog(@"路径不存在");
    }
            
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunEffectFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterCell" forIndexPath:indexPath];
    
    AliyunEffectInfo *effectInfo = _dataArray[indexPath.row];
    [cell cellModel:effectInfo];
    [cell setExclusiveTouch:YES];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
   if (indexPath.row == 0) {
        [self revokeButtonClick];
    }
    [self callEiditVCRegulator:indexPath.row isEnable:YES];
}

-(void)callEiditVCRegulator:(NSInteger)row isEnable:(BOOL)isEnable{
    if (_lastRow==row) {
        _lastRow = row;
        [self.regulatorView setSilderEnable:isEnable];
        return;
    }
    _lastRow = row;
    AliyunEffectFilterInfo *currentAnimationFilter = _dataArray[row];
    if (_delegate && [self.delegate respondsToSelector:@selector(didShowRegulatorView:isEnable:)]) {
        [_delegate didShowRegulatorView:currentAnimationFilter isEnable:isEnable];
    }
}

-(void)showRegulatorView:(AliyunEffectFilter*)effect paramList:(NSArray*)paramList isEnable:(BOOL)isEnable{
    if (_regulatorView) {
        [_regulatorView removeFromSuperview];
        _regulatorView = nil;
    }
    
    if(paramList.count<=0){
        return;
    }
    
    self.regulatorView = [AlivcRegulatorView initUIwithData:paramList inView:self];
    self.regulatorView.isSliderEnable = isEnable;
    __weak typeof(self) weakSelf = self;
    self.regulatorView.didRegulatorViewSliderChangeBlock = ^(NSArray *dataArr,float value, long row) {
        AliyunParam *param = [dataArr objectAtIndex:row];
        if (param.value.type == AliyunValueINT) {
            [param.value updateINT:(int)value];
        }else{
            [param.value updateFLOAT:value];
        }
        if (weakSelf.didChangeEffectFinish) {
            weakSelf.didChangeEffectFinish(effect);
        }
    };
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    BOOL result = CGRectContainsPoint(self.bounds, point);
    if (result) {
        return result;
    }
    for (UIView* v in self.subviews) {
        CGPoint localPoint = [v convertPoint:point fromView:self];
        result = CGRectContainsPoint(v.bounds, localPoint);
        if (result) {
            return result;
        }
    }
    return NO;
}

/**
 重写timelineView的set方法
 
 @param timelineView 进度条
 */
-(void)setTimelineView:(AliyunTimelineView *)timelineView{
    _timelineView = timelineView;
    if (_timelineView) {
        _timelineView.frame = CGRectMake(0, 15, CGRectGetWidth(_timeLinePalletView.frame), CGRectGetHeight(_timeLinePalletView.frame)-10);
        _timelineView.backgroundColor = self.backgroundColor;
        [_timeLinePalletView addSubview:_timelineView];
    }
}
/**
 占位view的懒加载
 
 @return 占位view
 */
- (UIView *)timeLinePalletView{
    if (!_timeLinePalletView) {
        _timeLinePalletView = [[UIView alloc]initWithFrame:CGRectMake(0, 44, ScreenWidth, 40)];
        _timeLinePalletView.backgroundColor = [UIColor clearColor];
        if (_timelineView) {
            _timelineView.frame = CGRectMake(0, 5, CGRectGetWidth(_timeLinePalletView.frame), CGRectGetHeight(_timeLinePalletView.frame)-10);
            _timelineView.backgroundColor = self.backgroundColor;
            [_timeLinePalletView addSubview:_timelineView];
        }
    }
    return _timeLinePalletView;
}

- (void)specialFilterReset{
    AliyunEffectFilterCell *selectCell = (AliyunEffectFilterCell *)[_collectionView cellForItemAtIndexPath:_preIdxPath];
    selectCell.selectedButton.hidden = YES;
    [self touchEnd];
}


/**
 结束长按的时候的调用方法
 */
- (void)endLongPress{
    [self touchEnd];
}

#pragma --mark AlivcGroupSelectorDelegate
- (void)didGroupSelectorShowMore{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didShowMore)]) {
        [self.delegate didShowMore];
    }
}

-(void)didGroupSelectorHitByInfo:(AliyunEffectInfo*)info{
    [self fetchDataByGroup:info];
}

#pragma --mark getters
- (NSMutableArray *)defaultFilerData {
    if (!_defaultFilerData) {
        _defaultFilerData = [[NSMutableArray alloc] init];
    }
    return _defaultFilerData;
}

@end
