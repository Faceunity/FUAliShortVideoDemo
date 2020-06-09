//
//  AlivcAppInfoViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/10.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcAppInfoViewController.h"
#import "AlivcMacro.h"
#if __has_include(<AliyunVideoSDKPro/AliyunVideoSDKInfo.h>)
#import <AliyunVideoSDKPro/AliyunVideoSDKInfo.h>
#endif
#import "AlivcImage.h"
#ifdef OPEN_PLAYVIDEO_PRIVATECODE
#import <AliyunPlayer/AliyunPlayer.h>
#endif

static NSString * alivcAppInfoCellIdentifier = @"ALIVC_APP_VERSION_CELL_IDENTIFIER";



@interface AlivcAppInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation AlivcAppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       
    UIImage *returnImage = [UIImage imageNamed:@"avcBackIcon"];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:returnImage style:UIBarButtonItemStylePlain target:self action:@selector(returnAction)];
    self.navigationItem.leftBarButtonItem = leftItem;
    
    self.title = NSLocalizedString(@"SDK版本信息" , nil);
    self.dataSource =[NSMutableArray arrayWithCapacity:10];
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    [self.view addSubview:self.tableView];
    [self setupDataSource];
    // Do any additional setup after loading the view.
}

- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}


-(void)setupDataSource{
#if __has_include(<AliyunVideoSDKPro/AliyunVideoSDKInfo.h>)
    
    NSString *version = [AliyunVideoSDKInfo version];
    NSString *alivcCommitId = [AliyunVideoSDKInfo alivcCommitId];
    NSString *mediaCoreCommitId =[AliyunVideoSDKInfo mediaCoreCommitId];
    NSString *videoSDKCommitId = [AliyunVideoSDKInfo videoSDKCommitId];
    NSString *videoSDKBuildId =[AliyunVideoSDKInfo videoSDKBuildId];
    [self.dataSource addObject:[NSString stringWithFormat:@"VERSION：%@",version]];
    [self.dataSource addObject:[NSString stringWithFormat:@"BUILD_ID：%@",videoSDKBuildId]];
    [self.dataSource addObject:[NSString stringWithFormat:@"MEDIA_CORE_COMMIT_ID：%@",mediaCoreCommitId]];
    [self.dataSource addObject:[NSString stringWithFormat:@"ALIVC_COMMIT_ID：%@",alivcCommitId]];
    [self.dataSource addObject:[NSString stringWithFormat:@"VIDEO_SDK_COMMIT_ID：%@",videoSDKCommitId]];
    
#endif
    
#ifdef OPEN_PLAYVIDEO_PRIVATECODE
    NSString * playerVersion = [AliPlayer getSDKVersion];
    [self.dataSource addObject:[NSString stringWithFormat:@"ALIPLAYER_VERSION：%@",playerVersion]];
#endif
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    [self.dataSource addObject:[NSString stringWithFormat:@"APP_VERSION：%@",appVersion]];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView =[[UITableView alloc]initWithFrame:CGRectMake(0, 20, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds)-20)];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:alivcAppInfoCellIdentifier];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellEditingStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
    }
    return _tableView;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 25;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataSource.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:alivcAppInfoCellIdentifier];
    cell.textLabel.text = (NSString *)self.dataSource[indexPath.row];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.font =[UIFont systemFontOfSize:14];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

@end
