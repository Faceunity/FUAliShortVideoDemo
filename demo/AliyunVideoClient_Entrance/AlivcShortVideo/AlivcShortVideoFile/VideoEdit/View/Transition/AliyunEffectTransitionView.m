//
//  AliyunEffectTransitionVIew.m
//  qusdk
//
//  Created by Vienta on 2018/6/6.
//  Copyright © 2018年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunEffectTransitionView.h"
#import "AliyunTransitionCover.h"
#import "AliyunTransitionIcon.h"
#import "AliyunTransitionCoverCell.h"
#import "AliyunTransitionIconCell.h"
#import "AliyunTransitionPreviewCell.h"
#import "AliyunImage.h"
#import "NSArray+AliyunDeepCopy.h"
#import "UIView+AlivcHelper.h"
#import "AlivcEditBottomHeaderView.h"

@interface AliyunEffectTransitionView()

@property (nonatomic, strong) AlivcEditBottomHeaderView *headerView;


@end

@implementation AliyunEffectTransitionView
{
    AliyunTransitionIcon *_selectedIcon;//当前选中的动画
    AliyunTransitionCover *_selectedCover;//当前选中的过渡片段
}

- (id)initWithFrame:(CGRect)frame delegate:(id<AliyunEffectTransitionViewDelegate>)delegate
{
    if (self = [super initWithFrame:frame]) {
        [self addVisualEffect];
//        self.backgroundColor = [UIColor colorWithRed:27.0/255 green:33.0/255 blue:51.0/255 alpha:1];
        _covers = [[NSMutableArray alloc]initWithCapacity:8];
        _icons = [[NSMutableArray alloc]initWithCapacity:8];
        
        [self addSubview:self.headerView];
        
        self.coverTableView = [[PTEHorizontalTableView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.headerView.frame)+15, frame.size.width, 40)];
        UITableView *coverNativeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 10, frame.size.width, 40) style:UITableViewStylePlain];
        [coverNativeTableView registerClass:[AliyunTransitionCoverCell class] forCellReuseIdentifier:@"AliyunTransitionCoverCell"];
        [coverNativeTableView registerClass:[AliyunTransitionPreviewCell class] forCellReuseIdentifier:@"AliyunTransitionPreviewCell"];
        coverNativeTableView.separatorColor = [UIColor clearColor];
        self.coverTableView.tableView = coverNativeTableView;
        self.coverTableView.delegate = self;
        self.coverTableView.tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.coverTableView];
        self.coverTableView.backgroundColor = [UIColor clearColor];
        coverNativeTableView.backgroundColor = [UIColor clearColor];
    
        self.transitionTableView = [[PTEHorizontalTableView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.frame)-62-15, frame.size.width, 62)];
        UITableView *transitionNativeTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 62) style:UITableViewStylePlain];
        [transitionNativeTableView registerClass:[AliyunTransitionIconCell class] forCellReuseIdentifier:@"AliyunTransitionIconCell"];
        transitionNativeTableView.separatorColor = [UIColor clearColor];
        self.transitionTableView.tableView = transitionNativeTableView;
        self.transitionTableView.delegate = self;
        self.transitionTableView.tableView.showsVerticalScrollIndicator = NO;
        [self addSubview:self.transitionTableView];
        self.transitionTableView.backgroundColor = [UIColor clearColor];
        transitionNativeTableView.backgroundColor = [UIColor clearColor];
        self.delegate = delegate;
    }
    return self;
}

