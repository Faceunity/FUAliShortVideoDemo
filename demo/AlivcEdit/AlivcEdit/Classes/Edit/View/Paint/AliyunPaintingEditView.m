//
//  AliyunPaintingEditView.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/3.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunPaintingEditView.h"
#import "UIView+AlivcHelper.h"
#import "UIColor+AlivcHelper.h"
#import "AliyunPaintingWidthView.h"
#import "AliyunPaintColorItemCell.h"
#import "AlivcEditBottomHeaderView.h"

@interface AliyunPaintingEditView()

#define CPV_HeaderVew_Height    45  //顶部页眉View高度
#define CPV_LineView_Height     1   //分割线高度

@property(nonatomic, strong)AlivcEditBottomHeaderView *headerView;    //顶部页眉View
@property(nonatomic, strong)UIView *contentView;   //中间内容View
@property(nonatomic, strong)AliyunPaintingWidthView *widthSelectView;//画笔宽度选择View
@property(nonatomic, strong)UICollectionView *colorsCollectionView;

@property (nonatomic, strong) NSMutableArray *colors;
@end
@implementation AliyunPaintingEditView
{
    UIButton *_iconBtn;//页眉IconButton
}

-(id)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        self.colors =[NSMutableArray arrayWithArray:[self configColors]];
        [self setupSubviews];
//        [self.colorsCollectionView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    }
    return self;
}

- (NSArray *)configColors
{
    NSArray *colors = @[@"shortVideo_edit_undo",@"#F9FAFB",@"#F4775C",
                        @"#FFA133",@"#EDC200",@"#50B83C",@"#47C1BF",
                        @"#007ACE",@"#5C6AC4",@"#9C6ADE"];
    
    return colors;
}

-(void)setupSubviews{
    [self addVisualEffect];
    [self addSubview:self.headerView];
    [self addSubview:self.contentView];
}

#pragma mark - Functions

-(void)showInView:(UIView *)superView animation:(BOOL)animation{
    [self removeFromSuperview];
    [superView addSubview:self];
    CGRect frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    self.frame = CGRectMake(self.frame.origin.x, ScreenHeight, self.frame.size.width, self.frame.size.height);
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = frame;
        } completion:^(BOOL finished) {
            
        }];
    }else{
        self.frame = frame;
    }
}

-(void)hiddenAnimation:(BOOL)animation{
    if (animation) {
        [UIView animateWithDuration:0.3 animations:^{
            self.frame = CGRectMake(self.frame.origin.x, ScreenHeight, self.frame.size.width, self.frame.size.height);
        } completion:^(BOOL finished) {
            [self removeFromSuperview];
        }];
    }else{
        [self removeFromSuperview];
    }
}

#pragma mark - Actions
- (void)redoButtonAction:(UIButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(onClickPaintRedoPaintButton)]) {
        [self.delegate onClickPaintRedoPaintButton];
    }
}

#pragma mark - UICollectionViewDelegate -

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {//撤销按钮
        AliyunPaintColorItemCell *effectCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPaintColorItemCell_Function" forIndexPath:indexPath];
        UIImageView *imgView = [[UIImageView alloc]initWithFrame:effectCell.colorView.bounds];
        imgView.image = [AlivcImage imageNamed:@"shortVideo_edit_undo"];
//        effectCell.colorView.layer.borderColor = [UIColor colorWithWhite:1 alpha:0.8].CGColor;
//        effectCell.colorView.layer.borderWidth = 1;
        [effectCell.colorView addSubview:imgView];
        return effectCell;
    }else{
        AliyunPaintColorItemCell *effectCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPaintColorItemCell" forIndexPath:indexPath];
        UIColor *color = [UIColor colorWithHexString:[self.colors objectAtIndex:indexPath.row]];
        effectCell.colorView.backgroundColor = color;
        return effectCell;
    }
    
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.colors.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) {//撤销
        if (_delegate && [_delegate respondsToSelector:@selector(onClickPaintUndoPaintButton)]) {
            [self.delegate onClickPaintUndoPaintButton];
        }
    }else{
        UIColor *color = [UIColor colorWithHexString:[NSString stringWithFormat:@"%@",_colors[indexPath.row]]];
        self.widthSelectView.widthtTagColor = color;
        if (_delegate && [_delegate respondsToSelector:@selector(onClickChangePaintColor:)]) {
            [self.delegate onClickChangePaintColor:color];
        }
    }
    
}



#pragma mark - GET

-(AlivcEditBottomHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CPV_HeaderVew_Height)];
        _headerView.backgroundColor = [UIColor clearColor];
        [_headerView setTitle:NSLocalizedString(@"涂鸦", comment) icon:[AlivcImage imageNamed:@"shortVideo_paint_icon"]];
        __weak typeof(self)weakSelf = self;
        [_headerView bindingApplyOnClick:^{//完成
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onClickPaintFinishButton)]) {
                [weakSelf.delegate onClickPaintFinishButton];
            }
        } cancelOnClick:^{//取消
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onClickPaintCancelButton)]) {
                [weakSelf.delegate onClickPaintCancelButton];
            }
        }];
    }
    return _headerView;
}
-(UIView *)contentView{
    if (!_contentView) {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame)- CGRectGetMaxY(self.headerView.frame))];
        [_contentView addSubview:self.widthSelectView];
        __weak typeof(self)weakSelf = self;
        [self.widthSelectView setChangeWidthHandle:^(NSInteger width) {
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(onClickChangePaintWidth:)]) {
                [weakSelf.delegate onClickChangePaintWidth:width];
            }
        }];
        [_contentView addSubview:self.colorsCollectionView];
        
        CGFloat pointY = CGRectGetHeight(self.contentView.frame)-CGRectGetMaxY(self.widthSelectView.frame);
        _colorsCollectionView.center = CGPointMake(_contentView.center.x, pointY);
        
        
    }
    return _contentView;
}

-(AliyunPaintingWidthView *)widthSelectView{
    if (!_widthSelectView) {
        _widthSelectView = [[AliyunPaintingWidthView alloc]initWithFrame: CGRectMake(15, 15, CGRectGetWidth(self.frame)-30, 40)];
    }
    return _widthSelectView;
}

-(UICollectionView *)colorsCollectionView{
    if (!_colorsCollectionView) {
        UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
        followLayout.itemSize = CGSizeMake(30, 30);
        followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        followLayout.minimumInteritemSpacing = 10;
        
        _colorsCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.frame)-20, 40) collectionViewLayout:followLayout];
        _colorsCollectionView.backgroundColor =[UIColor clearColor];
        _colorsCollectionView.showsHorizontalScrollIndicator = NO;
        _colorsCollectionView.showsVerticalScrollIndicator = NO;
        _colorsCollectionView.delegate = (id)self;
        _colorsCollectionView.dataSource = (id)self;
//        _colorsCollectionView.pagingEnabled = YES;
        [_colorsCollectionView registerClass:[AliyunPaintColorItemCell class] forCellWithReuseIdentifier:@"AliyunPaintColorItemCell"];
        [_colorsCollectionView registerClass:[AliyunPaintColorItemCell class] forCellWithReuseIdentifier:@"AliyunPaintColorItemCell_Function"];
    }
    return _colorsCollectionView;
}

@end
