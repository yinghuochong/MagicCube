//
//  YHCOpenGLProgram.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import "YHCShaderAttribute.h"
#import "YHCShaderUniform.h"

@interface YHCOpenGLProgram : NSObject
{
    GLuint _programId;  //shader program id
    
    NSString *_vertexShader;    //vertex and fragment shader name
    NSString *_fragmentShader;
    
    NSMutableDictionary *_attributes; //attributes and unifroms dictionary 
    NSMutableDictionary *_uniforms; //(key: 自定义的名字，只是为了方便程序员识别 value: attribute 或者 unform 名  ex:"postion","mvpMatrix")
    
    GLuint _currentAttributeIndex;  
    GLuint _currentUniformIndex;
}
@property (nonatomic, readonly) GLuint programId;

- (YHCOpenGLProgram *)init;

- (void)setVertexShader:(NSString *)newVertexShader;
- (void)setFragmentShader:(NSString *)newFragmentShader;
- (void)addAttributeLocation:(NSString *)newIndex forAttribute:(NSString *)newName;
- (void)addUniformLocation:(NSString *)newIndex forUniform:(NSString *)newName;

- (GLuint) getAttributeIDForIndex:(NSString *)index;
- (GLuint) getUniformIDForIndex:(NSString *)index;

- (BOOL)compileAndLink;

- (BOOL)compileShader:(GLuint *)shader ofType:(GLenum)type fromFile:(NSString *)file;
- (BOOL)linkProgram;
- (BOOL)validate;

@end
































