//
//  AliyunIntroduceController.m
//  AliyunVideoClient_Entrance
//
//  Created by 孙震 on 2019/3/19.
//  Copyright © 2019 Alibaba. All rights reserved.
//

#import "AlivcWebViewController.h"
#import <WebKit/WebKit.h>

@interface AlivcWebViewController ()

@property (nonatomic,weak) WKWebView *webView;
@property (nonatomic,weak) UILabel *nameLabel;
@property (nonatomic,weak) UIButton *backButton;
@property (nonatomic,weak) UIView *alivcNavBar;
@property (nonatomic,copy) NSString *url;

@end

@implementation AlivcWebViewController

- (instancetype)initWithUrl:(NSString *)url title:(NSString *)title{
    if (self = [super init]) {
        self.url = url;
        self.title = title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupNavBar];
    [self initWebView];
    [self loadData];
    
}

- (void)initWebView {
    CGFloat webViewX = 0;
    CGFloat webViewY = SafeTop + 44;
    CGFloat webViewW = ScreenWidth;
    CGFloat webVIewH = ScreenHeight - webViewY;
    WKWebView *webView = [[WKWebView alloc] initWithFrame:CGRectMake(webViewX, webViewY, webViewW, webVIewH)];
    [self.view addSubview:webView];
    self.webView = webView;
}

- (void)loadData {
    NSURL *url = [NSURL URLWithString:self.url];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}


- (void)setupNavBar {
    UIView *alivcNavBar = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 44 + SafeTop)];
    self.alivcNavBar = alivcNavBar;
    alivcNavBar.backgroundColor = RGBToColor(36, 40, 65);
    [self.view addSubview:alivcNavBar];
    //返回按钮
    UIButton *backButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.backButton = backButton;
    backButton.frame = CGRectMake(0, SafeTop, SizeWidth(28 + 12 + 12), 44);
    [backButton setImage:[AlivcImage imageNamed:@"avcBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(backButtonAction) forControlEvents:(UIControlEventTouchUpInside)];
    [alivcNavBar addSubview:backButton];
    //标题
    UILabel *nameLabel = [[UILabel alloc] init];
    self.nameLabel = nameLabel;
    self.nameLabel.bounds = CGRectMake(0, 0, 200, 44);
    self.nameLabel.font = [UIFont systemFontOfSize:15.f];
    self.nameLabel.textColor = [UIColor whiteColor];
    self.nameLabel.textAlignment = NSTextAlignmentCenter;
    self.nameLabel.text = self.title;
    [self.nameLabel sizeToFit];
    self.nameLabel.center = CGPointMake(ScreenWidth * 0.5, SafeTop + 22);
    [alivcNavBar addSubview:self.nameLabel];
}

- (void)backButtonAction {
    [self.navigationController popViewControllerAnimated:YES];
}
@end
