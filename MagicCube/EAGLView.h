//
//  EAGLView.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@class EAGLContext;

//该类将 CoreAnimation中的CAEAGLLayer 封装为一个方便使用的UIView的子类
//视图上的内容是基于 你的OPenGL场景渲染的一个平面
//这里如果EAGL 平面有alpha通道，需要将视图设置为不透明
@interface EAGLView : UIView {
@private
    //CAEAGLLayer 的尺寸
    GLint _framebufferWidth;
    GLint _framebufferHeight;
    
    //渲染时候用到的framebuffer 和 renderbuffer
    GLuint _defaultFramebuffer;
    GLuint _colorRenderbuffer ;
    GLuint _depthRenderbuffer;
}

@property (nonatomic, retain) EAGLContext *context;

- (void)setFramebuffer;
- (BOOL)presentFramebuffer;

@end
