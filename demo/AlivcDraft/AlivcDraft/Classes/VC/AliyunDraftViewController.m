//
//  AliyunDraftViewController.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/9.
//

#import "AliyunDraftViewController.h"
#import "UIColor+AlivcHelper.h"
#import "AliyunDraftConfig.h"
#import "AliyunDraftBundle.h"
#import "AliyunDraftTableViewCell.h"
#import <AliyunVideoSDKPro/AliyunEditorProject.h>
#import "AliyunDraftMoreMenuView.h"
#import "AliyunPathManager.h"
#import "AliyunDraftRenameView.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AliyunDraftLoader.h"
#import "AliyunCloudDraftModel.h"
#import "AliyunMediaConfig.h"


@interface NSLayoutConstraint (AlivcDraft)
- (instancetype) changeSecondItem:(id)secondItem;
@end

@interface AliyunDraftViewController () <
UIScrollViewDelegate,
UITableViewDelegate, UITableViewDataSource,
AliyunDraftBaseManagerDelegate,
AliyunDraftTableViewCellDelegate,
AliyunDraftMoreMenuViewDelegate,
UINavigationControllerDelegate,
UIImagePickerControllerDelegate>
@property (nonatomic, assign) AliyunDraftType tabType;

@property (nonatomic, strong) AliyunDraftMoreMenuView *menuView;

@property (weak, nonatomic) IBOutlet UIView *localTabView;
@property (weak, nonatomic) IBOutlet UIView *cloudTabView;
@property (weak, nonatomic) IBOutlet UIView *templateTabView;
@property (weak, nonatomic) IBOutlet UILabel *localTabLabel;
@property (weak, nonatomic) IBOutlet UILabel *cloudTabLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateTabLabel;
@property (weak, nonatomic) IBOutlet UILabel *localCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *templateCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *cloudCountLabel;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *selectedBoxCenter;

@property (weak, nonatomic) IBOutlet UIView *syncView;
@property (weak, nonatomic) IBOutlet UILabel *offlineDraftCountLabel;
@property (weak, nonatomic) IBOutlet UIButton *syncBtn;

@property (nonatomic, assign) BOOL afterDragScrollView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITableView *localDraftTable;
@property (weak, nonatomic) IBOutlet UITableView *cloudDraftTable;
@property (weak, nonatomic) IBOutlet UITableView *templateDraftTable;

@property (nonatomic, assign) BOOL isDraftOpening;

@property (nonatomic, weak) AliyunLocalDraftModel *draftCoverChanging;
@end

@implementation AliyunDraftViewController

- (instancetype) init {
    return [self initWithNibName:@"AliyunDraftViewController" bundle:AliyunDraftBundle.main];
}

- (void) showSetting {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"设置服务" message:@"" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    
    __weak typeof(self) weakSelf = self;
    __block UITextField *serviceTextField = nil;
    __block UITextField *userIdTextField = nil;
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        AliyunDraftConfig *config = AliyunDraftConfig.Shared;
        BOOL hasChange = NO;

        if (serviceTextField.text.length > 0 && ![config.serverUrl isEqualToString:serviceTextField.text]) {
            config.serverUrl = serviceTextField.text;
            hasChange = YES;
        }
        
        if (userIdTextField.text.length > 0 && ![config.userId isEqualToString:userIdTextField.text]) {
            config.userId = userIdTextField.text;
            hasChange = YES;
        }
        
        if (hasChange) {
            [weakSelf reconnectManager];
        }
    }];
    
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"服务地址";
        textField.text = AliyunDraftConfig.Shared.serverUrl;
        serviceTextField = textField;
    }];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"用户";
        textField.text = AliyunDraftConfig.Shared.userId;
        userIdTextField = textField;
    }];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

- (IBAction)settingBtnDidPressed:(UIButton *)sender {
    [self showSetting];
}

- (IBAction)backDidPressed:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void) switchToTab:(AliyunDraftType)tab {
    self.tabType = tab;
    CGPoint offset = CGPointMake(_scrollView.frame.size.width * tab, 0);
    _afterDragScrollView = NO;
    [_scrollView setContentOffset:offset animated:YES];
}

- (IBAction)localTabSelected:(UIButton *)sender {
    [self switchToTab:AliyunDraftType_Local];
}

- (IBAction)templateTabSelected:(id)sender {
    [self switchToTab:AliyunDraftType_Template];
}

- (IBAction)cloudTabSelected:(UIButton *)sender {
    [self switchToTab:AliyunDraftType_Cloud];
}

