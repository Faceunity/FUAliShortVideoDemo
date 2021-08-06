//
//  AlivcRollCaptionCell.h
//  AlivcCommon
//
//  Created by aliyun on 2021/3/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class AliyunRollCaptionItemStyle;

@interface AlivcRollCaptionCell : UITableViewCell

@property(nonatomic,strong)UIImageView *dotImg;
@property(nonatomic,strong)UILabel *wordLab;
@property(nonatomic,strong)UITextField *wordField;
@property(nonatomic,strong)UIButton *editBtn;

@property(nonatomic,strong)AliyunRollCaptionItemStyle *model;
@property(nonatomic,assign) NSInteger idx;

@property (nonatomic,copy) void (^didChangeTextFinish)(NSInteger idx,NSString *txt);

-(void)buildModel:(AliyunRollCaptionItemStyle*)model isSel:(BOOL)isSel idx:(NSInteger)idx;

@end

NS_ASSUME_NONNULL_END
