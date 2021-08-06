//
//  AliyunRollCaptionWordsController.m
//  AlivcCommon
//
//  Created by aliyun on 2021/3/9.
//

#import "AliyunRollCaptionWordsController.h"
#import "AlivcRollCaptionCell.h"
#import <AliyunVideoSDKPro/AliyunRollCaptionItemStyle.h>
#import "AliyunPaintColorItemCell.h"
#import "UIColor+AlivcHelper.h"

@interface AliyunRollCaptionWordsController ()<UITableViewDelegate,UITableViewDataSource>

@property(nonatomic,strong) UITableView *tableView;
@property(nonatomic, strong) UICollectionView *collectionView;
@property(nonatomic,strong) UIButton *colorBtn;

@property(nonatomic,strong) NSArray *colorArr;
@property(nonatomic,strong) NSMutableArray<NSNumber*> *selArr;

@end

@implementation AliyunRollCaptionWordsController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor blackColor]];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(20, SafeTop+20, 24, 24)];
    [backBtn setImage:[AlivcImage imageNamed:@"avcBackIcon"] forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(onBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backBtn];
    
    UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-16-24, SafeTop+20, 24, 24)];
    [okBtn setImage:[AlivcImage imageNamed:@"check"] forState:UIControlStateNormal];
    [okBtn addTarget:self action:@selector(onFinish) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:okBtn];
    
    _colorBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.frame)-48-40, SafeTop+20,24, 24)];
    [_colorBtn setImage:[AlivcImage imageNamed:@"alivc_svEdit_color"] forState:UIControlStateNormal];
    [self.view addSubview:_colorBtn];
    [_colorBtn addTarget:self action:@selector(clickColorBtn) forControlEvents:UIControlEventTouchUpInside];
    
    _colorArr = @[@"#F9FAFB",@"#F4775C",
                  @"#FFA133",@"#EDC200",@"#50B83C",@"#47C1BF",
                  @"#007ACE",@"#5C6AC4",@"#9C6ADE"];
    
    _selArr = @[].mutableCopy;
    
    //列表
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0,SafeTop+46, CGRectGetWidth(self.view.frame), CGRectGetHeight(self.view.frame)-46-SafeBottom)];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
    [_tableView setBackgroundColor:[UIColor clearColor]];
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    _tableView.estimatedRowHeight = 40;
    
    [_tableView registerClass:AlivcRollCaptionCell.class forCellReuseIdentifier:NSStringFromClass(AlivcRollCaptionCell.class)];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(30, 30);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-SafeBottom-40, ScreenWidth, 40) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor clearColor];
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
    _collectionView.delegate = (id<UICollectionViewDelegate>)self;
    [self.view addSubview:_collectionView];
    
    [_collectionView registerClass:[AliyunPaintColorItemCell class] forCellWithReuseIdentifier:@"AliyunPaintColorItemCell"];
    
    _collectionView.hidden = YES;
    _colorBtn.hidden = YES;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataArr.count;
}

#pragma --mark tableView
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlivcRollCaptionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass(AlivcRollCaptionCell.class)];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak typeof(self) weakSelf = self;
    cell.didChangeTextFinish = ^(NSInteger idx, NSString * _Nonnull txt) {
        AliyunRollCaptionItemStyle *style = [weakSelf.dataArr objectAtIndex:idx];
        AliyunRollCaptionItemStyle *model = [[AliyunRollCaptionItemStyle alloc]initWithText:txt startTime:style.startTime];
        model.fontName = style.fontName;
        model.textColor = style.textColor;
        [weakSelf.dataArr replaceObjectAtIndex:idx withObject:model];
        [weakSelf.tableView reloadData];
    };
    
    AliyunRollCaptionItemStyle *model = [_dataArr objectAtIndex:indexPath.row];
    if (model) {
        BOOL isSel = [_selArr containsObject:@(indexPath.row)];
        [cell buildModel:model isSel:isSel idx:indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AlivcRollCaptionCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    //如果是编辑状态，不进行处理
    if (cell && cell.editBtn.isSelected) {
        return;
    }
    if([_selArr containsObject:@(indexPath.row)]){
        [_selArr removeObject:@(indexPath.row)];
    }else{
        [_selArr addObject:@(indexPath.row)];
    }
    _colorBtn.hidden = (_selArr.count<=0);
    [self.tableView reloadData];
}

#pragma --mark collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _colorArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AliyunPaintColorItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPaintColorItemCell" forIndexPath:indexPath];
    UIColor *color = [UIColor colorWithHexString:[self.colorArr objectAtIndex:indexPath.row]];
    cell.colorView.backgroundColor = color;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    _collectionView.hidden = YES;
    UIColor *color = [UIColor colorWithHexString:[self.colorArr objectAtIndex:indexPath.row]];
    for (NSNumber *idxNum in _selArr) {
        AliyunRollCaptionItemStyle *model = [_dataArr objectAtIndex:idxNum.intValue];
        [model setTextColor:color];
    }
    [self.tableView reloadData];
}


#pragma --mark 私有方法
-(void)onBack{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)onFinish{
    if (self.didChangeWordsFinish) {
        self.didChangeWordsFinish(_dataArr);
    }
    [self onBack];
}

-(void)clickColorBtn{
    _collectionView.hidden = NO;
}

@end
