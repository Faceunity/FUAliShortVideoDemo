//
//  ElapsedTimeMeasurer.h
//  AlivcCommon
//
//  Created by coder.pi on 2022/3/10.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ElapsedTimeMeasurer : NSObject
- (void) begin;
- (int64_t) end; // ms; error: < 0
- (int64_t) endShowToast;
@end
