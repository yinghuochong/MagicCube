//
//  YHCTextString.m
//  TouchTargets
//
//  Created by lihua liu on 12-8-28.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "YHCTextString.h"

@implementation YHCTextString

// 由于要 获取OpenGL 大小 故 该类只能在OpenGL context 被创建之后才能进行使用
- (YHCTextString *)initWithString:(NSString *)newTextString
{
    if (self = [super init]) {
        _vertexArray = NULL;
        _textureCoordArray = NULL;
        
        _alive = TRUE;
        
        _color[0] = _color[1] = _color[2] = 0; //颜色初始化为黑色
        _alpha = 1; //完全不透明
        
        _lifespan = 0;  // 默认永久显示
        _lifeleft = 0;
        _decayAt = 0;
        
        _drift[0] = _drift[1] = _drift[2] = 0;
        
        _centered = TRUE;
        _size = 10;
        
        //        int a,b;
        //        
        //        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &a);
        //        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &b);
        
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &_screenWidth);
        glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &_screenHeight);
        
        [self setString:newTextString];
    }
    return self;
}

- (void)setString:(NSString *)newTextString
{
    if (_textureCoordArray != NULL) {
        free(_textureCoordArray);
        _textureCoordArray = NULL;
    }
    [_textString release];
    _textString = [newTextString retain];
    
    _alive = TRUE;
    _alpha = 1;
    _lifespan = 0;
}

- (void)setImporter:(YHCFontImporter *)newImporter
{
    _fontImporter = newImporter;
}

- (void)setPositionX:(int)newX andY:(int)newY andZ:(int)newZ
{
    float conversionXFactor = 2.0/(float)_screenWidth;
    float conversionYFactor = 2.0/(float)_screenHeight;
    
    _position[0] = conversionXFactor * ((float)newX - (float)_screenWidth/2.0);
    _position[1] = conversionYFactor * ((float)newY - (float)_screenHeight/2.0) * -1;
    _position[2] = 0;
}

- (void)setColorRed:(int)newRed andGreen:(int)newGreen andBlue:(int)newBlue
{
    float conversionFactor = 1.0/(float)255;
    _color[0] = conversionFactor * (float)newRed;
    _color[1] = conversionFactor * (float)newGreen;
    _color[2] = conversionFactor * (float)newBlue;
}

- (void)setColorAlpha:(int)newAlpha
{
    float conversionFactor = 1.0/(float)255;
    _alpha = conversionFactor * (float)newAlpha;
}

- (void)setLifespan:(int)newLifespan withDecayAt:(int)newDecayAt
{
    _lifespan = newLifespan;
    _decayAt = newDecayAt;
    _lifeleft = _lifespan;
}

- (void)setDriftX:(int)newX andY:(int)newY andZ:(int)newZ
{
    float conversionXFactor = 2.0/(float)_screenWidth;
    float conversionYFactor = 2.0/(float)_screenHeight;
    
    _drift[0] = conversionXFactor * (float)newX;
    _drift[1] = conversionYFactor * (float)newY * -1;
    _drift[2] = 0;
}

- (void)setSize:(int)newSize
{
    _size = newSize;
}

- (void)setCentered:(BOOL)newCentered
{
    _centered = newCentered;
}


- (NSString *)getString
{
    return _textString;
}

- (YHCFontImporter *)getImporter
{
    return _fontImporter;
}

- (float *)getOpenGLPosition
{
    return _position;
}

- (float *)getOpenGLColors
{
    return _color;
}

- (float)getOpenGLAlpha
{
    return _alpha;
}

- (int)getSize
{
    return _size;
}

- (BOOL)isCentered
{
    return _centered;
}

- (BOOL)isAlive
{
    return _alive;
}

- (float *)getOpenGLVertexArray
{
    [self populateVertexArray];
    return _vertexArray;
}

- (float *)getOpenGLTextureCoordArray
{
    if (_textureCoordArray == NULL) {
        [self populateTextureCoordArray];
    }
    return _textureCoordArray;
}

// 每个字符六个顶点 
- (int)getOpenGLNumVertices
{
    return [_textString length]*6;
}

