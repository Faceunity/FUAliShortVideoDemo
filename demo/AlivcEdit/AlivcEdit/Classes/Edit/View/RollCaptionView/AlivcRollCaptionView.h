//
//  AlivcRollCaptionView.h
//  AlivcCommon
//
//  Created by aliyun on 2021/3/9.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AlivcRollCaptionViewDelegate <NSObject>
@optional

-(void)didRollCaptionSelColor:(UIColor*)color;

-(void)didRollCaptionSelFont:(NSString*)fontName;

-(void)didRollCaptionClickWordsBtn;

-(void)didRollCaptionClickFinishBtn;

-(void)didRollCaptionClickClearBtn;

@end

@interface AlivcRollCaptionView : UIView

@property (nonatomic, weak) id<AlivcRollCaptionViewDelegate> delegate;
@property (nonatomic,strong,nullable) NSMutableArray *wordList;

-(void)showSubView:(BOOL)isShow;

@end

NS_ASSUME_NONNULL_END
