//
//  trace.h
//  iOS method trace(inspired by android method trace)
//
//  Created by hansong.lhs on 2016/12/23.
//  Copyright © 2016年 hansong.lhs. All rights reserved.
//

#ifndef trace_h
#define trace_h

#include <mach/mach.h>
#include <iostream>

#include "fd_file.h"
#include "light_hashmap.h"
#include "AliHAMethodTrace.h"

namespace instrument {
    
    // method event
    enum MethodTraceEvent {
        kMethodEntered = 0x00,
        kMethodExited = 0x01,
        kMethodUnwind = 0x02,
        kMethodInject = 0x03
    };
    
    // thread data
    typedef struct ThreadData {
        
        unsigned int thread_id; // thread id(different from thread number)
        char thread_name[10]; // thread name(would be empty if thread name is not set by calling pthread_setname_np explicitly)
        uintptr_t last_stack_trace[FRAME_COUNT_LIMIT]; // ponts to last stack trace
        uint8_t num_frames_of_last_stack_trace; // number of last stack trace
        
    } ThreadData;
    
    // event data
    typedef struct EventData {
        
        char event_name[256];
    } EventData;
    
    class Trace 
    {
        
    public:
        // start method tracing.
        static void Start(int trace_fd, int buffer_size, int sampling_interval_us, bool use_mmap);
        
        // stop method tracing.
        static void Stop();
        
        static void InjectEvent(const char *event);
        
    private:
        
        File* trace_file_; // trace file stream
        
        int64_t trace_start_time_; // trace start time
        
        uint8_t *buffer_; // trace data buffer
        
        const bool use_mmap_; // trace stored by memory or mmap
       
        const int buffer_size_; // buffer size
        
        int32_t header_data_start_position_; // header information start position
        
        int32_t trace_data_start_position_; // trace data start position
        
        int32_t current_offset_; // current buffer cursor
        
        bool overflow_; // buffer overflowed or not
        
        map_t thread_map_; // store all threads
        
        ThreadData *thread_data_slots_; // points to thread data slots array
        
        int cur_thread_slot_; // current thread slot
        
        map_t method_map_; // points to method map
        
        EventData *event_data_slots_; // points to event array
        
        int cur_event_slot_; // current event slot
        
        explicit Trace(File* trace_file, int buffer_size, bool use_mmap);
        
        // get thread stack frame samples
        static void GetSample(thread_t thread);
        
        // dump all thread list
        void DumpThreadList(std::ostringstream &os);
        
        // dump method list
        void DumpMethodList(std::ostringstream &os);
        
        // read clock diff
        void ReadClocks(thread_t thread, uint32_t *thread_clock_diff, uint32_t *wall_clock_diff);
        
        // compare and merge call stack
        void CompareAndMergeStackTrace(thread_t thread, uintptr_t *stack_trace, int num_frames);
        
        // log method event
        void LogMethodTraceEvent(thread_t thread, uintptr_t return_address, uint32_t thread_clock_diff, uint32_t wall_clock_diff, MethodTraceEvent event);
        
        // inject event
        void AppendEvent(const char * event);
        
        // generate trace header
        std::string GenerateTraceHeader();
        
        // finish method tracing and flush data to file
        void FinishTracing();
        
    };
    
}

#endif /* trace_hpp */
