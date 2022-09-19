//
//  AliyunLutFilterView.m
//  AlivcEdit
//
//  Created by mengyehao on 2021/11/18.
//

#import "AliyunLutFilterView.h"
#import "AlivcEditBottomHeaderView.h"
#import "AliyunEffectFilterCell.h"


@implementation AliyunLutFilterModel
@end



@interface AliyunLutFilterView()
@property (nonatomic, strong) UICollectionView *collectionView;

/**
 数据模型数组
 */
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, assign) NSInteger selectIndex;


@property (nonatomic, strong) AlivcEditBottomHeaderView *headerView;

@property (nonatomic, strong) UISlider *slider;



@end

@implementation AliyunLutFilterView


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColor = [UIColor clearColor];
       
        _dataArray = [[NSMutableArray alloc] init];
        _selectIndex = -1;
        [self addSubViews];
        
        [self fetchData];
    }
    return self;
}


/**
 添加子控件
 */
- (void)addSubViews {

    _headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), 45)];
    [_headerView setTitle:NSLocalizedString(@"lut滤镜", nil) icon:[AlivcImage imageNamed:@"shortVideo_fliter"]];
    [_headerView hiddenButton];
    [self addSubview:_headerView];
    
    [self addSubview:self.slider];
    
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(50, 70);
    layout.sectionInset = UIEdgeInsetsMake(5, 20, 20, 22);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    
    NSString *path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"AlivcEdit.bundle"];
    NSBundle *bundle = [NSBundle bundleWithPath:path];
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.slider.frame), ScreenWidth, 102) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:bundle] forCellWithReuseIdentifier:@"AliyunEffectFilterCell"];
    [_collectionView registerNib:[UINib nibWithNibName:@"AliyunEffectFilterCell" bundle:bundle] forCellWithReuseIdentifier:@"AliyunEffectFilterFuncCell"];
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self addSubview:_collectionView];
    
}


- (UISlider *)slider
{
    if (!_slider) {
        _slider = [[UISlider alloc] initWithFrame:CGRectMake(20, CGRectGetHeight(self.headerView.frame), ScreenWidth - 40, 40)];
        _slider.minimumValue = 0;
        _slider.maximumValue = 1.0;
        _slider.value = 1.0;
        [_slider addTarget:self action:@selector(onSliderChanged:) forControlEvents:UIControlEventValueChanged];
    }
    return _slider;
    
}


- (void)onSliderChanged:(UISlider *)sender
{
    if (self.dataArray.count <= self.selectIndex) {
        return;
    }
    
    if (self.selectIndex == 0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(lutFilterViewDelegateDidUpdateIndensity:)]) {
        [self.delegate lutFilterViewDelegateDidUpdateIndensity:sender.value];
    }
}



- (void)fetchData
{
    NSString *path =  [[NSBundle mainBundle] pathForResource:@"LutFilter.bundle" ofType:nil];

    path = [path stringByAppendingPathComponent:@"0-默认"];
    
    
    [self.dataArray addObject:[AliyunLutFilterModel new]];
    
    
    NSArray<NSString *> *subs = [[NSFileManager defaultManager] subpathsAtPath:path];
    
    for (NSString *name in subs) {
        
        if (![name hasSuffix:@".png"]) {
            AliyunLutFilterModel *model = [[AliyunLutFilterModel alloc] init];
            model.name = [name componentsSeparatedByString:@"-"].lastObject;
            NSString *tempPath = [path stringByAppendingPathComponent:name];
            model.iconPath = [tempPath stringByAppendingPathComponent:@"icon.png"];
            model.lookupPath = [tempPath stringByAppendingPathComponent:@"lookup.png"];
            [self.dataArray addObject:model];
        }
    }
    
    _selectIndex = 0;
    
    [self reloadData];
}

- (void) reloadData {
    [_collectionView reloadData];
    if (_selectIndex >= 0 && _selectIndex < _dataArray.count) {
        NSIndexPath *idx = [NSIndexPath indexPathForRow:_selectIndex inSection:0];
        [_collectionView selectItemAtIndexPath:idx animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
    }
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
    
    
    if (indexPath.row == 0) {
        cell.imageView.contentMode = UIViewContentModeCenter;
        cell.imageView.backgroundColor = rgba(255, 255, 255, 0.2);
        cell.imageView.image = [AlivcImage imageNamed:@"shortVideo_clear"];
        cell.nameLabel.text = NSLocalizedString(@"无效果", nil);
    } else {
        cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
        cell.imageView.backgroundColor = [UIColor clearColor];
        
        AliyunLutFilterModel *model = self.dataArray[indexPath.row];
        NSString *imagepath = model.iconPath;

        
        UIImage *image = [UIImage imageWithContentsOfFile:imagepath];;
        cell.imageView.image = image;
        cell.nameLabel.text = model.name;

    }
    
    [cell setExclusiveTouch:YES];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
   
    if (indexPath.row >= self.dataArray.count) {
        return;
    }
    
    
    _selectIndex = indexPath.row;
    
    NSString *path = [_dataArray[indexPath.row] lookupPath];
    if ([self.delegate respondsToSelector:@selector(lutFilterViewDelegateDidSelectLutFilter: indensity:)]) {
        [self.delegate lutFilterViewDelegateDidSelectLutFilter:path indensity:self.slider.value];
    }

}

- (void)updateSelected
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:_selectIndex inSection:0];
    [self collectionView:self.collectionView didSelectItemAtIndexPath:indexPath];
    [self.collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionCenteredHorizontally];
}


- (void)updateSelectedFilterWithResource:(NSString *)resourcePath insensity:(float)insensity
{
    for (int i = 0; i < _dataArray.count; ++i) {
        NSString *tmpFilterStr = [_dataArray[i] lookupPath];
        if ([resourcePath isEqualToString:tmpFilterStr]) {
            self.selectIndex =i;
            self.slider.value = insensity;
            break;
        }
    }
    [self updateSelected];
}

@end
