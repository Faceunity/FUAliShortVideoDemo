//
//  AlivcTemplateNodeListView.m
//  AlivcEdit
//
//  Created by Bingo on 2021/11/24.
//

#import "AlivcTemplateNodeListView.h"
#import "AliyunPhotoLibraryManager.h"
#import "AlivcPhotoPickerViewController.h"
#import "AliyunCompositionInfo.h"

@interface AlivcTemplateNodeItem : NSObject

@property (nonatomic, strong) AliyunTemplateNode *node;
@property (nonatomic, strong) UIImage *cover;
@property (nonatomic, assign) NSUInteger index;

@property (nonatomic, copy) void (^refreshBlock)(void);

@end

@implementation AlivcTemplateNodeItem
@end

@interface AlivcTemplateNodeCell : UICollectionViewCell

@property (nonatomic, strong) AlivcTemplateNodeItem *item;
@property (nonatomic, strong) UIImageView *coverView;
@property (nonatomic, strong) UILabel *infoLabel;
@property (nonatomic, strong) UIButton *selectedBtn;
@property (nonatomic, strong) UIImageView *lockView;
@property (nonatomic, strong) UILabel *descLabel;
@end

@implementation AlivcTemplateNodeCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.bounds) - 20, CGRectGetWidth(self.bounds), 20)];
        descLabel.textColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5];
        descLabel.font = [UIFont systemFontOfSize:10];
        descLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:descLabel];
        self.descLabel = descLabel;
        
        UIImageView *coverView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.bounds), CGRectGetMinY(self.descLabel.frame))];
        coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.2];
        coverView.contentMode = UIViewContentModeScaleAspectFill;
        coverView.clipsToBounds = YES;
        [self.contentView addSubview:coverView];
        self.coverView = coverView;
        
        UILabel *infoLabel = [[UILabel alloc] initWithFrame:self.coverView.bounds];
        infoLabel.textColor = [UIColor whiteColor];
        infoLabel.font = [UIFont systemFontOfSize:16];
        infoLabel.textAlignment = NSTextAlignmentCenter;
        infoLabel.numberOfLines = 0;
        infoLabel.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        [self.coverView addSubview:infoLabel];
        self.infoLabel = infoLabel;
        
        UIButton *selectedBtn = [[UIButton alloc] initWithFrame:self.coverView.bounds];
        [selectedBtn setTitle:@"点击编辑" forState:UIControlStateNormal];
        [selectedBtn setTitle:@"" forState:UIControlStateSelected];
        [selectedBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        selectedBtn.titleLabel.font = [UIFont systemFontOfSize:12];
        selectedBtn.backgroundColor = [[UIColor systemPinkColor] colorWithAlphaComponent:0.95];
        selectedBtn.hidden = YES;
        [self.coverView addSubview:selectedBtn];
        self.selectedBtn = selectedBtn;
        
        UIImageView *lockView = [[UIImageView alloc] initWithFrame:self.coverView.bounds];
        lockView.contentMode = UIViewContentModeCenter;
        lockView.image = [AlivcImage imageNamed:@"alivc_lock"];
        lockView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25];
        lockView.hidden = YES;
        [self.coverView addSubview:lockView];
        self.lockView = lockView;
    }
    return self;
}

- (void)updateItem:(AlivcTemplateNodeItem *)item {
    self.item.refreshBlock = nil;
    self.item = item;
    
    BOOL isLock = self.item.node.lock;
//    isLock = YES;
    self.lockView.hidden = !isLock;
    self.infoLabel.hidden = isLock;
    self.selectedBtn.selected = isLock;
    self.coverView.image = self.item.cover;
    self.infoLabel.text = self.item.node.info;
    self.descLabel.text = [NSString stringWithFormat:@"%tu", self.item.index];
    
    __weak typeof(self) weakSelf = self;
    self.item.refreshBlock = ^{
        weakSelf.coverView.image = weakSelf.item.cover;
        weakSelf.infoLabel.text = weakSelf.item.node.info;
    };
}

- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if (selected) {
        self.selectedBtn.hidden = NO;
    }
    else {
        self.selectedBtn.hidden = YES;
    }
}

@end


@interface AlivcTemplateNodeListView () <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) NSMutableArray<AlivcTemplateNodeItem *> *items;
@property (nonatomic, strong) AlivcTemplateNodeItem *currentItem;

@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) UIButton *clipTapBtn;
@property (nonatomic, strong) UIButton *textTapBtn;


@property (nonatomic, copy) void (^selectedNodeBlock)(AliyunTemplateNode * node);
@property (nonatomic, strong) NSMutableDictionary<NSString *, UIImage *> *coverCache;


@end

@implementation AlivcTemplateNodeListView

