//
//  AliyunEffectCaptionShowView.m
//  AliyunVideo
//
//  Created by TripleL on 17/3/16.
//  Copyright (C) 2010-2017 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectCaptionShowView.h"
#import "AliyunEffectCaptionGroup.h"
#import "AliyunEffectPasterInfo.h"
#import "AliyunEffectFontInfo.h"
#import "UIImageView+WebCache.h"
#import "AliyunPasterGroupCollectionViewCell.h"
#import "AliyunCaptionCollectionViewCell.h"
#import "AliyunDBHelper.h"
#import "AliyunImage.h"
#import "AliyunEffectFontManager.h"
#import "AliyunEffectResourceModel.h"
#import "AlivcDefine.h"

//分组选择的 cell
static NSString *IdentifierCaptionGroupCollectionViewShowCell = @"AliyunIdentifierCaptionGroupCollectionViewShowCell";
//分组选择为其他事件的cell
static NSString *IdentifierCaptionGroupCollectionViewFuncCell = @"AliyunIdentifierCaptionGroupCollectionViewFuncCell";
//纯字幕展示的cell
static NSString *IdentifierCaptionCollectionViewFontCell = @"AliyunIdentifierCaptionCollectionViewFontCell";
//字幕气泡展示的cell
static NSString *IdentifierAliyunCaptionCollectionViewCaptionCell = @"AliyunIdentifierCaptionCollectionViewCell";

@interface AliyunEffectCaptionShowView ()

@property (nonatomic, strong) NSMutableArray *groupData;
@property (nonatomic, strong) NSMutableArray *fontData;
@property (nonatomic, strong) NSMutableArray<AliyunEffectPasterInfo *> *pasterData;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

@end

@implementation AliyunEffectCaptionShowView

- (instancetype)init {
    if (self = [super init]) {
        [self addNotifications];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
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
    if ([model.name isEqualToString:self.selectTitle]) {
        self.selectTitle = nil;
    }
    [self fetchCaptionGroupDataWithCurrentShowGroup:nil];

}

- (void)removeFromSuperview {
    [self.dbHelper closeDB];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super removeFromSuperview];
}
#pragma mark - UI
- (void)setupSubViews {
    [super setupSubViews];
    self.selectIndex = 0;
    //设置顶部title信息
    [self.headerView setTitle:@"字幕" icon:[AlivcImage imageNamed:@"shortVideo_caption_font"]];
    [self.tabbarCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:IdentifierCaptionGroupCollectionViewShowCell];
    [self.tabbarCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:IdentifierCaptionGroupCollectionViewFuncCell];
    
    [self.pasterCollectionView registerClass:[AliyunCaptionCollectionViewCell class] forCellWithReuseIdentifier:IdentifierCaptionCollectionViewFontCell];
    [self.pasterCollectionView registerClass:[AliyunCaptionCollectionViewCell class] forCellWithReuseIdentifier:IdentifierAliyunCaptionCollectionViewCaptionCell];
}

#pragma mark - Data

