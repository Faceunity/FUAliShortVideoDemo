//
//  AlivcRollCaptionView.m
//  AlivcCommon
//
//  Created by aliyun on 2021/3/9.
//

#import "AlivcRollCaptionView.h"
#import <AliyunVideoSDKPro/AliyunRollCaptionItemStyle.h>
#import "AliyunPaintColorItemCell.h"
#import "AlivcRollCaptionFontCell.h"
#import "UIColor+AlivcHelper.h"

@interface AlivcRollCaptionView ()

@property (nonatomic, strong) UICollectionView *collectionView;
//0:关闭 1:颜色 2：字体
@property (nonatomic,assign) int optType;
@property (nonatomic,strong) NSArray *dataArr;

@property(nonatomic,strong) UIView *btnView;

@end

@implementation AlivcRollCaptionView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        
        UIButton *clearBtn = [[UIButton alloc] initWithFrame:CGRectMake(8, 4, 60, 24)];
        [clearBtn setTitle:@"清空" forState:UIControlStateNormal];
        [clearBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [clearBtn addTarget:self action:@selector(clickClearBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:clearBtn];
        
        UIButton *okBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.frame)-16-24, 4, 24, 24)];
        [okBtn setImage:[AlivcImage imageNamed:@"check"] forState:UIControlStateNormal];
        [okBtn addTarget:self action:@selector(clickFinishBtn) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:okBtn];
        
        //按钮
        _btnView = [[UIView alloc] initWithFrame:CGRectMake(0, 24, CGRectGetWidth(frame), 90)];
        [self addSubview:_btnView];
        
        
        UIButton *colorBtn = [[UIButton alloc] initWithFrame:CGRectMake((CGRectGetWidth(frame)- 40)/2, 0,40, 40)];
        [colorBtn setImage:[AlivcImage imageNamed:@"alivc_svEdit_color"] forState:UIControlStateNormal];
        [_btnView addSubview:colorBtn];
        [colorBtn addTarget:self action:@selector(clickColorBtn) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *wordsBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMinX(colorBtn.frame)-70, 0,40, 40)];
        [wordsBtn setImage:[AlivcImage imageNamed:@"alivc_svEdit_words"] forState:UIControlStateNormal];
        [_btnView addSubview:wordsBtn];
        [wordsBtn addTarget:self action:@selector(clickWordsBtn) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *fontBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetMaxX(colorBtn.frame)+30, 0,40, 40)];
        [fontBtn setImage:[AlivcImage imageNamed:@"shortVideo_tab_caption_font"] forState:UIControlStateNormal];
        [_btnView addSubview:fontBtn];
        [fontBtn addTarget:self action:@selector(clickFontBtn) forControlEvents:UIControlEventTouchUpInside];
        
        int y = 42;
        
        UILabel *colorLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(colorBtn.frame), y, 40, 20)];
        [colorLab setText:@"颜色"];
        [colorLab setTextColor:[UIColor whiteColor]];
        [colorLab setFont:[UIFont systemFontOfSize:12]];
        [colorLab setTextAlignment:NSTextAlignmentCenter];
        [_btnView addSubview:colorLab];
        
        UILabel *wordsLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(wordsBtn.frame), y, 40, 20)];
        [wordsLab setText:@"字幕"];
        [wordsLab setTextColor:[UIColor whiteColor]];
        [wordsLab setFont:[UIFont systemFontOfSize:12]];
        [wordsLab setTextAlignment:NSTextAlignmentCenter];
        [_btnView addSubview:wordsLab];
        
        UILabel *fontLab = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(fontBtn.frame), y, 40, 20)];
        [fontLab setText:@"字体"];
        [fontLab setTextColor:[UIColor whiteColor]];
        [fontLab setFont:[UIFont systemFontOfSize:12]];
        [fontLab setTextAlignment:NSTextAlignmentCenter];
        [_btnView addSubview:fontLab];
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 24, ScreenWidth, 102) collectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.showsHorizontalScrollIndicator = NO;
        _collectionView.dataSource = (id<UICollectionViewDataSource>)self;
        _collectionView.delegate = (id<UICollectionViewDelegate>)self;
        [self addSubview:_collectionView];
        
        [_collectionView registerClass:[AliyunPaintColorItemCell class] forCellWithReuseIdentifier:@"AliyunPaintColorItemCell"];
        [_collectionView registerClass:[AlivcRollCaptionFontCell class] forCellWithReuseIdentifier:@"AlivcRollCaptionFontCell"];
        
        [self showSubView:NO];
    }
    return self;
}

