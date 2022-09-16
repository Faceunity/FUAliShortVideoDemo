//
//  AlivcTemplateListViewController.m
//  AlivcEdit
//
//  Created by Bingo on 2021/11/22.
//

#import "AlivcTemplateListViewController.h"
#import "AlivcTemplateResourceManager.h"
#import "AlivcTemplateManager.h"
#import "AlivcTemplatePlayer.h"
#import "AlivcTemplateEditorViewController.h"
#import "AlivcTemplateBuilderViewController.h"
#import "SDWebImage.h"
#import "MBProgressHUD+AlivcHelper.h"

@interface AlivcTemplateItem : NSObject

@property (nonatomic, strong) AliyunTemplateLoader *loader;

@end

@implementation AlivcTemplateItem
@end

@protocol AlivcTemplateCellDelegate <NSObject>

- (void)onEditItemClicked:(AlivcTemplateItem *)item;
- (void)onExportItemClicked:(AlivcTemplateItem *)item;
- (void)onUpdateItemClicked:(AlivcTemplateItem *)item;

@end

@interface AlivcTemplateCell : UICollectionViewCell

@property (nonatomic, strong) AlivcTemplateItem *item;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *descLabel;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *editBtn;
@property (nonatomic, strong) UIButton *exportBtn;
@property (nonatomic, strong) UIButton *updateBtn;
@property (nonatomic, strong) AlivcTemplatePlayer *player;

@property (nonatomic, weak) id<AlivcTemplateCellDelegate> delegate;

@end

@implementation AlivcTemplateCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.coverView = [[UIImageView alloc] initWithFrame:self.bounds];
        self.coverView.contentMode = UIViewContentModeScaleAspectFit;
        self.coverView.backgroundColor = [UIColor blackColor];
        [self.contentView addSubview:self.coverView];
        self.player = [[AlivcTemplatePlayer alloc] initWithContainerView:self.coverView];
        
        self.emptyLabel = [UILabel new];
        self.emptyLabel.frame = self.contentView.bounds;
        self.emptyLabel.textColor = [UIColor whiteColor];
        self.emptyLabel.textAlignment = NSTextAlignmentCenter;
        self.emptyLabel.font = [UIFont systemFontOfSize:16];
        self.emptyLabel.hidden = YES;
        self.emptyLabel.text = @"还没有模板，请先到编辑器导出生成";
        [self.contentView addSubview:self.emptyLabel];
        
        self.descLabel = [UILabel new];
        self.descLabel.textColor = [UIColor whiteColor];
        self.descLabel.font = [UIFont systemFontOfSize:16];
        self.descLabel.numberOfLines = 1;
        self.descLabel.text = @"";
        [self.contentView addSubview:self.descLabel];
        
        self.playBtn = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        self.playBtn.selected = YES;
        [self.playBtn setImage:nil forState:UIControlStateNormal];
        [self.playBtn setImage:[AlivcImage imageNamed:@"qu_play"] forState:UIControlStateSelected];
        [self.playBtn addTarget:self action:@selector(onPlayBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.playBtn];
        
        self.editBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.editBtn setTitle:@"剪同款" forState:UIControlStateNormal];
        [self.editBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.editBtn.backgroundColor = [UIColor systemPinkColor];
        self.editBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.editBtn addTarget:self action:@selector(onEditBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.editBtn];
        
        self.exportBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.exportBtn setTitle:@"导出模板" forState:UIControlStateNormal];
        [self.exportBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.exportBtn.backgroundColor = [UIColor systemPinkColor];
        self.exportBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.exportBtn addTarget:self action:@selector(onExportBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.exportBtn];
        
        self.updateBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        [self.updateBtn setTitle:@"修改模板" forState:UIControlStateNormal];
        [self.updateBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.updateBtn.backgroundColor = [UIColor systemPinkColor];
        self.updateBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        [self.updateBtn addTarget:self action:@selector(onUpdateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.updateBtn];
        
         
    }
    return self;
}

- (void)dealloc {
    [self reset];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.coverView.frame = self.contentView.bounds;
    self.descLabel.frame = self.contentView.bounds;
    self.playBtn.frame = self.contentView.bounds;
    
    self.exportBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 64 - 12, SafeTop + 10, 64, 32);
    self.updateBtn.frame = CGRectMake(CGRectGetMinX(self.exportBtn.frame) - 64 - 12, SafeTop + 10, 64, 32);
    
    self.editBtn.frame = CGRectMake(CGRectGetWidth(self.contentView.bounds) - 64 - 12, CGRectGetHeight(self.contentView.bounds) - 32 - 34 - 6, 64, 32);
    
    self.descLabel.frame = CGRectMake(12, CGRectGetMinY(self.editBtn.frame), CGRectGetMinX(self.editBtn.frame) - 12, CGRectGetHeight(self.editBtn.frame));
}

