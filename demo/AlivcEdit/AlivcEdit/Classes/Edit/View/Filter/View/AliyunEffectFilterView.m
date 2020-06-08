//
//  AliyunEffectFilterView.m
//  qusdk
//
//  Created by Vienta on 2018/1/12.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectFilterView.h"
#import "AliyunEffectFilterCell.h"
#import "AliyunEffectInfo.h"
#import "AliyunDBHelper.h"
#import "AVC_ShortVideo_Config.h"
#import "AliyunEffectResourceModel.h"
#import "AlivcEditBottomHeaderView.h"
@interface AliyunEffectFilterView()

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
@property (nonatomic, assign) NSInteger effectType;

/**
 选中滤镜的序号
 */
@property (nonatomic, assign) NSInteger selectIndex;

@property (nonatomic, strong) AlivcEditBottomHeaderView *headerView;
@end

@implementation AliyunEffectFilterView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
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

    _headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 45)];
    [_headerView setTitle:NSLocalizedString(@"滤镜", nil) icon:[AlivcImage imageNamed:@"shortVideo_fliter"]];
    [_headerView hiddenButton];
    [self addSubview:_headerView];
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
    
    [self reloadDataWithEffectType:AliyunEffectTypeFilter];
}


/**
 重写hideTop的回调方法

 @param hideTop 录制中的滤镜hideTop为Yes,编辑中的滤镜hideTop为No
 */
- (void)setHideTop:(BOOL)hideTop{
    _hideTop = hideTop;
    _headerView.hidden = hideTop;
    _collectionView.frame = CGRectMake(0, 20, ScreenWidth, 102);
    
}


- (void)reloadDataWithEffectType:(NSInteger)eType {

    _effectType = eType;
    
    [_dataArray removeAllObjects];
    
    if (_selectIndex == -1) {
        _selectIndex = 0; //默认是不选中
    }
    __weak typeof(self)weakSelf = self;
    [_dbHelper queryResourceWithEffecInfoType:eType success:^(NSArray *infoModelArray) {
        for (AliyunEffectMvGroup *mvGroup in infoModelArray) {
            [weakSelf.dataArray addObject:mvGroup];
            if (weakSelf.selectedEffect) {
                if (mvGroup.eid == weakSelf.selectedEffect.eid) {
                    weakSelf.selectIndex = [infoModelArray indexOfObject:mvGroup] + 1;
                }
            }
        }
        
//        if (eType == AliyunEffectTypeFilter) {
//            // 在这里可以自定义滤镜顺序或者在LocalFilter文件里修改
//            AliyunEffectMvGroup *mvGroup = _dataArray[2];
//            _dataArray[2] = _dataArray[1];
//            _dataArray[1] = mvGroup;
//        }
        if (eType != AliyunEffectTypeSpecialFilter) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf.collectionView reloadData];
            });
        }
       
    } failure:^(NSError *error) {
        
    }];
    
    
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArray.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    AliyunEffectFilterCell *cell;
    if (indexPath.row == 0 || indexPath.row == _dataArray.count - 1) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell" forIndexPath:indexPath];
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunEffectFilterCell" forIndexPath:indexPath];
        
    }
    
    
    AliyunEffectInfo *effectInfo = _dataArray[indexPath.row];
    [cell cellModel:effectInfo];
    if (_effectType != AliyunEffectTypeSpecialFilter) {
        if (indexPath.row == _selectIndex) {
            [cell setSelected:YES];
            NSLog(@"滤镜测试%@：选中：%ld",effectInfo.name,_selectIndex);
        }else{
            [cell setSelected:NO];
            NSLog(@"滤镜测试%@：不选中：%ld",effectInfo.name,indexPath.row);
        }
    }
    if (_effectType == AliyunEffectTypeFilter) {
        if (indexPath.row == 0) {
            cell.imageView.contentMode = UIViewContentModeCenter;
            cell.imageView.backgroundColor = rgba(255, 255, 255, 0.2);
            cell.imageView.image = [AlivcImage imageNamed:@"shortVideo_clear"];
            cell.nameLabel.text = NSLocalizedString(@"无效果", nil);
        }else{
            cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
            cell.imageView.backgroundColor = [UIColor clearColor];
        }
    }
    
    [cell setExclusiveTouch:YES];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_effectType != AliyunEffectTypeSpecialFilter) {
        AliyunEffectFilterCell *lastSelectCell = (AliyunEffectFilterCell *)[collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:_selectIndex inSection:0]];
        NSLog(@"滤镜测试：不选中：%ld",_selectIndex);
        [lastSelectCell setSelected:NO];
    }
    
    AliyunEffectInfo *currentEffect = _dataArray[indexPath.row];
    if (_effectType == AliyunEffectTypeFilter) {
        [_delegate didSelectEffectFilter:(AliyunEffectFilterInfo *)currentEffect];
        _selectIndex = indexPath.row;
    }
}

//- (void)setSelectedEffect:(AliyunEffectInfo *)selectedEffect{
//    _selectedEffect = selectedEffect;
//    if(selectedEffect){
//        //获得index
//        self.selectIndex = 3;
//    }
//}

- (void)updateSelectedFilter:(AliyunEffectInfo *)filter{
    for (int i = 0; i < _dataArray.count; i++) {
        AliyunEffectInfo *tmpFilter = _dataArray[i];
        if ([filter.name isEqualToString:tmpFilter.name]) {
            self.selectIndex  = i;
            break;
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectIndex inSection:0];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}
@end
