//
//  AlivcTemplateEditorViewController.h
//  AlivcEdit
//
//  Created by Bingo on 2021/11/24.
//

#import <UIKit/UIKit.h>

@interface AlivcTemplateEditorViewController : UIViewController

- (instancetype)initWithTemplateTaskPath:(NSString *)templateTaskPath;  // 通过指定的模板，创建一个工程
- (instancetype)initWithTaskPath:(NSString *)taskPath;  // 打开一个已有的模板工程

@end
