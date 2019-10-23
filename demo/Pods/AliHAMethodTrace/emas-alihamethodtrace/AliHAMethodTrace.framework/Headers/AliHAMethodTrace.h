//
//  AliHAMethodTrace.h
//  AliHAMethodTrace
//
//  Created by hansong.lhs on 2017/10/23.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#ifndef AliHAMethodTrace_h
#define AliHAMethodTrace_h

#define FRAME_COUNT_LIMIT 256
#define PRINT_LOG(msg) do { printf("%s\n", msg); } while(0);

// bionic and glibc both have TEMP_FAILURE_RETRY, but eg Mac OS' libc doesn't.
#ifndef TEMP_FAILURE_RETRY
#define TEMP_FAILURE_RETRY(exp) ({ \
decltype(exp) _rc; \
do { \
_rc = (exp); \
} while (_rc == -1 && errno == EINTR); \
_rc; })
#endif

#endif /* AliHAMethodTrace_h */
