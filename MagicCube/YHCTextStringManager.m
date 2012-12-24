//
//  YHCTextStringManager.m
//  TouchTargets
//
//  Created by lihua liu on 12-8-28.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "YHCTextStringManager.h"

enum {
    ATTRIBUTE_VERTEX,
    ATTRIBUTE_TEXTURE_COORD,
    NUM_ATTRIBUTES
};
GLint attributes[NUM_ATTRIBUTES];

enum {
    UNIFORM_TEXTURE,
    UNIFORM_COLOR,
    UNIFORM_ALPHA,
    NUM_UNIFORMS
};
GLint unifroms[NUM_UNIFORMS];

@implementation YHCTextStringManager

- (YHCTextStringManager *)initWithCharacterSheetName : (NSString *)newCharacterSheetName
{
    if (self = [super init]) {
        _fontImporter = [[YHCFontImporter alloc] init];
        [_fontImporter loadCharacterPage:newCharacterSheetName];
        
        [YHCOpenGLTools loadTexture:&_texture fromFile:[_fontImporter getCharacterPageName]];
        
        _program = [[YHCOpenGLProgram alloc] init];
        [_program setVertexShader:@"YHCTextStringManager"];
        [_program setFragmentShader:@"YHCTextStringManager"];
        
        [_program addAttributeLocation:@"ATTRIBUTE_VERTEX" forAttribute:@"vertex"];
        [_program addAttributeLocation:@"ATTRIBUTE_TEXTURE_COORD" forAttribute:@"texture_coord"];
        
        [_program addUniformLocation:@"UNIFORM_TEXTURE" forUniform:@"texture"];
        [_program addUniformLocation:@"UNIFORM_COLOR" forUniform:@"color"];
        [_program addUniformLocation:@"UNIFORM_ALPHA" forUniform:@"alpha"];
        
        [_program compileAndLink];
        
        attributes[ATTRIBUTE_VERTEX] = [_program getAttributeIDForIndex:@"ATTRIBUTE_VERTEX"];
        attributes[ATTRIBUTE_TEXTURE_COORD] = [_program getAttributeIDForIndex:@"ATTRIBUTE_TEXTURE_COORD"];
        
        unifroms[UNIFORM_TEXTURE] = [_program getUniformIDForIndex:@"UNIFORM_TEXTURE"];
        unifroms[UNIFORM_COLOR] = [_program getUniformIDForIndex:@"UNIFORM_COLOR"];
        unifroms[UNIFORM_ALPHA] = [_program getUniformIDForIndex:@"UNIFORM_ALPHA"];
        
        _textStringArray = nil;
    }
    return  self;
}

- (void)addTextString:(YHCTextString *)newTextString
{
    if (_textStringArray == nil) {
        _textStringArray = [[NSMutableArray alloc] init];
    }
    [newTextString setImporter:_fontImporter];
    [_textStringArray addObject:newTextString];
}

- (void)drawTextString:(YHCTextString *)textString
{
    glUseProgram([_program programId]);
    glBindTexture(GL_TEXTURE_2D, _texture);
    
    glUniform1i(unifroms[UNIFORM_TEXTURE], 0);
    glUniform3fv(unifroms[UNIFORM_COLOR], 1, [textString getOpenGLColors]);
    glUniform1f(unifroms[UNIFORM_ALPHA], [textString getOpenGLAlpha]);
    
    glVertexAttribPointer(attributes[ATTRIBUTE_VERTEX], 3, GL_FLOAT, 0, 0, [textString getOpenGLVertexArray]);
    glEnableVertexAttribArray(attributes[ATTRIBUTE_VERTEX]);
    
    glVertexAttribPointer(attributes[ATTRIBUTE_TEXTURE_COORD], 2, GL_FLOAT, 0, 0, [textString getOpenGLTextureCoordArray]);
    glEnableVertexAttribArray(attributes[ATTRIBUTE_TEXTURE_COORD]);
    
#if defined (DEBUG)
    if (![_program validate]) {
        NSLog(@"validate program [%d] failed!",[_program programId]);
        return;
    }
#endif
    glDrawArrays(GL_TRIANGLES, 0, [textString getOpenGLNumVertices]);
    [textString update];
}

- (void)drawAllTextString
{
    if (_textStringArray == nil) {
        return;
    }
    for (int i=[_textStringArray count]-1; i>=0; i--) {
        if (![[_textStringArray objectAtIndex:i] isAlive]) {
            [_textStringArray removeObjectAtIndex:i];
        }
    }
    for (int i=0; i<[_textStringArray count]; i++) {
        [self drawTextString:[_textStringArray objectAtIndex:i]];
    }
    
}

- (void)destroyAllTextStrings
{
    [_textStringArray removeAllObjects];
}

- (void)dealloc {
    [_fontImporter release];
    [_textStringArray release];
    [_program release];
     
    [super dealloc];
}

@end