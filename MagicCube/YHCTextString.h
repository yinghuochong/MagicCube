//
//  YHCTextString.h
//  TouchTargets
//
//  Created by lihua liu on 12-8-28.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "YHCFontImporter.h"

@interface YHCTextString : NSObject
{
    NSString *_textString;  //要显示的字符串
    
    GLfloat *_vertexArray;  //字符串对应的顶点数组  每个字符两个三角形  每个三角形三个顶点 
    GLfloat *_textureCoordArray;    //字符串对应的贴图坐标 和顶点数组对应
    
    BOOL _alive;     //是否字符串正在显示
    
    float _position[3];  //字符串的位置，要显示 字符串的左下角位置  这里是屏幕位置
    float _color[3];     //字符串的颜色
    float _alpha;        //透明度
    float _lifespan;     //该字符串要显示的 时间长度  0 为永久显示
    float _decayAt;      //在 lifespan 的哪个点开始隐退
    float _lifeleft;     //剩余显示时间
    float _drift[3];         // 每次 update 偏移量 
    int _size;               //字体高度
    float _sizeConversion;   //计算屏幕大小到OpenGL大小的转换
    BOOL _centered;          //是否居中   相对于 position
    float _centerOffset;     //相对于中心点的偏移量
    
    int _screenWidth,_screenHeight;     //屏幕的大小
    YHCFontImporter *_fontImporter;     
}

- (YHCTextString *)initWithString:(NSString *)newTextString;

- (void)setString:(NSString *)newTextString;
- (void)setImporter:(YHCFontImporter *)newImporter;

- (void)setPositionX:(int)newX andY:(int)newY andZ:(int)newZ;
- (void)setColorRed:(int)newRed andGreen:(int)newGreen andBlue:(int)newBlue;
- (void)setColorAlpha:(int)newAlpha;
- (void)setLifespan:(int)newLifespan withDecayAt:(int)newDecayAt;
- (void)setDriftX:(int)newX andY:(int)newY andZ:(int)newZ;
- (void)setSize:(int)newSize;
- (void)setCentered:(BOOL)newCentered;

- (NSString *)getString;
- (YHCFontImporter *)getImporter;

- (float *)getOpenGLPosition;
- (float *)getOpenGLColors;
- (float)getOpenGLAlpha;
- (int)getSize;
- (BOOL)isCentered;
- (BOOL)isAlive;

- (float *)getOpenGLVertexArray;
- (float *)getOpenGLTextureCoordArray;
- (int)getOpenGLNumVertices;

- (void)populateVertexArray;
- (void)populateTextureCoordArray;
- (void)update;

@end





































