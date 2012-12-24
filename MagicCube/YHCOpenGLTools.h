//
//  YHCOpenGLTools.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-28.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface YHCOpenGLTools : NSObject

+ (void)loadTexture:(GLuint *)textureName fromFile:(NSString *)fileName;

@end
