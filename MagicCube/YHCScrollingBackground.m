//
//  YHCScrollingBackground.m
//  TouchTargets
//
//  Created by lihua liu on 12-8-30.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "YHCScrollingBackground.h"

#define SCROLL_AMOUNT -0.005

enum {
    ATTRIBUTE_BG_VERTEX,
    ATTRIBUTE_BG_TEXTURE_COORD,
    NUM_BG_ATTRIBUTES
};
GLint attributes[NUM_BG_ATTRIBUTES];

enum {
    UNIFORM_BG_TEXTURE,
    NUM_BG_UNIFORMS
};
GLint uniforms[NUM_BG_UNIFORMS];

static GLfloat myVertexArray[] = {
    -1, -1,  0,
     1, -1,  0,
    -1,  1,  0,
     1,  1,  0,
    -1,  1,  0,
     1, -1,  0
};

GLfloat textureCoordArray[12];

@implementation YHCScrollingBackground

- (YHCScrollingBackground *)init
{
    if((self = [super init])) {
        [YHCOpenGLTools loadTexture:&_texture fromFile:@"background.png"];
        
        _program = [[YHCOpenGLProgram alloc] init];
        
        [_program setVertexShader:@"YHCScrollingBackground"];
        [_program setFragmentShader:@"YHCScrollingBackground"];
        
        [_program addAttributeLocation:@"ATTRIBUTE_BG_VERTEX" forAttribute:@"vertex"];
        [_program addAttributeLocation:@"ATTRIBUTE_BG_TEXTURE_COORD" forAttribute:@"texture_coord"];
        
        [_program addUniformLocation:@"UNIFORM_BG_TEXTURE" forUniform:@"texture"];
        
        [_program compileAndLink];
        
        attributes[ATTRIBUTE_BG_VERTEX] = [_program getAttributeIDForIndex:@"ATTRIBUTE_BG_VERTEX"];
        attributes[ATTRIBUTE_BG_TEXTURE_COORD] = [_program getAttributeIDForIndex:@"ATTRIBUTE_BG_TEXTURE_COORD"];
        
        uniforms[UNIFORM_BG_TEXTURE] = [_program getUniformIDForIndex:@"UNIFORM_BG_TEXTURE"];
        
        textureCoordArray[0] = 0;
        textureCoordArray[1] = 0;
        
        textureCoordArray[2] = 1;
        textureCoordArray[3] = 0;
        
        textureCoordArray[4] = 0;
        textureCoordArray[5] = 1;
        
        textureCoordArray[6] = 1;
        textureCoordArray[7] = 1;
        
        textureCoordArray[8] = 0;
        textureCoordArray[9] = 1;
        
        textureCoordArray[10] = 1;
        textureCoordArray[11] = 0;
        
        _scrolling = FALSE;
    }
    
    return self;
}

- (void)startScrolling
{
    _scrolling = TRUE;
}

- (void)stopScrolling
{
    _scrolling = FALSE;
}

- (void)draw
{
    glUseProgram([_program programId]);
    
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glUniform1i(uniforms[UNIFORM_BG_TEXTURE], 0);
    
    glVertexAttribPointer(attributes[ATTRIBUTE_BG_VERTEX], 3, GL_FLOAT, 0, 0, myVertexArray);
    glEnableVertexAttribArray(attributes[ATTRIBUTE_BG_VERTEX]);
    
    glVertexAttribPointer(attributes[ATTRIBUTE_BG_TEXTURE_COORD], 2, GL_FLOAT, 0, 0, textureCoordArray);
    glEnableVertexAttribArray(attributes[ATTRIBUTE_BG_TEXTURE_COORD]);
    
#if defined(DEBUG)
    if(![_program validate]) {
        NSLog(@"Validate program [%d]ss failed!", [_program programId]);
        return;
    }
#endif
    
    glDrawArrays(GL_TRIANGLES, 0, 6);
    
    // If scrolling, update texture coordinates
    
    if(_scrolling == TRUE) {
        textureCoordArray[0] += SCROLL_AMOUNT;
        textureCoordArray[2] += SCROLL_AMOUNT;
        textureCoordArray[4] += SCROLL_AMOUNT;
        textureCoordArray[6] += SCROLL_AMOUNT;
        textureCoordArray[8] += SCROLL_AMOUNT;
        textureCoordArray[10] += SCROLL_AMOUNT;
    }
}
@end
