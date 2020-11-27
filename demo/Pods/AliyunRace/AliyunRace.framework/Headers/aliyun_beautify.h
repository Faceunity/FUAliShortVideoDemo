/*
   File:  aliyun_beautify.h
   
   Framework:  AliyunRace

   Copyright (C) Alibaba Cloud Computing, 2020 All rights reserved.
*/
#ifndef ALIYUN_RACE_BEAUTIFY_H
#define ALIYUN_RACE_BEAUTIFY_H
/*!
    @header      
    @copyright   Alibaba Cloud Computing
    @encoding    utf-8
    @version     1.2.0
    @abstract    <b><h1>阿里云RACE高级美颜功能</h1></b>包含美白、磨皮、锐化功能，美型默认包含优雅、精致、网红、可爱、婴儿五种脸型，提供包括眼睛、鼻子、嘴形等22种预置形状，便于客户根据产品需求扩展丰富的功能.
    <h2>美颜</h2>
    <div class="row">
     <div class="col" style="display: flex;" >
      <p style="margin: 0 10px;"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#21407;&#22270;</b><br>
      <img src="../res/origin.png" width="175" height="264" style="vertical-align:middle;/>
     </div>
     <div class="col" >
      <p style="margin: 0 10px;"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&#30952;&#30382;</b><br>
      <img src="../res/skinBuffing.png" width="175" height="264" style="vertical-align:middle;/>
     </div>
     <div class="col" >
      <p style="margin: 0 10px;"><b>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;美白</b><br>
      <img src="../res/skinBuffing.png" width="175" height="264" style="vertical-align:middle;/>
     </div>
   </div>
   <div class="row">
  
   </div>
  
   <br />
   <h2>美型</h2>
   <div>
     <img src="../res/face.gif" alt="Smiley face" width="375" height="500" />
   </div>
   <h2>集成方式</h2>
   <b>1. pod集成：</b>
    <pre>pod 'AliyunRace', '1.2.0' </pre>
   <b>2. framework集成：</b>
    <pre>获取AliyunRace.framework、Face3D.framwork、opencv2.framework并添加依赖到项目工程</pre>
   <h2>简单接口集成示例</h2>
    <pre class="brush: c;">
        race_t beautify = nullptr;
        // 1.创建高级美颜实例
        aliyun_beautify_create(&beautify);
        // 2.设置美颜参数
        aliyun_beautify_setSkinBuffing(beautify, skinBuffingValue); //磨皮
        aliyun_beautify_setSkinWhitening(beautify, skinWhiteningValue); //美白
        aliyun_beautify_setSharpen(beautify, sharpenValue); //锐化
        // 3.设置美型参数
        aliyun_beautify_setFaceSwitch(beautify, true); //开启美型功能
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_BIG_EYE, bigEyeValue);//大眼
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_LONG_FACE, longFaceValue);//脸长
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_CUT_FACE, cutFaceValue);//削脸
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_THIN_FACE, thinFaceValue);//瘦脸
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_LOWER_JAW, lowerJawValue);//下巴
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_MOUTH_WIDTH, mouthWidthValue);//唇宽
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_THIN_NOSE, thinNoseValue);//瘦鼻
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_THIN_MANDIBLE, thinMandibleValue);//下颌
        aliyun_beautify_setFaceShape(beautify, ALR_FACE_TYPE_CUT_CHEEK, cutCheekValue);//颧骨

        //4.美颜美型效果处理,返回渲染后的结果纹理id
        textureOut = aliyun_beautify_processSampleBuffer(beautify, sampleBuffer);

        //4.单纹理输入
        textureOut = aliyun_beautify_processTextureToTexture(beautify, textureIn, width,  height, rotation, flags);

        //5.销毁美颜美型实例
        aliyun_beautify_destroy(beautify);
    </pre>
*/

#include <stdint.h>
#import <CoreMedia/CoreMedia.h>
#include "aliyun_common.h"

