//
//  MBProgressHUDHelper.h
//  AlivcPhotoPicker
//
//  Created by mengyehao on 2021/11/11.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface MBProgressHUDHelper : NSObject

+ (void)showMessage:(NSString *)message image:(UIImage *)image inView:(UIView *)view;

+ (void)showSucessMessage:(NSString *)message inView:(UIView *)view;

+ (void)showWarningMessage:(NSString *)message inView:(UIView *)view;

+ (void)showMessage:(NSString *)message inView:(UIView *)view;


+ (void)showHUDAddedTo:(UIView *)view animated:(BOOL)animated;

+ (void)hideHUDForView:(UIView *)view animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
