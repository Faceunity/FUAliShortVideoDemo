//
//  AliyunFontEffectView.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunFontEffectView.h"
#import "AliyunFontEffectViewCell.h"
#import "NSString+AlivcHelper.h"

@interface AliyunFontEffectView()

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray *actions;//字体特效数据源
@property (nonatomic, assign) NSInteger selectIndex;//当前选中索引

@end

@implementation AliyunFontEffectView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubviews];
        [self setupData];
    }
    return self;
}

- (void)addSubviews {
    self.selectIndex =0;
    self.backgroundColor = [UIColor clearColor];
    self.bootomLine.hidden = YES;//隐藏下方分割线
    [self.contentView addSubview:self.collectionView];
}

- (void)setupData
{
    [self.actions removeAllObjects];
    
    NSArray *icons = @[@"transition_null_Nor",
                       @"transition_up_Nor",
                       @"transition_down_Nor",
                       @"transition_left_Nor",
                       @"transition_right_Nor",
                       @"transition_lineswipe_Nor",
                       @"transition_fade_Nor",
                       @"transition_scale_Nor"];
    NSArray *titles = @[[@"无" localString], [@"向上移动" localString],[@"向下移动" localString], [@"向左移动" localString], [@"向右移动" localString],[@"线性擦除" localString], [@"淡入淡出" localString],[@"缩放" localString] ];
    NSArray *types = @[@(TextActionTypeClear),@(TextActionTypeMoveTop),
                       @(TextActionTypeMoveDown),@(TextActionTypeMoveLeft) ,
                       @(TextActionTypeMoveRight),@(TextActionTypeLinerWipe),
                       @(TextActionTypeFade), @(TextActionTypeScale)];
    
    for (int idx = 0; idx < [icons count]; idx++) {
        AliyunSubtitleActionItem *actionItem = [[AliyunSubtitleActionItem alloc] init];
        TextActionType type = (TextActionType) [[types objectAtIndex:idx] intValue];
        actionItem.type = type;
        NSString *icon = [icons objectAtIndex:idx];
        actionItem.iconImage = [AlivcImage imageNamed:icon];
        actionItem.iconSelected =[AlivcImage imageNamed:@"shortVideo_Item_selected"];
        NSString *text = [titles objectAtIndex:idx];
        actionItem.iconText = text;
        [self.actions addObject:actionItem];
    }
    [self.collectionView reloadData];
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
}

#pragma mark - Get
- (NSMutableArray *)actions
{
    if (!_actions) {
        _actions = [[NSMutableArray alloc] init];
    }
    return _actions;
}

-(UICollectionView *)collectionView{
    if (!_collectionView) {
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        CGFloat w = (ScreenWidth - 15 * 3) / 4.5;
        CGFloat h = 90;
        layout.itemSize = CGSizeMake(w, h);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 20;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMidY(self.bounds)-h/2, CGRectGetWidth(self.frame), h) collectionViewLayout:layout];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.showsVerticalScrollIndicator = NO;
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = (id)self;
        _collectionView.dataSource = (id)self;
        [_collectionView registerClass:[AliyunFontEffectViewCell class] forCellWithReuseIdentifier:@"AliyunFontEffectViewCell"];
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDataSource UICollectionViewDelegate -

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.actions.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunFontEffectViewCell *actionItemCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunFontEffectViewCell" forIndexPath:indexPath];
    AliyunSubtitleActionItem *actionItem = [self.actions objectAtIndex:indexPath.row];
    [actionItemCell setSubtitleActionItem:actionItem];
    return actionItemCell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunSubtitleActionItem *actionItem = [self.actions objectAtIndex:indexPath.row];
    self.selectIndex = indexPath.row;
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectActionType:)]) {
        [self.delegate onSelectActionType:actionItem.type];
    }
}


-(void)setDefaultSelectItem:(TextActionType)actionType{
    self.selectIndex = actionType -1;
    if (self.selectIndex>0) {
        [self.collectionView reloadData];
        [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForRow:self.selectIndex inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    }
}

@end
