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
#define fontSelectView_btn_tag  2000

@interface AliyunFontSelectView()<UIPickerViewDelegate,UIPickerViewDataSource>
@property(nonatomic, strong)UIPickerView *pickView;
@property(nonatomic, strong)NSMutableArray *dataSource;
@property (nonatomic, assign) CGFloat selectedIndex;
@end

@implementation AliyunFontSelectView

-(id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
//        _isFirst = YES;
        [self setupSubviews_s];
        [self setupData];
    }
    return self;
}
-(void)showInView:(UIView *)superView animation:(BOOL)animation completion:(void (^)(BOOL))completion{
    [super showInView:superView animation:animation completion:completion];
    [self changeSpearatorLineColor];
    NSString *fontName = [[NSUserDefaults standardUserDefaults] objectForKey:AlivcEditPlayerPasterFontName];
    for(int i = 0; i < self.dataSource.count; i++) {
         AliyunEffectFontInfo *font = self.dataSource[i];
        if ([fontName isEqualToString:font.fontName]) {
                [self.pickView selectRow:i inComponent:0 animated:YES];
                [self pickerView:self.pickView didSelectRow:i inComponent:0];
            break;
        }
    }
}
-(void)setupData{
    if (self.dataSource.count >0) {
        [self.dataSource removeAllObjects];
    }
    // 获取字体
    AliyunDBHelper *helper = [[AliyunDBHelper alloc] init];
    __weak typeof(self)weakSelf = self;
    [helper queryResourceWithEffecInfoType:1 success:^(NSArray *infoModelArray) {
        for (AliyunEffectFontInfo *info in infoModelArray) {
            // 检测字体是否注册
            if (info.eid == -2) {//系统字体不用检测
                [self.dataSource addObject:info];
            }else{
                UIFont* aFont = [UIFont fontWithName:info.fontName size:14.0];
                BOOL isRegister = (aFont && ([aFont.fontName compare:info.fontName] == NSOrderedSame || [aFont.familyName compare:info.fontName] == NSOrderedSame));
                if (!isRegister) {
                    NSString *fontPath = [[[NSHomeDirectory() stringByAppendingPathComponent:info.resourcePath] stringByAppendingPathComponent:@"font"] stringByAppendingPathExtension:@"ttf"];
                    NSString *registeredName = [[AliyunEffectFontManager manager] registerFontWithFontPath:fontPath];
                    if (registeredName) {
                        [self.dataSource addObject:info];
                    }
                } else {
                    [self.dataSource addObject:info];
                }
            }
        }
        [weakSelf.pickView performSelectorOnMainThread:@selector(reloadAllComponents) withObject:nil waitUntilDone:NO];
        [self.pickView selectRow:0 inComponent:0 animated:NO];
    } failure:^(NSError *error) {
        [weakSelf.pickView performSelectorOnMainThread:@selector(reloadAllComponents) withObject:nil waitUntilDone:NO];
    }];
}
-(void)setupSubviews_s{
    [self.contentView addSubview:self.pickView];
    [self drawBottomButtons];
}

-(void)drawBottomButtons{
    NSArray *arr = @[[@"简约" localString], [@"手写" localString]];
    CGFloat width = 70;
    UIButton *lastBtn;
    for (int i =0; i<arr.count; i++) {
        UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(width*i, 0, width, CGRectGetHeight(self.bootomView.bounds))];
        [btn setTitle:arr[i] forState:UIControlStateNormal];
        btn.tag = fontSelectView_btn_tag+i;
        if (i==0) {
            btn.backgroundColor = [UIColor blackColor];
        }else{
            btn.backgroundColor = [UIColor clearColor];
        }
        btn.titleLabel.textColor = [UIColor whiteColor];
        btn.titleLabel.font = [UIFont systemFontOfSize:14];
        [btn addTarget:self action:@selector(btnAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.bootomView addSubview:btn];
        lastBtn = btn;
    }
    
    UIView *moreView = [[UIView alloc]initWithFrame:CGRectMake(CGRectGetMaxX(lastBtn.frame), 0, width, CGRectGetHeight(self.bootomView.bounds))];
    moreView.backgroundColor = [UIColor clearColor];
    [self.bootomView addSubview:moreView];
    
    UIButton *addBtn = [[UIButton alloc]initWithFrame:CGRectMake(CGRectGetMidX(moreView.bounds)-30/2, CGRectGetMidY(moreView.bounds)-30/2, 30, 30)];
    [addBtn setBackgroundImage:[AlivcImage imageNamed:@"shortVideo_tab_caption_add"] forState:UIControlStateNormal];
    [moreView addSubview:addBtn];
    
}

-(void)btnAction:(UIButton *)btn{
    if ([btn.currentTitle isEqualToString:[@"简约" localString]]) {
        
    }else if ([btn.currentTitle isEqualToString:[@"手写" localString]]){
        
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
    return self.dataSource.count;
}
-(CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component{
    return CGRectGetWidth(self.contentView.bounds);
}
-(CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component{
    return 50;
}
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component{
    self.selectedIndex = row;
    [self.pickView reloadAllComponents];
    if (self.delegate && [self.delegate respondsToSelector:@selector(onSelectFontWithFontInfo:)]) {
        AliyunEffectFontInfo *font = self.dataSource[row];
        [[NSUserDefaults standardUserDefaults] setObject:font.fontName forKey:AlivcEditPlayerPasterFontName];
        [self.delegate onSelectFontWithFontInfo:font];
    }

}
-(UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view{
    [self changeSpearatorLineColor];
    UILabel *lab = [[UILabel alloc]init];
    lab.textAlignment = NSTextAlignmentCenter;
    AliyunEffectFontInfo *font = self.dataSource[row];
    lab.text = font.name;
    if (self.selectedIndex == row) {
        lab.textColor = AlivcOxRGB(0x00C1DE);
        lab.font = [UIFont systemFontOfSize:22];
    }else{
        lab.font = [UIFont systemFontOfSize:18];
        lab.textColor = [UIColor whiteColor];
    }
    return lab;
}
#pragma mark - 改变分割线的颜色
- (void)changeSpearatorLineColor
{
    for(UIView *speartorView in self.pickView.subviews)
    {
        if (speartorView.frame.size.height < 1)//取出分割线view
        {
            speartorView.backgroundColor = AlivcOxRGBA(0x00C1DE,0.7);//改变分割线颜色
        }
    }
}

#pragma mark - Get
-(UIPickerView *)pickView{
    if (!_pickView) {
        _pickView = [[UIPickerView alloc]initWithFrame:self.contentView.bounds];
        _pickView.delegate = self;
        _pickView.dataSource = self;
    }
    return _pickView;
}

-(NSMutableArray *)dataSource{
    if (!_dataSource) {
        _dataSource = [NSMutableArray arrayWithCapacity:10];
    }
    return _dataSource;
}

@end
