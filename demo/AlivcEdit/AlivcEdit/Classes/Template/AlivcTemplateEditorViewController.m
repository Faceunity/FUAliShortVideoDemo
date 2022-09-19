//
//  AlivcTemplateEditorViewController.m
//  AlivcEdit
//
//  Created by Bingo on 2021/11/24.
//

#import "AlivcTemplateEditorViewController.h"
#import "AlivcTemplateResourceManager.h"
#import "AlivcTemplateNodeListView.h"
#import "AlivcPlayManager.h"
#import "AlivcPlayTimeView.h"
#import "AlivcExportViewController.h"
#import "AliyunDraftConfig.h"
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

@interface AlivcTemplateEditorViewController () <AlivcPlayManagerObserver>

@property (nonatomic, copy) NSString *templateTaskPath;
@property (nonatomic, copy) NSString *taskPath;
@property (nonatomic, strong) AliyunTemplateEditor *aliyunEditor;
@property (nonatomic, strong) AlivcPlayManager *playManager;

@property (nonatomic, strong) UIView *videoDisplayView;
@property (nonatomic, strong) UIView *selectedNodeView;
@property (nonatomic, strong) AlivcPlayTimeView *playTimeView;
@property (nonatomic, strong) AlivcTemplateNodeListView *nodeListView;

@end

@implementation AlivcTemplateEditorViewController

- (instancetype)initWithTemplateTaskPath:(NSString *)templateTaskPath {
    self = [super init];
    if (self) {
        _templateTaskPath = templateTaskPath;
    }
    return self;
}

- (instancetype)initWithTaskPath:(NSString *)taskPath {
    self = [super init];
    if (self) {
        _taskPath = taskPath;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1.0];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SafeTop, 60, 60)];
    [closeBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onCloseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    UIButton *exportBtn = [[UIButton alloc] initWithFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 64 - 12, SafeTop + 10, 64, 32)];
    [exportBtn setTitle:@"导出" forState:UIControlStateNormal];
    [exportBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    exportBtn.backgroundColor = [UIColor systemPinkColor];
    exportBtn.titleLabel.font = [UIFont systemFontOfSize:12];
    [exportBtn addTarget:self action:@selector(onExportBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exportBtn];
    
    [self setupNodeListView:CGRectMake(0, CGRectGetMaxY(self.view.bounds) - SafeBottom - 156, CGRectGetWidth(self.view.bounds), 156)];
    [self setupPlayTimeView:CGRectMake(0, CGRectGetMinY(self.nodeListView.frame) - 32 - 24, CGRectGetWidth(self.view.bounds), 32)];
    
    
    CGFloat startY = CGRectGetMaxY(closeBtn.frame);
    CGFloat height = CGRectGetMinY(self.playTimeView.frame) - 24.0 - startY;
    CGFloat width = CGRectGetWidth(self.view.bounds) - 16 * 2;
    self.videoDisplayView = [[UIView alloc] initWithFrame:CGRectMake(16, startY, width, height)];
//    self.videoDisplayView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoDisplayView];
    

    if (self.templateTaskPath) {
        NSString *taskPath = [[AlivcTemplateResourceManager projectTemplatePath] stringByAppendingPathComponent:[NSUUID UUID].UUIDString];
        self.aliyunEditor = [AliyunTemplateEditor createTemplateEditor:self.templateTaskPath onTaskPath:taskPath];
    }
    else if (self.taskPath) {
        self.aliyunEditor = [AliyunTemplateEditor openTemplateEditor:self.taskPath];
    }

    if (!self.aliyunEditor) {
        [self onErrorOccurs:nil];
    }
    
    self.aliyunEditor.preview = self.videoDisplayView;
    int ret = [self.aliyunEditor loadEditor];
    if (ret != ALIVC_COMMON_RETURN_SUCCESS) {
        NSLog(@"加载失败，可能是授权问题：%d", ret);
    }
    
    self.nodeListView.aliyunEditor = self.aliyunEditor;
    
    self.playManager = [[AlivcPlayManager alloc] initWithPlayer:self.aliyunEditor.getPlayer];
    [self.playManager addObserver:self];
    self.aliyunEditor.playerCallback = self.playManager.callbackSource;
    self.playTimeView.playManager = self.playManager;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.aliyunEditor startEdit];
    
    [self.playManager play];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self.playManager pause];
}

