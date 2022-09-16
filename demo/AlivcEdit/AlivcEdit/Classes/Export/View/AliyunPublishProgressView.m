//
//  AliyunPublishProgressView.m
//  qusdk
//
//  Created by Worthy on 2017/11/9.
//  Copyright © 2017年 Alibaba Group Holding Limited. All rights reserved.
//

#import "AliyunPublishProgressView.h"
#import "AVC_ShortVideo_Config.h"

typedef NS_ENUM(NSUInteger, __State) {
    __State_Loading,
    __State_Success,
    __State_Fail,
};

@interface AliyunPublishProgressView ()
@property(nonatomic, strong) UILabel *topLable;
@property(nonatomic, strong) UILabel *middleLable;
@property(nonatomic, strong) UILabel *bottomLable;

@property(nonatomic, strong) UILabel *centerLabel;
@property(nonatomic, strong) UIImageView *finishImageView;

@property(nonatomic, strong) UIButton *exportBtn;
@property(nonatomic, strong) UIButton *exportAndUploadBtn;

@property(nonatomic, assign) __State exportState;
@property(nonatomic, assign) __State uploadState;
@end

@implementation AliyunPublishProgressView

- (instancetype)initWithFrame:(CGRect)frame {
  self = [super initWithFrame:frame];
  if (self) {
    [self setupExportSelectedBtns];
  }
  return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
  self = [super initWithCoder:aDecoder];
  if (self) {
      [self setupExportSelectedBtns];
  }
  return self;
}

- (UIButton *)createBtn:(NSString *)title
               position:(CGPoint)pos
              onClicked:(SEL)clickedCB {
    
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 100, 32)];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    btn.backgroundColor = UIColor.systemPinkColor;
    btn.layer.cornerRadius = 6;
    btn.titleLabel.font = [UIFont systemFontOfSize:16];
    [btn addTarget:self action:clickedCB forControlEvents:UIControlEventTouchUpInside];
    btn.center = pos;
    [self addSubview:btn];
    return btn;
}

- (void)setupExportSelectedBtns {
    CGSize size = self.bounds.size;
    self.exportBtn = [self createBtn:@"合成"
                            position:CGPointMake(size.width * 0.5, size.height * 0.4)
                           onClicked:@selector(exportDidPressed:)];
    self.exportAndUploadBtn = [self createBtn:@"边合成边上传"
                                     position:CGPointMake(size.width * 0.5, size.height * 0.6)
                                    onClicked:@selector(exportAndUploadPressed:)];
}

- (void)removeExportBtns {
    [self.exportBtn removeFromSuperview];
    [self.exportAndUploadBtn removeFromSuperview];
    self.exportBtn = nil;
    self.exportAndUploadBtn = nil;
}

- (void) setExportAndUpload:(BOOL)exportAndUpload {
    _exportAndUpload = exportAndUpload;
    [self removeExportBtns];
    if (!_topLable) {
        [self setupTopViews];
    }
}

- (void) exportDidPressed:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(onAliyunPublishProgressViewDidExport:)]) {
        [_delegate onAliyunPublishProgressViewDidExport:self];
    }
}

- (void) exportAndUploadPressed:(UIButton *)btn {
    if ([_delegate respondsToSelector:@selector(onAliyunPublishProgressViewDidExportAndUpload:)]) {
        [_delegate onAliyunPublishProgressViewDidExportAndUpload:self];
    }
}

- (NSString *) stateDesc {
    if (!_exportAndUpload) {
        if (_exportState == __State_Loading) {
            return NSLocalizedString(@"视频合成中", nil);
        }
        if (_exportState == __State_Success) {
            return NSLocalizedString(@"合成成功", nil);
        }
        return NSLocalizedString(@"合成失败", nil);
    }
    
    if (_exportState == __State_Loading) {
        return NSLocalizedString(@"视频合并并上传中", nil);
    }
    if (_exportState == __State_Fail) {
        return NSLocalizedString(@"合成失败", nil);
    }
    if (_uploadState == __State_Loading) {
        return NSLocalizedString(@"合成成功，正在上传视频...", nil);
    }
    if (_uploadState == __State_Fail) {
        return NSLocalizedString(@"合成成功，上传失败", nil);
    }
    return NSLocalizedString(@"合成成功，上传成功", nil);
}

