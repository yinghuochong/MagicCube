//
//  YHCOpenGLProgram.m
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "YHCOpenGLProgram.h"

@implementation YHCOpenGLProgram

@synthesize programId = _programId;

- (YHCOpenGLProgram *)init
{
    if (self = [super init]) {
        _attributes = nil;
        _uniforms = nil;
        
        _currentAttributeIndex = 0;
        _currentUniformIndex = 0;
        
        _programId = 0;
    }
    return self;
}

- (void)setVertexShader:(NSString *)newVertexShader
{
    _vertexShader = newVertexShader;
}

- (void)setFragmentShader:(NSString *)newFragmentShader
{
    _fragmentShader = newFragmentShader;
}

- (void)addAttributeLocation:(NSString *)newIndex forAttribute:(NSString *)newName
{
    if (_attributes == nil) {
        _attributes = [[NSMutableDictionary alloc] init];
    }
    YHCShaderAttribute *newAttribute = [[YHCShaderAttribute alloc] initAttributeWithID:_currentAttributeIndex andName:newName];
    [_attributes setObject:newAttribute forKey:newIndex];
    [newAttribute release];
    _currentAttributeIndex++;
}

- (void)addUniformLocation:(NSString *)newIndex forUniform:(NSString *)newName
{
    if (_uniforms == nil) {
        _uniforms = [[NSMutableDictionary alloc] init];
    }
    YHCShaderUniform *newUniform = [[YHCShaderUniform alloc] initUniformWithID:_currentUniformIndex andName:newName];
    [_uniforms setObject:newUniform forKey:newIndex];
    [newUniform release];
    _currentUniformIndex++;
}

- (GLuint) getAttributeIDForIndex:(NSString *)index
{
    if (_attributes != nil) {
        YHCShaderAttribute *thisAttribute = [_attributes objectForKey:index];
        if (thisAttribute != nil) {
            return [thisAttribute attributeId];
        }
    }
    return 0;
}

- (GLuint) getUniformIDForIndex:(NSString *)index
{
    if (_uniforms != nil) {
        YHCShaderUniform *thisUniform = [_uniforms objectForKey:index];
        if (thisUniform != nil) {
            return [thisUniform uniformLocation];
        }
    }
    return 0;
}

- (BOOL)compileAndLink
{
    GLuint vertShader, fragShader;      //vector 和 fragment shader ID
    NSString *vertShaderPathname, *fragShaderPathname;  //vector 和 fragment 的shader路径

    _programId = glCreateProgram();     //创建一个shader program
    
    //创建并且编译 vector shader
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:_vertexShader ofType:@"vsh"];
    if (![self compileShader:&vertShader ofType:GL_VERTEX_SHADER fromFile:vertShaderPathname]) {
        NSLog(@"Failed to compile vertex shader, shader name: [%@]",_vertexShader);
        return NO;
    }
    //创建并且编译 fragment shader
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:_fragmentShader ofType:@"fsh"];
    if (![self compileShader:&fragShader ofType:GL_FRAGMENT_SHADER fromFile:fragShaderPathname]) {
        NSLog(@"Failed to compile fragment shader, shader name: [%@]",_fragmentShader);
        return NO; 
    }
    //附加 vector 和 fragment shader
    glAttachShader(_programId, vertShader);
    glAttachShader(_programId, fragShader);
    
    //在链接之前 绑定 attribute (attribute location 绑定 必须在链接之前)
    for (NSString *key in _attributes) {
        YHCShaderAttribute *thisAttribute = [_attributes objectForKey:key];
        glBindAttribLocation(_programId, thisAttribute.attributeId, [thisAttribute.attributeName UTF8String]);
    }
    //链接shader程序
    if (![self linkProgram]) {
        //如果链接失败，打印一个提示信息，然后释放掉所有申请的资源
        NSLog(@"Failed to link program: %d", _programId);
        
        if (vertShader) {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader) {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (_programId) {
            glDeleteProgram(_programId);
            _programId = 0;
        }
        return NO;
    }
    //链接成功后，从 OpenGL 获取uniform locations (该操作应该在link之后进行)
    for (NSString *key in _uniforms) {
        YHCShaderUniform *thisUniform = [_uniforms objectForKey:key];
        [thisUniform setUniformLocation:glGetUniformLocation(_programId, [thisUniform.uniformName UTF8String])];
    }
    //完成后清理一下一些不再需要的资源
    if (vertShader) {
        glDetachShader(_programId, vertShader);
        glDeleteShader(vertShader);
    }
    if (fragShader) {
        glDetachShader(_programId, fragShader);
        glDeleteShader(fragShader);
    }
    return YES;
}

- (BOOL)compileShader:(GLuint *)shader ofType:(GLenum)type fromFile:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source) {
        NSLog(@"Failed to load vertex shader [%@]",file);
        return NO;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0) {
        glDeleteShader(*shader);
        return NO;
    }
    return YES;
}

- (BOOL)linkProgram
{
    GLint status;
    glLinkProgram(_programId);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(_programId, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_programId, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(_programId, GL_LINK_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

- (BOOL)validate
{
    GLint logLength, status;
    
    glValidateProgram(_programId);
    glGetProgramiv(_programId, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0) {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(_programId, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(_programId, GL_VALIDATE_STATUS, &status);
    if (status == 0) {
        return NO;
    }
    return YES;
}

- (void)dealloc
{
    if (_programId) {
        glDeleteProgram(_programId);
        _programId = 0;
    }
    [_attributes release];
    [_uniforms release];
    [super dealloc];
}

@end