- (void)setupPlayTimeView:(CGRect)frame {
    self.playTimeView = [[AlivcPlayTimeView alloc] initWithFrame:frame];
    [self.view addSubview:self.playTimeView];
}

- (void)setupNodeListView:(CGRect)frame {
    __weak typeof(self) weakSelf = self;
    self.nodeListView = [[AlivcTemplateNodeListView alloc] initWithFrame:frame withSelectedNodeBlock:^(AliyunTemplateNode * node) {
        [weakSelf drawSelectedNode:node];
    }];
    [self.view addSubview:self.nodeListView];
}

- (void)drawSelectedNode:(AliyunTemplateNode *)node {
    
    if (!node) {
        self.selectedNodeView.hidden = YES;
        return;
    }
    
    NSTimeInterval startTime = [self.aliyunEditor playStartTimeWithNode:node] + 0.001;
    [self.playManager seek:startTime];
    
    if (!self.selectedNodeView) {
        self.selectedNodeView = [[UIView alloc] init];
        self.selectedNodeView.layer.borderWidth = 1.5;
        self.selectedNodeView.layer.borderColor = [UIColor systemPinkColor].CGColor;
        [self.videoDisplayView addSubview:self.selectedNodeView];
    }
    self.selectedNodeView.transform = CGAffineTransformIdentity;
    CGRect frame = [self.aliyunEditor getRenderWrapper].frame;
    frame = CGRectMake(frame.size.width * node.frame.origin.x, frame.size.height * node.frame.origin.y, frame.size.width * node.frame.size.width, frame.size.height * node.frame.size.height);
    frame = [[self.aliyunEditor getRenderWrapper] convertRect:frame toView:self.videoDisplayView];
    self.selectedNodeView.frame = frame;
    self.selectedNodeView.transform = CGAffineTransformMakeRotation(-node.rotation);
    self.selectedNodeView.hidden = NO;
}

- (void)onErrorOccurs:(NSError *)error {
    
    UIAlertController *alertController =[UIAlertController alertControllerWithTitle:@"" message:@"模板加载出现错误" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action2 =[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
    }];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:^{
        [self.navigationController popViewControllerAnimated:YES];
    }];
}

- (AliyunDraft *) saveToDraft {
    return [self.aliyunEditor saveToDraft:AliyunDraftConfig.Shared.templateManager.originMgr];
}

- (void)onCloseBtnClicked:(UIButton *)sender {
    
    [self saveToDraft];
    [self.navigationController popViewControllerAnimated:YES];
    
}

- (void)onExportBtnClicked:(UIButton *)sender {
    
    [self.playManager stop];
    [self.aliyunEditor stopEdit];
    
    AliyunDraft *draft = [self saveToDraft];
    NSString *fileName = [NSString stringWithFormat:@"%@-%ld.mp4", self.aliyunEditor.getCurrentTemplate.title, (long)[[NSDate date] timeIntervalSince1970] ] ;
    AlivcExportViewController *controller = [[AlivcExportViewController alloc] init];
    controller.taskPath = self.aliyunEditor.taskPath;
    controller.outputPath = [[AlivcTemplateResourceManager applyTemplatePath] stringByAppendingPathComponent:fileName];
    controller.outputSize = self.aliyunEditor.getEditorProject.config.outputResolution;
    controller.backgroundImage = [UIImage imageWithContentsOfFile:self.aliyunEditor.getCurrentTemplate.cover.path];
    controller.coverImage = controller.backgroundImage;
    controller.draft = draft;
    [self.navigationController pushViewController:controller animated:YES];
     
}

- (void)playStatus:(BOOL)isPlaying {
    if (isPlaying) {
        [self.nodeListView clearSelectedNode];
    }
}

@end
