//
//  AliyunFontSelectView.m
//  AliyunVideoClient_Entrance
//
//  Created by 王浩 on 2018/9/4.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AliyunFontSelectView.h"
#import "AliyunEffectFontInfo.h"
#import "AliyunEffectFontManager.h"
#import "AliyunDBHelper.h"
#import "NSString+AlivcHelper.h"
#import "AlivcDefine.h"
#import "AliyunCaptionCollectionViewCell.h"
#import "UIView+OPLayout.h"



@interface AliyunFontSelectView()<UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic, strong)UICollectionView *collectionView;
@property(nonatomic, strong)NSMutableArray *dataSource;
@property(nonatomic, assign)int faceType;
@property(nonatomic, strong) AliyunDBHelper *helper;
@property(nonatomic, assign) NSInteger seletedIndex;



@end

@implementation AliyunFontSelectView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupSubviews_s];
        [self setupData];
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
        
        [_collectionView registerClass:[AliyunCaptionCollectionViewCell class] forCellWithReuseIdentifier:@"AliyunCaptionCollectionViewCell"];
    }
    
    return _collectionView;
}


- (AliyunEffectFontInfo *)systemFont
{
    AliyunEffectFontInfo *model = [[AliyunEffectFontInfo alloc] init];
    return model;
}

-(void)setupData{
    if (self.dataSource.count >0) {
        [self.dataSource removeAllObjects];
    }
    // 获取字体
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    self.helper = helper;
    __weak typeof(self)weakSelf = self;
    [helper queryResourceWithEffecInfoType:1 success:^(NSArray *infoModelArray) {
        for (AliyunEffectFontInfo *info in infoModelArray) {
            // 检测字体是否注册
            if (info.eid == -2) {//系统字体不用检测
                info.fontName = nil;
                [weakSelf.dataSource addObject:info];
            }else{
                UIFont* aFont = [UIFont fontWithName:info.fontName size:14.0];
                BOOL isRegister = (aFont && ([aFont.fontName compare:info.fontName] == NSOrderedSame || [aFont.familyName compare:info.fontName] == NSOrderedSame));
                if (!isRegister) {
                    NSString *fontPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"font"] stringByAppendingPathExtension:@"ttf"];
                    NSString *registeredName = [[AliyunEffectFontManager manager] registerFontWithFontPath:fontPath];
                    if (registeredName) {
                        info.fontName = registeredName;
                        [weakSelf.dataSource addObject:info];
                    }
                } else {
                    [weakSelf.dataSource addObject:info];
                }
                if (weakSelf.dataSource.count > 0) {
                    [weakSelf.dataSource insertObject:[self systemFont] atIndex:0];
                }
            }
        }
        
        weakSelf.seletedIndex = 0;
        [weakSelf.collectionView reloadData];
    } failure:^(NSError *error) {
        [weakSelf.collectionView reloadData];
    }];
}
-(void)setupSubviews_s{
    
    self.contentView.op_height -= SafeBottom;
    self.bootomView.op_bottom -= SafeBottom;
    self.bootomLine.hidden = YES;
    [self.contentView addSubview:self.collectionView];
    [self addBomUI];
    
 
}

-(void)addBomUI{
    
    
    NSArray *arr = @[@"粗体",@"斜体"];
    CGFloat width = 70;
    UIButton *lastBtn;
    for (int i =0; i<arr.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(width *i, 0, width, CGRectGetHeight(self.bootomView.bounds))];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.tag = i;
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor redColor] forState:UIControlStateSelected];

        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(onBtnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bootomView addSubview:btn];
        lastBtn = btn;
    }
}

- (void)onBtnAction:(UIButton *)button
{
  
    button.selected = !button.selected;
    if (button.selected) {
        self.faceType |= (1<<button.tag);
    } else {
        self.faceType &= ~(1<<button.tag);
    }
    
    if (self.dataSource.count > self.seletedIndex) {
        AliyunEffectFontInfo *info = self.dataSource[self.seletedIndex];
        if ([self.delegate respondsToSelector:@selector(onSelectFontWithFontInfo:faceType:)]) {
            [self.delegate onSelectFontWithFontInfo:info faceType:self.faceType];
        }
    }
 
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunCaptionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunCaptionCollectionViewCell" forIndexPath:indexPath];
    cell.isFont = YES;
    cell.contentView.backgroundColor = [UIColor cyanColor];
    AliyunEffectFontInfo *info = self.dataSource[indexPath.row];
    
    if (indexPath.row == 0) {
        cell.showImageView.image = [UIImage imageNamed:@"avc_sys"];
    } else {
        
        NSString *iconPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"icon"] stringByAppendingPathExtension:@"png"];
        cell.showImageView.image = [UIImage imageWithContentsOfFile:iconPath];
    }

    cell.selected = indexPath.row == self.seletedIndex;
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{

    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:self.seletedIndex inSection:0]];
    cell.selected = NO;
    
    self.seletedIndex = indexPath.row;
    AliyunEffectFontInfo *info = self.dataSource[indexPath.row];

    if ([self.delegate respondsToSelector:@selector(onSelectFontWithFontInfo:faceType:)]) {
        [self.delegate onSelectFontWithFontInfo:info faceType:self.faceType];
    }
}

#pragma mark - Get


-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataSource;
}


-(void)showInView:(UIView *)superView animation:(BOOL)animation completion:(void (^ __nullable)(BOOL finished))completion
{
    [super showInView:superView animation:animation
           completion:completion];
}

- (void)willMoveToWindow:(UIWindow *)newWindow
{
    [super willMoveToWindow:newWindow];
    
    if (newWindow) {
        [self setupData];
    }
}


@end
