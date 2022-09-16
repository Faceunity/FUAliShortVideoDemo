//
//  AliyunCaptionShadowView.m
//  AlivcEdit
//
//  Created by mengyehao on 2021/5/26.
//

#import "AliyunCaptionShadowView.h"
#import "AliyunColorPaletteItemCell.h"
#import "UIView+OPLayout.h"


@interface AliyunCaptionShadowView()
@property (nonatomic, strong)UICollectionView *contentCollectView;
@property (nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, strong)UIButton *selectBtn;
@property (nonatomic, strong)NSIndexPath *seletedIndex;


@end

@implementation AliyunCaptionShadowView


-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.offset = UIOffsetZero;
        [self steupSubview_s];
        [self setupDataIsBorder:NO];
    }
    return self;
}

#pragma mark - Subviews
-(void)steupSubview_s{
    
    CGFloat adjustHeight = 56.f;
    
    self.bootomLine.hidden = YES;
    self.contentView.op_height -= adjustHeight;
    self.bootomView.op_top =  self.contentView.op_bottom;
    self.bootomView.op_height += adjustHeight;
    
    [self.contentView addSubview:self.contentCollectView];
    self.contentCollectView.center = self.contentView.center;
    NSArray *arr = @[@"X：",@"Y："];
    CGFloat left = 20;
    CGFloat tagLableWidth = 40;
    CGFloat height = 20;

    
    for (int i =0; i<arr.count; i++) {
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(left, i * 40, tagLableWidth, height)];
        label.text = [arr objectAtIndex:i];
        [label setTextColor:[UIColor whiteColor]];
        [self.bootomView addSubview:label];
        
        UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(label.op_right, label.op_top, self.bootomView.op_width - left - label.op_right, height)];
        [self.bootomView addSubview:slider];
        slider.minimumValue = -10;
        slider.maximumValue = 10;
        slider.value = 5;
        [slider addTarget:self action:@selector(onSliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        slider.tag = i;
        
      
    }
    self.offset = UIOffsetMake(5, 5);
    
}

- (UIColor *)color
{
    if (self.seletedIndex) {
        NSArray *colors = [self.dataSource objectAtIndex:self.seletedIndex.section];
        AliyunColor *color = [colors objectAtIndex:self.seletedIndex.row];
        
        CGFloat alpha = 1;
        if (self.seletedIndex.row == 0) {
            alpha = 0;
        }
        
        return     [UIColor colorWithRed:color.tR/255.0 green:color.tG/255.0 blue:color.tB/255.0 alpha:alpha];
    }
    
    return nil;
}

#pragma mark - Functions
- (void)onSliderValueChanged:(UISlider *)slider
{
    if (slider.tag == 0) {
        
        self.offset = UIOffsetMake(slider.value, self.offset.vertical);
    } else {
        self.offset = UIOffsetMake(self.offset.horizontal, slider.value);
    }
    
   
    
    
    if ([self.delegate respondsToSelector:@selector(captionShadowDidChangedShadowView:)]) {
        [self.delegate captionShadowDidChangedShadowView:self];
    }
}

#pragma mark - Actions

-(void)btnAction:(UIButton *)btn{
    if (self.selectBtn == btn) {
        return;
    }else{
        self.selectBtn.backgroundColor = [UIColor clearColor];
        btn.backgroundColor = [UIColor blackColor];
    }
    if ([btn.currentTitle isEqualToString:NSLocalizedString(@"填充",nil)]) {
        [self setupDataIsBorder:NO];
    }else if ([btn.currentTitle isEqualToString:NSLocalizedString(@"描边",nil)]){
        [self setupDataIsBorder:YES];
    }
    self.selectBtn = btn;
}