- (void)fetchCaptionGroupDataWithCurrentShowGroup:(AliyunEffectCaptionGroup *)group{
    [self.groupData removeAllObjects];
    __weak typeof (self)weakSelf = self;
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    [helper queryAllResourcesWithEffectType:1 success:^(NSArray *resourceArray) {
        AliyunEffectResourceModel *model = resourceArray.firstObject;
        if (model) {
            //系统字体选项固定到首部
            [self.groupData insertObject:model atIndex:0];
        }
    } faliure:^(NSError *error) {
        
    }];
    // 尾部添加add Button image
    [self.groupData addObject:@"shortVideo_paster_more"];
    if (group) {
        self.selectTitle = group.name;
    }
    
    [helper queryResourceWithEffecInfoType:6 success:^(NSArray *infoModelArray) {
        for (int index = 0; index < infoModelArray.count; index++) {
            AliyunEffectCaptionGroup *paster = infoModelArray[index];
            
            if (!group && self.selectTitle) {//普通刷新
                if ([paster.name isEqualToString:self.selectTitle]) {
                    [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
                }
            }else if (!group && index == infoModelArray.count - 1){// 没有指定选中的话 就展示第一条
                self.selectIndex = 0;
                [weakSelf fetchPasterInfoDataWithPasterGroup:nil];
            }else if(group) {
                // 判断是否是当前选中group
                if (paster.eid == group.eid && [paster.name isEqualToString:group.name]) {
                    [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
                    self.selectIndex = infoModelArray.count - index-1;
                }
            }
            [weakSelf.groupData insertObject:paster atIndex:1];
        }
        //  当前没有任何下载group时，刷新collectionView为空
        if (infoModelArray.count == 0) {
            [weakSelf fetchPasterInfoDataWithPasterGroup:nil];
        }
        [weakSelf.tabbarCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    } failure:^(NSError *error) {
        [weakSelf.tabbarCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}
-(void)defaultSelectCell:(NSIndexPath *)indexPath{
    [self.tabbarCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:(UICollectionViewScrollPositionNone)];
}


- (void)fetchPasterInfoDataWithPasterGroup:(AliyunEffectCaptionGroup *)group {
    [self.fontData removeAllObjects];
    [self.pasterData removeAllObjects];
    if (!group) {
        [self fetchFontData:^{
            [self.pasterData addObjectsFromArray:self.fontData];
            [self.pasterCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        }];
    }else{
        [self fetchFontData:nil];
        for (AliyunEffectPasterInfo *listModel in group.pasterList) {
            [self.pasterData addObject:listModel];
        }
        [self.pasterCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.pasterCollectionView reloadData];
        if ([self.pasterCollectionView numberOfItemsInSection:0] <= 0) {
            return ;
        }
        [self.pasterCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] atScrollPosition:(UICollectionViewScrollPositionNone) animated:YES];
    });
}

// 获取字体
- (void)fetchFontData:(void(^)(void))block {
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    [helper queryResourceWithEffecInfoType:1 success:^(NSArray *infoModelArray) {
        for (AliyunEffectFontInfo *info in infoModelArray) {
            // 检测字体是否注册
            UIFont* aFont = [UIFont fontWithName:info.fontName size:14.0];
            BOOL isRegister = (aFont && ([aFont.fontName compare:info.fontName] == NSOrderedSame || [aFont.familyName compare:info.fontName] == NSOrderedSame));
            if (!isRegister && info.eid!= -2) {
                NSString *fontPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"font"] stringByAppendingPathExtension:@"ttf"];
                NSString *registeredName = [[AliyunEffectFontManager manager] registerFontWithFontPath:fontPath];
                if (registeredName) {
                    [self.fontData addObject:info];
                }
            } else {
                [self.fontData addObject:info];
            }
        }
        if (block) {
            block();
        }
    } failure:^(NSError *error) {
        [self.pasterCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}
#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    if ([collectionView isEqual:self.tabbarCollectionView]) {
        return self.groupData.count;
    } else {
        return self.pasterData.count;
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.tabbarCollectionView) {
        if(indexPath.row == 0){// 系统字体
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierCaptionGroupCollectionViewShowCell forIndexPath:indexPath];
            AliyunEffectCaptionGroup *group = [self getFormatGroupInfo:self.groupData[indexPath.row]];
            [packageCell setGroup:group];
            if (self.selectTitle) {
                packageCell.selected = [self isEqualSelectedTitle:group.name];
            }else{
                packageCell.selected = indexPath.row == 0;
            }
            return packageCell;
        }else if(indexPath.row == (self.groupData.count - 1)) {
            // 最后一个是addButton
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierCaptionGroupCollectionViewFuncCell forIndexPath:indexPath];
            packageCell.iconImageView.image = [AlivcImage imageNamed:self.groupData[indexPath.row]];
            return packageCell;
        }else {
            AliyunPasterGroupCollectionViewCell *packageCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierCaptionGroupCollectionViewShowCell forIndexPath:indexPath];
            AliyunEffectCaptionGroup *group = [self getFormatGroupInfo:self.groupData[indexPath.row]];
            [packageCell setGroup:group];
            if (self.selectTitle) {
                packageCell.selected = [self isEqualSelectedTitle:group.name];
            }else{
                packageCell.selected = indexPath.row == 0;
            }
            return packageCell;
        }
        
    } else {
            id info = self.pasterData[indexPath.row];
            if ([info isKindOfClass:[AliyunEffectFontInfo class]]) {
                // 字体展示区
                AliyunCaptionCollectionViewCell *pasterCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierCaptionCollectionViewFontCell forIndexPath:indexPath];
                AliyunEffectFontInfo *font = self.fontData[indexPath.row];
                pasterCell.isFont = YES;
                if (font.eid == -2) {
                    // 系统字体
                    pasterCell.showImageView.image = [AliyunImage imageNamed:@"system_font_icon"];
                }else{
                    [pasterCell.showImageView sd_setImageWithURL:[NSURL URLWithString:[font.icon stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
                }
                return pasterCell;
            }else{
                // 字幕展示区
                AliyunCaptionCollectionViewCell *pasterCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierAliyunCaptionCollectionViewCaptionCell forIndexPath:indexPath];
                AliyunEffectPasterInfo *info = self.pasterData[indexPath.row];
                NSString *iconPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
                pasterCell.showImageView.image = [UIImage imageWithContentsOfFile:iconPath];
                return pasterCell;
            }
    }
}
-(AliyunEffectCaptionGroup *)getFormatGroupInfo:(id)effectInfo{
    AliyunEffectCaptionGroup *effectGroup = [AliyunEffectCaptionGroup new];
    if ([effectInfo isKindOfClass:[NSMutableArray class]]) {
        NSArray *arr = (NSArray *)effectInfo;
        AliyunEffectFontInfo *effectFont = (AliyunEffectFontInfo*)[arr firstObject];
        effectGroup.name = effectFont.name;
        effectGroup.effectType = effectFont.effectType;
        effectGroup.isDBContain = effectFont.isDBContain;
        effectGroup.groupId = effectFont.groupId;
        effectGroup.eid = effectFont.eid;
        
    }else{
        effectGroup = (AliyunEffectCaptionGroup *)effectInfo;
    }
    return effectGroup;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([collectionView isEqual:self.tabbarCollectionView]) {
        if (indexPath.row == 0) {
            // reload
            self.selectIndex = indexPath.row;
            AliyunEffectCaptionGroup *group = [self getFormatGroupInfo:self.groupData[indexPath.row]];
            self.selectTitle = group.name;
            [self fetchPasterInfoDataWithPasterGroup:nil];
        }else if (indexPath.row == self.groupData.count - 1) {
            // add
            if (self.delegate && [self.delegate respondsToSelector:@selector(pasterBottomViewMore:)]) {
                [self.delegate pasterBottomViewMore:self];
            }
        } else {
            // reload
            self.selectIndex = indexPath.row;
            AliyunEffectCaptionGroup *group = [self getFormatGroupInfo:self.groupData[indexPath.row]];
            self.selectTitle = group.name;
            [self fetchPasterInfoDataWithPasterGroup:self.groupData[indexPath.row]];
        }
        [collectionView reloadData];
    } else {
        id model = self.pasterData[indexPath.row];
        if ([model isKindOfClass:[AliyunEffectFontInfo class]]) {
            if (self.fontDelegate && [self.fontDelegate respondsToSelector:@selector(onClickFontWithFontInfo:)]) {
                [self.fontDelegate onClickFontWithFontInfo:model];
            }
        }else{
            if (self.delegate && [self.delegate respondsToSelector:@selector(pasterBottomView:didSelectedPasterModel:)]) {
                [self.delegate pasterBottomView:self didSelectedPasterModel:model];
            }
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

- (NSMutableArray *)fontData {
    if (!_fontData) {
        _fontData = [[NSMutableArray alloc] init];
    }
    return _fontData;
}

- (AliyunDBHelper *)dbHelper {
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
    }
    return _dbHelper;
}

@end
