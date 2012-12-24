//
//  Cube.h
//  MagicCube
//
//  Created by lihua liu on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>

#define FACE_NONE  -1
#define FACE_FRONT  0
#define FACE_RIGHT  1
#define FACE_BACK   2
#define FACE_LEFT   3
#define FACE_BOTTOM 4
#define FACE_TOP    5


// 这里是构造魔方用到的小方块   
//在程序中需要构造27个

struct Cube {
    GLfloat _vertices[78];   
    GLfloat _textureCoords[52];  
    
    GLbyte _row;
    GLbyte _col;
    GLbyte _layer;
    
    GLfloat _rotateMatrix[16];
    
    GLubyte _colors[104]; //select color  
    
    GLint _curIndex ; // 0,1,2,3.......26
};
typedef struct Cube Cube;