//
//  AlivcTemplateBuilderViewController.h
//  AlivcEdit
//
//  Created by Bingo on 2021/11/30.
//

#import <UIKit/UIKit.h>

@interface AlivcTemplateBuilderViewController : UIViewController

- (instancetype)initWithEditorTaskPath:(NSString *)taskPath isOpen:(BOOL)isOpen;

@property (nonatomic, copy) void (^updateComplatedBlock)(void);

@end
