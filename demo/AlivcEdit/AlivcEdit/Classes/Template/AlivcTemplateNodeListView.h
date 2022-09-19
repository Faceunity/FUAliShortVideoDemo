//
//  AlivcTemplateNodeListView.h
//  AlivcEdit
//
//  Created by Bingo on 2021/11/24.
//

#import <UIKit/UIKit.h>
#import <AliyunVideoSDKPro/AliyunVideoSDKPro.h>

@interface AlivcTemplateNodeListView : UIView

@property (nonatomic, strong) AliyunTemplateEditor *aliyunEditor;


- (instancetype)initWithFrame:(CGRect)frame withSelectedNodeBlock:(void(^)(AliyunTemplateNode *node))selectedNodeBlock;

- (void)clearSelectedNode;

@end
