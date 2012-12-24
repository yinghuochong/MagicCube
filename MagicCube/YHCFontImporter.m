//
//  YHCFontImporter.m
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "YHCFontImporter.h"

char characterSheetIndex[] =
{"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890-=!@#$%^&*()_+[]\\;',./{}|:\"<>?"};

@implementation YHCFontImporter

@synthesize characterPageWidth = _characterPageWidth;
@synthesize characterPageHeight = _characterPageHeight;

- (YHCFontImporter *)init
{
    if (self = [super init]) {
        _characterPageName = NULL;
    }
    return self;
}
- (void)loadCharacterPage:(NSString *)characterPageName
{
    _characterPageName = characterPageName;
    int characterLineBounds[16];    //存储每一行的上下边界值  共8行  16个值
    int currentCharacterLine = 0;    //当前处理的是哪一行
    BOOL inCharacterLine = FALSE;    //当前是否在处理字符
    
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:_characterPageName ofType:nil]] ;
    CGImageRef imageRef = [image CGImage];
    if (imageRef) {
        size_t imageWidth = CGImageGetWidth(imageRef);
        size_t imageHeight = CGImageGetHeight(imageRef);
        _characterPageWidth = imageWidth;
        _characterPageHeight = imageHeight;
        
        //分配一块内存来保存图片数据，使用RGBA格式
        GLubyte *imageData = (GLubyte *)malloc(imageWidth*imageHeight*4);
        memset(imageData, 0, (imageWidth*imageHeight*4));
        CGContextRef imageContextRef = CGBitmapContextCreate(imageData, imageWidth, imageHeight, 8, imageWidth*4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
        CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)imageWidth,(CGFloat)imageHeight), imageRef);
        CGContextRelease(imageContextRef);
        
        //找到每行字符 的最高和最低的位置    保存到characterLineBounds
        for (int i=0; i<imageHeight; i++) {
            BOOL cleanLine = TRUE;  //未有检测到任何像素
            for (int j=0; j<(imageWidth*4); j+=4) {
                int pixelPos = (i*imageWidth*4) + j;
                if (imageData[pixelPos]<250 || imageData[pixelPos+1]<250 || imageData[pixelPos+2]<250) {
                    cleanLine = FALSE;
                    break;
                }
            }
            if (cleanLine == FALSE) {
                if (inCharacterLine == FALSE) {
                    characterLineBounds[currentCharacterLine++] = i+3;
                    inCharacterLine = TRUE;
                }
            }else{
                if (inCharacterLine == TRUE) {
                    characterLineBounds[currentCharacterLine++] = (i-1)+3;
                    inCharacterLine = FALSE;
                }
            }
        }
        // 找到每个字符的左上角和右下角的位置，保存到 _characterCoords 中， 不包括开始两个用来确定边界的字符
        int currentCharacter = 0;
        for (int i=0; i<16; i+=2) {
            BOOL inCharacter = FALSE;
            int inCharacterNumber = 0;
            BOOL cleanColumn = TRUE;
            int spacingCounter = 0;
            
            for (int j=0; j<(imageWidth*4); j+=4) {
                cleanColumn = TRUE;
                for (int k=characterLineBounds[i]; k<characterLineBounds[i+1]; k++) {
                    int pixelInColumn = k*(imageWidth*4)+j;
                    if (imageData[pixelInColumn]<250 || imageData[pixelInColumn+1]<250 || imageData[pixelInColumn+2]<250) {
                        cleanColumn = FALSE;
                        break;
                    }
                }
                if (cleanColumn == FALSE) {
                    if (inCharacter == FALSE) {
                        if (inCharacterNumber++ > 1) {
                            _characterCoords[currentCharacter++] = (j/4)-1;
                            _characterCoords[currentCharacter++] = characterLineBounds[i]-1;
                            spacingCounter = 0;
                        }
                        inCharacter = TRUE;
                    }
                }else{
                    if (inCharacter == TRUE) {
                        if (spacingCounter++ > ALLOWABLE_IN_CHARACTER_WHITESPACE) {
                            if (inCharacterNumber > 2) {
                                _characterCoords[currentCharacter++] = (j/4)-1+2-spacingCounter;
                                _characterCoords[currentCharacter++] = characterLineBounds[i+1]+2-spacingCounter;
                            }
                            spacingCounter = 0;
                            inCharacter = FALSE;
                        }
                    }
                }
            }
        }
        [image release];
        free(imageData);
    }
}

- (int *)getCoordinateArray
{
    return _characterCoords;
}

- (char *)getCharacterIndex
{
    return characterSheetIndex;
}

- (NSString *)getCharacterPageName
{
    return _characterPageName;
}

@end