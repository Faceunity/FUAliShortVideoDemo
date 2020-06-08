//
//  QUPasterSelectView.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/13.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPasterShowView.h"
#import "UIView+AlivcHelper.h"
#import "AliyunPasterGroupCollectionViewCell.h"
#import "AliyunEffectPasterGroup.h"
#import "AliyunEffectPasterInfo.h"
#import "AliyunDBHelper.h"
#import "AliyunEffectResourceModel.h"
#import "AlivcDefine.h"

//分组选择的 cell
static NSString *IdentifierTabbarCollectionViewShowCell = @"AliyunIdentifierPackageCollectionViewShowCell";
//分组选择为button的cell
static NSString *IdentifierTabbarCollectionViewButtonCell = @"AliyunIdentifierPackageCollectionViewButtonCell";
//动图展示的cell
static NSString *IdentifierPasterCollectionViewCell = @"AliyunIdentifierPasterCollectionViewCell";

@interface AliyunPasterShowView ()

@property (nonatomic, strong) NSMutableArray *groupData;//分组数据源
@property (nonatomic, strong) NSMutableArray<AliyunEffectPasterInfo *> *pasterData;//动图数据源

@end

@implementation AliyunPasterShowView

#pragma mark - UI

-(void)setupSubViews{
    [super setupSubViews];
    self.selectIndex = 0;
    //设置顶部title信息
    [self.headerView setTitle:NSLocalizedString(@"动图", nil)  icon:[AlivcImage imageNamed:@"shortVideo_paster_gif"]];
    [self.tabbarCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:IdentifierTabbarCollectionViewShowCell];
    [self.tabbarCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:IdentifierTabbarCollectionViewButtonCell];
    [self.pasterCollectionView registerClass:[AliyunPasterCollectionViewCell class] forCellWithReuseIdentifier:IdentifierPasterCollectionViewCell];
    [self addNotifications];
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
    if ([model.name isEqualToString:self.selectTitle]) {
        self.selectTitle = nil;
    }
    [self fetchPasterGroupDataWithCurrentShowGroup:nil];
}
-(void)removeFromSuperview{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}

#pragma mark - Data 

- (void)fetchPasterGroupDataWithCurrentShowGroup:(AliyunEffectPasterGroup *)group{
    [self.groupData removeAllObjects];
    // 头部添加remove Button image
//    [self.groupData addObject:@"QPSDK.bundle/edit_paster_none"];
    // 尾部添加add Button image
    [self.groupData addObject:@"shortVideo_paster_more"];
    if (group) {
        self.selectTitle = group.name;
    }
    __weak typeof (self)weakSelf = self;
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    [helper queryResourceWithEffecInfoType:2 success:^(NSArray *infoModelArray) {
        for (int index = 0; index < infoModelArray.count; index++) {
            AliyunEffectPasterGroup *paster = infoModelArray[index];
            if (!group && self.selectTitle) {//普通刷新
                if ([paster.name isEqualToString:self.selectTitle]) {
                    [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
                }
            }else if (!group && index == infoModelArray.count - 1){// 没有指定选中的话 就展示第一条
                self.selectIndex = 0;
                self.selectTitle = paster.name;
                [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
            }else if(group){
                // 判断是否是当前选中group
                if (paster.eid == group.eid && [paster.name isEqualToString:group.name]) {
                    [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
                    self.selectIndex = infoModelArray.count - index-1;
                }
            }
            [weakSelf.groupData insertObject:paster atIndex:0];
        }
        //  当前没有任何下载group时，刷新collectionView为空
        if (infoModelArray.count == 0) {
            [weakSelf fetchPasterInfoDataWithPasterGroup:nil];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [weakSelf.tabbarCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        });
    } failure:^(NSError *error) {
        [weakSelf.tabbarCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

- (void)fetchPasterInfoDataWithPasterGroup:(AliyunEffectPasterGroup *)group {
    
    [self.pasterData removeAllObjects];
    for (AliyunEffectPasterInfo *listModel in group.pasterList) {
        [self.pasterData addObject:listModel];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pasterCollectionView reloadData];
        if ([self.pasterCollectionView numberOfItemsInSection:0] <= 0) {
            return ;
        }
    });
}


#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.tabbarCollectionView]) {
        return self.groupData.count;
    } else {
        return  self.pasterData.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.tabbarCollectionView]) {
        if (indexPath.row == self.groupData.count - 1) {
            //最后一个是addButton
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierTabbarCollectionViewButtonCell forIndexPath:indexPath];
            packageCell.iconImageView.image = [AlivcImage imageNamed:self.groupData[indexPath.row]];
            return packageCell;
        } else {
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierTabbarCollectionViewShowCell forIndexPath:indexPath];
            AliyunEffectPasterGroup *group = self.groupData[indexPath.row];
            [packageCell setGroup:group];
            if (self.selectTitle) {
                packageCell.selected = [self isEqualSelectedTitle:group.name];
            }else{
                packageCell.selected = indexPath.row == 0;
            }
            return packageCell;
        }
    } else {
        AliyunPasterCollectionViewCell *pasterCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierPasterCollectionViewCell forIndexPath:indexPath];
        AliyunEffectPasterInfo *info = self.pasterData[indexPath.row];
        NSString *iconPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
        pasterCell.showImageView.image = [UIImage imageWithContentsOfFile:iconPath];
        return pasterCell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([collectionView isEqual:self.tabbarCollectionView]) {
        if (indexPath.row == self.groupData.count - 1) {
            // add
            if (self.delegate && [self.delegate respondsToSelector:@selector(pasterBottomViewMore:)]) {
                [self.delegate pasterBottomViewMore:self];
            }
        } else {
            // reload
            self.selectIndex = indexPath.row;
            AliyunEffectPasterGroup *group = self.groupData[indexPath.row];
            self.selectTitle = group.name;
            [self fetchPasterInfoDataWithPasterGroup:self.groupData[indexPath.row]];
        }
        [collectionView reloadData];
        
    } else {
        if (self.delegate && [self.delegate respondsToSelector:@selector(pasterBottomView:didSelectedPasterModel:)]) {
            [self.delegate pasterBottomView:self didSelectedPasterModel:self.pasterData[indexPath.row]];
        }
    }
}



#pragma mark - Set
- (NSMutableArray *)groupData {
    if (!_groupData) {
        _groupData = [[NSMutableArray alloc] init];
    }
    return _groupData;
}

- (NSMutableArray *)pasterData {
    if (!_pasterData) {
        _pasterData = [[NSMutableArray alloc] init];
    }
    return _pasterData;
}

@end
