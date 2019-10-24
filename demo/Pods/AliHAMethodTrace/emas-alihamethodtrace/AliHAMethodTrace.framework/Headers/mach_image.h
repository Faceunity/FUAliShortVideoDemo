//
//  binaryimage.h
//  TBInstrument
//
//  Created by hansong.lhs on 2017/1/29.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#include <stdio.h>
#include <mach-o/loader.h>
#include <string>

namespace instrument {
    
    uintptr_t firstCmdAfterHeader(const struct mach_header *header);
    
    void printBinaryImages(std::ostringstream &os);
}