- (instancetype)initWithFrame:(CGRect)frame withSelectedNodeBlock:(void(^)(AliyunTemplateNode *node))selectedNodeBlock {
    self = [super initWithFrame:frame];
    if (self) {
        self.items = [NSMutableArray array];
        self.selectedNodeBlock = selectedNodeBlock;
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    
    CGFloat width = (CGRectGetWidth(self.bounds) - 16 * 3) / 2;
    UIButton *clipTapBtn = [[UIButton alloc] initWithFrame:CGRectMake(16.0, 0, width, 32)];
    [clipTapBtn setTitle:@"视频编辑" forState:UIControlStateNormal];
    clipTapBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [clipTapBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [clipTapBtn setTitleColor:[UIColor systemPinkColor] forState:UIControlStateSelected];
    [clipTapBtn addTarget:self action:@selector(onClipTapBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:clipTapBtn];
    self.clipTapBtn = clipTapBtn;
    
    UIButton *textTapBtn = [[UIButton alloc] initWithFrame:CGRectMake(width + 16 * 2, 0, width, 32)];
    [textTapBtn setTitle:@"字幕编辑" forState:UIControlStateNormal];
    textTapBtn.titleLabel.font = [UIFont systemFontOfSize:16];
    [textTapBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [textTapBtn setTitleColor:[UIColor systemPinkColor] forState:UIControlStateSelected];
    [textTapBtn addTarget:self action:@selector(onTextTapBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:textTapBtn];
    self.textTapBtn = textTapBtn;
        
    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(80, 100);
    layout.minimumInteritemSpacing = 12.0;
    layout.sectionInset = UIEdgeInsetsMake(0, 24, 0, 24);
    
    self.collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 32+24, CGRectGetWidth(self.bounds), 100) collectionViewLayout:layout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    [self addSubview:self.collectionView];
    [self.collectionView registerClass:[AlivcTemplateNodeCell class] forCellWithReuseIdentifier:@"AlivcTemplateNodeCell"];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.items.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    AlivcTemplateNodeCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"AlivcTemplateNodeCell" forIndexPath:indexPath];
    AlivcTemplateNodeItem *item = [self.items objectAtIndex:indexPath.row];
    [self updateCover:item reset:NO];
    [cell updateItem:item];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    AlivcTemplateNodeItem *item = [self.items objectAtIndex:indexPath.row];
    if (item == self.currentItem) {
        if (!self.currentItem.node.lock) {
            [self onEditItem:item];
        }
    }
    else {
        self.currentItem = item;
        if (self.selectedNodeBlock) {
            self.selectedNodeBlock(item.node);
        }
    }
}

- (void)clearSelectedNode {
    
    self.currentItem = nil;
    [self.collectionView reloadData];
    
    if (self.selectedNodeBlock) {
        self.selectedNodeBlock(nil);
    }
}

- (void)setAliyunEditor:(AliyunTemplateEditor *)aliyunEditor {
    _aliyunEditor = aliyunEditor;
    
    [self onClipTapBtnClicked:self.clipTapBtn];
}

- (void)onClipTapBtnClicked:(UIButton *)sender {
    [self.items removeAllObjects];
    
    NSArray<AliyunTemplateClipNode *> *sortNodes = [[self.aliyunEditor clipNodes] sortedArrayUsingComparator:^NSComparisonResult(AliyunTemplateClipNode *obj1, AliyunTemplateClipNode *obj2) {
        if (obj1.lock && !obj2.lock) {
            return NSOrderedAscending;
        }
        else if (!obj1.lock && obj2.lock) {
            return NSOrderedDescending;
        }
        else if (obj1.timelineIn < obj2.timelineIn) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    
    [sortNodes enumerateObjectsUsingBlock:^(AliyunTemplateClipNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AlivcTemplateNodeItem *item = [AlivcTemplateNodeItem new];
        item.node = obj;
        item.index = idx + 1;
        [self.items addObject:item];
    }];
    self.clipTapBtn.selected = YES;
    self.textTapBtn.selected = NO;
    
    [self clearSelectedNode];
}

- (void)onTextTapBtnClicked:(UIButton *)sender {
    [self.items removeAllObjects];
    
    NSArray<AliyunTemplateCaptionNode *> *sortNodes = [[self.aliyunEditor captionNodes] sortedArrayUsingComparator:^NSComparisonResult(AliyunTemplateCaptionNode *obj1, AliyunTemplateCaptionNode *obj2) {
        if (obj1.lock && !obj2.lock) {
            return NSOrderedAscending;
        }
        else if (!obj1.lock && obj2.lock) {
            return NSOrderedDescending;
        }
        else if (obj1.timelineIn < obj2.timelineIn) {
            return NSOrderedAscending;
        }
        return NSOrderedDescending;
    }];
    [sortNodes enumerateObjectsUsingBlock:^(AliyunTemplateCaptionNode * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        AlivcTemplateNodeItem *item = [AlivcTemplateNodeItem new];
        item.node = obj;
        item.index = idx + 1;
        [self.items addObject:item];
    }];
    self.clipTapBtn.selected = NO;
    self.textTapBtn.selected = YES;
    
    [self clearSelectedNode];
}

- (void)onEditItem:(AlivcTemplateNodeItem *)item {
    
    __weak typeof(self)weakSelf =self;
    if ([item.node isKindOfClass:AliyunTemplateClipNode.class]) {
        AliyunTemplateClipNode *node = (AliyunTemplateClipNode *)item.node;
        AlivcVideoDurationRange timeRange;
        timeRange.min = node.timelineOut - node.timelineIn;
        timeRange.max = timeRange.min + 60 * 60;
        
        AlivcPhotoPickerViewController *vc = [AlivcPhotoPickerViewController new];
        vc.maxSelectCount = 1;
        vc.timeRange = timeRange;
        vc.didClickNextBlock = ^(NSArray<AliyunCompositionInfo *> *infos) {
            [(UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController popViewControllerAnimated:YES];
            if (infos.count > 0) {
                AliyunCompositionInfo *info = infos.firstObject;
                if ([[NSFileManager defaultManager] fileExistsAtPath:info.sourcePath]) {
                    NSLog(@"fileExistsAtPath:updateClipNode");
                }
                int ret = [weakSelf.aliyunEditor updateClipNode:node clipPath:info.sourcePath clipType:info.type == AliyunCompositionInfoTypeVideo ? AliyunClipVideo : AliyunClipImage];
                if (ret == ALIVC_COMMON_RETURN_SUCCESS) {
                    if (weakSelf.selectedNodeBlock) {
                        weakSelf.selectedNodeBlock(node);
                    }
                    [weakSelf updateCover:item reset:YES];
                    if (item.refreshBlock) {
                        item.refreshBlock();
                    }
                }
                else {
                    NSLog(@"替换失败: %d", ret);
                }
            }
        };
        [(UINavigationController *)[UIApplication sharedApplication].keyWindow.rootViewController pushViewController:vc animated:YES];
    }
    else
    {
        AliyunTemplateCaptionNode *node = (AliyunTemplateCaptionNode *)item.node;
        NSString *caption = node.captionTrack.text;
        
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"请输入文字" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action){
            UITextField *titleTextField = alertController.textFields.firstObject;
            NSLog(@"%@", titleTextField.text);
            if (titleTextField.text.length > 0) {
                int ret = [weakSelf.aliyunEditor updateCaptionNode:node text:titleTextField.text];
                if (ret == ALIVC_COMMON_RETURN_SUCCESS) {
                    if (weakSelf.selectedNodeBlock) {
                        weakSelf.selectedNodeBlock(node);
                    }
                    if (item.refreshBlock) {
                        item.refreshBlock();
                    }
                }
                else {
                    NSLog(@"替换失败: %d", ret);
                }
            }
        }]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil]];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.text = caption;
        }];
        [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertController animated:true completion:nil];
    }
    
}