- (void)updateItem:(AlivcTemplateItem *)item {
    self.item = item;
    
    if (!self.item.loader) {
        self.emptyLabel.hidden = NO;
        self.descLabel.hidden = YES;
        self.exportBtn.hidden = YES;
        self.updateBtn.hidden = YES;
        self.editBtn.hidden = YES;
        self.playBtn.hidden = YES;
        return;
    }
    
    self.emptyLabel.hidden = YES;
    self.descLabel.hidden = NO;
    self.exportBtn.hidden = NO;
    self.updateBtn.hidden = NO;
    self.editBtn.hidden = NO;
    self.playBtn.hidden = NO;
    
    AliyunTemplate *template = [self.item.loader getTemplate];

    self.descLabel.text = template.title;
    [self.descLabel sizeToFit];
    
    
    if (template.cover.path > 0) {
        self.coverView.image = [UIImage imageWithContentsOfFile:template.cover.path];
    }
    else {
        if (template.cover.URL.length > 0) {
            [self.coverView sd_setImageWithURL:[NSURL URLWithString:template.cover.URL]];
        } else {
            self.coverView.image = nil;
        }
    }
    
    [self reset];
    self.player.playUrl = template.previewVideo.path ?: template.previewVideo.URL;
}

- (void)play {
    [self.player play];
}

- (void)reset {
    [self.player stop];
    self.playBtn.selected = YES;
}

- (void)onPlayBtnClicked:(UIButton *)sender {
    if (![self.player isPlaying]) {
        [self.player play];
        self.playBtn.selected = NO;
    }
    else if (self.playBtn.isSelected) {
        [self.player resume];
        self.playBtn.selected = NO;
    }
    else {
        [self.player pause];
        self.playBtn.selected = YES;
    }
}

- (void)onEditBtnClicked:(UIButton *)sender {
    [self reset];
    if ([self.delegate respondsToSelector:@selector(onEditItemClicked:)]) {
        [self.delegate onEditItemClicked:self.item];
    }
}

- (void)onExportBtnClicked:(UIButton *)sender {
    [self reset];
    if ([self.delegate respondsToSelector:@selector(onExportItemClicked:)]) {
        [self.delegate onExportItemClicked:self.item];
    }
}

- (void)onUpdateBtnClicked:(UIButton *)sender {
    [self reset];
    if ([self.delegate respondsToSelector:@selector(onUpdateItemClicked:)]) {
        [self.delegate onUpdateItemClicked:self.item];
    }
}

@end

@interface AlivcTemplateListViewController () <UICollectionViewDataSource, UICollectionViewDelegate, AlivcTemplateCellDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) NSMutableArray<AlivcTemplateItem *> *items;
@property (nonatomic, weak) AlivcTemplateCell *currentCell;

@end

@implementation AlivcTemplateListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self setupUI];
    
    UIButton *closeBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, SafeTop, 60, 60)];
    [closeBtn setImage:[AlivcImage imageNamed:@"shortVideo_edit_close"] forState:UIControlStateNormal];
    [closeBtn addTarget:self action:@selector(onCloseBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:closeBtn];
    
    MBProgressHUD *loading = [MBProgressHUD showMessage:@"加载中" alwaysInView:self.view];
    __weak typeof(self) weakSelf = self;
    [AlivcTemplateManager loadAllTemplates:^(NSArray<AliyunTemplateLoader *> *templateLoaders) {
        [weakSelf loadItems:templateLoaders];
        [loading replaceSuccessMessage:@"加载成功"];
        [loading hideAnimated:YES];
    }];
}

- (void)loadItems:(NSArray<AliyunTemplateLoader *> *)templateLoaders {
    self.items = [NSMutableArray array];
    [templateLoaders enumerateObjectsUsingBlock:^(AliyunTemplateLoader * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AlivcTemplateItem *item = [AlivcTemplateItem new];
        item.loader = obj;
        [self.items addObject:item];
    }];
    if (self.items.count == 0) {
        [self.items addObject:[AlivcTemplateItem new]];
    }
    [self.collectionView reloadData];
    
    self.currentCell = nil;
}

- (void)setupUI {

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = self.view.bounds.size;
    layout.minimumInteritemSpacing = 0.0;
    layout.minimumLineSpacing = 0.0;
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:self.view.bounds collectionViewLayout:layout];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self.view addSubview:self.collectionView];
    [self.collectionView registerClass:[AlivcTemplateCell class] forCellWithReuseIdentifier:@"AlivcTemplateCell"];
    self.collectionView.pagingEnabled = YES;