-(void)showSubView:(BOOL)isShow{
    self.collectionView.hidden = !isShow;
    self.btnView.hidden = isShow;
}

#pragma --mark collectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _dataArr.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_optType==2) {
        AlivcRollCaptionFontCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlivcRollCaptionFontCell" forIndexPath:indexPath];
        NSString *fontName = [self.dataArr objectAtIndex:indexPath.row];
        [cell.fontLab setText:fontName];
        [cell.fontLab setFont:[UIFont fontWithName:fontName size:12]];
        return cell;
    }else{
        AliyunPaintColorItemCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AliyunPaintColorItemCell" forIndexPath:indexPath];
        UIColor *color = [UIColor colorWithHexString:[self.dataArr objectAtIndex:indexPath.row]];
        cell.colorView.backgroundColor = color;
        return cell;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (_optType==1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRollCaptionSelColor:)]) {
            UIColor *color = [UIColor colorWithHexString:[self.dataArr objectAtIndex:indexPath.row]];
            [self.delegate didRollCaptionSelColor:color];
        }
    }else if (_optType==2){
        if (self.delegate && [self.delegate respondsToSelector:@selector(didRollCaptionSelFont:)]) {
            NSString *fontName = [self.dataArr objectAtIndex:indexPath.row];
            [self.delegate didRollCaptionSelFont:fontName];
        }
    }
    [self showSubView:NO];
}

-(void)clickColorBtn{
    _optType = 1;
    [self showSubView:YES];
    _dataArr = @[@"#F9FAFB",@"#F4775C",
                 @"#FFA133",@"#EDC200",@"#50B83C",@"#47C1BF",
                 @"#007ACE",@"#5C6AC4",@"#9C6ADE"];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(30, 60);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    [self.collectionView setCollectionViewLayout:layout];
    [self.collectionView reloadData];
}

-(void)clickFontBtn{
    _optType = 2;
    [self showSubView:YES];
    _dataArr = @[@"Helvetica",@"Georgia",@"PingFangTC-Semibold",@"Papyrus"];
    
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(60, 60);
    layout.minimumInteritemSpacing = 20;
    layout.minimumLineSpacing = 20;
    [self.collectionView setCollectionViewLayout:layout];
    
    [self.collectionView reloadData];
}

-(void)clickWordsBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRollCaptionClickWordsBtn)]) {
        [self.delegate didRollCaptionClickWordsBtn];
    }
}

-(void)clickFinishBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRollCaptionClickFinishBtn)]) {
        [self.delegate didRollCaptionClickFinishBtn];
    }
    [self showSubView:NO];
}

-(void)clickClearBtn{
    if (self.delegate && [self.delegate respondsToSelector:@selector(didRollCaptionClickClearBtn)]) {
        [self.delegate didRollCaptionClickClearBtn];
    }
    [self showSubView:NO];
    self.wordList = nil;
}

- (NSMutableArray *)wordList{
    if (!_wordList) {
        _wordList = @[
            [[AliyunRollCaptionItemStyle alloc]initWithText: @"我来到，你的城市" startTime:1.32],
            [[AliyunRollCaptionItemStyle alloc]initWithText:@"走过你来时的路" startTime:3.06],
            [[AliyunRollCaptionItemStyle alloc]initWithText:@"想像着，没我的日子" startTime:4.67],
            [[AliyunRollCaptionItemStyle alloc]initWithText:@"你是怎样的孤独" startTime:6.42],
            [[AliyunRollCaptionItemStyle alloc]initWithText:@"昨天已经" startTime:8.80]
        ].mutableCopy;
    }
    return _wordList;
}

@end
