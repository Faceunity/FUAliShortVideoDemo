//
//  AlivcBottomMenuFilterView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/6.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcBottomMenuSpecialFilterView.h"
#import "AliyunEffectSpecialFilterCell.h"
#import "AliyunEffectInfo.h"
#import "AliyunDBHelper.h"
#import "AVC_ShortVideo_Config.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunEffectMvGroup.h"
#import "NSString+AlivcHelper.h"
#import "AlivcGroupSelector.h"
#import "AlivcDefine.h"
#import "AlivcRegulatorView.h"
#import <AliyunVideoSDKPro/AliyunEffectFilter.h>

@interface AlivcBottomMenuSpecialFilterView ()<AlivcGroupSelectorDelegate>
/**
 显示view
 */
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 数据模型数组
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

/**
 FMDB的封装类
 */
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

/**
 数据类型
 */
//@property (nonatomic, assign) NSInteger effectType;

@property (nonatomic,strong) AlivcGroupSelector *groupSelector;

//原有的内置特效
@property (nonatomic, strong) NSMutableArray *defaultFilerData;

/**
 选中滤镜的序号
 */
@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, copy)DidSelectEffectFilterBlock selectFilterBlock;

@property (nonatomic, copy) void(^showMoreFilterBlock)(void);

@property (nonatomic,strong) AlivcRegulatorView* regulatorView;

//当前选中的分组资源的path，nil为默认
@property (nonatomic,copy) NSString *currentPath;

@end

@implementation AlivcBottomMenuSpecialFilterView

- (instancetype)initWithFrame:(CGRect)frame withItems:(NSArray<AlivcBottomMenuHeaderViewItem *> *)items{
    self = [super initWithFrame:frame withItems:items];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        _dbHelper = [[AliyunDBHelper alloc] init];
        _dataArray = [[NSMutableArray alloc] init];
        _selectIndex = -1;
        [self addSubViews];
    }
    return self;
}

/**
 添加子控件
 */
- (void)addSubViews {
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(50, 70);
    layout.sectionInset = UIEdgeInsetsMake(5, 20, 20, 22);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, (CGRectGetHeight(self.contentView.frame)-90)/2-44-10-SafeBottom, ScreenWidth, 90) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcRecord.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectSpecialFilterCell" bundle:bundle] forCellWithReuseIdentifier:@"AliyunEffectSpecialFilterCell"];
    
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self.contentView addSubview:_collectionView];
    
    _groupSelector = [[AlivcGroupSelector alloc] initWithFrame:CGRectMake(0,  CGRectGetMaxY(_collectionView.frame), ScreenWidth, 44)];
    [self.contentView addSubview:_groupSelector];

    _groupSelector.delegate = self;
    
    [self addNotifications];
    
    [self fetchEffectGroupDataWithCurrentShowGroup:nil];
//    dispatch_async(dispatch_get_global_queue(0, 0), ^{
//        [self reloadDataWithEffectType:AliyunEffectTypeSpecialFilter];
//        [self fetchEffectGroupDataWithCurrentShowGroup:nil];
//    });
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
        self.groupSelector.resurcePath = @"";
    }
    [self fetchEffectGroupDataWithCurrentShowGroup:nil];
}

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    

    AliyunEffectSpecialFilterCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectSpecialFilterCell" forIndexPath:indexPath];
    
    AliyunEffectInfo *effectInfo = _dataArray[indexPath.row];
    [cell cellModel:effectInfo];
    
    if (indexPath.row == _selectIndex && [self.groupSelector checkPathisEqualTo:_currentPath]) {
        [cell setSelected:YES];
        NSLog(@"滤镜测试%@：选中：%ld",effectInfo.name,(long)_selectIndex);
    }else{
        [cell setSelected:NO];
        NSLog(@"滤镜测试%@：不选中：%ld",effectInfo.name,(long)indexPath.row);
    }
//    if (_effectType == AliyunEffectTypeSpecialFilter) {
        if (indexPath.row == 0) {
            cell.imageView.contentMode = UIViewContentModeCenter;
            cell.imageView.backgroundColor = rgba(255, 255, 255, 0.2);
            cell.imageView.image = [AlivcImage imageNamed:@"shortVideo_clear"];
            cell.nameLabel.text = NSLocalizedString(@"无效果", nil);
            if (_selectIndex == 0) {
                [cell setSelected:YES];
            }else{
                [cell setSelected:NO];
            }
        }else{
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.backgroundColor = [UIColor clearColor];
        }
//    }
    [cell setExclusiveTouch:YES];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
//    if (_effectType == AliyunEffectTypeSpecialFilter) {
        AliyunEffectSpecialFilterCell *lastSelectCell = (AliyunEffectSpecialFilterCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
                NSLog(@"滤镜测试：不选中：%ld",_selectIndex);
        [lastSelectCell setSelected:NO];
//    }
    
    AliyunEffectInfo *currentEffect = _dataArray[indexPath.row];
//    if (_effectType == AliyunEffectTypeSpecialFilter) {
        if (_selectFilterBlock) {
            _selectFilterBlock(currentEffect);
        }
        _selectIndex = indexPath.row;
        _currentPath = self.groupSelector.resurcePath;
//    }
}

-(void)registerDidSelectEffectFilterBlock:(DidSelectEffectFilterBlock)block{
    _selectFilterBlock = block;
}

-(void)registerDidShowMoreEffectFilterBlock:(void(^)(void))block{
    _showMoreFilterBlock = block;
}

-(void)showRegulatorView:(AliyunEffectFilter*)effect paramList:(NSArray*)paramList{
    if (_regulatorView) {
        [_regulatorView removeFromSuperview];
        _regulatorView = nil;
    }
    
    if(paramList.count<=0){
        return;
    }
    
    self.regulatorView = [AlivcRegulatorView initUIwithData:paramList inView:self];
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

#pragma --mark loadData
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
        
        [weakSelf.groupSelector refreshData];
        
        //  当前没有任何下载group时，刷新collectionView
        if (weakSelf.groupSelector.groupData.count <= 2) {
            [weakSelf fetchDataByGroup:nil];
        }
        
    } failure:^(NSError *error) {
        [weakSelf.groupSelector refreshData];
    }];
}

- (void)fetchDataByGroup:(AliyunEffectInfo *)group {
    [_dataArray removeAllObjects];
    
    AliyunEffectInfo *effctNone = [[AliyunEffectInfo alloc] init];
    effctNone.name = [@"无效果" localString];
    effctNone.eid = -1;
    effctNone.effectType = AliyunEffectTypeSpecialFilter;
    effctNone.icon = @"shortVideo_clear";
    [self.dataArray insertObject:effctNone atIndex:0];
    
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

#pragma --mark AlivcGroupSelectorDelegate
- (void)didGroupSelectorShowMore{
    if (_showMoreFilterBlock) {
        _showMoreFilterBlock();
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

- (AlivcRegulatorView *)regulatorView{
    if (!_regulatorView) {
        _regulatorView = [[AlivcRegulatorView alloc] init];
//        [self addSubview:_regulatorView];
    }
    return _regulatorView;
}

@end
