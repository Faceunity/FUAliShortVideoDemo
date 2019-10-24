//
//  TBZlibUtils.h
// 
//
//  Created by Alvin on 4/30/13.
//
//

#ifndef TBRestZlibUtils_h
#define TBRestZlibUtils_h

#import <Foundation/Foundation.h>
#include <zlib.h>

@interface TBRestZlibUtils : NSObject

+ (NSData *)gzipInflate:(NSData *)data;

+ (NSData *)gzipDeflate:(NSData *)data;
@end

#endif