-(void)setupDataSourceClips:(NSArray *)images blockHandle:(void (^)(NSArray<AliyunTransitionCover *> *, NSArray<AliyunTransitionIcon *> *))block{
    
    if (_covers) {
        [_covers removeAllObjects];
        for (int idx = 0; idx < [images count]; idx++) {
            AliyunTransitionCover *cover = [[AliyunTransitionCover alloc] init];
            cover.image = [images objectAtIndex:idx];
            cover.isTransitionIdx = NO;
            cover.isSelect = NO;
            [_covers addObject:cover];
            if (idx < [images count] - 1) {
                AliyunTransitionCover *cover1 = [[AliyunTransitionCover alloc] init];
                cover1.image = [AlivcImage imageNamed:@"transition_cover_point_Sel"];
                cover1.image_Nor = [AlivcImage imageNamed:@"transition_cover_point_Nor"];
                cover1.isTransitionIdx = YES;
                cover1.isSelect = idx == 0?:NO;//默认选中
                cover1.transitionIdx = idx;
                
                [_covers addObject:cover1];
            }
        }
    }
    
    NSArray *textArray = @[@"无",@"向上移动",@"向下移动", @"向左移动", @"向右移动", @"百叶窗", @"淡入淡出",@"圆形", @"多边形"];
    NSArray *iconNameArray =  @[@"transition_null",
                                @"transition_up",
                                @"transition_down",
                                @"transition_left",
                                @"transition_right",
                                @"transition_shuffer",
                                @"transition_fade",
                                @"transition_circle",
                                @"transition_star"];
    
    NSArray *types = @[@(TransitionTypeNull),
                       @(TransitionTypeMoveUp),
                       @(TransitionTypeMoveDown),
                       @(TransitionTypeMoveLeft),
                       @(TransitionTypeMoveRight),
                       @(TransitionTypeShuffer),
                       @(TransitionTypeFade),
                       @(TransitionTypeCircle),
                       @(TransitionTypeStar)];
    if (_icons) {
        [_icons removeAllObjects];
        for (int idx = 0; idx < textArray.count; idx++) {
            NSString *text = [textArray objectAtIndex:idx];
            NSString *iconName = [iconNameArray objectAtIndex:idx];
            UIImage *iconImage = [AlivcImage imageNamed:[NSString stringWithFormat:@"%@_Nor",iconName]];
            UIImage *coverIcon = [AlivcImage imageNamed:[NSString stringWithFormat:@"%@_Cover",iconName]];
            AliyunTransitionIcon *tIcon = [[AliyunTransitionIcon alloc] init];
            tIcon.image = iconImage;
            tIcon.coverIcon =coverIcon;
            tIcon.imageSel =[AlivcImage imageNamed:@"shortVideo_Item_selected"];
            tIcon.text = text;
            if (idx == 0) {
                tIcon.isSelect = YES;//默认选中
                _selectedIcon = tIcon;
            }else{
                tIcon.isSelect = NO;
            }
            tIcon.type = [[types objectAtIndex:idx] intValue];
            [_icons addObject:tIcon];
        }
    }
    [self.transitionTableView.tableView reloadData];
    [self.coverTableView.tableView reloadData];
    if (block) {
        block([_covers copy],[_icons copy]);
    }
}

#pragma UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(PTEHorizontalTableView *)horizontalTableView numberOfRowsInSection:(NSInteger)section
{
    if (horizontalTableView == self.coverTableView) {
        return [_covers count];
    }
    if (horizontalTableView == self.transitionTableView) {
        return [_icons count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(PTEHorizontalTableView *)horizontalTableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (horizontalTableView == self.coverTableView) {
        if (indexPath.row % 2 == (0)) {
            AliyunTransitionPreviewCell *cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"AliyunTransitionPreviewCell"];
            AliyunTransitionCover *cover = [_covers objectAtIndex:indexPath.row];
            [cell setTransitionCover:cover];
            return cell;
        }else{
            AliyunTransitionCoverCell *cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"AliyunTransitionCoverCell"];
            AliyunTransitionCover *cover = [_covers objectAtIndex:indexPath.row];
            [cell setTransitionCover:cover];
            return cell;
        }
        
    }
    
    if (horizontalTableView == self.transitionTableView) {
        AliyunTransitionIconCell *cell = [horizontalTableView.tableView dequeueReusableCellWithIdentifier:@"AliyunTransitionIconCell"];
        AliyunTransitionIcon *icon = [_icons objectAtIndex:indexPath.row];
        [cell setTransitionIcon:icon];
        
        
        return cell;
    }
    return nil;
}