- (BOOL) checkNeedShowSetting {
    if (!AliyunDraftConfig.Shared.hasService) {
        [self showSetting];
        return YES;
    }
    return NO;
}

- (IBAction)syncDidPressed:(UIButton *)sender {
    if ([self checkNeedShowSetting]) {
        return;
    }
    
    MBProgressHUD *loading = [MBProgressHUD showMessage:@"备份中" alwaysInView:self.view];
    __weak typeof(self) weakSelf = self;
    [AliyunDraftConfig.Shared.cloudManager uploadAllLocalDraft:^(BOOL isSuccess) {
        if (isSuccess) {
            [loading replaceSuccessMessage:@"备份成功"];
        } else {
            [loading replaceWarningMessage:@"备份失败"];
        }
        [loading hideAnimated:YES afterDelay:2.0];
        [weakSelf reloadList];
    }];
}

#define CELL_IDENTIFIER @"DraftCellIdentifier"

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *cell = [UINib nibWithNibName:@"AliyunDraftTableViewCell" bundle:AliyunDraftBundle.main];
    [self.localDraftTable registerNib:cell forCellReuseIdentifier:CELL_IDENTIFIER];
    [self.cloudDraftTable registerNib:cell forCellReuseIdentifier:CELL_IDENTIFIER];
    [self.templateDraftTable registerNib:cell forCellReuseIdentifier:CELL_IDENTIFIER];

    AliyunDraftConfig.Shared.localManager.delegate = self;
    AliyunDraftConfig.Shared.cloudManager.delegate = self;
    AliyunDraftConfig.Shared.templateManager.delegate = self;

    _tabType = AliyunDraftType_Cloud;
    self.tabType = AliyunDraftType_Local;
}

- (void) updateCount
{
    self.cloudCountLabel.text = @(AliyunDraftConfig.Shared.cloudManager.list.count).stringValue;
    self.localCountLabel.text = @(AliyunDraftConfig.Shared.localManager.list.count).stringValue;
    self.templateCountLabel.text = @(AliyunDraftConfig.Shared.templateManager.list.count).stringValue;

    int needSyncDraftCount = AliyunDraftConfig.Shared.localManager.needSyncDraftCount;
    self.offlineDraftCountLabel.text = [NSString stringWithFormat:@"%d个草稿可备份", needSyncDraftCount];
    self.syncBtn.hidden = (needSyncDraftCount == 0);
}

static void s_highlightLabel(UILabel *label, BOOL isHighlight)
{
    label.textColor = isHighlight ? UIColor.whiteColor : [UIColor colorWithHexString:@"#696969"];
}

- (void) updateUIWithTabType:(AliyunDraftType)tabType
{
    switch (tabType) {
        case AliyunDraftType_Local:
            // highlight
            s_highlightLabel(_localTabLabel, YES);
            s_highlightLabel(_localCountLabel, YES);
            s_highlightLabel(_cloudTabLabel, NO);
            s_highlightLabel(_cloudCountLabel, NO);
            s_highlightLabel(_templateTabLabel, NO);
            s_highlightLabel(_templateCountLabel, NO);
            _selectedBoxCenter = [_selectedBoxCenter changeSecondItem:_localTabView];
            break;
        case AliyunDraftType_Template:
            // highlight
            s_highlightLabel(_localTabLabel, NO);
            s_highlightLabel(_localCountLabel, NO);
            s_highlightLabel(_cloudTabLabel, NO);
            s_highlightLabel(_cloudCountLabel, NO);
            s_highlightLabel(_templateTabLabel, YES);
            s_highlightLabel(_templateCountLabel, YES);
            _selectedBoxCenter = [_selectedBoxCenter changeSecondItem:_templateTabView];
            break;
        case AliyunDraftType_Cloud:
            // highlight
            s_highlightLabel(_localTabLabel, NO);
            s_highlightLabel(_localCountLabel, NO);
            s_highlightLabel(_cloudTabLabel, YES);
            s_highlightLabel(_cloudCountLabel, YES);
            s_highlightLabel(_templateTabLabel, NO);
            s_highlightLabel(_templateCountLabel, NO);
            _selectedBoxCenter = [_selectedBoxCenter changeSecondItem:_cloudTabView];
            break;
        default:
            break;
    }
    
    BOOL isLocal = (tabType == AliyunDraftType_Local);
    [UIView animateWithDuration:0.2 animations:^{
        [self.view layoutIfNeeded];
        self.syncView.alpha = isLocal ? 1.0 : 0.0;
    }];
}

