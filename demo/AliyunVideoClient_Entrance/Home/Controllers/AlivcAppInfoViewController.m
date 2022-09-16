//
//  AlivcAppInfoViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by wanghao on 2019/4/10.
//  Copyright © 2019年 Alibaba. All rights reserved.
//

#import "AlivcAppInfoViewController.h"
#import "AlivcMacro.h"
#import "AVC_ShortVideo_Config.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AliyunVideoConfig.h"

#if __has_include(<AliyunVideoSDKPro/AliyunVideoSDKInfo.h>)
#import <AliyunVideoSDKPro/AliyunVideoSDKInfo.h>
#endif
#import "AlivcImage.h"
#ifdef OPEN_PLAYVIDEO_PRIVATECODE
#import <AliyunPlayer/AliyunPlayer.h>
#endif

#if SDK_VERSION == SDK_VERSION_BASE
#import <AliyunVideoSDKBasic/AliyunVideoLicense.h>
#else
#import <AliyunVideoSDKPro/AliyunVideoLicense.h>
#endif

static NSString * alivcAppInfoCellIdentifier = @"ALIVC_APP_VERSION_CELL_IDENTIFIER";



@interface AlivcAppInfoViewController ()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic, strong)UIButton *uploadLogBtn;
@property(nonatomic, strong)UITableView *tableView;
@property(nonatomic, strong)NSMutableArray *dataSource;

@end

@implementation AlivcAppInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
       
    UIImage *returnImage = [UIImage imageNamed:@"avcBackIcon"];
    UIBarButtonItem *leftItem = [[UIBarButtonItem alloc]initWithImage:returnImage style:UIBarButtonItemStylePlain target:self action:@selector(returnAction)];
    UIBarButtonItem *rightItem =[[UIBarButtonItem alloc] initWithTitle:@"更新证书" style:UIBarButtonItemStylePlain target:self action:@selector(onLicenseUpdate)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
    self.navigationItem.rightBarButtonItem = rightItem;
    
    self.title = NSLocalizedString(@"SDK版本信息" , nil);
    self.dataSource =[NSMutableArray arrayWithCapacity:10];
    self.view.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
    [self.view addSubview:self.tableView];
    [self setupDataSource];
    [self addUploadLogBtn];
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (_uploadLogBtn) {
        CGPoint center = CGPointMake(self.view.bounds.size.width * 0.5, self.view.bounds.size.height);
        center.y -= _uploadLogBtn.frame.size.height * 0.5 + 4;
        _uploadLogBtn.center = center;
    }
}

- (void)onLicenseUpdate {
    MBProgressHUD *loading = [MBProgressHUD showMessage:@"证书更新中..." alwaysInView:self.view];
    [AliyunVideoConfig RefreshLicense:^(BOOL isSuccess, NSString * _Nonnull errMsg) {
        if (isSuccess) {
            [loading replaceSuccessMessage:@"更新成功"];
        } else {
            [loading replaceWarningMessage:errMsg];
        }
        [loading hideAnimated:YES afterDelay:3];
    }];
}

- (void) addUploadLogBtn {
    if (_uploadLogBtn) {
        return;
    }
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 120, 36)];
    btn.backgroundColor = UIColor.orangeColor;
    btn.layer.cornerRadius = 4;
    btn.layer.masksToBounds = YES;
    [btn setTitle:@"提取日志" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(uploadLogDidPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    _uploadLogBtn = btn;
}

- (void)uploadLogDidPressed:(UIButton *)btn {
    NSString *logPath = AliyunVideoSDKInfo.logPath;
    NSString *targetPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    targetPath = [targetPath stringByAppendingPathComponent:@"MockUploadLog"];
    BOOL isDirectory = NO;
    if ([NSFileManager.defaultManager fileExistsAtPath:targetPath isDirectory:&isDirectory] && isDirectory) {
        [NSFileManager.defaultManager removeItemAtPath:targetPath error:nil];
    }
    
    NSError *copyError = nil;
    if ([NSFileManager.defaultManager copyItemAtPath:logPath toPath:targetPath error:&copyError]) {
        [MBProgressHUD showMessage:@"提取成功" inView:self.view];
    } else {
        NSLog(@"copy log error: %@", copyError);
        MBProgressHUD *hud = [MBProgressHUD showMessage:@"提取日志失败" alwaysInView:self.view];
        hud.detailsLabel.text = copyError.localizedDescription;
        [hud hideAnimated:YES afterDelay:5];
    }
}

- (void)returnAction {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

static NSString * s_formatTime(NSTimeInterval time)
{
    NSDateFormatter *dateFormat = [NSDateFormatter new];
    dateFormat.dateFormat = @"yyyy-MM-dd HH:mm:ss";
    return [dateFormat stringFromDate:[NSDate dateWithTimeIntervalSince1970:time]];
}

static NSString * s_featureName(AliyunVideoFeatureType type)
{
    switch (type) {
        case AliyunVideoFeatureTypeMV: return @"MV";
        case AliyunVideoFeatureTypeSticker: return @"Sticker";
        case AliyunVideoFeatureTypeCropCompose: return @"CropCompose";
        case AliyunVideoFeatureTypeCaption: return @"Caption";
        default: return @"Unknown";
    }
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
    
    // license
    AliyunVideoLicense *license = AliyunVideoLicenseManager.CurrentLicense;
    [self.dataSource addObject:NSLocalizedString(@"许可证信息", nil)];
    [self.dataSource addObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"许可证签发时间", nil), s_formatTime(license.certSignTime)]];
    [self.dataSource addObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"许可证有效时间", nil), s_formatTime(license.certExpireTime)]];
    [self.dataSource addObject:[NSString stringWithFormat:@"%@: %@", NSLocalizedString(@"业务到期时间", nil), s_formatTime(license.expireTime)]];
    [self.dataSource addObject:NSLocalizedString(@"增值服务", nil)];
    for (AliyunVideoLicenseFeature *feature in license.features) {
        [self.dataSource addObject:s_featureName(feature.feature)];
        [self.dataSource addObject:[NSString stringWithFormat:@"[%@] - [%@]",
                                    s_formatTime(feature.startTime),
                                    s_formatTime(feature.endTime)]];
    }
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