static NSString * s_formatSize(size_t size, size_t *unit) {
    NSArray<NSString *> *Units = @[@"B", @"KB", @"MB", @"GB"];
    size_t target = 1024;
    for (int i = 0; i < Units.count; ++i) {
        if (size <= target) {
            *unit = target/1024;
            return Units[i];
        }
        target *= 1024;
    }
    return @"";
}

- (void) updateUploadProgress {
    if (_exportState == __State_Success && _uploadState == __State_Loading) {
        size_t total = MAX(_totalSize, _uploadedSize);
        size_t cur = _uploadedSize;
        size_t progress = cur * 100 / total;
        size_t unit = 1;
        NSString *unitStr = s_formatSize(total, &unit);
        _middleLable.text = [NSString stringWithFormat:@"合成成功，正在上传视频 %zu%%(%zu%@ / %zu%@)",
                             progress, cur/unit, unitStr, total/unit, unitStr];
    }
}

- (void) setUploadedSize:(NSUInteger)uploadedSize {
    _uploadedSize = uploadedSize;
    [self updateUploadProgress];
}

- (void) setTotalSize:(NSUInteger)totalSize {
    _totalSize = totalSize;
    [self updateUploadProgress];
}

- (void)setupTopViews {
  CGFloat width = CGRectGetWidth(self.frame);
  CGFloat height = CGRectGetHeight(self.frame);
  self.backgroundColor = rgba(27, 33, 51, 0.50);
  _topLable =
      [[UILabel alloc] initWithFrame:CGRectMake(0, height / 2 - 40, width, 24)];
  _topLable.font = [UIFont boldSystemFontOfSize:24.f];
  _topLable.textColor = [UIColor whiteColor];
  _topLable.textAlignment = NSTextAlignmentCenter;
  _topLable.text = NSLocalizedString(@"我的视频" , nil);
  [self addSubview:_topLable];

  _middleLable =
      [[UILabel alloc] initWithFrame:CGRectMake(0, height / 2 - 5, width, 22)];
  _middleLable.font = [UIFont systemFontOfSize:16.f];
  _middleLable.textColor = [UIColor whiteColor];
  _middleLable.textAlignment = NSTextAlignmentCenter;
    _middleLable.text = [self stateDesc];
  [self addSubview:_middleLable];

  _bottomLable =
      [[UILabel alloc] initWithFrame:CGRectMake(0, height / 2 + 18, width, 18)];
  _bottomLable.font = [UIFont systemFontOfSize:12.f];
  _bottomLable.textColor = rgba(188, 188, 188, 1);
  _bottomLable.textAlignment = NSTextAlignmentCenter;
  _bottomLable.text = NSLocalizedString(@"请不要关闭应用" , nil);
  [self addSubview:_bottomLable];

  _finishImageView = [[UIImageView alloc]
      initWithFrame:CGRectMake((width - 26) / 2, height / 2 - 40, 26, 26)];
  _finishImageView.image = [AliyunImage imageNamed:@"icon_composite_success"];
  _finishImageView.hidden = YES;
  [self addSubview:_finishImageView];
}

- (void)setProgress:(CGFloat)progress {
  _topLable.text = [NSString stringWithFormat:@"%d%%", (int)(progress * 100)];
    _middleLable.text = [self stateDesc];
  _bottomLable.text = NSLocalizedString(@"请不要关闭应用" , nil);
  _topLable.hidden = NO;
  _middleLable.hidden = NO;
  _bottomLable.hidden = NO;
  _finishImageView.hidden = YES;
}
- (void)markAsExportFinihed {
    _exportState = __State_Success;
    _middleLable.text = [self stateDesc];
  _topLable.hidden = YES;
  _middleLable.hidden = NO;
    _bottomLable.hidden = (!_exportAndUpload || _uploadState != __State_Loading);
    _finishImageView.hidden = NO;
}
- (void)markAsUploadFinished {
    _uploadState = __State_Success;
    _middleLable.text = [self stateDesc];
}
- (void)markAsUploadFail {
    _uploadState = __State_Fail;
    _middleLable.text = [self stateDesc];
}
- (void)markAsExportFailed {
    _exportState = __State_Fail;
  _finishImageView.image = [AliyunImage imageNamed:@"icon_composite_fail"];
    _middleLable.text = [self stateDesc];
  _bottomLable.text = NSLocalizedString(@"请返回编辑稍后再试", nil);
  _topLable.hidden = YES;
  _middleLable.hidden = NO;
  _bottomLable.hidden = NO;
  _finishImageView.hidden = NO;
}

@end