- (void) setTabType:(AliyunDraftType)tabType
{
    if (_tabType == tabType) {
        return;
    }
    
    _tabType = tabType;
    [self updateUIWithTabType:tabType];
    
    if (_tabType == AliyunDraftType_Cloud) {
        [self checkNeedShowSetting];
    }
}

- (AliyunDraftMoreMenuView *) menuView
{
    if (!_menuView) {
        _menuView = [AliyunDraftMoreMenuView LoadFromNib];
        _menuView.delegate = self;
        _menuView.frame = self.view.bounds;
        [self.view addSubview:_menuView];
    }
    return _menuView;
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    _menuView.frame = self.view.bounds;
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [AliyunDraftConfig.Shared.cloudManager checkDraftsState];
    
    [self refreshList];
    [self reloadList];
}

- (void) reconnectManager {
    AliyunDraftConfig.Shared.localManager.delegate = self;
    AliyunDraftConfig.Shared.cloudManager.delegate = self;
    AliyunDraftConfig.Shared.templateManager.delegate = self;
    [self refreshList];
    [self reloadList];
}

- (void) refreshList {
    [AliyunDraftConfig.Shared.localManager refreshList];
    [AliyunDraftConfig.Shared.templateManager refreshList];
    if (AliyunDraftConfig.Shared.hasService) {
        [AliyunDraftConfig.Shared.cloudManager refreshList];
    }
}

- (void) reloadList {
    [self updateCount];
    [self.templateDraftTable reloadData];
    [self.cloudDraftTable reloadData];
    [self.localDraftTable reloadData];
}

- (void) checkDeleteOldCloudProjectWithId:(NSString *)projectId {
    if (projectId.length == 0) {
        return;
    }
    
    AliyunCloudDraftModel *curCloudModel = [AliyunDraftConfig.Shared.cloudManager findDraftWithId:projectId];
    if (!curCloudModel) {
        return;
    }
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"提示" message:@"是否覆盖旧备份？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"不覆盖" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {}];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"覆盖" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [AliyunDraftConfig.Shared.cloudManager deleteDraftWithId:projectId];
    }];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [self presentViewController:alertController animated:YES completion:nil];
}

// MARK: - AliyunDraftMoreMenuViewDelegate
- (void) onAliyunDraftMoreMenuViewDidSync:(AliyunDraftMoreMenuView *)menuView {
    if ([self checkNeedShowSetting]) {
        return;
    }
    
    AliyunLocalDraftModel *localModel = (AliyunLocalDraftModel *)menuView.draft;
    if (localModel.state == AliyunDraftState_syncing) {
        [MBProgressHUD showMessage:@"备份中，请稍后" inView:self.view];
        return;
    }
    
    if (localModel.state == AliyunDraftState_Synced) {
        [MBProgressHUD showMessage:@"备份完成" inView:self.view];
        return;
    }
    
    [self checkDeleteOldCloudProjectWithId:localModel.projectId];

    MBProgressHUD *loading = [MBProgressHUD showMessage:@"备份中" alwaysInView:self.view];
    [AliyunDraftConfig.Shared.cloudManager uploadLocalDraft:localModel completion:^(BOOL isSuccess) {
        if (isSuccess) {
            [loading replaceSuccessMessage:@"备份成功"];
        } else {
            [loading replaceWarningMessage:@"备份失败"];
        }
        [loading hideAnimated:YES afterDelay:2.0];
    }];
}

- (void) onAliyunDraftMoreMenuViewDidRename:(AliyunDraftMoreMenuView *)menuView {
    __weak typeof(self) weakSelf = self;
    [AliyunDraftRenameWindow ShowOn:self.view withTitle:menuView.draft.title confirm:^(NSString *title) {
        AliyunLocalDraftModel *localDraft = (AliyunLocalDraftModel *)menuView.draft;
        [localDraft.draft renameTitle:title];
        if (menuView.type == AliyunDraftType_Template) {
            [weakSelf.templateDraftTable reloadData];
        }
        else {
            [weakSelf.localDraftTable reloadData];
        }
        
    }];
}

- (void) onAliyunDraftMoreMenuViewDidUpdateCover:(AliyunDraftMoreMenuView *)menuView {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        _draftCoverChanging = (AliyunLocalDraftModel *)menuView.draft;
        UIImagePickerController * imagePickerVC = [[UIImagePickerController alloc] init];
        imagePickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePickerVC.delegate = self;
        [self presentViewController:imagePickerVC animated:YES completion:nil];
    }
}

