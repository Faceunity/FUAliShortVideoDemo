//
//  sampling_thread.h
//  Pods
//
//  Created by hansong.lhs on 2017/7/3.
//
//

#ifndef sampling_h
#define sampling_h

#include <mach/mach.h>

namespace instrument {
    
    // sampling parameter
    struct SamplingParameter {
        
        // sampling interval in us
        int sampleing_interval_;
        
        // sampling callback on each thread
        void (*sampling_callback_)(thread_t thread);
        
    };
    
    class SamplingThread final {
        
    public:
        
        // start sampling thread with callback
        static void* RunSamplingThread(void* arg);
        
        // stop sampling
        static void StopSampling();
        
        // get current stack trace of given thread
        static void GetBackTrace(thread_t thread, uintptr_t *backtrace, int *count);
        
    };
    
}

#endif /* sampling_h */
