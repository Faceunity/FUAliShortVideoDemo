//
//  AlivcGroupSelector.m
//  AFNetworking
//
//  Created by lileilei on 2020/1/3.
//

#import "AlivcGroupSelector.h"
#import "AlivcMacro.h"
#import "AlivcImage.h"
#import "AlivcGroupSelectorCell.h"
#import "AliyunEffectInfo.h"

//分组选择的 cell
static NSString *IdentifierGroupSelectorShowCell = @"IdentifierGroupSelectorShowCell";
//分组选择为button的cell
static NSString *IdentifierGroupSelectorButtonCell = @"IdentifierGroupSelectorButtonCell";

@interface AlivcGroupSelector ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView *tabbarCollectionView;

@end

@implementation AlivcGroupSelector

-(instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _selectIndex = -1;
        [self setupSubViews];
    }
    return self;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self setupSubViews];
    }
    return self;
}

-(void)setupSubViews{
    self.backgroundColor = AlivcOxRGBA(0xffffff, 0.1);
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(60, 44);
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    followLayout.minimumLineSpacing = 0;
    followLayout.minimumInteritemSpacing = 0;
    
    self.tabbarCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 44) collectionViewLayout:followLayout];
    self.tabbarCollectionView.backgroundColor =[UIColor clearColor];
    self.tabbarCollectionView.showsHorizontalScrollIndicator = NO;
    self.tabbarCollectionView.delegate = (id)self;
    self.tabbarCollectionView.dataSource = (id)self;
    
//    self.tabbarCollectionView.pagingEnabled = YES;
    [self addSubview: self.tabbarCollectionView];
    
    [self.tabbarCollectionView registerClass:[AlivcGroupSelectorCell class] forCellWithReuseIdentifier:IdentifierGroupSelectorShowCell];
    [self.tabbarCollectionView registerClass:[AlivcGroupSelectorCell class] forCellWithReuseIdentifier:IdentifierGroupSelectorButtonCell];
}

#pragma --mark collectionView代理方法
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.groupData.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.groupData.count - 1) {
        //最后一个是addButton
        AlivcGroupSelectorCell *packageCell = [self.tabbarCollectionView dequeueReusableCellWithReuseIdentifier:IdentifierGroupSelectorButtonCell forIndexPath:indexPath];
        packageCell.iconImageView.image = [AlivcImage imageNamed:self.groupData[indexPath.row]];
        return packageCell;
    } else {
        AlivcGroupSelectorCell *packageCell = [self.tabbarCollectionView dequeueReusableCellWithReuseIdentifier:IdentifierGroupSelectorShowCell forIndexPath:indexPath];
        AliyunEffectInfo *group = self.groupData[indexPath.row];
        [packageCell setGroup:group];
        if (self.selectTitle) {
            packageCell.selected =  [group.name isEqualToString:self.selectTitle];
        }else{
            packageCell.selected = indexPath.row == 0;
        }
        
        if (packageCell.selected) {
            self.selectTitle = group.name;
            self.resurcePath = group.resourcePath?:@"";
        }
        
        return packageCell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.groupData.count - 1) {
        // add
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGroupSelectorShowMore)]) {
            [self.delegate didGroupSelectorShowMore];
        }
    } else {
        // reload
        self.selectIndex = indexPath.row;
        AliyunEffectInfo *group = self.groupData[indexPath.row];
        self.selectTitle = group.name;
        self.resurcePath = group.resourcePath?:@"";
        if (self.delegate && [self.delegate respondsToSelector:@selector(didGroupSelectorHitByInfo:)]) {
            [self.delegate didGroupSelectorHitByInfo:group];
        }
    }
    [collectionView reloadData];
  
}

-(void)refreshData{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tabbarCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    });
}

-(BOOL)checkPathisEqualTo:(NSString*)path{
    if ([self.resurcePath isEqualToString:path?:@""]) {
        return YES;
    }
    return NO;
}

#pragma --mark getters
- (NSMutableArray *)groupData {
    if (!_groupData) {
        _groupData = [[NSMutableArray alloc] init];
    }
    return _groupData;
}

@end
