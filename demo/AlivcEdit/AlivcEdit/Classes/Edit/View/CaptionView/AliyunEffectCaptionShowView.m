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
#import <SDWebImage/UIImageView+WebCache.h>
#import "AliyunPasterGroupCollectionViewCell.h"
#import "AliyunCaptionCollectionViewCell.h"
#import "AliyunDBHelper.h"
#import "AliyunImage.h"
#import "AliyunEffectFontManager.h"
#import "AliyunEffectResourceModel.h"
#import "AlivcDefine.h"
#import "UIView+OPLayout.h"
#import "AliyunEffectPasterGroup.h"


//分组选择为其他事件的cell
static NSString *IdentifierCaptionGroupCollectionViewFuncCell = @"AliyunIdentifierCaptionGroupCollectionViewFuncCell";

@interface AliyunEffectCaptionShowView ()

@property (nonatomic, strong) NSMutableArray *groupData;


@end

@implementation AliyunEffectCaptionShowView

#pragma mark - UI
- (void)setupSubViews {
    [super setupSubViews];
    self.selectIndex = 0;
    
    self.pasterCollectionView.frame = CGRectZero;
    self.pasterCollectionView.dataSource = nil;
    self.pasterCollectionView.delegate = nil;
    
    //设置顶部title信息
    [self.headerView setTitle:NSLocalizedString( @"字幕", nil) icon:[AlivcImage imageNamed:@"shortVideo_caption_font"]];
    
    self.bottomBar.op_top = CGRectGetMaxY(self.timeLinePalletView.frame);
    [self.tabbarCollectionView registerClass:[AliyunPasterGroupCollectionViewCell class] forCellWithReuseIdentifier:IdentifierCaptionGroupCollectionViewFuncCell];
    
    AliyunEffectPasterGroup *addGroup = [AliyunEffectPasterGroup new];
    addGroup.name = @"添加";
    
    [self.groupData addObject:addGroup];
    
    [self.tabbarCollectionView reloadData];
}

-(void)defaultSelectCell:(NSIndexPath *)indexPath{
    [self.tabbarCollectionView selectItemAtIndexPath:indexPath animated:YES scrollPosition:(UICollectionViewScrollPositionNone)];
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.groupData.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {

    AliyunPasterGroupCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:IdentifierCaptionGroupCollectionViewFuncCell forIndexPath:indexPath];
    AliyunEffectPasterGroup *addGroup = self.groupData[indexPath.row];
    cell.group = addGroup;
    return cell;

}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([self.fontDelegate respondsToSelector:@selector(captionShowViewonClickAddNew)]) {
        [self.fontDelegate captionShowViewonClickAddNew];
    }
}

#pragma mark - Set
- (NSMutableArray *)groupData {
    if (!_groupData) {
        _groupData = [[NSMutableArray alloc] init];
    }
    return _groupData;
}
@end
