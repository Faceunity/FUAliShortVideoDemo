/*
   File:  aliyun_face_detect.h
   
   Framework:  AliyunRace

   Copyright (C) Alibaba Cloud Computing, 2020 All rights reserved.
*/
#ifndef ALI_ALR_FACE_DETECT_H
#define ALI_ALR_FACE_DETECT_H
/*!
    @header
    @copyright   Alibaba Cloud Computing
    @encoding    utf-8
    @version     1.2.0
    @abstract    <h1>阿里云RACE人脸检测功能</h1>
    <h2>关键点位信息</h2>
    <p>
     <img src="../res/race_face.png" alt="Smiley face" width="375" height="667">
    </p>
    <p>
     <img src="../res/face_key_points.png" alt="Smiley face" width="886" height="350">
    <p>
*/

#include <stdint.h>
#include "aliyun_common.h"

#ifdef __cplusplus
extern "C" {
#endif

#define ALR_FACE_DETECT_MODE_VIDEO           0x10000000  /*! 检测视频流. */
#define ALR_FACE_DETECT_MODE_IMAGE           0x20000000  /*! 检测单张图片. */

/*!
 * @typedef aliyun_rect_t
 * @abstract 检测到的人脸区域，以左上角为原点.
 */
typedef struct
{
    int left;    /*! @field left         left of the face rectangle. */
    int top;     /*! @field top         top of the face rectangle. */
    int right;   /*! @field right       right of the face rectangle. */
    int bottom;  /*! @field bottom   bottom of the face rectangle. */

} aliyun_rect_t;

/*!
 * @typedef aliyun_point_t
 * @abstract 点的信息，以左上角为原点.
 */
typedef struct
{
    float x;    /*! @field x    the point x value. */
    float y;    /*! @field y    the point y value. */
    
} aliyun_point_t;

/*!
 * @typedef aliyun_face_t
 * @abstract 单个人脸的点位信息.
 */
typedef struct
{
    aliyun_rect_t rect;                  /*! @field rect    人脸区域. */
    float score;                         /*! @field score    置信值. */
    aliyun_point_t landmarks_array[106]; /*! @field landmarks_array    106 关键点位. */
    float landmarks_visible_array[106];  /*! @field landmarks_visible_array    106 关键点位是否可见. */
    float yaw;                           /*! @field yaw    水平转角，真实度量的左负右正. */
    float pitch;                         /*! @field pitch   俯仰角，真实度量的上负下正. */
    float roll;                          /*! @field roll    旋转角，真实度量的左负右正. */
    float eye_distance;                  /*! @field eye_distance    两眼间距. */
    int faceID;                          /*! @field faceID    人脸ID. */

} aliyun_face_t;

/*!
 * @typedef aliyun_face_info_t
 * @abstract 图像中人脸信息.
 * @see aliyun_face_t
 */
typedef struct
{
    aliyun_face_t *p_faces;              /*! @field p_faces    人脸信息指针. */
    int face_count;                      /*! @field face_count    检测到的人脸数量. */

} aliyun_face_info_t;

/*!
 * @enum aliyun_face_param_type_t
 * @abstract 人脸检测参数.
*/
typedef enum
{
    ALR_FACE_PARAM_DETECT_INTERVAL        = 1,  /*! @const ALR_FACE_PARAM_DETECT_INTERVAL       人脸检测的帧率（默认值30，即每隔30帧检测一次）. */
    ALR_FACE_PARAM_SMOOTH_THRESHOLD       = 2,  /*! @const ALR_FACE_PARAM_SMOOTH_THRESHOLD    人脸关键点平滑系数（默认值0.25）. */
    ALR_FACE_PARAM_POSE_SMOOTH_THRESHOLD  = 4,  /*! @const ALR_FACE_PARAM_POSE_SMOOTH_THRESHOLD    姿态平衡系数(0,1], 越大平滑成都越大. */
    ALR_FACE_PARAM_DETECT_THRESHOLD       = 5,  /*! @const ALR_FACE_PARAM_DETECT_THRESHOLD     人脸检测阈值(0,1), 阈值越大，误检越少，但漏检测会增加, default 0.95. */
    ALR_FACE_PARAM_ALIGNMENT_INTERVAL     = 11, /*! @const ALR_FACE_PARAM_ALIGNMENT_INTERVAL     人脸检测对齐间隔，默认1，一般不要超过5. */
    ALR_FACE_PARAM_MAX_FACE_SUPPORT       = 12, /*! @const ALR_FACE_PARAM_MAX_FACE_SUPPORT     最多支持检出的人脸个数，最大设为32. */
    ALR_FACE_PARAM_DETECT_IMG_SIZE        = 13, /*! @const ALR_FACE_PARAM_DETECT_IMG_SIZE     人脸检测输入的图像大小，default： 240. */

} aliyun_face_param_type_t;


/*!
 * @function aliyun_face_default_create
 * @abstract 创建人脸检测句柄.
 * @param handle race句柄.
 * @param config  ALR_FACE_DETECT_MODE_VIDEO 检测视频流, ALR_FACE_DETECT_MODE_IMAGE检测单张图片.
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code.
 */
RACE_EXTERN int aliyun_face_default_create(race_t* handle, unsigned int config);

/*!
 * @function aliyun_face_setParam
 * @abstract 设置人脸检测参数.
 * @param handle race句柄
 * @param type 人脸检测参数类型
 * @param value 人脸检测参数类型对应的值
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_face_setParam(race_t handle, aliyun_face_param_type_t type, float value);

/*!
 * @function aliyun_face_detect
 * @abstract 人脸检测接口.
 * @param handle race句柄
 * @param buffer input image
 * @param format support type BGR、RGBA、RGB、Y(GRAY)，推荐使用RGBA
 * @param width  width
 * @param height height
 * @param bytesPerRow 用于检测的图像的跨度(以像素为单位),即每行的字节数,
 * @param rotation rotate image to frontalization for face detection
 * @param config MOBILE_FACE_DETECT, or MOBILE_FACE_DETECT|MOBILE_EYE_BLINK et.al 默认值0
 * @param outRotation result process rotate specific angle first, angle =  0/90/180/270
 * @param outFlipAxis  flip x/y 0(no flip)/1(flip X axis)/2(flip Y axis)
 * @param faceInfo store face detetion result
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_face_detect(race_t handle,
                                   uint8_t *buffer,
                                   aliyun_image_format_t format,
                                   uint32_t width,
                                   uint32_t height,
                                   uint32_t bytesPerRow,
                                   aliyun_rotation_t rotation,
                                   uint32_t config,
                                   aliyun_rotation_t outRotation,
                                   uint32_t outFlipAxis,
                                   aliyun_face_info_t* faceInfo);

/*!
 * @function aliyun_face_reset_tracking
 * @abstract 针对video模式下，清空之前跟踪的缓存信息，当视频流分辨率变化时调用.
 * @param handle race句柄
 */
RACE_EXTERN void aliyun_face_reset_tracking(race_t handle);

/*!
 * @function aliyun_face_destroy
 * @abstract 销毁人脸检测句柄.
 * @param handle  race句柄
 */
RACE_EXTERN void aliyun_face_destroy(race_t handle);

#ifdef __cplusplus
}
#endif
#endif //ALI_ALR_FACE_DETECT_H