#ifdef __IPHONE_11_0
    if ([self.collectionView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)])
    {
        if (@available(iOS 11.0, *)) {
            self.collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
#endif
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlivcTemplateCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlivcTemplateCell" forIndexPath:indexPath];
    [cell updateItem:[self.items objectAtIndex:indexPath.row]];
    cell.delegate = self;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {

}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.currentCell == nil) {
        CGFloat yPoint = scrollView.contentOffset.y + scrollView.frame.size.height / 2;
        CGFloat xPoint = scrollView.frame.size.width / 2;
        CGPoint center = CGPointMake(xPoint, yPoint);
        NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:center];
        self.currentCell = (AlivcTemplateCell *)[self.collectionView cellForItemAtIndexPath:path];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGFloat yPoint = scrollView.contentOffset.y + scrollView.frame.size.height / 2;
    CGFloat xPoint = scrollView.frame.size.width / 2;
    CGPoint center = CGPointMake(xPoint, yPoint);
    NSIndexPath *path = [self.collectionView indexPathForItemAtPoint:center];
    AlivcTemplateCell *cell = (AlivcTemplateCell *)[self.collectionView cellForItemAtIndexPath:path];
    if (cell) {
        if (cell != self.currentCell) {
            [self.currentCell reset];
            self.currentCell = cell;
        }
    }
    else {
        [self.currentCell reset];
    }
}

- (void)onEditItemClicked:(AlivcTemplateItem *)item {
    
    MBProgressHUD *loading = [MBProgressHUD showMessage:@"资源下载中..." alwaysInView:self.view];

    NSString *templateTaskPath = [item.loader getTaskPath];
    __weak typeof(self) weakSelf = self;
    [item.loader loadProject:[AlivcTemplateResourceManager projectResourceImport:templateTaskPath reset:NO shouldDownload:YES] completed:^(NSError *error) {
        if (error) {
            [loading replaceWarningMessage:[NSString stringWithFormat:@"加载资源失败：%zd", error.code]];
            [loading hideAnimated:YES afterDelay:3];
        }
        else {
            [loading hideAnimated:YES];
            AlivcTemplateEditorViewController *tevc = [[AlivcTemplateEditorViewController alloc] initWithTemplateTaskPath:templateTaskPath];
            [weakSelf.navigationController pushViewController:tevc animated:YES];
        }
    }];
}

- (void)onExportItemClicked:(AlivcTemplateItem *)item {
    
    NSString *taskPath = [[AlivcTemplateResourceManager exportTemplatePath] stringByAppendingPathComponent:[item.loader getTemplate].title];
    NSString *templateTaskPath = [item.loader getTaskPath];
    
    if ([templateTaskPath hasPrefix:[AlivcTemplateResourceManager localTemplatePath]]) {
        [MBProgressHUD showWarningMessage:@"内置模板，不做导出" inView:self.view];
        return;
    }
    
    AliyunTemplateResourceExport *resourceExport = [AliyunTemplateResourceExport new];
    resourceExport.selfResourceExport = [AlivcTemplateResourceManager templateResourceExport:taskPath];
    resourceExport.projectResourceExport = [AlivcTemplateResourceManager projectResourceExport:taskPath];
    
    MBProgressHUD *loading = [MBProgressHUD showMessage:@"导出中..." alwaysInView:self.view];
    [AliyunTemplateExporter export:taskPath templateTaskPath:templateTaskPath resourceExport:resourceExport completed:^(NSError *error) {
        
        if (error) {
            [loading replaceWarningMessage:[NSString stringWithFormat:@"失败：%@", [error.userInfo objectForKey:NSLocalizedDescriptionKey]]];
        }
        else {
            [loading replaceSuccessMessage:@"导出成功：Documents/com.aliyun.video/template_export"];
        }
        [loading hideAnimated:YES afterDelay:3];
    }];
}

- (void)onUpdateItemClicked:(AlivcTemplateItem *)item {
    AlivcTemplateBuilderViewController *vc = [[AlivcTemplateBuilderViewController alloc] initWithEditorTaskPath:item.loader.getTaskPath isOpen:YES];
    if (vc) {
        __weak typeof(self) weakSelf = self;
        vc.updateComplatedBlock = ^{
            item.loader = [[AliyunTemplateLoader alloc] initWithTaskPath:item.loader.getTaskPath];
            [weakSelf.collectionView reloadData];
        };
        [self.navigationController pushViewController:vc animated:YES];
    }
    else {
        [MBProgressHUD showWarningMessage:@"内置模板，不能更改" inView:self.view];
    }
}

- (void)onCloseBtnClicked:(UIButton *)sender {
    
    [self.navigationController popViewControllerAnimated:YES];
    
}

@end
