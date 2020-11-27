//
//  PoseEsmition.h
//  Avatar
//
//  Created by zhoushiwei on 14-3-10.
//  Copyright (c) 2014年 zhoushiwei. All rights reserved.
//

#ifndef Avatar_PoseEsmition_h
#define Avatar_PoseEsmition_h

#include <iostream>
#include <string.h>
#include <vector>
#include <opencv2/core.hpp>
#include "pixelai_face3D.h"

using namespace cv;
using namespace std;


class FaceShapeParameter{
    
public:
    bool enable;
    float scale;
};


class PortraitBeauty{
    
private:

public:
    PortraitBeauty();
    ~PortraitBeauty();
    
public:
    bool InitData(const std::string& path,const pixelai_istream_func& istream_func = nullptr);
    bool loadFaceShapeModel(const std::string& path);
    Mat FaceBeauty(cv::Mat&shape2D);
    std::vector<cv::Point2f> ProjectShapeTo2D(Mat&Shape_3D);
    void doBeauty(Mat &SS_);
    void doBeautyForTri(Mat& SS_);
    bool ReadData(const std::string &Mainpath, std::vector<cv::Mat> &params);
    void RemoveJitter(const std::vector<std::array<float, 2>>& prev, std::vector<std::array<float, 2>>& landmarks, float& model_scale);
    
    void SetFaceParam(float scale, ALMFaceShapeType type)
    {
//        cout<<"scale "<<scale<<endl;
//        if(scale>1.0) scale=1.0;
//        if(scale<-1.0) scale=-1.0;
        faceshape_param[type].enable = true;
        faceshape_param[type].scale = scale;
    }
    
    float GetFaceParam(ALMFaceShapeType type)
    {
        return faceshape_param[type].scale;
    }
    void EnableFaceParam(ALMFaceShapeType type)
    {
        faceshape_param[type].enable = 1;
    }
    void DisableFaceParam(ALMFaceShapeType type)
    {
        faceshape_param[type].enable = 0;
    }
    
    void SetDefaultFaceShapeParams();
    
    /// @brief 人脸美型主接口
    /// @param[in] input_pts 输入的人脸关键点，106个点集合
    /// @param[out] positionArray 美型前的3D坐标插值后返回的2D坐标点
    /// @param[out] coordArray 美型后的3D坐标插值后返回的2D坐标点
    /// @param[out] indexArray 三角网格顶点索引值
    void FaceBeautyInterface(const std::vector<std::array<float, 2> >& input_pts,std::vector<float>& positionArray,std::vector<float> &coordArray,std::vector<unsigned short> &indexArray, int width = 720, int height = 1280, int faceCount = 1, int rotate = 0);
    
    
    
    // 旧版渲染需要暴露接口
    Mat posepram;
    std::vector<cv::Mat> faceshape_coefs;
    std::vector<int> faceshape_coefs_valid;
private:
    Mat poseplocal;
    Mat s;
    Mat SS_;  //人脸3D点
    Mat MeanVector2 ;
    Mat Variation;
    Mat Rotation_matrix;
    
private:
    FaceShapeParameter faceshape_param[ALMFaceShapeTypMAX];
    pixelai_istream_func istream_func;
    pixelai_ostream_func ostream_func;
};




#endif
