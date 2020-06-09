//
//  AliyunEffectTransitionVIew.m
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectTransitionView.h"
#import "AliyunTransitionCover.h"
#import "AliyunTransitionIcon.h"
#import "AliyunTransitionCoverCell.h"
#import "AliyunTransitionIconCell.h"
#import "AliyunTransitionPreviewCell.h"
#import "AliyunImage.h"
#import "UIView+AlivcHelper.h"
#import "AlivcEditBottomHeaderView.h"
#import "NSString+AlivcHelper.h"
#import "AlivcGroupSelector.h"
#import "AlivcDefine.h"
#import "AliyunEffectResourceModel.h"
#import "AliyunDBHelper.h"
#import "AliyunEffectFilterInfo.h"
#import "AlivcRegulatorView.h"
#import <AliyunVideoSDKPro/AliyunTransitionEffect.h>

@interface AliyunEffectTransitionView()<AlivcGroupSelectorDelegate>

@property (nonatomic, strong) AlivcEditBottomHeaderView *headerView;

@property (nonatomic, strong) AlivcGroupSelector *groupSelector;

/**
 选中的转场的数据模型
 */
@property (nonatomic, strong) AliyunTransitionIcon *selectedTransition;

//原有的内置转场
@property (nonatomic, strong) NSMutableArray *defaultFilerData;

@property (nonatomic,strong) AlivcRegulatorView* regulatorView;

//记录当前选中的TransitionCover
@property (nonatomic,assign) NSInteger curTransitionCoverRow;

@property (nonatomic,strong) AliyunTransitionCover *selectedCover;//当前选中的过渡片段

@end

@implementation AliyunEffectTransitionView
{
    AliyunTransitionIcon *_selectedIcon;//当前选中的动画
}

- (id)initWithFrame:(CGRect)frame delegate:(id<AliyunEffectTransitionViewDelegate>)delegate
{
    if (self = [super initWithFrame:frame]) {
        [self addVisualEffect];
//        self.backgroundColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:1];
        _covers = [[NSMutableArray alloc]initWithCapacity:8];
        _icons = [[NSMutableArray alloc]initWithCapacity:8];
        
        [self addSubview:self.headerView];
        
        self.coverTableView = [[PTEHorizontalTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+15, frame.size.width, 40)];
        UITableView *coverNativeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 40) style:UITableViewStylePlain];
        [coverNativeTableView registerClass:[AliyunTransitionCoverCell class] forCellReuseIdentifier:@"AliyunTransitionCoverCell"];
        [coverNativeTableView registerClass:[AliyunTransitionPreviewCell class] forCellReuseIdentifier:@"AliyunTransitionPreviewCell"];
        coverNativeTableView.separatorColor = [UIColor clearColor];
        self.coverTableView.tableView = coverNativeTableView;
        self.coverTableView.delegate = self;
        self.coverTableView.tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.coverTableView];
        self.coverTableView.backgroundColor = [UIColor clearColor];
        coverNativeTableView.backgroundColor = [UIColor clearColor];
    
        self.transitionTableView = [[PTEHorizontalTableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-62-15-44-SafeBottom, frame.size.width, 62)];
        UITableView *transitionNativeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 62) style:UITableViewStylePlain];
        [transitionNativeTableView registerClass:[AliyunTransitionIconCell class] forCellReuseIdentifier:@"AliyunTransitionIconCell"];
        transitionNativeTableView.separatorColor = [UIColor clearColor];
        self.transitionTableView.tableView = transitionNativeTableView;
        self.transitionTableView.delegate = self;
        self.transitionTableView.tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.transitionTableView];
        self.transitionTableView.backgroundColor = [UIColor clearColor];
        transitionNativeTableView.backgroundColor = [UIColor clearColor];
        self.delegate = delegate;
        
        _groupSelector = [[AlivcGroupSelector alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - 44-SafeBottom, CGRectGetWidth(self.bounds), 44)];
        [self addSubview:self.groupSelector];
        _groupSelector.delegate = self;
        
        _curTransitionCoverRow = 1;
        
        [self addNotifications];
    }
    return self;
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
    [self fetchEffectGroupDataWithCurrentShowGroup:nil];
    
    if (model.resourcePath.length>0) {
        //如果当前选中cover是自定义的 则关闭参数调节器
        if ([_selectedCover.resourcePath isEqualToString:model.resourcePath]) {
            [self showRegulatorView:nil paramList:nil index:_selectedCover.transitionIdx];
        }
        
        //删除后变更cover选中图片
        for (AliyunTransitionCover *cover in _covers) {
            if ([cover.resourcePath isEqualToString:model.resourcePath]) {
                cover.image = [AlivcImage imageNamed:@"transition_cover_point_Sel"];
                cover.image_Nor = [AlivcImage imageNamed:@"transition_cover_point_Nor"];
                cover.name = nil;
                cover.transitionPath = nil;
                cover.resourcePath = nil;
                cover.paramsJsonString = nil;
            }
        }
        
        //如果存在已经缓存，则清除
        if (self.delegate && [self.delegate respondsToSelector:@selector(clearRetentionByPath:)]) {
            [self.delegate clearRetentionByPath:model.resourcePath];
        }
    }
    
    [self.coverTableView.tableView reloadData];
}

