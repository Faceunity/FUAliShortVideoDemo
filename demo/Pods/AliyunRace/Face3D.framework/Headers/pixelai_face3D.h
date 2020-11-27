#ifndef INCLUDE_PIXELAI_FACE3D_H_
#define INCLUDE_PIXELAI_FACE3D_H_

#include <stdio.h>
#include "pixelai_common.h"
#include "ALMFaceShapeType.h"
#include <vector>

#define PIXELAI_DENSIFY_LANDMARK 0

#define PIXELAI_FACE3D_LANDMARK_NUM 72
#define PIXELAI_FACE_LANDMARK106_NUM 106
#define PIXELAI_FACE_EXT_LANDMARK_NUM 134
#define PIXELAI_FACE_LANDMARK240_NUM 240

/// ******************** PixelAI 3D人脸美型初始化接口 ********************
/// @brief create handle for face 3D FaceBeauty
/// @param[in] model_Path model path for face 3D FaceBeauty
/// @parma[out] handle, return NULL, if failed
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
PIXELAI_SDK_API pixelai_result_t
pixelai_dl_face3DFaceBeauty_create(pixelai_handle_t *handle,
                                   const std::string& model_Path,const pixelai_istream_func& func = nullptr);
/// ******************** PixelAI 3D人脸美型主程序接口 ********************
/// @brief 人脸美型主接口
/// @param[in] input_pts 输入的人脸关键点，106个点集合  归一化到（0到1 的坐标值）
/// @param[out] positionArray 美型前的3D坐标插值后返回的2D坐标点
/// @param[out] coordArray 美型后的3D坐标插值后返回的2D坐标点
/// @param[out] indexArray 三角网格顶点索引值
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
PIXELAI_SDK_API pixelai_result_t
pixelai_dl_face3DFaceBeauty_Run(pixelai_handle_t handle,
                         const std::vector<std::array<float, 2> > &input_pts,
                         std::vector<float>& positionArray,
                         std::vector<float> &coordArray,
                         std::vector<unsigned short> &indexArray,
                         int width=720, int height=1280,
                         int faceCount= 1
                         );

/// ******************** PixelAI 3D人脸美型参数设置接口 ********************
/// @brief 3D人脸美型参数设置接口
/// @param[in] type 人脸参数模板
/// @param[in] strength 人脸美型模板对应的参数值
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
PIXELAI_SDK_API pixelai_result_t pixelai_updateFaceShapeWithType( pixelai_handle_t handle,ALMFaceShapeType type ,float &strength);


/// ******************** PixelAI 3D人脸函数接口 ********************
/// @brief create handle for face 3D
/// @param[in] model_Path model path for face 3D
/// @parma[out] handle, return NULL, if failed
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
PIXELAI_SDK_API pixelai_result_t
pixelai_dl_face3D_create(
    const char *model_Path,
    pixelai_handle_t *handle
);

/// @brief 人脸驱动
/// @param[in] handle with initialed
/// @param[in] inputPts 输入的人脸关键点信息，可以是68或者106个点集合
/// @param[in] image_width 输入图像的宽
/// @param[in] image_height 输入图像的高
/// @param[in] iterNum 设置迭代次数，迭代次数越高精度越高，反正则越低，低端机型可以适当降低迭代次数
/// @param[out] pose_parameter 返回的姿态矩阵参数 ：
///    pose_parameter[0]=pitch;
///    pose_parameter[1]=yaw;
///    pose_parameter[2]=roll;
///    pose_parameter[3]=scale;
///    pose_parameter[4]=tx;
///    pose_parameter[5]=ty;
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
PIXELAI_SDK_API pixelai_result_t
pixelai_dl_face3D_detect(
    pixelai_handle_t handle,
    std::vector<std::array<float, 2> > inputPts,
    int image_width,
    int image_height,
    int iterNum,
    float *pose_parameter,
    std::vector<std::array<float, 3> > &Position
);

pixelai_result_t pixelai_dl_face3D_avatar(
                                          pixelai_handle_t handle,
                                          std::vector<std::array<float, 2> > inputPts,
                                          int image_width,
                                          int image_height,
                                          int iterNum,
                                          float *pose_parameter,
                                          std::vector<float> &fits_expression
                                          );

/// @brief face estimation for face 3D
/// @param[in] p_face 输入的人脸关键点信息，可以是68或者106个点集合
/// @parma[out] returnPose
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
//PIXELAI_SDK_API pixelai_result_t
//pixelai_dl_faceEstimation_detect(
//    std::vector<std::array<float, 2> > inputPts,
//    std::vector<float> &returnPose,
//    float *ration_parameter
//);

/// @brief face estimation for face 3D
/// @param[in] inputPts 输入坐标点
/// @param[in] angle 旋转角度（0-360）
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
PIXELAI_SDK_API pixelai_result_t
pixelai_dl_rotatePoints(std::vector<std::array<float, 2> > &inputPts,float &angle,int &cols,int &rows);

/// @brief destroy face3D handle
/// @param[in] handle to destroy
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
PIXELAI_SDK_API pixelai_result_t
pixelai_dl_face3D_destroy(
    pixelai_handle_t *handle
);

/// @brief destroy faceBeauty handle
/// @param[in] handle to destroy
/// @return 成功返回PIXELAI_OK， 失败返回其他错误码
PIXELAI_SDK_API pixelai_result_t
pixelai_dl_faceBeauty_destroy(
     pixelai_handle_t *handle
                              );

#endif
