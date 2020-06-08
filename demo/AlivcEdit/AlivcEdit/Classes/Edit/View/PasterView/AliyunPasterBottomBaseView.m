//
//  AliyunPasterBottomBaseView.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/1.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunPasterBottomBaseView.h"
#import "UIView+AlivcHelper.h"
#import "AliyunPasterCollectionFlowLayout.h"
#import "AliyunPasterGroupCollectionViewCell.h"

@interface AliyunPasterBottomBaseView()
@property (nonatomic, strong) UIView *timeLinePalletView;//timeLine占位View
@property (nonatomic, strong) UIView *bottomBar;//底部操作View

@property (nonatomic, assign) CGFloat headerViewHeight;
@property (nonatomic, assign) CGSize  timeLineSize;
@property (nonatomic, assign) CGFloat bottomBarHeight;


@end

@implementation AliyunPasterBottomBaseView
{
    UIButton *_iconBtn;
}


- (instancetype)init {
    if (self = [super init]) {
        [self setupData];
        
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupData];
    }
    return self;
}
-(void)setupData{
    self.selectIndex = 0;
    self.backgroundColor = [UIColor clearColor];
}


#pragma mark - UI

- (void)setupSubViews {
    //增加毛玻璃效果
    [self addVisualEffect];
    //添加头部View
    [self addSubview:self.headerView];
    //添加缩略图占位View
    [self addSubview:self.timeLinePalletView];
    //添加中间展示动图、字幕、字幕气泡的View
    [self addSubview:self.pasterCollectionView];
    //添加底部footView
    [self addSubview:self.bottomBar];
}

#pragma mark - Get
- (AlivcEditBottomHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), self.headerViewHeight)];
        __weak typeof(self)weakSelf = self;
        [_headerView bindingApplyOnClick:^{//确认
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(pasterBottomViewApply:)]) {
                [weakSelf.delegate pasterBottomViewApply:weakSelf];
            }
        } cancelOnClick:^{//取消
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(pasterBottomViewCancel:)]) {
                [weakSelf.delegate pasterBottomViewCancel:weakSelf];
            }
        }];
    }
    return _headerView;
}
- (UIView *)timeLinePalletView{
    if (!_timeLinePalletView) {
        _timeLinePalletView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame), ScreenWidth, self.timeLineSize.height)];
        _timeLinePalletView.backgroundColor = [UIColor clearColor];
    }
    return _timeLinePalletView;
}

-(UIView *)bottomBar{
    if (!_bottomBar) {
        _bottomBar = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame) - self.bottomBarHeight-SafeBottom, CGRectGetWidth(self.bounds), self.bottomBarHeight)];
        _bottomBar.backgroundColor = AlivcOxRGBA(0xffffff, 0.1);
    }
    
    UICollectionViewFlowLayout *followLayout = [[UICollectionViewFlowLayout alloc] init];
    followLayout.itemSize = CGSizeMake(self.bottomBarHeight+20, self.bottomBarHeight);
    followLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    followLayout.minimumLineSpacing = 0;
    followLayout.minimumInteritemSpacing = 0;
    
    self.tabbarCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(_bottomBar.bounds), self.bottomBarHeight) collectionViewLayout:followLayout];
    self.tabbarCollectionView.backgroundColor =[UIColor clearColor];
    self.tabbarCollectionView.showsHorizontalScrollIndicator = NO;
    self.tabbarCollectionView.delegate = (id)self;
    self.tabbarCollectionView.dataSource = (id)self;
//    self.tabbarCollectionView.pagingEnabled = YES;
    [_bottomBar addSubview: self.tabbarCollectionView];
    return _bottomBar;
}

- (UICollectionView *)pasterCollectionView{
    if (!_pasterCollectionView) {
        AliyunPasterCollectionFlowLayout *layout = [[AliyunPasterCollectionFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(55, 55);
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _pasterCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.timeLinePalletView.frame), CGRectGetWidth(self.frame), CGRectGetHeight(self.frame) - self.bottomBarHeight-SafeBottom-CGRectGetMaxY(self.timeLinePalletView.frame)) collectionViewLayout:layout];
        _pasterCollectionView.backgroundColor = [UIColor clearColor];
        _pasterCollectionView.showsHorizontalScrollIndicator = NO;
        _pasterCollectionView.showsVerticalScrollIndicator = NO;
        _pasterCollectionView.delegate = (id)self;
        _pasterCollectionView.dataSource = (id)self;
//        _pasterCollectionView.pagingEnabled = YES;
    }
    return _pasterCollectionView;
}

-(CGFloat)headerViewHeight{
    if (self.delegate && [_delegate respondsToSelector:@selector(pasterBottomViewForHeaderViewHeight:)]) {
        _headerViewHeight = [_delegate pasterBottomViewForHeaderViewHeight:self];
    }else{
        _headerViewHeight = 45.f;//headerViewHeight默认值
    }
    return _headerViewHeight;
}
-(CGFloat)bottomBarHeight{
    if (self.delegate && [_delegate respondsToSelector:@selector(pasterBottomViewForHeaderViewHeight:)]) {
        _bottomBarHeight = [_delegate pasterBottomViewForHeaderViewHeight:self];
    }else{
        _bottomBarHeight = 44.f;//bottomBarHeight默认值
    }
    return _bottomBarHeight;
}
-(CGSize)timeLineSize{
    if (self.delegate && [_delegate respondsToSelector:@selector(pasterBottomViewForTimeLineViewSize:)]) {
        _timeLineSize = [_delegate pasterBottomViewForTimeLineViewSize:self];
    }else{
        _timeLineSize = CGSizeMake(CGRectGetWidth(self.frame),45.f);//timeLineSize默认值
    }
    return _timeLineSize;
}

#pragma mark - Set
-(void)setTimeLineView:(AliyunTimelineView *)timeLineView{
    _timeLineView = timeLineView;
    if (timeLineView) {
        timeLineView.frame = CGRectMake(0, 5, self.timeLineSize.width, self.timeLineSize.height-10);
        timeLineView.backgroundColor = self.backgroundColor;
        [_timeLinePalletView addSubview:timeLineView];
    }
}

#pragma mark - Public Functions

//是否是上次选中的title
-(BOOL)isEqualSelectedTitle:(NSString *)title{
    if ([title isEqualToString:self.selectTitle]) {
        return YES;
    }
    return NO;
}

//-(void)reset{
//    _lastPasterCollectionCell.isSelected = NO;
//    _lastPasterCollectionCell = nil;
//}

@end
