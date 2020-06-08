//
//  AlivcRecordPasterView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/5/5.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcRecordPasterView.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "AliyunMagicCameraEffectCell.h"
#import "AliyunPasterInfo.h"

//static NSString *AlivcRecordPasterViewPasterCellIdentifier = @"AlivcRecordPasterViewPasterCellIdentifier";

@interface AlivcRecordPasterView ()

/**
 动图view
 */
@property (nonatomic, strong) UICollectionView *gifCollectionView;


/**
 人脸动图选中的序号
 */
@property (nonatomic, assign) NSInteger selectGifIndex;

@property (nonatomic, strong) NSMutableArray *pasterDataSource; //动图数据源

@property (nonatomic, strong) NSMutableDictionary *cellDic;

@end
//TODO:只做了基础的UI托板的优化，业务逻辑还是老的，待优化
@implementation AlivcRecordPasterView
- (instancetype)initWithFrame:(CGRect)frame withItems:(NSArray<AlivcBottomMenuHeaderViewItem *> *)items{
    self = [super initWithFrame:frame withItems:items];
    if (self) {
        _pasterDataSource =[NSMutableArray arrayWithCapacity:10];
    }
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    if (!self.gifCollectionView.superview) {
        [self.contentView addSubview:self.gifCollectionView];
    }
}
- (void)setGifSelectedIndex:(NSInteger)selectedIndex{
    self.selectGifIndex = selectedIndex;
    [self.gifCollectionView reloadData];
}

- (UICollectionView *)gifCollectionView {
    if (!_gifCollectionView) {
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.sectionInset = UIEdgeInsetsMake(15, 22, 20, 22);
        flowLayout.minimumInteritemSpacing = 20;
        flowLayout.minimumLineSpacing = 20;
        _gifCollectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:flowLayout];
        _gifCollectionView.backgroundColor = [UIColor clearColor];
        _gifCollectionView.delegate = (id)self;
        _gifCollectionView.dataSource = (id)self;
//        [_gifCollectionView registerClass:[AliyunMagicCameraEffectCell class] forCellWithReuseIdentifier:@"AliyunMagicCameraEffectCell"];
    }
    return _gifCollectionView;
}



#pragma mark - UICollectionViewDataSource && UICollectionViewDelegate -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.pasterDataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    //由于要更新下载进度 这里cell不复用了
    NSString *identifier = [_cellDic objectForKey:[NSString stringWithFormat:@"%@", indexPath]];
    // 如果取出的唯一标示符不存在，则初始化唯一标示符，并将其存入字典中，对应唯一标示符注册Cell
    if (identifier == nil) {
        identifier = [NSString stringWithFormat:@"AliyunMagicCameraEffectCell%@", [NSString stringWithFormat:@"%@", indexPath]];
        [_cellDic setValue:identifier forKey:[NSString stringWithFormat:@"%@", indexPath]];
        // 注册Cell
        [_gifCollectionView registerClass:[AliyunMagicCameraEffectCell class]  forCellWithReuseIdentifier:identifier];
    }
    
    AliyunMagicCameraEffectCell *effectCell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    NSLog(@"\n-----动图下载测试：%ld,%p-------\n",(long)indexPath.row,effectCell);
    AliyunPasterInfo *pasterInfo = [self.pasterDataSource objectAtIndex:indexPath.row];
    
    if (pasterInfo.bundlePath != nil) {
        UIImage *iconImage = [UIImage imageWithContentsOfFile:pasterInfo.icon];
        [effectCell.imageView setImage:iconImage];
        [effectCell shouldDownload:NO];
        NSLog(@"动图下载测试刷新图片：bundlePath：%@",pasterInfo.bundlePath);
    } else {
        
        if ([pasterInfo fileExist] && pasterInfo.icon) {
            NSLog(@"动图下载测试刷新图片 存在：icon：%@ ",pasterInfo.icon);
            UIImage *iconImage = [UIImage imageWithContentsOfFile:pasterInfo.icon];
            if (!iconImage) {
                NSURL *url = [NSURL URLWithString:pasterInfo.icon];
                [effectCell.imageView sd_setImageWithURL:url];
                NSLog(@"动图下载测试url");
            } else {
                [effectCell.imageView setImage:iconImage];
                NSLog(@"动图下载测试iconImage");
            }
        } else {
            NSLog(@"动图下载测试刷新图片 不存在：icon：%@\n",pasterInfo.icon);
            NSURL *url = [NSURL URLWithString:pasterInfo.icon];
            [effectCell.imageView sd_setImageWithURL:url];
            
        }
        if (pasterInfo.icon == nil) {
            [effectCell shouldDownload:NO];
        } else {
            BOOL shouldDownload = ![pasterInfo fileExist];
            [effectCell shouldDownload:shouldDownload];
            NSLog(@"动图下载测试:下载按钮:%d",shouldDownload);
        }
        
    }
    if (indexPath.row == 0) {
        effectCell.imageView.contentMode = UIViewContentModeCenter;
        effectCell.imageView.backgroundColor = rgba(255, 255, 255, 0.2);
        effectCell.imageView.layer.cornerRadius = effectCell.imageView.frame.size.width/2;
        effectCell.imageView.layer.masksToBounds = YES;
        effectCell.imageView.image = [AlivcImage imageNamed:@"shortVideo_clear"];
        
    }else{
        effectCell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        effectCell.imageView.backgroundColor = [UIColor clearColor];
        effectCell.imageView.layer.cornerRadius = 50/2;
        effectCell.imageView.layer.masksToBounds = YES;
    }
    if (indexPath.row == _selectGifIndex) {
        [effectCell setApplyed:YES];
        
        NSLog(@"动图下载测试选择效果设置为YES");
    }else{
        [effectCell setApplyed:NO];
        NSLog(@"动图下载测试选择效果设置为NO");
    }
    return effectCell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunMagicCameraEffectCell *cell = (AliyunMagicCameraEffectCell *)[self.gifCollectionView cellForItemAtIndexPath:indexPath];
    
    if(cell.isLoading) {
        return;
    }
    
    AliyunPasterInfo *pasterInfo = self.pasterDataSource[indexPath.row];
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcRecordPasterViewDidSelectedPasterInfo:cell:)]) {
        [self.delegate alivcRecordPasterViewDidSelectedPasterInfo:pasterInfo cell:cell];
    }
}

