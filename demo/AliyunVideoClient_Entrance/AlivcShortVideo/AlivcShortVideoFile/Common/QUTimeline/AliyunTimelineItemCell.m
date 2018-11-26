//
//  AliyunTimelineItemCell.m
//  QPSDKCore
//
//  Created by Vienta on 2016/11/25.
//  Copyright © 2016年 lyle. All rights reserved.
//

#import "AliyunTimelineItemCell.h"

@implementation AliyunTimelinePercent



@end


@interface AliyunTimelineItemCell ()

@property (nonatomic, strong) UIView *greyView;
@property (nonatomic, strong) NSMutableArray *greyViews;
@property (nonatomic, strong) NSMutableArray *percents;
@property (nonatomic, strong) NSMutableArray *filterPercents;
@property (nonatomic, strong) NSMutableArray *filterViews;
@property (nonatomic, strong) NSMutableArray *timeFilterPercents;
@property (nonatomic, strong) NSMutableArray *timeFilterViews;

@end

@implementation AliyunTimelineItemCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        UIColor *backgroundColor = [UIColor clearColor];
        self.backgroundColor = backgroundColor;
        self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(frame), CGRectGetHeight(frame))];
        self.imageView.contentMode = UIViewContentModeScaleAspectFill;
        self.imageView.clipsToBounds = YES;
        [self addSubview:self.imageView];
        
        self.greyView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.greyView];
//        self.greyView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.4];
        self.greyView.backgroundColor = AlivcOxRGBA(0x3CF2FF, 0.7);
        self.greyView.hidden = YES;
    }
    return self;
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    self.imageView.bounds = self.bounds;
}

- (void)refreshGreyviews
{
    for (AliyunTimelinePercent *percent in self.percents) {
        CGFloat x = percent.leftPercent * self.bounds.size.width;
        CGFloat width = (percent.rightPercent - percent.leftPercent) * self.bounds.size.width;
        CGRect frame = CGRectMake(x, 0, width, CGRectGetHeight(self.bounds));
        UIView *greyview = [[UIView alloc] initWithFrame:frame];
        greyview.backgroundColor = AlivcOxRGBA(0x3CF2FF, 0.7);
//        greyview.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:.4];
        [self addSubview:greyview];
        [self.greyViews addObject:greyview];
    }
}

- (void)refreshFilterviews {
    for (AliyunTimelinePercent *percent in self.filterPercents) {
        CGFloat x = percent.leftPercent * self.bounds.size.width;
        CGFloat width = (percent.rightPercent - percent.leftPercent) * self.bounds.size.width;
        CGRect frame = CGRectMake(x, 0, width, CGRectGetHeight(self.bounds));
        UIView *filterView = [[UIView alloc] initWithFrame:frame];
        filterView.backgroundColor = percent.color;
        [self addSubview:filterView];
        [self.filterViews addObject:filterView];
    }
}

- (void)refreshTimeFilterviews {
    for (AliyunTimelinePercent *percent in self.timeFilterPercents) {
        CGFloat x = percent.leftPercent * self.bounds.size.width;
        CGFloat width = (percent.rightPercent - percent.leftPercent) * self.bounds.size.width;
        CGRect frame = CGRectMake(x, 0, width, CGRectGetHeight(self.bounds));
        UIView *filterView = [[UIView alloc] initWithFrame:frame];
        filterView.backgroundColor = percent.color;
        [self addSubview:filterView];
        [self.timeFilterViews addObject:filterView];
    }
}

- (void)setMappedBeginTime:(CGFloat)mappedBeginTime
                   endTime:(CGFloat)mappedEndTime
                     image:(UIImage *)image
          timelinePercents:(NSArray *)percents
    timelineFilterPercents:(NSArray *)filterPercents
timelineTimeFilterPercents:(NSArray *)timeFilterPercents
{
    self.mappedBeginTime = mappedBeginTime;
    self.mappedEndTime = mappedEndTime;
    
    if (![self.imageView.image isEqual:image]) {
        [self.imageView setImage:image];
    }
    
    [self.percents removeAllObjects];
    [self.percents addObjectsFromArray:percents];
    [self.greyViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.greyViews removeAllObjects];
    [self refreshGreyviews];

    [self.filterPercents removeAllObjects];
    [self.filterPercents addObjectsFromArray:filterPercents];
    [self.filterViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.filterViews removeAllObjects];
    [self refreshFilterviews];


    [self.timeFilterPercents removeAllObjects];
    [self.timeFilterPercents addObjectsFromArray:timeFilterPercents];
    [self.timeFilterViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.timeFilterViews removeAllObjects];
    
    [self refreshTimeFilterviews];
}

- (NSMutableArray *)greyViews
{
    if (!_greyViews) {
        _greyViews = [[NSMutableArray alloc] init];
    }
    return _greyViews;
}

- (NSMutableArray *)percents
{
    if (!_percents) {
        _percents = [[NSMutableArray alloc] init];
    }
    return _percents;
}

- (NSMutableArray *)filterPercents {
    if (!_filterPercents) {
        _filterPercents = [[NSMutableArray alloc] init];
    }
    return _filterPercents;
}

- (NSMutableArray *)filterViews {
    if (!_filterViews) {
        _filterViews = [[NSMutableArray alloc] init];
    }
    return _filterViews;
}

- (NSMutableArray *)timeFilterPercents {
    if (!_timeFilterPercents) {
        _timeFilterPercents = [[NSMutableArray alloc] init];
    }
    return _timeFilterPercents;
}

- (NSMutableArray *)timeFilterViews {
    if (!_timeFilterViews) {
        _timeFilterViews = [[NSMutableArray alloc] init];
    }
    return _timeFilterViews;
}

@end
