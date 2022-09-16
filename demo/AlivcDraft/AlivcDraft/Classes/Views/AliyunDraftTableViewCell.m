//
//  AliyunDraftTableViewCell.m
//  AlivcDraft
//
//  Created by coder.pi on 2021/7/9.
//

#import "AliyunDraftTableViewCell.h"
#import "AliyunDraftBundle.h"
#import "AliyunDraftInfo.h"
#import "AliyunCloudDraftModel.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface AliyunDraftTableViewCell () <AliyunDraftInfoDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *coverImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *modifyTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *durationLabel;
@property (weak, nonatomic) IBOutlet UIButton *downloadBtn;
@property (weak, nonatomic) IBOutlet UIImageView *syncOKIcon;

@property (nonatomic, assign) BOOL hasAlreadySync;
@end

@implementation AliyunDraftTableViewCell

static NSString * s_formatDuration(NSTimeInterval duration)
{
    int tmp = duration;
    int sec = tmp % 60;
    tmp /= 60;
    int min = tmp % 60;
    tmp /= 60;
    if (tmp > 0) {
        return [NSString stringWithFormat:@"%02d:%02d:%02d", tmp, min, sec];
    }
    return [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

static NSString * s_formatSize(size_t size)
{
    if (size < 1024) {
        return [NSString stringWithFormat:@"%zuK", size];
    }
    return [NSString stringWithFormat:@"%zuM", size / 1024];
}

- (void) awakeFromNib
{
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.hasAlreadySync = NO;
    self.coverImageView.contentMode = UIViewContentModeScaleAspectFill;
}

- (void) updateModifyTime {
    if (_type != AliyunDraftType_Cloud) {
        _modifyTimeLabel.text = [NSString stringWithFormat:@"更新于 %@", _draft.modifiedTime];
    } else {
        AliyunCloudDraftModel *cloudDraft = (AliyunCloudDraftModel *)_draft;
        _modifyTimeLabel.text = [NSString stringWithFormat:@"备份于 %@", cloudDraft.backupTime];
    }
}

- (void) setDraft:(AliyunDraftInfo *)draft
{
    if (_draft != draft) {
        if (_draft.delegate == self) {
            _draft.delegate = nil;
        }
        _draft = draft;
        _draft.delegate = self;
    }

    if (_draft.cover.isLocal) {
        _coverImageView.image = [UIImage imageWithContentsOfFile:_draft.cover.path];
    } else {
        UIImage *img = [AliyunDraftBundle imageNamed:@"alivcicon"];
        if (_draft.cover.URL.length > 0) {
            [_coverImageView sd_setImageWithURL:[NSURL URLWithString:_draft.cover.URL] placeholderImage:img];
        } else {
            _coverImageView.image = img;
        }
    }
    
    [self updateModifyTime];
    _titleLabel.text = _draft.title;
    _sizeLabel.text = s_formatSize(_draft.size);
    _durationLabel.text = s_formatDuration(_draft.duration);
    self.hasAlreadySync = (_draft.state == AliyunDraftState_Synced);
}

- (void) setType:(AliyunDraftType)type
{
    _type = type;
    _downloadBtn.hidden = (type != AliyunDraftType_Cloud);
    _syncOKIcon.hidden = (type != AliyunDraftType_Local);
    [self updateModifyTime];
}

- (void) setHasAlreadySync:(BOOL)hasAlreadySync
{
    _hasAlreadySync = hasAlreadySync;
    _syncOKIcon.alpha = hasAlreadySync ? 1.0 : 0.0;
    _downloadBtn.alpha = hasAlreadySync ? 0.0 : 1.0;
}

- (IBAction)moreDidPressed:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(onAliyunDraftTableViewCellDidClickMore:)]) {
        [_delegate onAliyunDraftTableViewCellDidClickMore:self];
    }
}

- (IBAction)downloadDidPressed:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(onAliyunDraftTableViewCellDidClickDownload:)]) {
        [_delegate onAliyunDraftTableViewCellDidClickDownload:self];
    }
}

// MARK: - AliyunDraftInfoDelegate
- (void) onAliyunDraftInfo:(AliyunDraftInfo *)info stateDidChange:(AliyunDraftState)state {
    self.hasAlreadySync = (state == AliyunDraftState_Synced);
}
@end
