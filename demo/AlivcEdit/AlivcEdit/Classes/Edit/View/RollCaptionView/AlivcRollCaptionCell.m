//
//  AlivcRollCaptionCell.m
//  AlivcCommon
//
//  Created by aliyun on 2021/3/9.
//

#import "AlivcRollCaptionCell.h"

#import <AliyunVideoSDKPro/AliyunRollCaptionItemStyle.h>

@implementation AlivcRollCaptionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self setBackgroundColor:[UIColor clearColor]];
        [self.contentView setBackgroundColor:[UIColor clearColor]];
        
        _dotImg = [[UIImageView alloc] init];
        [self addSubview:_dotImg];
        _dotImg.layer.cornerRadius = 4;
        [_dotImg setBackgroundColor:[UIColor whiteColor]];
        
        _editBtn = [[UIButton alloc] init];
        [_editBtn.titleLabel setFont:[UIFont systemFontOfSize:12]];
        [self addSubview:_editBtn];
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn setTitle:@"完成" forState:UIControlStateSelected];
        [_editBtn addTarget:self action:@selector(clickEidtBtn:) forControlEvents:UIControlEventTouchUpInside];
        
        _wordLab = [[UILabel alloc] init];
        [self addSubview:_wordLab];
        
        _wordField = [[UITextField alloc] init];
        [_wordField setBackgroundColor:[UIColor lightGrayColor]];
        [self addSubview:_wordField];
        _wordField.hidden = YES;
        
        [_editBtn setSelected:NO];
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    _dotImg.frame = CGRectMake(16,(CGRectGetHeight(self.frame)-8)/2, 8, 8);
    _editBtn.frame = CGRectMake(CGRectGetWidth(self.frame)-30-16, (CGRectGetHeight(self.frame)-30)/2, 60, 30);
    _wordLab.frame = CGRectMake(32, (CGRectGetHeight(self.frame)-24)/2, CGRectGetWidth(self.frame)-60-16-8, 24);
    _wordField.frame = CGRectMake(32, (CGRectGetHeight(self.frame)-24)/2, CGRectGetWidth(self.frame)-60-16-8, 24);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)buildModel:(AliyunRollCaptionItemStyle*)model isSel:(BOOL)isSel idx:(NSInteger)idx{
    _model = model;
    _idx = idx;
    [_wordLab setText:model.text];
    [_wordLab setTextColor:model.textColor];
    _editBtn.hidden = !isSel;
    if (isSel) {
        [_dotImg setBackgroundColor:[UIColor blueColor]];
    }else{
        [_dotImg setBackgroundColor:[UIColor whiteColor]];
    }
}

-(void)clickEidtBtn:(UIButton*)btn{
    if (_editBtn.isSelected) {
        [self.wordField resignFirstResponder];
        if (self.didChangeTextFinish) {
            self.didChangeTextFinish(_idx,_wordField.text);
        }
    }else{
        [_wordField setText:_model.text];
        [_wordField setTextColor:_model.textColor];
        [self.wordField becomeFirstResponder];
    }
    _wordField.hidden = _editBtn.isSelected;
    _wordLab.hidden = !_editBtn.isSelected;
    [_editBtn setSelected:!_editBtn.isSelected];
}

@end
