/*
   File:  aliyun_common.h
   
   Framework:  AliyunRace

   Copyright (C) Alibaba Cloud Computing, 2020 All rights reserved.
*/
#ifndef ALIYUN_COMMON_H
#define ALIYUN_COMMON_H

/*!
    @header
    @abstract    <h1>阿里云RACE基本数据类型</h1>
    @copyright   Alibaba Cloud Computing
    @encoding    utf-8
    @version     1.2.0
*/



#ifdef __cplusplus
extern "C" {
#endif

#ifndef RACE_EXTERN
#if defined(_MSC_VER_)
#ifdef RACE_SHARED_LIB
#define RACE_EXTERN __declspec(dllexport)
#else
#define RACE_EXTERN __declspec(dllimport)
#endif
#else
#define RACE_EXTERN __attribute__((visibility("default")))
#endif
#endif

/*!
 * @abstract race 句柄
 */
typedef void* race_t;

/*!
 * @enum aliyun_image_format_t
 * @abstract   图像像素格式类型
 * @constant   ALR_IMAGE_FORMAT_BGRA            bgra
 * @constant   ALR_IMAGE_FORMAT_RGBA            rgba
 * @constant   ALR_IMAGE_FORMAT_I420               yuv i420
 * @constant   ALR_IMAGE_FORMAT_NV21             yuv nv21
 * @constant   ALR_IMAGE_FORMAT_NV12             yuv nv12
 */
typedef enum
{
    ALR_IMAGE_FORMAT_BGRA  = 4,
    ALR_IMAGE_FORMAT_RGBA  = 5,
    ALR_IMAGE_FORMAT_I420  = 6,
    ALR_IMAGE_FORMAT_NV21  = 7,
    ALR_IMAGE_FORMAT_NV12  = 8
    
} aliyun_image_format_t;

/*!
 * @enum aliyun_color_range_t
 * @abstract 图像颜色范围
 * @constant ALR_COLOR_RANGE_FULL
 * @constant ALR_COLOR_RANGE_LIMITED
 */
typedef enum
{
    ALR_COLOR_RANGE_FULL,
    ALR_COLOR_RANGE_LIMITED
    
} aliyun_color_range_t;

/*!
 * @enum aliyun_color_standard_t
 * @abstract 图像色彩标准
 * @constant ALR_COLOR_STANDARD_BT709
 * @constant ALR_COLOR_STANDARD_BT601
 */
typedef enum
{
    ALR_COLOR_STANDARD_BT709 = 1,
    ALR_COLOR_STANDARD_BT601 = 2,
    
} aliyun_color_standard_t;

/*!
 * @enum aliyun_rotation_t
 * @abstract 旋转角度（顺时针）
 * @constant ALR_ROTATE_0_CW              0 clockwise
 * @constant ALR_ROTATE_90_CW            90 clockwise
 * @constant ALR_ROTATE_180_CW          180 clockwise
 * @constant ALR_ROTATE_270_CW           270 clockwise
 */
typedef enum
{
    ALR_ROTATE_0_CW    = 0,
    ALR_ROTATE_90_CW   = 90,
    ALR_ROTATE_180_CW  = 180,
    ALR_ROTATE_270_CW  = 270,
    
} aliyun_rotation_t;

/*!
 * @enum aliyun_log_level_t
 * @abstract 日志级别
 * @constant ALR_LOG_LEVEL_VERBOSE              verbose
 * @constant ALR_LOG_LEVEL_DEBUG                   debug
 * @constant ALR_LOG_LEVEL_INFO                       info
 * @constant ALR_LOG_LEVEL_WARN                     warn
 * @constant ALR_LOG_LEVEL_ERROR                   error
 * @constant ALR_LOG_LEVEL_FATAL                      fatal
 */
typedef enum
{
    ALR_LOG_LEVEL_VERBOSE = 2,
    ALR_LOG_LEVEL_DEBUG,
    ALR_LOG_LEVEL_INFO,
    ALR_LOG_LEVEL_WARN,
    ALR_LOG_LEVEL_ERROR,
    ALR_LOG_LEVEL_FATAL,
    
} aliyun_log_level_t;

/*!
 * @enum aliyun_return_value_t
 * @abstract Returns values
 * @constant ALR_OK                                     Returns  if the call succeeds
 * @constant ALR_FAIL                                   Returns  if the call failed
 * @constant ALR_INVALID_HANDLE            Returns  if the handle equals NULL
 * @constant ALR_INVALID_VALUE               Returns  if the values not supported
 * @constant ALR_INVALID_LICENSE           Returns  if the license verification failed
 * @constant ALR_INVALID_FORMAT            Returns  if the image format not supported
 */
typedef enum
{
    ALR_OK                   = 0,
    ALR_FAIL                 = -1,
    ALR_INVALID_HANDLE       = -2,
    ALR_INVALID_VALUE        = -3,
    ALR_INVALID_LICENSE      = -4,
    ALR_INVALID_FORMAT       = -5,
    
} aliyun_return_value_t;


/*!
 * @abstract 设置日志级别，默认级别ALR_LOG_LEVEL_WARN.
 * @param level 日志级别
 * @namespace AliyunRace
 */
RACE_EXTERN void aliyun_setLogLevel(int level);

#ifdef __cplusplus
}
#endif

#endif //ALIYUN_COMMON_H
