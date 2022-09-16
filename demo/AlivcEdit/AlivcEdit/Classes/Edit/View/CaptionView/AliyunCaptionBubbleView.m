//
//  AliyunCaptionBubbleView.m
//  AlivcEdit
//
//  Created by mengyehao on 2021/5/26.
//

#import "AliyunCaptionBubbleView.h"

#import "AliyunEffectCaptionGroup.h"
#import "AliyunEffectPasterInfo.h"
#import "AliyunEffectFontInfo.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AliyunPasterGroupCollectionViewCell.h"
#import "AliyunCaptionCollectionViewCell.h"
#import "AliyunDBHelper.h"
#import "AliyunImage.h"
#import "AliyunEffectFontManager.h"
#import "AliyunEffectResourceModel.h"
#import "AlivcDefine.h"
#import "AliyunEffectPasterGroup.h"
#import "AlivcGroupSelector.h"
#import "UIView+AlivcHelper.h"
#import "AliyunEditViewController.h"
#import "UIView+OPLayout.h"

//字幕气泡展示的cell
static NSString *IdentifierAliyunCaptionCollectionViewCaptionCell = @"AliyunIdentifierCaptionCollectionViewCell";

@interface AliyunCaptionBubbleView()<UICollectionViewDataSource,UICollectionViewDelegate,AlivcGroupSelectorDelegate>
@property (nonatomic, strong) NSMutableArray<AliyunEffectPasterInfo *> *pasterData;
@property (nonatomic, strong) AliyunDBHelper *dbHelper;

@property (nonatomic, strong) AlivcGroupSelector *groupSelector;

@end

@implementation AliyunCaptionBubbleView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.op_height -= SafeBottom;
        self.bootomLine.op_top -= SafeBottom;
        self.bootomView.op_top -= SafeBottom;
        
        [self.contentView addSubview:self.collectionView];
        
        _groupSelector = [[AlivcGroupSelector alloc] initWithFrame:self.bootomView.bounds];
        [self.bootomView addSubview:self.groupSelector];
        _groupSelector.delegate = self;
        
        [self fetchCaptionGroupDataWithCurrentShowGroup:nil];
    }
    return self;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake(80, 80);
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[AliyunCaptionCollectionViewCell class] forCellWithReuseIdentifier:IdentifierAliyunCaptionCollectionViewCaptionCell];
    }
    
    return _collectionView;
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.pasterData.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    // 字幕展示区
    AliyunCaptionCollectionViewCell *pasterCell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierAliyunCaptionCollectionViewCaptionCell forIndexPath:indexPath];
    AliyunEffectPasterInfo *info = self.pasterData[indexPath.row];
    
    if (info.resourcePath.length == 0) {
        pasterCell.showImageView.image = [UIImage imageNamed:@"icon_clear"];
    } else {
  
        NSString *iconPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
        pasterCell.showImageView.image = [UIImage imageWithContentsOfFile:iconPath];
    }
    return pasterCell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunEffectPasterInfo *info = self.pasterData[indexPath.row];

    if ([self.delegate respondsToSelector:@selector(captionBubbleViewDidSeleted:)]) {
        [self.delegate captionBubbleViewDidSeleted:info];
    }
}


#pragma mark - Set

- (NSMutableArray *)pasterData {
    if (!_pasterData) {
        _pasterData = [[NSMutableArray alloc] init];
    }
    return _pasterData;
}

- (AliyunDBHelper *)dbHelper {
    if (!_dbHelper) {
        _dbHelper = [[AliyunDBHelper alloc] init];
    }
    return _dbHelper;
}

- (void)fetchCaptionGroupDataWithCurrentShowGroup:(AliyunEffectCaptionGroup *)group{
    [self.groupSelector.groupData removeAllObjects];
    
    [self.groupSelector.groupData addObject:@"shortVideo_paster_more"];
    if (group) {
        self.groupSelector.selectTitle = group.name;
    }
    __weak typeof (self)weakSelf = self;
    [[AliyunDBHelper new] queryResourceWithEffecInfoType:AliyunEffectTypeCaption success:^(NSArray *infoModelArray) {
        for (int index = 0; index < infoModelArray.count; index++) {
            AliyunEffectCaptionGroup *paster = infoModelArray[index];

            if (!group && weakSelf.groupSelector.selectTitle) {//普通刷新
                if ([paster.name isEqualToString:weakSelf.groupSelector.selectTitle]) {
                    [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
                }
            }else if (!group && index == infoModelArray.count - 1){// 没有指定选中的话 就展示第一条
                weakSelf.groupSelector.selectIndex = 0;
                [weakSelf fetchPasterInfoDataWithPasterGroup:infoModelArray.firstObject];
            }else if(group) {
                // 判断是否是当前选中group
                if (paster.eid == group.eid && [paster.name isEqualToString:group.name]) {
                    [weakSelf fetchPasterInfoDataWithPasterGroup:paster];
                    weakSelf.groupSelector.selectIndex = infoModelArray.count - index;
                }
            }
            [weakSelf.groupSelector.groupData insertObject:paster atIndex:0];
        }
        //  当前没有任何下载group时，刷新collectionView为空
        if (infoModelArray.count == 0) {
            [weakSelf fetchPasterInfoDataWithPasterGroup:nil];
        }
        [weakSelf.groupSelector refreshData];
    } failure:^(NSError *error) {
        [weakSelf.groupSelector refreshData];
    }];

}

- (AliyunEffectPasterInfo *)emptyModel
{
    AliyunEffectPasterInfo *model = [[AliyunEffectPasterInfo alloc] init];
    model.resourcePath = @"";
    return model;
}

- (void)fetchPasterInfoDataWithPasterGroup:(AliyunEffectCaptionGroup *)group {
    [self.pasterData removeAllObjects];
    [self.pasterData addObjectsFromArray:group.pasterList];
    if (self.pasterData.count > 0) {
        [self.pasterData insertObject:[self emptyModel] atIndex:0];
    }
    [self.collectionView reloadData];
}


#pragma --mark AlivcGroupSelectorDelegate
- (void)didGroupSelectorShowMore{
    UIViewController *vc = [self getCurrentVC];
    if([vc isKindOfClass:AliyunEditViewController.class]){
        __weak typeof (self)weakSelf = self;
        [((AliyunEditViewController*)vc) presentAliyunEffectMoreControllerWithAliyunEffectType: AliyunEffectTypeCaption completion:^(AliyunEffectInfo *info) {
            [weakSelf fetchCaptionGroupDataWithCurrentShowGroup:(AliyunEffectCaptionGroup*)info];
        }];
    }
}

-(void)didGroupSelectorHitByInfo:(AliyunEffectInfo*)info{
    [self fetchPasterInfoDataWithPasterGroup:(AliyunEffectCaptionGroup*)info];
}


@end