- (void)tableView:(PTEHorizontalTableView *)horizontalTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (horizontalTableView == self.coverTableView) {
        AliyunTransitionCover *cover = [_covers objectAtIndex:indexPath.row];
        if (cover.isTransitionIdx) {
            [self transitionCoverCellStatusChange:cover];
        }
        [horizontalTableView.tableView reloadData];
        [self.transitionTableView.tableView reloadData];
    }
    
    if (horizontalTableView == self.transitionTableView) {
        AliyunTransitionIcon *icon = [_icons objectAtIndex:indexPath.row];
        //选中效果
        [self transitionIconCellStatusChange:icon];
        [self.coverTableView.tableView reloadData];
        
        if (_selectedCover) {
            [self.delegate didSelectTransitionType:(TransitionType)icon.type index:_selectedCover.transitionIdx];
        }
        
        [horizontalTableView.tableView reloadData];
    }
}
//改变Cover Cell选中状态
-(void)transitionCoverCellStatusChange:(AliyunTransitionCover *)cover{
    BOOL isRepeated = NO;
    for (AliyunTransitionCover *lastSelCover in _covers) {
        if (lastSelCover.isSelect) {
            if (lastSelCover == cover) {
                isRepeated = NO;
                return;
            }
            lastSelCover.isSelect = NO;
        }
    }
    if (isRepeated) {return;}
    cover.isSelect = YES;
    for (AliyunTransitionIcon *icon in _icons) {
        if (icon.type == cover.type) {
            icon.isSelect = YES;
        }else{
            icon.isSelect =NO;
        }
    }
}
//改变动画cell选中状态
-(void)transitionIconCellStatusChange:(AliyunTransitionIcon *)icon{
    BOOL isRepeated = NO;
    for (AliyunTransitionIcon *lastSelIcon in _icons) {
        if (lastSelIcon.isSelect) {
            if (lastSelIcon == icon) {
                isRepeated = NO;
                return;
            }
            lastSelIcon.isSelect = NO;
        }
    }
    if (isRepeated) {return;}
    icon.isSelect = YES;
    for (AliyunTransitionCover *lastSelCover in _covers) {
        if (lastSelCover.isSelect) {
            lastSelCover.image = icon.coverIcon;
            lastSelCover.type = icon.type;
            lastSelCover.transitionImage_Nor = icon.image;
            _selectedCover = lastSelCover;
        }
    }
}

- (CGFloat)tableView:(PTEHorizontalTableView *)horizontalTableView widthForCellAtIndexPath:(NSIndexPath *)indexPath{
    if (horizontalTableView == self.coverTableView) {
        if (indexPath.row % (2) == 0) {
            return 90;
        }else{
            return 57;
        }
    }
    if (horizontalTableView == self.transitionTableView) {
        return 70;
    }
    return 0;
}



#pragma mark - Get
- (AlivcEditBottomHeaderView *)headerView{
    if (!_headerView) {
        _headerView = [[AlivcEditBottomHeaderView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, 45)];
        _headerView.backgroundColor = [UIColor clearColor];
        [_headerView setTitle:@"转场" icon:[AlivcImage imageNamed:@"shortVideo_transition_icon"]];
        __weak typeof(self)weakSelf = self;
        [_headerView bindingApplyOnClick:^{//确认
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(applyButtonClickCovers:andIcons:transitionInfo:)]) {
                [weakSelf.delegate applyButtonClickCovers:_covers andIcons:_icons transitionInfo:[weakSelf getTransitionIfon]];
            }
        } cancelOnClick:^{//取消
            if (weakSelf.delegate && [weakSelf.delegate respondsToSelector:@selector(transitionCancelButtonClickTransitionInfo:)]) {
                [weakSelf.delegate transitionCancelButtonClickTransitionInfo:[weakSelf getTransitionIfon]];
            }
        }];
    }
    return _headerView;
}

-(NSDictionary *)getTransitionIfon{
    NSMutableDictionary *transitionInfo = [NSMutableDictionary dictionaryWithCapacity:8];
    for (int i = 0; i<_covers.count; i++) {
        AliyunTransitionCover *cover = _covers[i];
        if (cover.isTransitionIdx) {//本次转场编辑状态保存
            [transitionInfo setValue:@(cover.type) forKey:[NSString stringWithFormat:@"%d",cover.transitionIdx]];
        }
    }
    return [transitionInfo copy];
}

-(void)setIcons:(NSMutableArray<AliyunTransitionIcon *> *)icons{
    _icons = icons;
    [self.transitionTableView.tableView reloadData];
}
-(void)setCovers:(NSMutableArray<AliyunTransitionCover *> *)covers{
    _covers = covers;
    [self.coverTableView.tableView reloadData];
}
@end
