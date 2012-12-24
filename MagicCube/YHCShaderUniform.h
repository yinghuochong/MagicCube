//
//  YHCShaderUniform.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

//该类主要用于操作shader中的uniform变量
#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface YHCShaderUniform : NSObject
{
    GLuint _uniformId;
    NSString *_unifromName;
    GLuint _uniformLocation;
}
@property (nonatomic, assign)GLuint unifromId;
@property (nonatomic, retain)NSString *uniformName;
@property (nonatomic, assign)GLuint uniformLocation;

- (YHCShaderUniform *)initUniformWithID:(GLuint)newUniformId andName:(NSString *)newUniformName;

@end