-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

-(void)setupDataSourceClips:(NSArray *)images blockHandle:(void (^)(NSArray<AliyunTransitionCover *> *, NSArray<AliyunTransitionIcon *> *))block{
    
    if (_covers) {
        [_covers removeAllObjects];
        for (int idx = 0; idx < [images count]; idx++) {
            AliyunTransitionCover *cover = [[AliyunTransitionCover alloc] init];
            cover.image = [images objectAtIndex:idx];
            cover.isTransitionIdx = NO;
            cover.isSelect = NO;
            [_covers addObject:cover];
            if (idx < [images count] - 1) {
                AliyunTransitionCover *cover1 = [[AliyunTransitionCover alloc] init];
                cover1.image = [AlivcImage imageNamed:@"transition_cover_point_Sel"];
                cover1.image_Nor = [AlivcImage imageNamed:@"transition_cover_point_Nor"];
                cover1.isTransitionIdx = YES;
                cover1.isSelect = idx == 0?:NO;//默认选中
                cover1.transitionIdx = idx;
                
                [_covers addObject:cover1];
            }
        }
    }
    
    //加载分组选择器
    [self fetchEffectGroupDataWithCurrentShowGroup:nil];
    [self.coverTableView.tableView reloadData];
    if (block) {
        block([_covers copy],[_icons copy]);
    }
}

#pragma UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(PTEHorizontalTableView *)horizontalTableView numberOfRowsInSection:(NSInteger)section
{
    if (horizontalTableView == self.coverTableView) {
        return [_covers count];
    }
    if (horizontalTableView == self.transitionTableView) {
        return [_icons count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(PTEHorizontalTableView *)horizontalTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (horizontalTableView == self.coverTableView) {
        if (indexPath.row % 2 == (0)) {
            AliyunTransitionPreviewCell *cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"AliyunTransitionPreviewCell"];
            AliyunTransitionCover *cover = [_covers objectAtIndex:indexPath.row];
            [cell setTransitionCover:cover];
            return cell;
        }else{
            AliyunTransitionCoverCell *cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"AliyunTransitionCoverCell"];
            AliyunTransitionCover *cover = [_covers objectAtIndex:indexPath.row];
            [cell setTransitionCover:cover];
            return cell;
        }
        
    }
    
    if (horizontalTableView == self.transitionTableView) {
        AliyunTransitionIconCell *cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"AliyunTransitionIconCell"];
        AliyunTransitionIcon *icon = [_icons objectAtIndex:indexPath.row];
        [cell setTransitionIcon:icon];
        
        
        return cell;
    }
    return nil;
}

