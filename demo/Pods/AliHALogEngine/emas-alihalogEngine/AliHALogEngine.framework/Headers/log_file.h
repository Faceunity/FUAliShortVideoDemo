//
//  log_file.hpp
//  AliHALogEngine
//
//  Created by hansong.lhs on 2017/12/16.
//  Copyright © 2017年 alibaba. All rights reserved.
//

#ifndef log_file_hpp
#define log_file_hpp

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
    
    // File format:
    //
    // Header format: |M|O|T|U|3| AppKey len| AppKey| Src | 加密方式 | 4字节调用日志接口条数| 4字节真实写入文件条数| 4字节写入文件失败条数|
    //
    // Binary Header format:
    //     u4  magic('MOTU')
    //     u2  header length
    //     u8  start time in usec
    //     ... padding to header length
    //
    //
    
    /**
     * Log level
     */
    enum LogLevel { OFF = 0, ErrorLevel = 1, WarnLevel = 2, InfoLevel = 3, DebugLevel = 4 };
    
    class LogFile final {
        
    public:
        
        /**
         * initialize log environment,
         */
        static bool Init(const char* log_dir,
                            uint32_t buffer_size,
                         const char* app_key, uint32_t app_key_length,
                         const char* secret, uint32_t secret_length,
                         const char* secret_sign, uint32_t secret_sign_length,
                         const char* rsa_public_key_md5, uint32_t rsa_public_key_md5_length);
        
        /**
         * set log level
         */
        static void SetLogLevel(LogLevel log_level);
        
        /**
         * append formated log
         * @param log_level log level
         * @param type log type
         * @param module biz module
         * @param time_str absolute time
         * @param content log content
         * @param exception exception
         */
        static void AppendLog(LogLevel log_level, const char* type, const char* module, const char* tag, const char* time_str, const char* content, const char *exception);
        
        /**
         * simply append log with default type, tag and current time_str,
         */
        static void AppendLog(LogLevel log_level, const char* module, const char* content);
        
        /**
         * flush bufferd log before upload log
         */
        static void FlushHotData();
        
        /**
         * delete
         */
        static void DeleteAllLogs();
        
        /**
         * get log file by days
         */
        static std::string GetLogFileName(uint32_t days_to_today);

    private:

        /**
         * set log level
         */
        void PrivateSetLogLevel(LogLevel log_level);
        
        /**
         * append formated log
         * @param log_level log level
         * @param type log type
         * @param module biz module
         * @param time_str absolute time
         * @param content log content
         * @param exception exception 
         */
        void PrivateAppendLog(LogLevel log_level, const char* type, const char* module, const char* tag, const char* time_str, const char* content, const char* exception);
        
        /**
         *
         * simply append log with default type, tag and current time_str,
         */
        void PrivateAppendLog(LogLevel log_level, const char* module, const char* content);
        
        /**
         * flush bufferd log before upload log
         */
        void PrivateFlushHotData();
        
        /**
         * delete
         */
        void PrivateDeleteAllLogs();
        
        /**
         * dealloc method
         */
        ~LogFile();
        
    private:
        
        // constructor
        LogFile(const char* log_dir,
                uint32_t buffer_size,
                const char* app_key, uint32_t app_key_length,
                const char* secret, uint32_t secret_length,
                const char* secret_sign, uint32_t secret_sign_length,
                const char* rsa_public_key_md5, uint32_t rsa_public_key_md5_length);
       
        // initialize mmap cache
        void InitCache();
        
        /**
         * check log for:
         * 1) write log header
         * 2) check log size
         */
        void CheckLog();
        
        /**
         * delete expired data
         */
        void DeleteExpiredData();
        
        /**
         * write log header
         */
        void GenerateLogHeader(uint8_t *header_buffer, uint32_t *header_length);
       
        /**
         * write secret part
         */
        void WriteLogSecretBlock();
        
        // check whether buffer is overflowed or not
        bool CheckBufferOverflow();
        
        // WaitUntilBufferOverflow
        void WaitUntilBufferOverflow();
        
        // looper to check buffer and dump to file
        void AsyncLoopAndDump();
        
        /**
         * flush bufferd(mmaped) log to file on startup
         */
        void FlushCachedData();
        
        // get buffered data
        uint8_t* GetBufferedData(uint32_t* buffered_size);
        
    private:
        
        bool fatal_error_;
        
        // use mmap of not
        bool use_mmap_;
        
        // random secret and length of secret
        char* secret_;
        const uint32_t secret_length_;
        
        // appkey and appkey length
        char* app_key_;
        const uint32_t app_key_length_;
        
        // encrypt secret(random string + rsa public key sign) and secret-sign length
        char* secret_sign_;
        const uint32_t secret_sign_length_;
        
        // rsa public key md5 and length
        char* rsa_public_key_md5_;
        const uint32_t rsa_public_key_md5_length_;

        // log level
        LogLevel log_level_;
        
        // log storage directory
        const std::string log_dir_;
        
        // data file name of today
        const std::string today_log_file_name_;
        
        // pointer to buffer
        uint8_t* buffer_;
        
        // buffer size
        uint32_t buffer_size_;
        
        // current offset
        uint32_t cur_offset_;
        
        // overflow boundary
        const uint32_t offset_boundary_;
        
        // buffer operation mutex
        std::mutex buffer_op_mutex_;
        // dump thread condition variable
        std::condition_variable dump_thread_cv_;
        // dump thread cv mutex
        std::mutex dump_thread_cv_mtx_;
        
        // log counter
        uint32_t log_index_;
        
    };
    
}

#endif /* log_file_hpp */