#ifdef __cplusplus
extern "C" {
#endif

/*!
 * @enum ALRFaceShape
 * @abstract 美型脸型类型
 */
typedef enum
{
    ALR_FACE_TYPE_CUT_CHEEK       = 0,  /*! @constant ALR_FACE_TYPE_CUT_CHEEK  颧骨建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_CUT_FACE        = 1,  /*! @constant ALR_FACE_TYPE_CUT_FACE  削脸建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_THIN_FACE       = 2,  /*! @constant ALR_FACE_TYPE_THIN_FACE  瘦脸建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_LONG_FACE       = 3,  /*! @constant ALR_FACE_TYPE_LONG_FACE  脸长建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_LOWER_JAW       = 4,  /*! @constant ALR_FACE_TYPE_LOWER_JAW  下巴缩短建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_HIGHER_JAW      = 5,  /*! @constant ALR_FACE_TYPE_HIGHER_JAW  下巴拉长建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_THIN_JAW        = 6,  /*! @constant ALR_FACE_TYPE_THIN_JAW  瘦下巴建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_THIN_MANDIBLE   = 7,  /*! @constant ALR_FACE_TYPE_THIN_MANDIBLE  瘦下颌建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_BIG_EYE         = 8,  /*! @constant ALR_FACE_TYPE_BIG_EYE  大眼建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_EYE_ANGLE1      = 9,  /*! @constant ALR_FACE_TYPE_EYE_ANGLE1  眼角1建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_CANTHUS         = 10, /*! @constant ALR_FACE_TYPE_CANTHUS  眼距建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_CANTHUS1        = 11, /*! @constant ALR_FACE_TYPE_CANTHUS1  拉宽眼距建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_EYE_ANGLE2      = 12, /*! @constant ALR_FACE_TYPE_EYE_ANGLE2  眼角2建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_EYE_TDANGLE     = 13, /*! @constant ALR_FACE_TYPE_EYE_TDANGLE  眼睛高度建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_THIN_NOSE       = 14, /*! @constant ALR_FACE_TYPE_THIN_NOSE  瘦鼻建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_NOSE_WING       = 15, /*! @constant ALR_FACE_TYPE_NOSE_WING  鼻翼建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_NASAL_HEIGHT    = 16, /*! @constant ALR_FACE_TYPE_NASAL_HEIGHT  鼻长建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_NOSE_TIP_HEIGHT = 17, /*! @constant ALR_FACE_TYPE_NOSE_TIP_HEIGHT  鼻头长建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_MOUTH_WIDTH     = 18, /*! @constant ALR_FACE_TYPE_MOUTH_WIDTH  唇宽建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_MOUTH_SIZE      = 19, /*! @constant ALR_FACE_TYPE_MOUTH_SIZE  嘴唇大小建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_MOUTH_HIGH      = 20, /*! @constant ALR_FACE_TYPE_MOUTH_HIGH  唇高建议取值范围 [-1, 1]. */
    ALR_FACE_TYPE_PHILTRUM        = 21, /*! @constant ALR_FACE_TYPE_PHILTRUM  人中建议取值范围 [0, 1]. */
    ALR_FACE_TYPE_MAX             = 22  /*! @constant ALR_FACE_TYPE_MAX  脸型类型的数量. */

} ALRFaceShape;

/*!
 * @function aliyun_beautify_getVersion
 * @abstract 获取当前美颜版本信息
 * @param major 主版本号
 * @param minor 次版本号
 */
RACE_EXTERN void aliyun_beautify_getVersion(int* major, int *minor);

/*!
 * @function aliyun_beautify_create
 * @abstract 创建美颜美型实例
 * @discussion aliyun_beautify_create必须在GL线程创建
 * @param handle race句柄
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_beautify_create(race_t *handle);

/*!
 * @function aliyun_beautify_setFaceDebug
 * @abstract 开启调试信息
 * @param handle race句柄
 * @param enable 调试开启标志
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_beautify_setFaceDebug(race_t handle, bool enable);

/*!
 * @function aliyun_beautify_setFaceSwitch
 * @abstract 开启美型功能
 * @param handle race句柄
 * @param switchOn 是否开启人脸检测及美型处理
 */
RACE_EXTERN void aliyun_beautify_setFaceSwitch(race_t handle, bool switchOn);

/*!
 * @function aliyun_beautify_setSkinBuffing
 * @abstract 设置磨皮强度
 * @param handle race句柄
 * @param level 磨皮等级，建议取值范围 [0, 1.5]
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_beautify_setSkinBuffing(race_t handle, float level);

/*!
 * @function aliyun_beautify_setSharpen
 * @abstract 设置锐化强度
 * @param handle race句柄
 * @param level 锐化等级，建议取值范围 [0, 1]
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_beautify_setSharpen(race_t handle, float level);

/*!
 * @function aliyun_beautify_setSkinWhitening
 * @abstract 设置美白强度
 * @param handle race句柄
 * @param level 美白等级，建议取值范围 [0, 1]
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_beautify_setSkinWhitening(race_t handle, float level);

/*!
 * @function aliyun_beautify_setFaceShape
 * @abstract 设置美型参数
 * @param handle race句柄
 * @param type 美型脸型类型
 * @param level 美型脸型类型参数，可以超出 ALRFaceShape 中定义的参数范围
 * @see ALRFaceShape
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_beautify_setFaceShape(race_t handle, ALRFaceShape type, float level);

/*!
 * @function aliyun_beautify_processTextureToTexture
 * @abstract 美颜处理接口，输入纹理输出纹理，必须在GL线程调用
 * @param handle race句柄
 * @param texture 输入图像纹理
 * @param width 输入图像纹理宽度
 * @param height 输入图像纹理高度
 * @param rotation 输入图像纹理旋转角度ALR_ROTATE_XXX
 * @return Returns texture id > 0 if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_beautify_processTextureToTexture(race_t handle,
                                                        uint32_t texture,
                                                        uint32_t width,
                                                        uint32_t height,
                                                        aliyun_rotation_t rotation);

/*!
 * @function aliyun_beautify_processBufferToBuffer
 * @abstract 美颜处理接口输入buffer输出buffer
 * @discussion 输出的buffer的format、宽高和输入buffer保持一致，必须在GL线程调用
 * @param handle race句柄
 * @param buffer 输入图像buffer
 * @param format 只支持RGBA, NV12, NV21, I420
 * @param width 输入图像宽度
 * @param height 输入图像高度
 * @param rotation 输入图像旋转角度ALR_ROTATE_XXX
 * @param bufferOut 输出图像地址
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */
RACE_EXTERN int aliyun_beautify_processBufferToBuffer(race_t handle,
                                                      uint8_t *buffer,
                                                      aliyun_image_format_t format,
                                                      uint32_t width,
                                                      uint32_t height,
                                                      uint32_t bytesPerRow,
                                                      aliyun_rotation_t rotation,
                                                      aliyun_color_range_t range,
                                                      aliyun_color_standard_t standard,
                                                      uint8_t *bufferOut);

/*!
 * @function aliyun_beautify_processSampleBuffer
 * @abstract 高级美颜，输入是类型 CMSampleBufferRef 的图像数据, 格式支持NV12和BGRA, 返回与输入同样大小的纹理 id
 * @param handle race句柄
 * @param sampleBuffer 图像数据 CMSampleBufferRef
 * @return Returns texture id > 0 if the call succeeds, otherwise Returns error code
 */

RACE_EXTERN int aliyun_beautify_processSampleBuffer(race_t handle, CMSampleBufferRef sampleBuffer);

/*!
 * @function aliyun_beautify_processPixelBuffer
 * @abstract 高级美颜，输入是类型 CVPixelBufferRef 的图像数据，调用该函数后已经过美颜处理
 * @discussion 必须在GL线程调用
 * @param handle race句柄
 * @param pixelBuffer 图像数据 CVPixelBufferRef 只支持NV12
 * @return Returns ALR_OK if the call succeeds, otherwise Returns error code
 */

RACE_EXTERN int aliyun_beautify_processPixelBuffer(race_t handle, CVPixelBufferRef pixelBuffer);

/*!
 * @function aliyun_beautify_destroy
 * @abstract 销毁美颜美型实例
 * @discussion 必须在aliyun_beautify_create创建的线程调用，否则会出现GPU泄露
 * @see aliyun_beautify_create
 * @param handle race句柄
 */
RACE_EXTERN void aliyun_beautify_destroy(race_t handle);

#ifdef __cplusplus
}
#endif

#endif // ALIYUN_RACE_BEAUTIFY_H