- (void)tableView:(PTEHorizontalTableView *)horizontalTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (horizontalTableView == self.coverTableView) {
        AliyunTransitionCover *cover = [_covers objectAtIndex:indexPath.row];
        if (cover.isTransitionIdx) {
            _curTransitionCoverRow = indexPath.row;
            [self transitionCoverCellStatusChange:cover];
//            if (cover.name) {
                [self.delegate previewTransitionIndex:cover];
//            }
        }
        [horizontalTableView.tableView reloadData];
        [self.transitionTableView.tableView reloadData];
    }
    
    if (horizontalTableView == self.transitionTableView) {
        AliyunTransitionIcon *icon = [_icons objectAtIndex:indexPath.row];
        //选中效果
        [self transitionIconCellStatusChange:icon];
        [self.coverTableView.tableView reloadData];
        
        if (_selectedCover) {
            [self.delegate didSelectTransitionType:(TransitionType)icon.type resoucePath:icon.resoucePath index:_selectedCover.transitionIdx];
        }
        
        [horizontalTableView.tableView reloadData];
    }
}
//改变Cover Cell选中状态
-(void)transitionCoverCellStatusChange:(AliyunTransitionCover *)cover{
    for (AliyunTransitionCover *lastSelCover in _covers) {
        if (lastSelCover.isSelect) {
            lastSelCover.isSelect = NO;
        }
    }
    cover.isSelect = YES;
    for (AliyunTransitionIcon *icon in _icons) {
        if ([icon.text isEqualToString:cover.name]) {
            icon.isSelect = YES;
        }else{
            icon.isSelect =NO;
        }
    }
//    _selectedCover = cover;
}
//改变动画cell选中状态
-(void)transitionIconCellStatusChange:(AliyunTransitionIcon *)icon{
    BOOL isRepeated = NO;
    for (AliyunTransitionIcon *lastSelIcon in _icons) {
        if (lastSelIcon.isSelect) {
            if (lastSelIcon == icon) {
                isRepeated = NO;
                return;
            }
            lastSelIcon.isSelect = NO;
        }
    }
    if (isRepeated) {return;}
    icon.isSelect = YES;
    for (AliyunTransitionCover *lastSelCover in _covers) {
        if (lastSelCover.isSelect) {
            lastSelCover.image = icon.coverIcon;
            lastSelCover.name = icon.text;
            lastSelCover.type = icon.type;
            lastSelCover.transitionPath = icon.resoucePath;
            lastSelCover.transitionImage_Nor = icon.image;
            lastSelCover.resourcePath = self.groupSelector.resurcePath;
            _selectedCover = lastSelCover;
        }
    }
}

- (CGFloat)tableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath{
    if (horizontalTableView == self.coverTableView) {
        if (indexPath.row % (2) == 0) {
            return 90;
        }else{
            return 57;
        }
    }
    if (horizontalTableView == self.transitionTableView) {
        return 70;
    }
    return 0;
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

-(void)showRegulatorView:(AliyunTransitionEffect*)effect paramList:(NSArray*)paramList index:(int)idx{
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
            weakSelf.didChangeEffectFinish(effect,idx);
            weakSelf.selectedCover.paramsJsonString = [effect getFliterParamString];
            AliyunTransitionCover *curCover = [weakSelf.covers objectAtIndex:weakSelf.curTransitionCoverRow];
            if(curCover){
                curCover.paramsJsonString = weakSelf.selectedCover.paramsJsonString;
            }
        }
    };
}

-(void)updateRegulatorViewWithCover:(AliyunTransitionCover*)cover{
    if (cover.transitionPath.length>0) {
           AliyunTransitionEffect *customEffect = [[AliyunTransitionEffect alloc] initWithPath:cover.transitionPath];
           if (cover.paramsJsonString.length>0) {
               customEffect.paramString = cover.paramsJsonString;
           }
           NSArray *paramList = [AlivcRegulatorView getSliderParams:customEffect.effectConfig];
           [self showRegulatorView:customEffect paramList:paramList index:cover.transitionIdx];
       }else{
           [self showRegulatorView:nil paramList:nil index:cover.transitionIdx];
       }
}

