//
//  MatrixTools.m
//  MagicCube
//
//  Created by lihua liu on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//


#import "MatrixTools.h"

@implementation MatrixTools

+(void)copyMatrix : (GLfloat *)mSource to:(GLfloat *)mTarget
{
    for (int i = 0; i < 16; i++) {
        mTarget[i] = mSource[i];
    }
}
+(void)applyIdentity : (GLfloat *)m
{
    // First column
    m[0] = 1;
    m[1] = 0;
    m[2] = 0;
    m[3] = 0;
    
    // Second column
    m[4] = 0;
    m[5] = 1;
    m[6] = 0;
    m[7] = 0;
    
    // Third column
    m[8] = 0;
    m[9] = 0;
    m[10] = 1;
    m[11] = 0;
    
    // Fourth column
    m[12] = 0;
    m[13] = 0;
    m[14] = 0;
    m[15] = 1;
}
/*
 
 这里为什么创建一个临时对象并且在函数最后 把他copy到m3 呢，为啥不直接赋给m3
 
 因为如果m3 出现在m1 或者m2 的位置的话  当我们进行计算的时候可能会修改他
 比如 
 
 [YHCMatrixTools multiplyMatrix:scaleMatrix by:mvpMatrix giving:mvpMatrix]
 
 这种情况  mvpMatrix 在计算的时候就会被修改
 
 */

+ (void)multiplyMatrix:(GLfloat *)m1 by:(GLfloat *)m2 giving:(GLfloat *)m3 {
    GLfloat tempMatrix[16];
    
    // First column
    tempMatrix[0] = (m1[0] * m2[0]) + (m1[4] * m2[1]) + (m1[8] * m2[2]) + (m1[12] * m2[3]);
    tempMatrix[1] = (m1[1] * m2[0]) + (m1[5] * m2[1]) + (m1[9] * m2[2]) + (m1[13] * m2[3]);
    tempMatrix[2] = (m1[2] * m2[0]) + (m1[6] * m2[1]) + (m1[10] * m2[2]) + (m1[14] * m2[3]);
    tempMatrix[3] = (m1[3] * m2[0]) + (m1[7] * m2[1]) + (m1[11] * m2[2]) + (m1[15] * m2[3]);
    
    // Second column
    tempMatrix[4] = (m1[0] * m2[4]) + (m1[4] * m2[5]) + (m1[8] * m2[6]) + (m1[12] * m2[7]);
    tempMatrix[5] = (m1[1] * m2[4]) + (m1[5] * m2[5]) + (m1[9] * m2[6]) + (m1[13] * m2[7]);
    tempMatrix[6] = (m1[2] * m2[4]) + (m1[6] * m2[5]) + (m1[10] * m2[6]) + (m1[14] * m2[7]);
    tempMatrix[7] = (m1[3] * m2[4]) + (m1[7] * m2[5]) + (m1[11] * m2[6]) + (m1[15] * m2[7]);
    
    // Third column
    tempMatrix[8] = (m1[0] * m2[8]) + (m1[4] * m2[9]) + (m1[8] * m2[10]) + (m1[12] * m2[11]);
    tempMatrix[9] = (m1[1] * m2[8]) + (m1[5] * m2[9]) + (m1[9] * m2[10]) + (m1[13] * m2[11]);
    tempMatrix[10] = (m1[2] * m2[8]) + (m1[6] * m2[9]) + (m1[10] * m2[10]) + (m1[14] * m2[11]);
    tempMatrix[11] = (m1[3] * m2[8]) + (m1[7] * m2[9]) + (m1[11] * m2[10]) + (m1[15] * m2[11]);
    
    // Fourth column
    tempMatrix[12] = (m1[0] * m2[12]) + (m1[4] * m2[13]) + (m1[8] * m2[14]) + (m1[12] * m2[15]);
    tempMatrix[13] = (m1[1] * m2[12]) + (m1[5] * m2[13]) + (m1[9] * m2[14]) + (m1[13] * m2[15]);
    tempMatrix[14] = (m1[2] * m2[12]) + (m1[6] * m2[13]) + (m1[10] * m2[14]) + (m1[14] * m2[15]);
    tempMatrix[15] = (m1[3] * m2[12]) + (m1[7] * m2[13]) + (m1[11] * m2[14]) + (m1[15] * m2[15]);
    
    [self copyMatrix:tempMatrix to:m3];
}

+ (void)applyTranslation:(GLfloat *)m x:(GLfloat)x y:(GLfloat)y z:(GLfloat)z
{
    GLfloat tempMatrix[16];
    
    [self applyIdentity:tempMatrix];
    
    tempMatrix[12] = x;
    tempMatrix[13] = y;
    tempMatrix[14] = z;
    
    [self multiplyMatrix:tempMatrix by:m giving:m];
}

+ (void)applyScale:(GLfloat *)m x:(GLfloat)x y:(GLfloat)y z:(GLfloat)z 
{
    GLfloat tempMatrix[16];
    
    [self applyIdentity:tempMatrix];
    
    tempMatrix[0] = x;
    tempMatrix[5] = y;
    tempMatrix[10] = z;
    
    [self multiplyMatrix:tempMatrix by:m giving:m];
}

+ (void)applyRotation:(GLfloat *)m x:(GLfloat)x y:(GLfloat)y z:(GLfloat)z 
{
    GLfloat tempMatrix[16];
    
    if(x != 0) {
        GLfloat c = cosf(x);
        GLfloat s = sinf(x);
        
        [self applyIdentity:tempMatrix];
        
        tempMatrix[5] = c;
        tempMatrix[6] = -s;
        tempMatrix[9] = s;
        tempMatrix[10] = c;
        
        [self multiplyMatrix:tempMatrix by:m giving:m];
    }
    
    if(y != 0) {
        GLfloat c = cosf(y);
        GLfloat s = sinf(y);
        
        [self applyIdentity:tempMatrix];
        
        tempMatrix[0] = c;
        tempMatrix[2] = s;
        tempMatrix[8] = -s;
        tempMatrix[10] = c;
        
        [self multiplyMatrix:tempMatrix by:m giving:m];
    }
    
    if(z != 0) {
        GLfloat c = cosf(z);
        GLfloat s = sinf(z);
        
        [self applyIdentity:tempMatrix];
        
        tempMatrix[0] = c;
        tempMatrix[1] = -s;
        tempMatrix[4] = s;
        tempMatrix[5] = c;
        
        [self multiplyMatrix:tempMatrix by:m giving:m];
    }
}
/*
 + (void)applyProjection:(GLfloat *)m aspect:(GLfloat)aspect
 {
 GLfloat tempMatrix[16];
 
 [self applyIdentity:tempMatrix];
 
 tempMatrix[0] = 1;
 tempMatrix[5] = 1 / aspect;
 
 [self multiplyMatrix:tempMatrix by:m giving:m];
 }
 */


+ (void)applyProjection:(GLfloat *)m fov:(GLfloat)fov aspect:(GLfloat)aspect near:(GLfloat)near far:(GLfloat)far 
{
    GLfloat tempMatrix[16];
    
    [self applyIdentity:tempMatrix];
    
    GLfloat r = fov * M_PI / 180.0f;
    GLfloat f = 1.0f / tanf(r / 2.0f);
    
    tempMatrix[0] = f;
    tempMatrix[5] = f / aspect;
    tempMatrix[10] = -((far + near) / (far - near));
    tempMatrix[11] = -1;
    tempMatrix[14] = -(2 * far * near / (far - near));
    tempMatrix[15] = 0;
    
    [self multiplyMatrix:tempMatrix by:m giving:m];
}


@end