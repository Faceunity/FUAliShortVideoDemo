//
//  AlivcTabbarView.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2018/10/10.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AlivcTabbarView.h"
#import "AliyunTabBarCell.h"

@interface AlivcTabbarView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong)UICollectionView *tabbar;
@property (nonatomic, strong)AliyunTabBarCell *lastAliyunTabBarCell;//上次选中的cell
@property (nonatomic, strong)NSArray *itmeInfo;//数据源
@end

@implementation AlivcTabbarView
-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        [self setSubviews];
    }
    return self;
}
-(void)setSubviews{
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(80, 30);
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    followLayout.minimumLineSpacing = 0;
    followLayout.minimumInteritemSpacing = 0;
    _tabbar = [[UICollectionView alloc] initWithFrame:self.bounds collectionViewLayout:followLayout];
    _tabbar.delegate = self;
    _tabbar.dataSource = self;
    _tabbar.backgroundColor =[UIColor clearColor];
    _tabbar.showsHorizontalScrollIndicator = NO;
    [_tabbar registerClass:[AliyunTabBarCell class] forCellWithReuseIdentifier:@"AliyunTabBarCell"];
    [self addSubview:_tabbar];
    dispatch_async(dispatch_get_main_queue(), ^{
        [_tabbar selectItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    });
    
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return  self.itmeInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunTabBarCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunTabBarCell" forIndexPath:indexPath];
    NSDictionary *itemDic = self.itmeInfo[indexPath.row];
    [cell setTitle:itemDic[@"title"] icon:[AlivcImage imageNamed:itemDic[@"iconName"]]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    TabBarItemType type = (TabBarItemType)indexPath.row;
    AliyunTabBarCell *cell = (AliyunTabBarCell *)[collectionView cellForItemAtIndexPath:indexPath];
    if (cell == _lastAliyunTabBarCell) {
        return;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(alivcTabbarViewDidSelectedType:)]) {
        [self.delegate alivcTabbarViewDidSelectedType:type];
    }
}
#pragma mark -Setter
-(void)setTabItems:(NSArray *)tabItems{
    _tabItems = tabItems;
    [self.tabbar reloadData];
}

#pragma mark - Getter -

-(NSArray *)itmeInfo{
    NSMutableArray *mutArr = [[NSMutableArray alloc]initWithCapacity:9];
    if (!_tabItems) {
        _tabItems = @[@(TabBarItemTypeFont),
                      @(TabBarItemTypeColor),
                      @(TabBarItemTypeKeboard),
                      @(TabBarItemTypeAnimation)];
    }else{
        for(NSNumber *typeNum in _tabItems) {
            switch ([typeNum integerValue]) {
                case TabBarItemTypeKeboard:
                {
                    [mutArr addObject:@{@"title":@"键盘",@"iconName":@"shortVideo_tab_caption_keybord"}];
                }
                    break;
                case TabBarItemTypeColor:
                {
                    [mutArr addObject:@{@"title":@"颜色",@"iconName":@"shortVideo_tab_caption_color"}];
                }
                    break;
                case TabBarItemTypeFont:
                {
                    [mutArr addObject:@{@"title":@"字体",@"iconName":@"shortVideo_tab_caption_font"}];
                }
                    break;
                case TabBarItemTypeAnimation:
                {
                    [mutArr addObject:@{@"title":@"特效",@"iconName":@"shortVideo_tab_caption_animation"}];
                }
                    break;
                    
                default:
                    break;
            }
        }
    }
    return [NSArray arrayWithArray:mutArr];
}

@end