//计算字符串顶点坐标
- (void)populateVertexArray
{
    float x, y, z;
    float ulX, ulY, lrX, lrY;  //upper left, lower right
    
    int textStringLength = [_textString length];
    float totalLength = 0; //记录字符串 渲染 的总长度  
    
    if (_vertexArray != NULL) {
        free(_vertexArray);
    }
    _vertexArray = malloc(textStringLength * sizeof(GLfloat)*3*3*2);
    
    x = _position[0];
    y = _position[1];
    z = _position[2];
    
    float conversionXFactor = 2.0/(float)_screenWidth;
    float conversionYFactor = 2.0/(float)_screenHeight;
    
    char *characterIndex = [_fontImporter getCharacterIndex];
    int *characterCoords = [_fontImporter getCoordinateArray];
    
    for (int i = 0; i < textStringLength; i++) {
        unichar currentChar = [_textString characterAtIndex:i];
        BOOL charFound = FALSE;
        
        for (int j=0; j< NUM_CHARACTERS; j++) {
            if (characterIndex[j] == currentChar) {
                int arrayIndex = j*4;
                
                ulX = characterCoords[arrayIndex    ];
                ulY = characterCoords[arrayIndex + 1];
                lrX = characterCoords[arrayIndex + 2];
                lrY = characterCoords[arrayIndex + 3];
                
                int letterWidth = (lrX - ulX);
                int letterHeight = (lrY - ulY);
                
                float characterAspectRatio = (float)letterWidth/(float)letterHeight;
                
                int adjLetterWidth = _size * characterAspectRatio;
                int adjLetterHeight = _size;
                
                totalLength += (adjLetterWidth * conversionXFactor);
                
                int vertexIndex = i * 18;
                
                //左下角
                _vertexArray[vertexIndex    ] = x;
                _vertexArray[vertexIndex + 1] = y;
                _vertexArray[vertexIndex + 2] = z;
                
                //右下
                x += adjLetterWidth * conversionXFactor;
                
                _vertexArray[vertexIndex + 3] = x;
                _vertexArray[vertexIndex + 4] = y;
                _vertexArray[vertexIndex + 5] = z;
                
                //左上
                x -= adjLetterWidth * conversionXFactor;
                y += adjLetterHeight * conversionYFactor;
                
                _vertexArray[vertexIndex + 6] = x;
                _vertexArray[vertexIndex + 7] = y;
                _vertexArray[vertexIndex + 8] = z;
                
                // 第二个三角形 右上
                x += adjLetterWidth * conversionXFactor;
                
                _vertexArray[vertexIndex + 9 ] = x;
                _vertexArray[vertexIndex + 10] = y;
                _vertexArray[vertexIndex + 11] = z;
                
                //左上
                x -= adjLetterWidth * conversionXFactor;
                
                _vertexArray[vertexIndex + 12] = x;
                _vertexArray[vertexIndex + 13] = y;
                _vertexArray[vertexIndex + 14] = z;
                
                //右下
                x += adjLetterWidth * conversionXFactor;
                y -= adjLetterHeight * conversionYFactor;
                
                _vertexArray[vertexIndex + 15] = x;
                _vertexArray[vertexIndex + 16] = y;
                _vertexArray[vertexIndex + 17] = z;
                
                charFound = TRUE;
                break;
            }
        }
        if (charFound == FALSE) {
            currentChar = '-';
            
            for (int j=0; j< NUM_CHARACTERS; j++) {
                if (characterIndex[j] == currentChar) {
                    int arrayIndex = j*4;
                    
                    ulX = characterCoords[arrayIndex    ];
                    ulY = characterCoords[arrayIndex + 1];
                    lrX = characterCoords[arrayIndex + 2];
                    lrY = characterCoords[arrayIndex + 3];
                    
                    int letterWidth = (lrX - ulX);
                    int letterHeight = (lrY - ulY);
                    
                    float characterAspectRatio = (float)letterWidth/(float)letterHeight;
                    
                    int adjLetterWidth = _size * characterAspectRatio;
                    int adjLetterHeight = _size;
                    
                    totalLength += (adjLetterWidth * conversionXFactor);
                    
                    int vertexIndex = i * 18;
                    
                    //左下角
                    _vertexArray[vertexIndex    ] = x;
                    _vertexArray[vertexIndex + 1] = y;
                    _vertexArray[vertexIndex + 2] = z;
                    
                    //右下
                    x += adjLetterWidth * conversionXFactor;
                    
                    _vertexArray[vertexIndex + 3] = x;
                    _vertexArray[vertexIndex + 4] = y;
                    _vertexArray[vertexIndex + 5] = z;
                    
                    //左上
                    x -= adjLetterWidth * conversionXFactor;
                    y += adjLetterHeight * conversionYFactor;
                    
                    _vertexArray[vertexIndex + 6] = x;
                    _vertexArray[vertexIndex + 7] = y;
                    _vertexArray[vertexIndex + 8] = z;
                    
                    // 第二个三角形 右上
                    x += adjLetterWidth * conversionXFactor;
                    
                    _vertexArray[vertexIndex + 9 ] = x;
                    _vertexArray[vertexIndex + 10] = y;
                    _vertexArray[vertexIndex + 11] = z;
                    
                    //左上
                    x -= adjLetterWidth * conversionXFactor;
                    
                    _vertexArray[vertexIndex + 12] = x;
                    _vertexArray[vertexIndex + 13] = y;
                    _vertexArray[vertexIndex + 14] = z;
                    
                    //右下
                    x += adjLetterWidth * conversionXFactor;
                    y -= adjLetterHeight * conversionYFactor;
                    
                    _vertexArray[vertexIndex + 15] = x;
                    _vertexArray[vertexIndex + 16] = y;
                    _vertexArray[vertexIndex + 17] = z;
                    
                    break;
                }
            }
        }
    }
    //如果设置了居中显示  则将所有顶点的x坐标左移 总长度的一半
    if (_centered == TRUE) {
        for (int i = 0; i<(textStringLength * 18); i+=3) {
            _vertexArray[i] -= (totalLength/2.0);
        }
    }
}

