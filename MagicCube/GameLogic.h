//
//  GameLogic.h
//  MagicCube
//
//  Created by lihua liu on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import "Cube.h"
#import "YHCOpenGLProgram.h"

#define ROTATE_NONE            -1
#define ROTATE_ALL              0
// from + to -
#define ROTATE_X_CLOCKWISE      1
#define ROTATE_X_ANTICLOCKWISE  2
#define ROTATE_Y_CLOCKWISE      3
#define ROTATE_Y_ANTICLOCKWISE  4
#define ROTATE_Z_CLOCKWISE      5
#define ROTATE_Z_ANTICLOCKWISE  6

//这里是魔方的主要逻辑

@interface GameLogic
+ (void)resetColorFlag ;
+ (void)initVecteAndTextCoord:(Cube *)cube:(GLint)row:(GLint)col:(GLint)layer;
+ (void) checkRotationState: (GLint *) rotationState currentSlice:(GLbyte*) currentSlice cube1:(Cube *)cube1 face1:(GLint)face1 cube2:(Cube *)cube2 face2:(GLint)face2 flag:(GLint)flag;
+ (void)getNextPoint:(CGPoint)point1 point2:(CGPoint)point2 nextPoint:(CGPoint *)point3 inc:(GLint)inc flag:(GLint)flag;
void changeTextureCoords(GLfloat * textureCoord1 ,GLbyte index1 ,GLfloat * textureCoord2,GLbyte index2);
+ (void)sliceRotateWith :(GLint)rcl rotationState:(GLint) rotationState cubes:(Cube *)cubes;
void swapTexture(GLint* array,int gap,Cube *cubes);

void changeColors(GLubyte * color1 ,GLbyte index1 ,GLubyte * color2,GLbyte index2);
void swapColors(GLint* array,int gap,Cube *cubes);
void find(Cube *cubes,int cubeIndex,int face,int *c,int *f);
+ (void)clearColor: (Cube *)cubes;
+ (Boolean)isOK:(Cube*)cubes;
+ (void)switchPrograme:(YHCOpenGLProgram *)program;
@end
