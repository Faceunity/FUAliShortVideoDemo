//
//  AliyunCaptionTextAlignmentView.m
//  AlivcEdit
//
//  Created by aliyun on 2021/6/26.
//

#import "AliyunCaptionTextAlignmentView.h"

static NSString *kAliyunCaptionTextAlignmentCell = @"AliyunCaptionTextAlignmentCell";


@interface AliyunCaptionTextAlignmentCell : UICollectionViewCell

@property (nonatomic ,strong) UIButton *titleBtn;

@end


@implementation AliyunCaptionTextAlignmentCell

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
    [self.contentView addSubview:self.titleBtn];
}

- (UIButton *)titleBtn
{
    if (!_titleBtn) {
        _titleBtn = [[UIButton alloc]initWithFrame:self.contentView.bounds];
        _titleBtn.enabled = NO;
        
    }
    
    return _titleBtn;;
}

@end


@interface AliyunCaptionTextAlignmentView()<UICollectionViewDataSource,UICollectionViewDelegate>
@property (nonatomic, strong) NSArray<NSString *> *dataArr;
@property (nonatomic, strong) UICollectionView *collectionView;

@end

@implementation AliyunCaptionTextAlignmentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.contentView addSubview:self.collectionView];
    }
    return self;
}

- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.itemSize = CGSizeMake((CGRectGetWidth(self.contentView.frame)-30)/3, 80);
        layout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
        layout.minimumLineSpacing = 10;
        layout.minimumInteritemSpacing = 10;
        
        
        _collectionView = [[UICollectionView alloc]initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        
        [_collectionView registerClass:[AliyunCaptionTextAlignmentCell class] forCellWithReuseIdentifier:kAliyunCaptionTextAlignmentCell];
    }
    
    return _collectionView;
}

#pragma mark - CollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    return self.dataArr.count;
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    AliyunCaptionTextAlignmentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kAliyunCaptionTextAlignmentCell forIndexPath:indexPath];
    NSString *title = self.dataArr[indexPath.row];
    
    [cell.titleBtn setTitle:title forState:UIControlStateNormal];

    return cell;
    
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(captionTextAlignmentSelected:)]) {
        [self.delegate captionTextAlignmentSelected:indexPath.row];
    }
}


#pragma mark - Set

- (NSArray *)dataArr {
    if (!_dataArr) {
        _dataArr = @[@"左对齐",@"居中对齐",@"右对齐"];
    }
    return _dataArr;
}


@end
