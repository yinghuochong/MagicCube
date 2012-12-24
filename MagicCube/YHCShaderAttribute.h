//
//  YHCShaderAttribute.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//
// 该类主要处理shader中的attribute变量

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface YHCShaderAttribute : NSObject
{
    GLuint _attributeId;
    NSString *_attributeName;
}
@property (nonatomic, assign) GLuint attributeId;
@property (nonatomic, retain) NSString *attributeName;

- (YHCShaderAttribute *)initAttributeWithID:(GLuint)newAttributeId andName:(NSString *)newAttributeName;

@end














































