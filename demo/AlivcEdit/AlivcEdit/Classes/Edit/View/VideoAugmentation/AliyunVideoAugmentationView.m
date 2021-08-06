//
//  AliyunVideoAugmentationView.m
//  AlivcCommon
//
//  Created by Bingo on 2021/1/25.
//

#import "AliyunVideoAugmentationView.h"
#import "AliyunVideoAugmentationCell.h"
#import "UIView+AlivcHelper.h"
#import "AlivcEditBottomHeaderView.h"
#import "UIColor+AlivcHelper.h"
#import <AliyunVideoSDKPro/AliyunEffect.h>
#import "_AlivcLiveBeautifySliderView.h"

#define AES_HeaderVew_Height    45  //顶部页眉View高度
#define AES_LineView_Height     1   //分割线高度


@interface AliyunVideoAugmentationView() <_AlivcLiveBeautifySliderViewDelegate>
@property (nonatomic, strong) AlivcEditBottomHeaderView *headerView;    //顶部页眉View
@property (nonatomic, strong) UIView *contentView;                      //中间内容View
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *modelArr;

@property (nonatomic, strong) _AlivcLiveBeautifySliderView *slider;
@property (nonatomic, assign) NSInteger currentType;

@end

@implementation AliyunVideoAugmentationView

-(id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.currentType = -1;
        self.modelArr =[NSMutableArray arrayWithArray:[self configModels]];
        [self setupSubviews];
    }
    return self;
}

-(void)setupSubviews {
    [self addVisualEffect];
    [self addSubview:self.headerView];
    [self addSubview:self.contentView];
    [self addSubview:self.slider];

    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:NO scrollPosition:UICollectionViewScrollPositionNone];
}

-(void)layoutSubviews {
    [super layoutSubviews];
}

- (NSArray *)configModels {
    AliyunVideoAugmentationCellModel *reset = [AliyunVideoAugmentationCellModel new];
    reset.type = -1;
    reset.title =  NSLocalizedString(@"重置", nil);
    reset.iconPath = @"alivc_svEdit_augmentation";
    
    AliyunVideoAugmentationCellModel *brightness = [AliyunVideoAugmentationCellModel new];
    brightness.type = AliyunVideoAugmentationTypeBrightness;
    brightness.title =  NSLocalizedString(@"亮度", nil);
    brightness.iconPath = @"alivc_augmentation_brightness";
    
    AliyunVideoAugmentationCellModel *contrast = [AliyunVideoAugmentationCellModel new];
    contrast.type = AliyunVideoAugmentationTypeContrast;
    contrast.title =  NSLocalizedString(@"对比度", nil);
    contrast.iconPath = @"alivc_augmentation_contrast";
    
    AliyunVideoAugmentationCellModel *saturation = [AliyunVideoAugmentationCellModel new];
    saturation.type = AliyunVideoAugmentationTypeSaturation;
    saturation.title =  NSLocalizedString(@"饱和度", nil);
    saturation.iconPath = @"alivc_augmentation_saturation";
    
    AliyunVideoAugmentationCellModel *sharpness = [AliyunVideoAugmentationCellModel new];
    sharpness.type = AliyunVideoAugmentationTypeSharpness;
    sharpness.title =  NSLocalizedString(@"锐度", nil);
    sharpness.iconPath = @"alivc_augmentation_sharpness";
    
    AliyunVideoAugmentationCellModel *vignette = [AliyunVideoAugmentationCellModel new];
    vignette.type = AliyunVideoAugmentationTypeVignette;
    vignette.title =  NSLocalizedString(@"暗角", nil);
    vignette.iconPath = @"alivc_augmentation_vignette";
    
    NSArray *modelArr = @[reset, brightness, contrast, saturation, sharpness, vignette];
    
    return modelArr;
}

#pragma mark - GET
-(AlivcEditBottomHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[AlivcEditBottomHeaderView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), AES_HeaderVew_Height)];
        _headerView.backgroundColor = [UIColor clearColor];
        [_headerView hiddenButton];
        [_headerView setTitle:NSLocalizedString(@"增强", nil) icon:[AlivcImage imageNamed:@"alivc_svEdit_audio"]];
    }
    return _headerView;
}

-(UIView *)contentView {
    if (!_contentView) {
        _contentView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - CGRectGetMaxY(self.headerView.frame))];
        [_contentView addSubview:self.collectionView];
    }
    return _contentView;
}

- (_AlivcLiveBeautifySliderView *)slider {
    if (!_slider)
    {
        CGRect rect = self.headerView.frame;
        rect.origin.y -= 15;
        rect.size.height += 15;
        _slider = [[_AlivcLiveBeautifySliderView alloc] initWithFrame:rect];
        [_slider setClipsToBounds:NO];
        [_slider setBackgroundColor:[UIColor clearColor]];
        [_slider setHidden:YES];
        [_slider setMaximumValue:1.0];
        [_slider setMinimumValue:0.0];
        _slider.delegate = self;
        
        [self.contentView addSubview:_slider];
    }
    return _slider;
}

-(UICollectionView *)collectionView {
    if (!_collectionView) {
        
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        layout.itemSize = CGSizeMake(50, 70);
        layout.sectionInset = UIEdgeInsetsMake(15, 22, 20, 22);
        layout.minimumInteritemSpacing = 20;
        layout.minimumLineSpacing = 20;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:self.contentView.bounds collectionViewLayout:layout];
        _collectionView.backgroundColor =[UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.delegate = (id)self;
        _collectionView.dataSource = (id)self;
        [_collectionView registerClass:[AliyunVideoAugmentationCell class] forCellWithReuseIdentifier:@"AliyunVideoAugmentationCell"];
    }
    return _collectionView;
}

- (void)showSlider:(NSInteger)type {
    if (type == -1) {
        self.headerView.hidden = NO;
        self.slider.hidden = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoAugmentationDidSelectType:value:)]) {
            [self.delegate videoAugmentationDidSelectType:type value:0.0];
        }
    }
    else {
        self.headerView.hidden = YES;
        self.slider.hidden = NO;

        float value = 0.0;
        if (self.delegate && [self.delegate respondsToSelector:@selector(videoAugmentationGetCurrentValue:)]) {
            value = [self.delegate videoAugmentationGetCurrentValue:type];
        }
        [_slider setOriginalValue:value];
        [_slider setValue:value];
        [_slider setShowFloat:YES];
    }
}

#pragma mark - UICollectionViewDelegate -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    AliyunVideoAugmentationCell *effectCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunVideoAugmentationCell" forIndexPath:indexPath];
    [effectCell cellModel:self.modelArr[indexPath.row]];
 
    return effectCell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.modelArr.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunVideoAugmentationCellModel *model = self.modelArr[indexPath.row];
    
    self.currentType = model.type;
    [self showSlider:self.currentType];
}

#pragma mark - _AlivcLiveBeautifySliderViewDelegate

- (void)sliderView:(_AlivcLiveBeautifySliderView *)sliderView valueDidChange:(float)value {
    if (self.delegate && [self.delegate respondsToSelector:@selector(videoAugmentationDidSelectType:value:)]) {
        [self.delegate videoAugmentationDidSelectType:self.currentType value:value];
    }
}

- (void)sliderViewTouchDidCancel:(_AlivcLiveBeautifySliderView *)sliderView {
    
}

@end
