//
//  ElapsedTimeMeasurer.m
//  AlivcCommon
//
//  Created by coder.pi on 2022/3/10.
//

#import "ElapsedTimeMeasurer.h"
#import <mach/mach_time.h>
#import "MBProgressHUD+AlivcHelper.h"

@interface ElapsedTimeMeasurer()
@property (nonatomic, assign) uint64_t beginTime;
@end

@implementation ElapsedTimeMeasurer
- (void) begin
{
    _beginTime = mach_absolute_time();
}

- (int64_t) end
{
    if (_beginTime == 0)
    {
        return -1;
    }
    
    mach_timebase_info_data_t info;
    if (mach_timebase_info(&info) != KERN_SUCCESS) {
        return -1;
    }
    
    uint64_t cur = mach_absolute_time();
    uint64_t elapsed = cur - _beginTime;
    uint64_t nanos = elapsed * info.numer / info.denom;
    return nanos / NSEC_PER_MSEC;
}

- (int64_t) endShowToast
{
    int64_t ms = [self end];
    if (ms < 0)
    {
        return ms;
    }

    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (!window) {
        window = UIApplication.sharedApplication.windows.firstObject;
    }
    if (!window) {
        return ms;
    }
    
    NSString *msg = [NSString stringWithFormat:@"耗时：%.03f秒", ms/1000.0];
    [MBProgressHUD showMessage:msg inView:window];
    return ms;
}

@end