#pragma mark - Get
-(UICollectionView *)contentCollectView{
    if (!_contentCollectView) {
        CGFloat inset = 8;
        float itemSize =(CGRectGetWidth(self.contentView.bounds)-8*9-inset*2-40)/9;
        UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
        followLayout.itemSize = CGSizeMake(itemSize, itemSize);
        followLayout.minimumLineSpacing = 8;
        followLayout.sectionInset = UIEdgeInsetsMake(inset, 0, inset, 0);
        followLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
        
        _contentCollectView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds)-40, CGRectGetHeight(self.contentView.bounds)-40) collectionViewLayout:followLayout];
        _contentCollectView.backgroundColor = [UIColor clearColor];
        _contentCollectView.delegate = (id)self;
        _contentCollectView.dataSource = (id)self;
        _contentCollectView.showsHorizontalScrollIndicator = NO;
        _contentCollectView.showsVerticalScrollIndicator = NO;
        [_contentCollectView registerClass:[AliyunColorPaletteItemCell class] forCellWithReuseIdentifier:@"AliyunColorPaletteItemCell"];
        [_contentCollectView registerClass:[AliyunColorPaletteItemCell class] forCellWithReuseIdentifier:@"AliyunColorPaletteItemCell_line"];
        //        _contentCollectView.pagingEnabled = YES;
    }
    return _contentCollectView;
}

#pragma mark - UICollectionViewDataSource UICollectionViewDelegate -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.dataSource.count;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSMutableArray *array = [self.dataSource objectAtIndex:section];
    return array.count;
}


- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section + indexPath.row ==0) {//第一个cell是清除效果
        AliyunColorPaletteItemCell *lineCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunColorPaletteItemCell_line" forIndexPath:indexPath];
        AliyunColor *firstColor = [[AliyunColor alloc]initWithDict:@{@"tR":@0,@"tG":@0,@"tB":@0.0,@"sR":@151,@"sG":@151,@"sB":@151,@"isStroke":@1}];
        lineCell.color = firstColor;
        [lineCell drawLine];
        return lineCell;
    }else{
        AliyunColorPaletteItemCell *effectCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunColorPaletteItemCell" forIndexPath:indexPath];
        NSArray *colors = [self.dataSource objectAtIndex:indexPath.section];
        AliyunColor *color = [colors objectAtIndex:indexPath.row];
        effectCell.color = color;
        return effectCell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.seletedIndex = indexPath;

    if ([self.delegate respondsToSelector:@selector(captionShadowDidChangedShadowView:)]) {
        [self.delegate captionShadowDidChangedShadowView:self];
    }
    
}