- (void) onAliyunDraftMoreMenuViewDidCopy:(AliyunDraftMoreMenuView *)menuView
{
    NSString *editDir = [AliyunPathManager compositionRootDir];
    NSString *taskPath = [editDir stringByAppendingPathComponent:[AliyunPathManager randomString]];
    NSString *title = [NSString stringWithFormat:@"%@副本", menuView.draft.title];
    AliyunLocalDraftManager * draftManager = AliyunDraftConfig.Shared.localManager;
    if (menuView.type == AliyunDraftType_Template) {
        draftManager = AliyunDraftConfig.Shared.templateManager;
    }
    [draftManager copyDraft:(AliyunLocalDraftModel *)menuView.draft toPath:taskPath withTitle:title];
}

- (void) onAliyunDraftMoreMenuViewDidDelete:(AliyunDraftMoreMenuView *)menuView
{
    AliyunDraftInfo *draft = menuView.draft;
    if (menuView.type == AliyunDraftType_Local) {
        [AliyunDraftConfig.Shared.localManager deleteDraft:(AliyunLocalDraftModel *)draft];
    }
    else if (menuView.type == AliyunDraftType_Template) {
        [AliyunDraftConfig.Shared.templateManager deleteDraft:(AliyunLocalDraftModel *)draft];
    }
    else {
        [AliyunDraftConfig.Shared.cloudManager deleteDraftWithId:draft.projectId];
    }
}

// MARK: - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey, id> *)info {
    UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
    if (image) {
        [_draftCoverChanging.draft updateCover:image];
        [_localDraftTable reloadData];
        [_templateDraftTable reloadData];
    }
    _draftCoverChanging = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    _draftCoverChanging = nil;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

// MARK: - AliyunDraftBaseManagerDelegate
- (void) onAliyunDraftBaseManager:(AliyunDraftBaseManager *)mgr listDidChange:(NSArray<AliyunDraftInfo *> *)list {
    [self updateCount];
    if (mgr == AliyunDraftConfig.Shared.localManager) {
        [_localDraftTable reloadData];
    }
    else if (mgr == AliyunDraftConfig.Shared.templateManager) {
        [_templateDraftTable reloadData];
    }
    else {
        [_cloudDraftTable reloadData];
    }
}

// MARK: - AliyunDraftTableViewCellDelegate
- (void) onAliyunDraftTableViewCellDidClickMore:(AliyunDraftTableViewCell *)cell {
    self.menuView.draft = cell.draft;
    self.menuView.type = self.tabType;
    self.menuView.isShow = YES;
}

- (void) downloadDraft:(AliyunCloudDraftModel *)cloudDraft {
    if (cloudDraft.state == AliyunDraftState_syncing) {
        [MBProgressHUD showMessage:NSLocalizedString(@"正在下载，请稍后", nil) inView:self.view];
        return;
    }
    
    if (cloudDraft.state == AliyunDraftState_Synced) {
        [MBProgressHUD showMessage:NSLocalizedString(@"已经同步到本地，请到剪辑里进行编辑", nil) inView:self.view];
        return;
    }
    
    MBProgressHUD *loading = [MBProgressHUD showMessage:@"下载中" alwaysInView:self.view];
    [AliyunDraftConfig.Shared.cloudManager downloadCloudDraft:cloudDraft completion:^(BOOL isSuccess) {
        if (isSuccess) {
            [loading replaceSuccessMessage:@"下载成功"];
        } else {
            [loading replaceWarningMessage:@"下载错误"];
        }
        [loading hideAnimated:YES afterDelay:2.0];
    }];
}

