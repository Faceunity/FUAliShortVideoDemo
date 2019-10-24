//
//  trace_file.h
//  AliHALogEngine
//
//  Document and protocl: https://lark.alipay.com/aliapm-mobile/design/protocol
//
//  TraceFile defined the file format and manage the file protocols. TraceFile record the client event sequencely and guarantee the consistency,
//
//  Created by hansong.lhs on 2017/7/11.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#ifndef trace_file_h
#define trace_file_h

#include <stdint.h>
#include <stdlib.h>
#include <map>
#include <thread>
#include <vector>
#include <string>
#include <mutex>
#include <condition_variable>
#include <sstream>

namespace instrument {
    
    static const char*    kTraceHotDataTrimName       = "hotdata.trim.trace";
    
    class TraceFile final {
        
    public:
        
        /**
         * initialize trace environment
         */
        static bool Init(const char* session_dir,
                         uint32_t buffer_size,
                         uint64_t app_start_time,
                         std::map<const char*, const char*> app_info_properties,
                         std::map<const char*, const char*> device_info_properties,
                         std::map<const char*, const char*> type_descriptors);
        
        /**
         * trim mmapped data by data length(first four bytes)
         */
        static void FlushCachedData(const char* session_dir);

        // append data with no body
        static void Append(uint16_t type, uint64_t time);
        
        // append data with additional data(double)
        static void Append(uint32_t type, uint64_t time, float params[], uint16_t param_size);
        
        // append data with string body
        static void Append(uint16_t type, uint64_t time, const char* data);
        
        // append data with string body and additional data(double)
        static void Append(uint16_t type, uint64_t time, const char* data, float params[], uint16_t param_size);
        
        // append data with string body and desc
        static void Append(uint16_t type, uint64_t time, const char* data, const char* desc);
        
        // append data with string body and additional data(double)
        static void Append(uint16_t type, uint64_t time, const char* data, const char* desc, float params[], uint16_t param_size);
        
        // append raw data
        static void Append(uint16_t type, uint64_t time, uint8_t* data, uint32_t size);
        
        ~TraceFile();

    private:
        
        // append data with no body
        void PrivateAppend(uint16_t type, uint64_t time);
        
        // append data with additional data(double)
        void PrivateAppend(uint32_t type, uint64_t time, float params[], uint16_t param_size);
        
        // append data with string body
        void PrivateAppend(uint16_t type, uint64_t time, const char* data);
        
        // append data with string body and additional data(double)
        void PrivateAppend(uint16_t type, uint64_t time, const char* data, float params[], uint16_t param_size);
        
        // append data with string body and desc
        void PrivateAppend(uint16_t type, uint64_t time, const char* data, const char* desc);
        
        // append data with string body and additional data(double)
        void PrivateAppend(uint16_t type, uint64_t time, const char* data, const char* desc, float params[], uint16_t param_size);
        
        // append raw data
        void PrivateAppend(uint16_t type, uint64_t time, uint8_t* data, uint32_t size);
        
    private:
        
        bool fatal_error_;
        
        // session dir
        std::string session_dir_;
        
        // use mmap or memory buffer
        bool use_mmap_;
        
        // pointer to buffer
        uint8_t* buffer_;
        
        // buffer size
        uint32_t buffer_size_;
        
        // current offset
        uint32_t cur_offset_;
        
        // offset of binary data
        uint32_t binary_offset_;
        
        // overflow boundary
        const uint32_t offset_boundary_;
        
        // start time
        uint64_t start_time_;
        
        // buffer operation mutex
        std::mutex buffer_op_mutex_;
        // dump thread condition variable
        std::condition_variable dump_thread_cv_;
        // dump thread cv mutex
        std::mutex dump_thread_cv_mtx_;

    private:
        
        // constructor
        TraceFile(const char* session_dir, uint32_t buffer_size, uint64_t app_start_time);
        
        // internal append header
        void AppendHeader(uint16_t type, uint64_t time, uint32_t body_size);
        
        // internal append method
        void AppendString(const char *data, uint32_t length);
        
        // check whether buffer is overflowed or not
        bool CheckBufferOverflow();
        
        // looper to check buffer and dump to file
        void AsyncLoopAndDump();
        
        // wait until buffer overflow
        void WaitUntilBufferOverflow();
        
        // get buffered data
        uint8_t* GetBufferedData(uint32_t *buffered_size);
        
    };
    
}

#endif /* trace_file_h */
