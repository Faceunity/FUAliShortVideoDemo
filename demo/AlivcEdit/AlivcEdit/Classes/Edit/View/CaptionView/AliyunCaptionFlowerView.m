//
//  AliyunCaptionFlowerView.m
//  AlivcEdit
//
//  Created by mengyehao on 2021/5/26.
//

#import "AliyunCaptionFlowerView.h"

//字幕气泡展示的cell
static NSString *kAliyunCaptionFlowerViewCell = @"AliyunCaptionFlowerViewCell";

static NSString *const kFont_effectRelativePath = @"Resource/font_effect";


@interface AliyunCaptionFlowerViewCell : UICollectionViewCell

@property (nonatomic ,strong) UIImageView *iconView;

@end


@implementation AliyunCaptionFlowerViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    [self.contentView addSubview:self.iconView];
}

- (UIImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[UIImageView alloc]initWithFrame:self.contentView.bounds];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
    }
    
    return _iconView;;
}

@end


@interface AliyunCaptionFlowerView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray<NSString *> *pasterData;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AliyunCaptionFlowerView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.collectionView];
        [self fetchData];
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
        
        [_collectionView registerClass:[AliyunCaptionFlowerViewCell class] forCellWithReuseIdentifier:kAliyunCaptionFlowerViewCell];
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
    AliyunCaptionFlowerViewCell
     *pasterCell = [collectionView dequeueReusableCellWithReuseIdentifier:kAliyunCaptionFlowerViewCell forIndexPath:indexPath];
    NSString *path = self.pasterData[indexPath.row];
    
    if (path.length == 0) {
        pasterCell.iconView.image = [UIImage imageNamed:@"icon_clear"];
    } else {
        NSString *iconPath = [[path stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
        pasterCell.iconView.image = [UIImage imageWithContentsOfFile:iconPath];
    }

    return pasterCell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *path = self.pasterData[indexPath.row];
    
    if ([self.delegate respondsToSelector:@selector(captionFlowerViewDidSeletedFlowerPath:)]) {
        [self.delegate captionFlowerViewDidSeletedFlowerPath:path];
    }
}


#pragma mark - Set

- (NSMutableArray *)pasterData {
    if (!_pasterData) {
        _pasterData = [[NSMutableArray alloc] init];
    }
    return _pasterData;
}

- (void)fetchData
{
    
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"FlowerFont.bundle" ofType:nil];
    
    path = [path stringByAppendingPathComponent:@"font_effect"];
//    BOOL isExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
//    
//     [[NSFileManager defaultManager] subpathsAtPath:path];
    
    for (int i = 1; i< 8; i++) {
        NSString *suf = [NSString stringWithFormat:@"effect%d",i];
        NSString *subpath = [path stringByAppendingPathComponent:suf];
        [self.pasterData addObject:subpath];
    }
    
    if (self.pasterData.count > 0) {
        [self.pasterData insertObject:[self emptyPath] atIndex:0];
    }
    
    [self.collectionView reloadData];
}


- (NSString *)emptyPath
{
    return @"";
}



@end
