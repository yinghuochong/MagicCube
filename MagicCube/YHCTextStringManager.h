//
//  YHCTextStringManager.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-28.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHCOpenGLProgram.h"
#import "YHCFontImporter.h"
#import "YHCTextString.h"
#import "YHCOpenGLTools.h"

@interface YHCTextStringManager : NSObject
{
    YHCOpenGLProgram *_program;
    GLuint _texture;
    NSMutableArray *_textStringArray;
    YHCFontImporter *_fontImporter;
}

- (YHCTextStringManager *)initWithCharacterSheetName : (NSString *)newCharacterSheetName;
- (void)addTextString:(YHCTextString *)newTextString;
- (void)drawTextString:(YHCTextString *)textString;
- (void)drawAllTextString;
- (void)destroyAllTextStrings;

@end