- (void)updateCover:(AlivcTemplateNodeItem *)item reset:(BOOL)reset {
    if (! [item.node isKindOfClass:AliyunTemplateClipNode.class]) {
        return;
    }
    
    if (item.cover && !reset) {
        return;
    }
    
    if (!self.coverCache) {
        self.coverCache = [NSMutableDictionary dictionary];
    }
    
    AliyunTemplateClipNode *clipNode = (AliyunTemplateClipNode *)item.node;
    if (reset) {
        [self.coverCache removeObjectForKey:clipNode.nodeKey];
    }
    NSString *path = clipNode.clip.source.path;
    UIImage *cover = nil;
    if (clipNode.clip.source.type == AEPSourceType_Video) {
        cover = [self thumbnailWithVideoPath:path outputSize:CGSizeMake(200, 200) startTime:clipNode.timelineIn];
    }
    else if (clipNode.clip.source.type == AEPSourceType_Image) {
        cover = [UIImage imageWithContentsOfFile:path];
    }
    if (cover) {
        [self.coverCache setObject:cover forKey:clipNode.nodeKey];
    }
    item.cover = cover;
}

- (UIImage *)thumbnailWithVideoPath:(NSString *)videoPath outputSize:(CGSize)outputSize startTime:(NSTimeInterval)startTime {
    AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoPath]];
    AVAssetImageGenerator *_generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    _generator.maximumSize = outputSize;
    _generator.appliesPreferredTrackTransform = YES;
    _generator.requestedTimeToleranceAfter = kCMTimeZero;
    _generator.requestedTimeToleranceBefore = kCMTimeZero;
    CMTime time = CMTimeMake(startTime * 1000, 1000);
    CGImageRef image = [_generator copyCGImageAtTime:time
                                          actualTime:NULL
                                               error:nil];
    UIImage *picture = [UIImage imageWithCGImage:image];
    CGImageRelease(image);
    return picture;
}

@end