- (void) openDraft:(AliyunDraft *)draft isTemplate:(BOOL)isTemplate {
    if (_isDraftOpening) {
        return;
    }
    _isDraftOpening = YES;
    MBProgressHUD *loading = [MBProgressHUD showMessage:@"加载中" alwaysInView:self.view];
    [draft load:^(NSArray<AliyunDraftLoadTask *> *tasks) {
        for (AliyunDraftLoadTask *task in tasks) {
            [AliyunDraftConfig.Shared.loader download:task];
        }
    } completion:^(NSString *taskPath, AliyunEditorBaseProject *project, NSError *error) {
        if (!taskPath || !project || error) {
            NSString *msg = error ? error.localizedDescription : @"加载草稿失败";
            [loading replaceWarningMessage:msg];
            [loading hideAnimated:YES afterDelay:2.0];
            self.isDraftOpening = NO;
            return;
        }
        
        [loading replaceSuccessMessage:@"加载成功"];
        [loading hideAnimated:YES afterDelay:1.0];
        
        if (isTemplate) {
            
            Class viewControllerClass = NSClassFromString(@"AlivcTemplateEditorViewController");
            UIViewController *templateEditor = [[viewControllerClass alloc]init];
            [templateEditor setValue:taskPath forKey:@"taskPath"];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:templateEditor animated:YES];
                self.isDraftOpening = NO;
            });
        }
        else {
            AliyunMediaConfig *mediaConfig = [AliyunMediaConfig new];
            mediaConfig.outputSize = CGSizeMake(project.config.outputWidth, project.config.outputHeight);
            mediaConfig.videoQuality = (AliyunMediaQuality)project.config.videoQuality;
            mediaConfig.cutMode = (AliyunMediaCutMode)project.config.displayMode;
            mediaConfig.encodeMode = (AliyunEncodeMode)project.config.videoCodec;
            mediaConfig.fps = project.config.FPS;
            mediaConfig.gop = project.config.GOP;
            mediaConfig.outputPath = [[taskPath stringByAppendingPathComponent:AliyunPathManager.randomString] stringByAppendingPathExtension:@"mp4"];
            
            Class viewControllerClass = NSClassFromString(@"AliyunEditViewController");
            UIViewController *editor = [[viewControllerClass alloc]init];
            [editor setValue:mediaConfig forKey:@"config"];
            [editor setValue:taskPath forKey:@"taskPath"];

 
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.navigationController pushViewController:editor animated:YES];
                self.isDraftOpening = NO;
            });
        }
    }];
}

- (void) onAliyunDraftTableViewCellDidClickDownload:(AliyunDraftTableViewCell *)cell {
    [self downloadDraft:(AliyunCloudDraftModel *)cell.draft];
}

- (AliyunDraftType) typeOfTableView:(UITableView *)tableView {
    if (tableView == _localDraftTable) {
        return AliyunDraftType_Local;
    }
    if (tableView == _templateDraftTable) {
        return AliyunDraftType_Template;
    }
    return AliyunDraftType_Cloud;
}

- (NSArray<AliyunDraftInfo *> *) listOfType:(AliyunDraftType)type {
    if (type == AliyunDraftType_Local) {
        return AliyunDraftConfig.Shared.localManager.list;
    }
    if (type == AliyunDraftType_Template) {
        return AliyunDraftConfig.Shared.templateManager.list;
    }
    return AliyunDraftConfig.Shared.cloudManager.list;
}

// MARK: - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self listOfType:[self typeOfTableView:tableView]].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunDraftTableViewCell *cell = (AliyunDraftTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CELL_IDENTIFIER];
    cell.delegate = self;
    AliyunDraftType type = [self typeOfTableView:tableView];
    cell.type = type;
    cell.draft = [self listOfType:type][indexPath.row];
    return cell;
}

// MARK: - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (_scrollView != scrollView) {
        return;
    }
    
    if (scrollView.isDragging) {
        _afterDragScrollView = YES;
    }
    
    if (_afterDragScrollView) {
        int index = (int)(scrollView.contentOffset.x / scrollView.frame.size.width);
        self.tabType = (AliyunDraftType)index;
    }
}

// MARK: - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    AliyunDraftType type = [self typeOfTableView:tableView];
    if (type == AliyunDraftType_Cloud) {
        [self downloadDraft:(AliyunCloudDraftModel *)[self listOfType:type][indexPath.row]];
    }
    else if (type == AliyunDraftType_Template) {
        [self openDraft:((AliyunLocalDraftModel *)[self listOfType:type][indexPath.row]).draft isTemplate:YES];
    }
    else {
        [self openDraft:((AliyunLocalDraftModel *)[self listOfType:type][indexPath.row]).draft isTemplate:NO];
    }
}

// MARK: - ViewController
- (BOOL)shouldAutorotate {
    return NO;
}
-(UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}
-(UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
    return UIInterfaceOrientationPortrait;
}
- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end

@implementation NSLayoutConstraint (AlivcDraft)

- (instancetype) changeSecondItem:(id)secondItem
{
    [NSLayoutConstraint deactivateConstraints:@[self]];
    NSLayoutConstraint *newConstraint = [NSLayoutConstraint constraintWithItem:self.firstItem
                                                                     attribute:self.firstAttribute
                                                                     relatedBy:self.relation
                                                                        toItem:secondItem
                                                                     attribute:self.secondAttribute
                                                                    multiplier:self.multiplier
                                                                      constant:self.constant];
    [newConstraint setPriority:self.priority];
    newConstraint.shouldBeArchived = self.shouldBeArchived;
    newConstraint.identifier = self.identifier;
    newConstraint.active = true;
    
    [NSLayoutConstraint activateConstraints:@[newConstraint]];
    return newConstraint;
}

@end
