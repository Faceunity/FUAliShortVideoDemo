//
//  ALMFaceShapeType.h
//  AliMedia
//
//  Created by 天荫 on 2018/10/2.
//  Copyright © 2018年 alibaba. All rights reserved.
//

#ifndef POSEFaceShapeType_h
#define POSEFaceShapeType_h

typedef enum ALMFaceShapeType{
    ALMFaceShapeTypeCutCheek = 0,//颧骨        [0,1]
    ALMFaceShapeTypeCutFace = 1,//削脸        [0,1]
    ALMFaceShapeTypeThinFace = 2,//瘦脸       [0,1]
    ALMFaceShapeTypeLongFace = 3,//脸长       [0,1]
    ALMFaceShapeTypeLowerJaw = 4,//下巴缩短    [-1,1]
    ALMFaceShapeTypeHigherJaw = 5,//下巴拉长   [-1,1]
    ALMFaceShapeTypeThinJaw = 6,//瘦下巴       [0,1]
    ALMFaceShapeTypeThinMandible = 7,//瘦下颌   [0,1]
    ALMFaceShapeTypeBigEye = 8, //大眼        [0,1]
    ALMFaceShapeTypeEyeAngle1 = 9,//眼角1     [0,1]
    ALMFaceShapeTypeCanthus = 10,//眼距       [-1,1]
    ALMFaceShapeTypeCanthus1 = 11,//拉宽眼距   [-1,1]
    ALMFaceShapeTypeEyeAngle2 = 12,//眼角2    [-1,1]
    ALMFaceShapeTypeEyeTDAngle = 13,//眼睛高度 [-1,1]
    ALMFaceShapeTypeThinNose = 14,//瘦鼻      [0,1]
    ALMFaceShapeTypeNosewing = 15,//鼻翼      [0,1]
    ALMFaceShapeTypeNasalHeight = 16,//鼻长   [-1,1]
    ALMFaceShapeTypeNoseTipHeight = 17,//鼻头长[-1,1]
    ALMFaceShapeTypeMouthWidth = 18,//唇宽    [-1,1]
    ALMFaceShapeTypeMouthSize = 19,//嘴唇大小  [-1,1]
    ALMFaceShapeTypeMouthHigh = 20,//唇高     [-1,1]
    ALMFaceShapeTypePhiltrum = 21, //人中     [-1,1]
    ALMFaceShapeTypMAX        = 22//最大值
}ALMFaceShapeType;


typedef enum ALMFaceType{
    PEAR = 0,
    HEART = 1,
    SQUARE = 2,
    OVAL = 3,
    LONG = 4,
    ROUND = 5,
    ALMFaceTypeMax = 6,
}ALMFaceType;

#endif /* POSEFaceShapeType_h */
