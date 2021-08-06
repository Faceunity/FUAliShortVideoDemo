//
//  UIDevice+AlivcInfo.m
//  AlivcCommon
//
//  Created by mengyehao on 2021/2/2.
//

#import "UIDevice+AlivcInfo.h"
#import <sys/utsname.h>


@implementation UIDevice (AlivcInfo)

+ (int)iphoneDeviceCode
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *phoneType = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    if ([phoneType hasPrefix:@"iPad"]) {
        return 0;
    }
    NSRange range = [phoneType rangeOfString:@","];
    
    int code = 0;
    NSRange range1 = NSMakeRange(6, range.location - 6);
    if (range1.length != NSNotFound) {
        NSString *subStr = [phoneType substringWithRange:range1];
        code = [subStr intValue];
    }
    
    return code;
}

@end