- (void)setupDataIsBorder:(BOOL)isBorder
{
    [self.dataSource removeAllObjects];
    NSArray *configColors = [self configColorsIsBorder:isBorder];
    for (NSArray *array in configColors) {
        NSMutableArray *marray = [[NSMutableArray alloc] init];
        for (NSDictionary *dict in array) {
            AliyunColor *color = [[AliyunColor alloc] initWithDict:dict];
            [marray addObject:color];
        }
        [self.dataSource addObject:marray];
    }
    
    [self.contentCollectView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
}

- (NSMutableArray *)dataSource
{
    if (!_dataSource) {
        _dataSource = [[NSMutableArray alloc] init];
    }
    return _dataSource;
}

- (NSArray *)configColorsIsBorder:(BOOL)isBorder
{
    
    NSArray *colors = @[@[@{@"tR":@255,@"tG":@255,@"tB":@255,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@248,@"tG":@170,@"tB":@153,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@255,@"tG":@197,@"tB":@128,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@255,@"tG":@234,@"tB":@138,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@187,@"tG":@229,@"tB":@179,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@182,@"tG":@236,@"tB":@235,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@180,@"tG":@224,@"tB":@250,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@179,@"tG":@188,@"tB":@245,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@227,@"tG":@208,@"tB":@255,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0}],
                        @[
                            @{@"tR":@249,@"tG":@250,@"tB":@251,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@244,@"tG":@119,@"tB":@92,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@255,@"tG":@161,@"tB":@51,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@237,@"tG":@194,@"tB":@0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@80,@"tG":@184,@"tB":@60,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@71,@"tG":@193,@"tB":@191,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@0,@"tG":@122,@"tB":@206,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@92,@"tG":@106,@"tB":@196,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@156,@"tG":@106,@"tB":@222,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0}],
                        @[
                            @{@"tR":@99,@"tG":@115,@"tB":@129,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@241,@"tG":@85,@"tB":@51,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@255,@"tG":@138,@"tB":@0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@156,@"tG":@111,@"tB":@25,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@16,@"tG":@128,@"tB":@67,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@0,@"tG":@132,@"tB":@142,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@8,@"tG":@78,@"tB":@138,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@32,@"tG":@46,@"tB":@120,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                            @{@"tR":@80,@"tG":@36,@"tB":@143,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0}
                        ],
                        @[@{@"tR":@33,@"tG":@43,@"tB":@54,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@229,@"tG":@81,@"tB":@48,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@242,@"tG":@131,@"tB":@0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@87,@"tG":@59,@"tB":@0,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@23,@"tG":@54,@"tB":@48,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@0,@"tG":@49,@"tB":@54,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@0,@"tG":@21,@"tB":@42,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@0,@"tG":@6,@"tB":@57,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0},
                          @{@"tR":@35,@"tG":@0,@"tB":@81,@"sR":@0,@"sG":@0,@"sB":@0,@"isStroke":@0}
                        ],
    ];
    NSArray *borderColors = @[
        @[@{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@255,@"sG":@255,@"sB":@255,@"isStroke":@1},
          @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@248,@"sG":@170,@"sB":@153,@"isStroke":@1},
          @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@255,@"sG":@197,@"sB":@128,@"isStroke":@1},
          @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@255,@"sG":@234,@"sB":@138,@"isStroke":@1},
          @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@187,@"sG":@229,@"sB":@179,@"isStroke":@1},
          @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@182,@"sG":@236,@"sB":@235,@"isStroke":@1},
          @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@180,@"sG":@224,@"sB":@250,@"isStroke":@1},
          @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@179,@"sG":@188,@"sB":@245,@"isStroke":@1},
          @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@227,@"sG":@208,@"sB":@255,@"isStroke":@1}],
        @[
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@249,@"sG":@250,@"sB":@251,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@244,@"sG":@119,@"sB":@92,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@255,@"sG":@161,@"sB":@51,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@237,@"sG":@194,@"sB":@0,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@80,@"sG":@184,@"sB":@60,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@71,@"sG":@193,@"sB":@191,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@0,@"sG":@122,@"sB":@206,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@92,@"sG":@106,@"sB":@196,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@156,@"sG":@106,@"sB":@222,@"isStroke":@1}],
        @[
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@99,@"sG":@115,@"sB":@129,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@241,@"sG":@85,@"sB":@51,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@255,@"sG":@138,@"sB":@0,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@156,@"sG":@111,@"sB":@25,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@16,@"sG":@128,@"sB":@67,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@0,@"sG":@132,@"sB":@142,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@8,@"sG":@78,@"sB":@138,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@32,@"sG":@46,@"sB":@120,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@80,@"sG":@36,@"sB":@143,@"isStroke":@1}],
        @[
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@33,@"sG":@43,@"sB":@54,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@229,@"sG":@81,@"sB":@48,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@242,@"sG":@131,@"sB":@0,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@87,@"sG":@59,@"sB":@0,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@23,@"sG":@54,@"sB":@48,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@0,@"sG":@49,@"sB":@54,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@0,@"sG":@21,@"sB":@42,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@0,@"sG":@6,@"sB":@57,@"isStroke":@1},
            @{@"tR":@0,@"tG":@0,@"tB":@0,@"sR":@35,@"sG":@0,@"sB":@81,@"isStroke":@1}
        ]
    ];
    
    
    return isBorder?borderColors:colors;
}

@end