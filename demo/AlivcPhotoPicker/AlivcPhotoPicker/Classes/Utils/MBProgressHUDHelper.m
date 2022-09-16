//
//  MBProgressHUDHelper.m
//  AlivcPhotoPicker
//
//  Created by mengyehao on 2021/11/11.
//

#import "MBProgressHUDHelper.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import "AlivcPhotoPickerBundle.h"

static CGFloat kSecondPerText = 0.16;


@implementation MBProgressHUDHelper


+ (void)showHUDAddedTo:(UIView *)view animated:(BOOL)animated
{
     [MBProgressHUD showHUDAddedTo:view animated:animated];
}

+ (void)hideHUDForView:(UIView *)view animated:(BOOL)animated {
    [MBProgressHUD hideHUDForView:view animated:animated];

}

+ (UIImage *)warningImage{
    return [AlivcPhotoPickerBundle imageNamed:@"avcPromptWarning"];
}

+ (UIImage *)sucessImage{
    return [AlivcPhotoPickerBundle imageNamed:@"avcPromptSuccess"];
}


+ (void)showMessage:(NSString *)message image:(UIImage *)image inView:(UIView *)view{
    
    MBProgressHUD  *hud =[MBProgressHUD showHUDAddedTo:view animated:true];
    
    
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[UIImageView alloc]initWithImage:image];
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    hud.contentColor = [UIColor whiteColor];
    hud.label.numberOfLines = 5;
    hud.label.text = message;
    hud.userInteractionEnabled = NO;
    
    
    [hud hideAnimated:true afterDelay:[self showTimeWithMessage:message]];
}

+ (CGFloat )showTimeWithMessage:(NSString *)message{
    if (message) {
        CGFloat time = message.length * kSecondPerText;
        
        if (time > 5) {
            time = 5;
        }
        return time;
    }
    return 0;
}

+ (void)showSucessMessage:(NSString *)message inView:(UIView *)view{
    [self showMessage:message image:[self sucessImage] inView:view];
}

+ (void)showWarningMessage:(NSString *)message inView:(UIView *)view{
    [self showMessage:message image:[self warningImage] inView:view];
}

+ (void)showMessage:(NSString *)message inView:(UIView *)view{
    if (view) {
        dispatch_async(dispatch_get_main_queue(), ^{
            MBProgressHUD  *hud =[MBProgressHUD showHUDAddedTo:view animated:true];
            hud.mode = MBProgressHUDModeText;
            hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
            hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
            hud.contentColor = [UIColor whiteColor];
            hud.label.numberOfLines = 10;
            hud.label.text = message;
            [hud hideAnimated:true afterDelay:[self showTimeWithMessage:message]];
        });
    }
}

+ (MBProgressHUD *)showMessage:(NSString *)message alwaysInView:(UIView *)view{
    MBProgressHUD  *hud =[MBProgressHUD showHUDAddedTo:view animated:true];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.bezelView.style = MBProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    hud.contentColor = [UIColor whiteColor];
    hud.label.numberOfLines = 10;
    hud.label.text = message;
    return hud;
}

@end