//计算字符串的贴图坐标
- (void)populateTextureCoordArray
{
    float s, t;
    float ulX, ulY, lrX, lrY; // 同上
    int textStringLength = [_textString length];
    
    if (_textureCoordArray != NULL) {
        free(_textureCoordArray);
    }
    //  2个三角形 * 3个顶点  每个顶点坐标 x,y
    _textureCoordArray = malloc(textStringLength * sizeof(GLfloat) * 2 * 3 *2);
    s = t = 0;
    
    float conversionXFactor = 1.0/(float)_fontImporter.characterPageWidth;
    float conversionYFactor = 1.0/(float)_fontImporter.characterPageHeight;
    
    char *characterIndex = [_fontImporter getCharacterIndex];
    int *characterCoords = [_fontImporter getCoordinateArray];
    
    for (int i=0; i<textStringLength; i++) {
        char currentChar = [_textString characterAtIndex:i];
        float textureCoords[8];
        memset(textureCoords, 0, sizeof(float)*8);
        
        for (int j=0; j<NUM_CHARACTERS; j++) {
            if (characterIndex[j] == currentChar) {
                int arrayIndex = j*4;
                
                ulX = characterCoords[arrayIndex    ];
                ulY = characterCoords[arrayIndex + 1];
                lrX = characterCoords[arrayIndex + 2];
                lrY = characterCoords[arrayIndex + 3];
                
                //贴图坐标从左下角开始 ，记录的边界坐标是从右上角开始的， 这里先进行转换
                int pageHeight = _fontImporter.characterPageHeight;
                //左下
                textureCoords[0] = ulX;
                textureCoords[1] = pageHeight - lrY;
                //左上
                textureCoords[2] = ulX;
                textureCoords[3] = pageHeight - ulY;
                //右下
                textureCoords[4] = lrX;
                textureCoords[5] = pageHeight - lrY;
                //右上
                textureCoords[6] = lrX;
                textureCoords[7] = pageHeight - ulY;
                break;
            }
        }
        
        int textureCoordIndex = i*12;
        _textureCoordArray[textureCoordIndex    ] = textureCoords[0]*conversionXFactor;
        _textureCoordArray[textureCoordIndex + 1] = textureCoords[1]*conversionYFactor;
        
        _textureCoordArray[textureCoordIndex + 2] = textureCoords[4]*conversionXFactor;
        _textureCoordArray[textureCoordIndex + 3] = textureCoords[5]*conversionYFactor;
        
        _textureCoordArray[textureCoordIndex + 4] = textureCoords[2]*conversionXFactor;
        _textureCoordArray[textureCoordIndex + 5] = textureCoords[3]*conversionYFactor;
        
        _textureCoordArray[textureCoordIndex + 6] = textureCoords[6]*conversionXFactor;
        _textureCoordArray[textureCoordIndex + 7] = textureCoords[7]*conversionYFactor;
        
        _textureCoordArray[textureCoordIndex + 8] = textureCoords[2]*conversionXFactor;
        _textureCoordArray[textureCoordIndex + 9] = textureCoords[3]*conversionYFactor;
        
        _textureCoordArray[textureCoordIndex + 10] = textureCoords[4]*conversionXFactor;
        _textureCoordArray[textureCoordIndex + 11] = textureCoords[5]*conversionYFactor;
        
    }
}
- (void)update
{
    _position[0] += _drift[0];
    _position[1] += _drift[1];
    _position[2] += _drift[2];
    
    if (_lifespan > 0) {
        _lifeleft -- ;
        
        if (_lifeleft <= 0) {
            _alive = FALSE;
        }else{
            if (_lifeleft <= _decayAt) {
                _alpha = _lifeleft / _decayAt;
            }
        }
    }
}


- (void)dealloc
{
    if (_vertexArray != NULL) {
        free(_vertexArray);
        _vertexArray = NULL;
    }
    if (_textureCoordArray != NULL) {
        free(_textureCoordArray);
        _textureCoordArray = NULL;
    }
    [_textString release];
    [super dealloc];
}

@end