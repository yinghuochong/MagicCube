//
//  ViewController.h
//  MagicCube
//
//  Created by lihua liu on 12-9-10.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

//**************************//
//   QuartzCore.framework
//   OpenGLES.framework
//   CoreGraphics.framework
//*************************//

#import <UIKit/UIKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <QuartzCore/QuartzCore.h>
#import <Foundation/Foundation.h>

#import "EAGLView.h"
#import "YHCOpenGLProgram.h"
#import "YHCTextStringManager.h"
#import "YHCScrollingBackground.h"

@interface ViewController : UIViewController
{
    EAGLContext *_context;
    YHCOpenGLProgram *_program;
    
    //GLuint _program;
    
    GLboolean drawing;    //是否绘制，控制drawframe是否执行
    CADisplayLink *_displayLink;
    
    //变换矩阵
    GLfloat _scaleMatrix[16]; 
    GLfloat _rotationMatrix[16]; 
    GLfloat _translationMatrix[16]; 
    GLfloat _projectionMatrix[16];
    
    GLfloat _sliceRotationMatrix[16];
    //当前要旋转的面
    GLbyte _currentSlice[3];
    
    //touch操作 用到的变量
    GLfloat _lastPinchDistance;
    GLfloat _lastZoomDistance;
    CGPoint _lastTouchPosition; 
    
    CGPoint _firstPostion;
    //贴图
    GLuint _textureName;
    
    GLfloat _sliceRotateAngle;
    GLint _rotationState;
    
    GLboolean _isSelectMode;  
    GLboolean _isCheck;
    
    YHCTextStringManager *_textManager;
    YHCScrollingBackground *_background;
    
    YHCTextString *_timeLabel ;
    time_t _startTime;
    long _consumeTime;
    
    YHCTextString *_stepLable;
    GLuint _stepCount;
    
    GLboolean _isOK;
}

- (void)startDraw;
- (void)stopDraw;
@end