/**
 动图应用上去之后更新UI状态
 */
- (void)refreshUIWhenThePasterInfoApplyedWithPasterInfo:(AliyunPasterInfo *)pasterInfo{
    NSInteger newIndex = [self.pasterDataSource indexOfObject:pasterInfo];
    if (newIndex != _selectGifIndex) {
        AliyunMagicCameraEffectCell *cell = (AliyunMagicCameraEffectCell *)[self.gifCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectGifIndex inSection:0]];
        if (cell) {
            [cell setApplyed:NO];
        }else{
            //获取不到cell表明用户在下载过程中滑动到其他地方去了
            [self.gifCollectionView reloadData];
        }
        
        NSLog(@"\n动图下载测试把%ld选中设为NO %p\n",_selectGifIndex,cell);
    }
    if (newIndex < self.pasterDataSource.count) {
        AliyunMagicCameraEffectCell *cell = (AliyunMagicCameraEffectCell *)[self.gifCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:newIndex inSection:0]];
        if (cell) {
            [cell setApplyed:YES];
            cell.downloadImageView.hidden = YES;
        }else{
            //获取不到cell表明用户在下载过程中滑动到其他地方去了
            [self.gifCollectionView reloadData];
        }
        _selectGifIndex = newIndex;
        NSLog(@"\n动图下载测试把%ld选中设为YES %p\n",_selectGifIndex,cell);
    }
}

//动图数组刷新ui
- (void)refreshUIWithGifItems:(NSArray *)pasterInfos{
    
    //当新加载的数据与已有数据不一致时，重新校验选中index;因为添加了2个本地元素，这里需要+2
    if (_selectGifIndex>0 && _selectGifIndex<_pasterDataSource.count
        && _pasterDataSource.count>0 && _pasterDataSource.count!=pasterInfos.count+2) {
        AliyunPasterInfo *selPaster = [_pasterDataSource objectAtIndex:_selectGifIndex];
        for (int i=0; i<pasterInfos.count; i++) {
            AliyunPasterInfo *p = [pasterInfos objectAtIndex:i];
            if (p.eid == selPaster.eid) {
                _selectGifIndex = i + 2;
                break;
            }
        }
    }
    
    //load本地数据
    AliyunPasterInfo *empty1 = [[AliyunPasterInfo alloc] init];
    empty1.icon = @"MV_none";
    
    empty1.bundlePath = @"icon";
    NSString *filterName = [NSString stringWithFormat:@"Face_Sticker/hanfumei-800"];
    NSString *path = [[NSBundle mainBundle] pathForResource:filterName ofType:nil];
    AliyunPasterInfo *paster = [[AliyunPasterInfo alloc] initWithBundleFile:path];
    if (self.pasterDataSource.count >0) {
        [self.pasterDataSource removeAllObjects];
    }
    [_pasterDataSource addObject:empty1];
    if (paster) {
      [_pasterDataSource addObject:paster];
    }
    [_pasterDataSource addObjectsFromArray:pasterInfos];
    [self.gifCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
}

- (NSMutableDictionary *)cellDic{
    if (!_cellDic) {
        _cellDic = @[].mutableCopy;
    }
    return _cellDic;
}

@end
