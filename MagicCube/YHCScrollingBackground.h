//
//  YHCScrollingBackground.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-30.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHCOpenGLProgram.h"
#import "YHCOpenGLTools.h"

@interface YHCScrollingBackground : NSObject
{
    YHCOpenGLProgram *_program;
    GLuint _texture;
    BOOL _scrolling;
}

- (YHCScrollingBackground *)init;
- (void)startScrolling;
- (void)stopScrolling;
- (void)draw;

@end
