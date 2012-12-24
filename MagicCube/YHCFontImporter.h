//
//  YHCFontImporter.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define NUM_CHARACTERS 92
#define ALLOWABLE_IN_CHARACTER_WHITESPACE 3

@interface YHCFontImporter : NSObject
{
    //字符图片的名字
    NSString *_characterPageName;
    //字符坐标数组，每个字符有四个坐标值 分别是 左上角 （x,y） 右下角 (x,y)
    int _characterCoords[NUM_CHARACTERS * 4];
    //字符图片大小
    int _characterPageWidth;
    int _characterPageHeight;
}
@property (nonatomic, readonly) int characterPageWidth;
@property (nonatomic, readonly) int characterPageHeight;

- (YHCFontImporter *)init;
- (void)loadCharacterPage:(NSString *)characterPageName;
- (int *)getCoordinateArray;
- (char *)getCharacterIndex;
- (NSString *)getCharacterPageName;

@end










