#pragma --mark Data
- (void)fetchEffectGroupDataWithCurrentShowGroup:(AliyunEffectInfo *)group{
    [self.groupSelector.groupData removeAllObjects];
    
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
    [helper queryResourceWithEffecInfoType:AliyunEffectTypeTransition success:^(NSArray *infoModelArray) {
        for (int index = 0; index < infoModelArray.count; index++) {
            AliyunEffectInfo *info = infoModelArray[index];
                        
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
    
    [_icons removeAllObjects];
    
    AliyunTransitionIcon *tIcon = [[AliyunTransitionIcon alloc] init];
    tIcon.image = [AlivcImage imageNamed:@"transition_null_Nor"];
    tIcon.coverIcon =[AlivcImage imageNamed:@"transition_null_Nor"];
    tIcon.imageSel =[AlivcImage imageNamed:@"shortVideo_Item_selected"];
    tIcon.text = [@"无" localString];
    tIcon.type = TransitionTypeNull;
    [self.icons insertObject:tIcon atIndex:0];
    
    if (self.groupSelector.selectIndex == -1) {
        self.groupSelector.selectIndex = 0; //默认是不选中
    }
    
    if (group.eid == 0) {
        //加载原有内置的特效
        [self.icons addObjectsFromArray:self.defaultFilerData];
    }else{
        //加载下载的特效
         NSString *dirPath = [NSHomeDirectory() stringByAppendingPathComponent:group.resourcePath];
        [self loadLocalEffects:dirPath isDestDir:NO];
    }
    
    if (!_selectedIcon) {
        _selectedIcon = [self.icons firstObject];
    }
    
    [self.transitionTableView.tableView reloadData];
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
                            AliyunTransitionIcon *tIcon = [[AliyunTransitionIcon alloc] init];
                            //[UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/%@/icon.png",basePath, path]];
                            tIcon.isCustomLocaleLanguage = YES;
                            tIcon.image = [AlivcImage imageNamed:@"transition_defalut_Nor"];;
                            tIcon.coverIcon =[AlivcImage imageNamed:@"transition_defalut_Nor"];;
                            tIcon.imageSel =[AlivcImage imageNamed:@"shortVideo_Item_selected"];
                            tIcon.textEn = path;
                            if (i18nDic) {
                                tIcon.text = i18nDic[path][@"name"][@"zh_cn"];
                            }
                            tIcon.isSelect = NO;
                            tIcon.type = -1;
                            tIcon.resoucePath = [basePath stringByAppendingPathComponent:path];
                            
                            [self.icons addObject:tIcon];
                            
                            if (self.selectedTransition) {
                                    if (tIcon.eid == self.selectedTransition.eid) {
                                        self.groupSelector.selectIndex = [self.icons indexOfObject:tIcon] + 1;
                                    }
                                }
                        }
                    }
                }else{
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
    if (self.delegate && [self.delegate respondsToSelector:@selector(didShowMoreTransition)]) {
        [self.delegate didShowMoreTransition];
    }
}

-(void)didGroupSelectorHitByInfo:(AliyunEffectInfo*)info{
    [self fetchDataByGroup:info];
    if (_curTransitionCoverRow>0 && _curTransitionCoverRow<_covers.count) {
        AliyunTransitionCover *cover = [_covers objectAtIndex:_curTransitionCoverRow];
        [self transitionCoverCellStatusChange:cover];
        [self.transitionTableView.tableView reloadData];
    }
}

#pragma mark - Get
- (AlivcEditBottomHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
        _headerView.backgroundColor = [UIColor clearColor];
        [_headerView setTitle:[@"转场" localString] icon:[AlivcImage imageNamed:@"shortVideo_transition_icon"]];
        __weak typeof(self)weakSelf = self;
        [_headerView bindingApplyOnClick:^{//确认
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(applyButtonClickCovers:andIcons:transitionInfo:)]) {
                [weakSelf.delegate applyButtonClickCovers:weakSelf.covers andIcons:weakSelf.icons transitionInfo:[weakSelf getTransitionIfon]];
            }
        } cancelOnClick:^{//取消
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(transitionCancelButtonClickTransitionInfo:)]) {
                [weakSelf.delegate transitionCancelButtonClickTransitionInfo:[weakSelf getTransitionIfon]];
            }
        }];
    }
    return _headerView;
}

