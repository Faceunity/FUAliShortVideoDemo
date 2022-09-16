//
//  AlivcPhotoPickerViewController.h
//  Pods
//
//  Created by mengyehao on 2021/11/10.
//



#define P_ScreenWidth  [UIScreen mainScreen].bounds.size.width

#define P_ScreenHeight  [UIScreen mainScreen].bounds.size.height


#define P_RGBToColor(R,G,B)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:1.0]

#define P_rgba(R,G,B,A)  [UIColor colorWithRed:(R * 1.0) / 255.0 green:(G * 1.0) / 255.0 blue:(B * 1.0) / 255.0 alpha:A]


#define P_IS_IPHONEX (([[UIScreen mainScreen] bounds].size.height<812)?NO:YES)
#define P_SafeTop (([[UIScreen mainScreen] bounds].size.height<812) ? 20 : 44)
#define P_SafeBottom (([[UIScreen mainScreen] bounds].size.height<812) ? 0 : 34)

#define P_StatusBarHeight (([[UIScreen mainScreen] bounds].size.height<812) ? 20 : 44)
#define P_NoStatusBarSafeTop (IS_IPHONEX ? 44 : 0)

#define P_KquTabBarHeight  (IS_IPHONEX ? 100 : 0)