-(NSDictionary *)getTransitionIfon{
    NSMutableDictionary *transitionInfo = [NSMutableDictionary dictionaryWithCapacity:8];
    for (int i = 0; i<_covers.count; i++) {
        AliyunTransitionCover *cover = _covers[i];
        if (cover.isTransitionIdx) {//本次转场编辑状态保存
            [transitionInfo setValue:cover forKey:[NSString stringWithFormat:@"%d",cover.transitionIdx]];
        }
    }
    return [transitionInfo copy];
}

-(void)setIcons:(NSMutableArray<AliyunTransitionIcon *> *)icons{
    _icons = icons;
    [self.transitionTableView.tableView reloadData];
}
-(void)setCovers:(NSMutableArray<AliyunTransitionCover *> *)covers{
    _covers = covers;
    [self.coverTableView.tableView reloadData];
}

-(void)updateGroupSelector{
    if (_covers.count>0) {
        AliyunTransitionCover *selCover = nil;
        
//        if (self.selectedCover) {
//            [self updateRegulatorViewWithCover:self.selectedCover];
//        }
        for (AliyunTransitionCover *cover in _covers) {
            if (cover.isSelect && cover.isTransitionIdx) {
                selCover = cover;
                break;
            }
        }
        
        if (selCover) {
             [self updateRegulatorViewWithCover:selCover];
            
            for (AliyunEffectInfo *group in self.groupSelector.groupData) {
                if (!selCover.name) {
                    if ([group.name isEqualToString: self.groupSelector.selectTitle]) {
                        [self didGroupSelectorHitByInfo:group];
                        return;
                    }
                }
                if ([group isKindOfClass:AliyunEffectInfo.class] && [group.resourcePath isEqualToString:selCover.resourcePath]) {
                    [self didGroupSelectorHitByInfo:group];
                    return;
                }
            }
        }
        [self didGroupSelectorHitByInfo:nil];
    }
}

- (NSMutableArray *)defaultFilerData {
    if (!_defaultFilerData) {
        _defaultFilerData = [[NSMutableArray alloc] init];
        
        NSArray *textArray = @[[@"向上移动" localString],[@"向下移动" localString], [@"向左移动" localString], [@"向右移动" localString], [@"百叶窗" localString], [@"淡入淡出" localString],[@"圆形" localString], [@"多边形" localString]];
        NSArray *iconNameArray =  @[@"transition_up",
                                    @"transition_down",
                                    @"transition_left",
                                    @"transition_right",
                                    @"transition_shuffer",
                                    @"transition_fade",
                                    @"transition_circle",
                                    @"transition_star"];
        
        NSArray *types = @[@(TransitionTypeMoveUp),
                           @(TransitionTypeMoveDown),
                           @(TransitionTypeMoveLeft),
                           @(TransitionTypeMoveRight),
                           @(TransitionTypeShuffer),
                           @(TransitionTypeFade),
                           @(TransitionTypeCircle),
                           @(TransitionTypeStar)];
        for (int idx = 0; idx < textArray.count; idx++) {
            NSString *text = [textArray objectAtIndex:idx];
            NSString *iconName = [iconNameArray objectAtIndex:idx];
            UIImage *iconImage = [AlivcImage imageNamed:[NSString stringWithFormat:@"%@_Nor",iconName]];
            UIImage *coverIcon = [AlivcImage imageNamed:[NSString stringWithFormat:@"%@_Cover",iconName]];
            AliyunTransitionIcon *tIcon = [[AliyunTransitionIcon alloc] init];
            tIcon.image = iconImage;
            tIcon.coverIcon =coverIcon;
            tIcon.imageSel =[AlivcImage imageNamed:@"shortVideo_Item_selected"];
            tIcon.text = text;
            tIcon.isSelect = NO;
            tIcon.type = [[types objectAtIndex:idx] intValue];
            tIcon.resoucePath = nil;
            [_defaultFilerData addObject:tIcon];
        }
        
    }
    return _defaultFilerData;
}

@end
