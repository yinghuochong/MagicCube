//
//  GameLogic.m
//  MagicCube
//
//  Created by lihua liu on 12-8-13.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "GameLogic.h"
#import "Cube.h"
#import "MatrixTools.h"


#define MOVE 2.0

#define FC     0.33,1.00, 0.33,0.67, 0.67,1.00, 0.67,0.67  //1 Front face
#define RC     0.67,0.67, 0.33,0.67, 0.67,0.33, 0.33,0.33  //2 Right face
#define BC     0.33,0.33, 0.33,0.00, 0.67,0.33, 0.67,0.00  //3 Back face
#define LC     0.33,1.00, 0.00,1.00, 0.33,0.67, 0.00,0.67  //4 Left face
#define DC     0.33,0.67, 0.00,0.67, 0.33,0.33, 0.00,0.33  //5  down face
#define TC     0.00,0.33, 0.00,0.00, 0.33,0.33, 0.33,0.00  //6  Top face
#define NC     1.00,1.00, 1.00,1.00, 1.00,1.00, 1.00,1.00  //no color
#define MV     0.00,0.33, 0.00,0.33                        // move to top

@implementation GameLogic


static const GLfloat cubeVerticesStrip[] = {
    -1,-1, 1,  1,-1, 1, -1, 1, 1,  1, 1, 1,     // Front face
    1, 1, 1,  1,-1, 1,  1, 1,-1,  1,-1,-1,     // Right face
    1,-1,-1, -1,-1,-1,  1, 1,-1, -1, 1,-1,     // Back face
    -1, 1,-1, -1,-1,-1, -1, 1, 1, -1,-1, 1,     // Left face
    -1,-1, 1, -1,-1,-1,  1,-1, 1,  1,-1,-1,     // Bottom face
    1,-1,-1, -1, 1, 1,                         // move to top
    -1, 1, 1,  1, 1, 1, -1, 1,-1,  1, 1,-1      // Top Face
};
static const GLfloat textureCoords[][52]={
    FC,NC,NC,LC,NC,MV,TC,   FC,NC,NC,NC,NC,MV,TC,   FC,RC,NC,NC,NC,MV,TC,   FC,NC,NC,LC,NC,MV,NC,
    FC,NC,NC,NC,NC,MV,NC,   FC,RC,NC,NC,NC,MV,NC,   FC,NC,NC,LC,DC,MV,NC,   FC,NC,NC,NC,DC,MV,NC,
    FC,RC,NC,NC,DC,MV,NC,   NC,NC,NC,LC,NC,MV,TC,   NC,NC,NC,NC,NC,MV,TC,   NC,RC,NC,NC,NC,MV,TC,
    NC,NC,NC,LC,NC,MV,NC,   NC,NC,NC,NC,NC,MV,NC,   NC,RC,NC,NC,NC,MV,NC,   NC,NC,NC,LC,DC,MV,NC,
    NC,NC,NC,NC,DC,MV,NC,   NC,RC,NC,NC,DC,MV,NC,   NC,NC,BC,LC,NC,MV,TC,   NC,NC,BC,NC,NC,MV,TC,
    NC,RC,BC,NC,NC,MV,TC,   NC,NC,BC,LC,NC,MV,NC,   NC,NC,BC,NC,NC,MV,NC,   NC,RC,BC,NC,NC,MV,NC,
    NC,NC,BC,LC,DC,MV,NC,   NC,NC,BC,NC,DC,MV,NC,   NC,RC,BC,NC,DC,MV,NC,
};

static GLubyte colorFlag = 1;

//将colorFlag 重置为1   因为其为静态变量
+ (void)resetColorFlag 
{
    colorFlag = 1;
}

+ (void)initVecteAndTextCoord:(Cube *)cube:(GLint)row:(GLint)col:(GLint)layer
{
    GLfloat moveX = MOVE * (col-1);
    GLfloat moveY = -MOVE * (row-1);
    GLfloat moveZ = -MOVE * (layer-1);
    for (int i=0,j=0; i<78; i+=3) {
        cube->_vertices[i] = cubeVerticesStrip[j++] + moveX;
        cube->_vertices[i+1] = cubeVerticesStrip[j++] + moveY;
        cube->_vertices[i+2] = cubeVerticesStrip[j++] + moveZ;
    }
    int index = row*3+col+layer*9;
    for (int i=0; i<52; i++) {
        cube->_textureCoords[i] = textureCoords[index][i];
    }
    
    cube->_row = row;
    cube->_col = col;
    cube->_layer = layer;
    
    for (int i=0; i<104; i++) {
        cube->_colors[i]=0;
    }
    cube->_colors[0] = cube->_colors[4] = cube->_colors[8] = cube->_colors[12] = colorFlag++;
    cube->_colors[16] = cube->_colors[20] = cube->_colors[24] = cube->_colors[28] = colorFlag++;
    cube->_colors[32] = cube->_colors[36] = cube->_colors[40] = cube->_colors[44] = colorFlag++;
    cube->_colors[48] = cube->_colors[52] = cube->_colors[56] = cube->_colors[60] = colorFlag++;
    cube->_colors[64] = cube->_colors[68] = cube->_colors[72] = cube->_colors[76] = colorFlag++;
    cube->_colors[80] =colorFlag-1; cube->_colors[84] = colorFlag;
    cube->_colors[88] = cube->_colors[92] = cube->_colors[96] = cube->_colors[100] = colorFlag++;
    
    [MatrixTools applyIdentity:cube->_rotateMatrix];
}

+ (void)clearColor: (Cube *)cubes
{
    int flag=0;
    for(int i = 0 ;i <27;i++){
        if (cubes[i]._layer != 0) {
            cubes[i]._colors[0] = cubes[i]._colors[4] = cubes[i]._colors[8] = cubes[i]._colors[12] = flag;
        }
        if (cubes[i]._layer != 2) {
            cubes[i]._colors[32] = cubes[i]._colors[36] = cubes[i]._colors[40] = cubes[i]._colors[44] = flag;
        }
        if (cubes[i]._row != 0) {
            cubes[i]._colors[88] = cubes[i]._colors[92] = cubes[i]._colors[96] = cubes[i]._colors[100] = flag;
        }
        if (cubes[i]._row != 2) {
            cubes[i]._colors[64] = cubes[i]._colors[68] = cubes[i]._colors[72] = cubes[i]._colors[76] = flag;
        }
        if (cubes[i]._col != 0) {
            cubes[i]._colors[48] = cubes[i]._colors[52] = cubes[i]._colors[56] = cubes[i]._colors[60] = flag;
        }
        if (cubes[i]._col != 2) {
            cubes[i]._colors[16] = cubes[i]._colors[20] = cubes[i]._colors[24] = cubes[i]._colors[28] = flag;
        }
    }
}

+ (void) checkRotationState: (GLint *) rotationState currentSlice:(GLbyte*) currentSlice cube1:(Cube *)cube1 face1:(GLint)face1 cube2:(Cube *)cube2 face2:(GLint)face2 flag:(GLint)flag
{
    
    if (flag == -1) {
        Cube *temp = cube1;
        cube1 = cube2;
        cube2 = temp;
    }
    
    int row1 = cube1->_row, col1 = cube1->_col, layer1 = cube1->_layer;
    int row2 = cube2->_row, col2 = cube2->_col, layer2 = cube2->_layer;
    
    if ((row1==row2 && col1 < col2 && layer1 == layer2 && layer1 == 0 && face1 == FACE_FRONT) || 
        (row1 == row2 && col1 == col2 && layer1 < layer2 && col1 == 2 && face1 == FACE_RIGHT) || 
        (row1 == row2 && col1 > col2 && layer1 == layer2 && layer1 == 2 && face1 == FACE_BACK)|| 
        (row1 == row2 && col1 == col2 && layer1 > layer2 && col1 == 0 && face1 == FACE_LEFT) ||
        (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_LEFT&&face2==FACE_FRONT)||(face1 == FACE_FRONT&&face2==FACE_RIGHT)||(face1 == FACE_RIGHT&&face2==FACE_BACK)||(face1 == FACE_BACK&&face2==FACE_LEFT))) )  {
        *rotationState = ROTATE_Y_ANTICLOCKWISE;
        currentSlice[0] =row1; 
        currentSlice[1] =-1;
        currentSlice[2] =-1;
    }else if ((row1 == row2 && col1 < col2 && layer1 == layer2 && layer1 == 2 && face1 == FACE_BACK) ||
              (row1 == row2 && col1 == col2 && layer1 < layer2 && col1 == 0 && face1 == FACE_LEFT) || 
              (row1 == row2 && col1 > col2 && layer1 == layer2 && layer1 == 0 && face1 == FACE_FRONT)|| 
              (row1 == row2 && col1 == col2 && layer1 > layer2 && col1 == 2 && face1 == FACE_RIGHT) ||
              (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_FRONT&&face2==FACE_LEFT)||(face1 == FACE_RIGHT&&face2==FACE_FRONT)||(face1 == FACE_BACK&&face2==FACE_RIGHT)||(face1 == FACE_LEFT&&face2==FACE_BACK))))  {
        *rotationState = ROTATE_Y_CLOCKWISE;
        currentSlice[0] =row1; 
        currentSlice[1] =-1;
        currentSlice[2] =-1;
    }else if ((row1 == row2 && col1 == col2 && layer1 < layer2 && row1 == 0  && face1 == FACE_TOP) || 
              (row1 > row2 && col1 == col2 && layer1 == layer2 && layer1 == 0  && face1 == FACE_FRONT)||
              (row1 < row2 && col1 == col2 && layer1 == layer2 && layer1 == 2  && face1 == FACE_BACK)||
              (row1 == row2 && col1 == col2 && layer1 > layer2 && row1 == 2  && face1 == FACE_BOTTOM)||
              (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_FRONT&&face2==FACE_TOP)||(face1 == FACE_TOP&&face2==FACE_BACK)||(face1 == FACE_BACK&&face2==FACE_BOTTOM)||(face1 == FACE_BOTTOM&&face2==FACE_FRONT))))  {
        *rotationState = ROTATE_X_CLOCKWISE;
        currentSlice[0] =-1; 
        currentSlice[1] =col1;
        currentSlice[2] =-1;
    }else if ((row1 == row2 && col1 == col2 && layer1 < layer2 && row1 == 2 && face1 == FACE_BOTTOM) || 
              (row1 > row2 && col1 == col2 && layer1 == layer2 && layer1 == 2 && face1 == FACE_BACK) ||
              (row1 < row2 && col1 == col2 && layer1 == layer2 && layer1 == 0 && face1 == FACE_FRONT)||
              (row1 == row2 && col1 == col2 && layer1 > layer2 && row1 == 0 && face1 == FACE_TOP)||  
              (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_TOP&&face2==FACE_FRONT)||(face1 == FACE_BACK&&face2==FACE_TOP)||(face1 == FACE_BOTTOM&&face2==FACE_BACK)||(face1 == FACE_FRONT&&face2==FACE_BOTTOM))))  {
        *rotationState = ROTATE_X_ANTICLOCKWISE;
        currentSlice[0] =-1; 
        currentSlice[1] =col1;
        currentSlice[2] =-1;
    }else if ((row1 == row2 && col1 < col2 && layer1 == layer2 && row1 == 0 && face1 == FACE_TOP) || 
              (row1 < row2 && col1 == col2 && layer1 == layer2 && col1 == 2 && face1 == FACE_RIGHT) ||
              (row1 == row2 && col1 > col2 && layer1 == layer2 && row1 == 2 && face1 == FACE_BOTTOM) ||
              (row1 > row2 && col1 == col2 && layer1 == layer2 && col1 == 0 && face1 == FACE_LEFT)||
              (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_TOP&&face2==FACE_RIGHT)||(face1 == FACE_RIGHT&&face2==FACE_BOTTOM)||(face1 == FACE_BOTTOM&&face2==FACE_LEFT)||(face1 == FACE_LEFT&&face2==FACE_TOP))))  {
        *rotationState = ROTATE_Z_CLOCKWISE;
        currentSlice[0] =-1; 
        currentSlice[1] =-1;
        currentSlice[2] =layer1;
    }else if ((row1 == row2 && col1 < col2 && layer1 == layer2 && row1 == 2 && face1 == FACE_BOTTOM) || 
              (row1 < row2 && col1 == col2 && layer1 == layer2 && col1 == 0 && face1 == FACE_LEFT) ||
              (row1 == row2 && col1 > col2 && layer1 == layer2 && row1 == 0 && face1 == FACE_TOP) ||
              (row1 > row2 && col1 == col2 && layer1 == layer2 && col1 == 2 && face1 == FACE_RIGHT)||
              (row1 == row2 && col1 == col2 && layer1 == layer2 && ((face1 == FACE_RIGHT&&face2==FACE_TOP)||(face1 == FACE_TOP&&face2==FACE_LEFT)||(face1 == FACE_LEFT&&face2==FACE_BOTTOM)||(face1 == FACE_BOTTOM&&face2==FACE_RIGHT))))  {
        *rotationState = ROTATE_Z_ANTICLOCKWISE;
        currentSlice[0] =-1; 
        currentSlice[1] =-1;
        currentSlice[2] =layer1;                    
    }
    NSLog(@"*rotationState     %d",*rotationState);
}
+ (void)getNextPoint:(CGPoint)point1 point2:(CGPoint)point2 nextPoint:(CGPoint *)point3 inc:(GLint)inc flag:(GLint)flag;
{
    GLfloat slopeX = 0,  slopeY = 0;
    GLfloat deltaX = fabsf(point2.x - point1.x);
    GLfloat deltaY = fabsf(point2.y - point1.y);
    
    slopeY = fabsf(deltaX==0?0:deltaY/deltaX);
    slopeX = fabsf(deltaY==0?0:deltaX/deltaY);
    
    if (point1.x<=point2.x && point1.y<=point2.y){
        if (deltaX>deltaY)
            *point3 = CGPointMake(point2.x+inc, point2.y+inc*slopeY);
        else
            *point3 = CGPointMake(point2.x+inc*slopeX, point2.y+inc);
    }
    else if (point1.x>=point2.x && point1.y>=point2.y) {
        if (deltaX>deltaY)
            *point3 = CGPointMake(point2.x-inc, point2.y-inc*slopeY);
        else
            *point3 = CGPointMake(point2.x-inc*slopeX, point2.y-inc);
    }
    else if (point1.x<=point2.x && point1.y>=point2.y) {
        if (deltaX>deltaY)
            *point3 = CGPointMake(point2.x+inc, point2.y-inc*slopeY);
        else
            *point3 = CGPointMake(point2.x+inc*slopeX, point2.y-inc);
    }
    else if (point1.x>=point2.x && point1.y<=point2.y){ 
        if (deltaX>deltaY)
            *point3 = CGPointMake(point2.x-inc, point2.y+inc*slopeY);
        else
            *point3 = CGPointMake(point2.x-inc*slopeX, point2.y+inc);
    }
}


void changeColors(GLubyte * color1 ,GLbyte index1 ,GLubyte * color2,GLbyte index2)
{
    GLint temp1 = (index1==5?88:index1*16);
    GLint temp2 = (index2==5?88:index2*16);
    for (int i=0; i<16; i++) {
        color1[temp1+i] = color2[temp2+i];
    }
}

void find(Cube *cubes,int cubeIndex,int face,int *c,int *f)
{
    for (int i=0; i<27; i++) {
        if(cubes[i]._row*3+cubes[i]._col+cubes[i]._layer*9 == cubeIndex){
            *c = i;
            break;
        }
    }
    //find color same
    for (int i=0; i<80; i+=16) {
        if ((cubes[*c]._colors[i]-1)%6 == face) {
            *f= i/16;
            return;
        }
    }
    if ((cubes[*c]._colors[88]-1)%6 == face) {
        *f=5;
        return;
    }
    
    for (int i=0; i<80; i+=16) {
        if (cubes[*c]._colors[i] == 0) {
            *f= i/16;
            return;
        }
    }
    if (cubes[*c]._colors[88] == 0) {
        *f=5;
        return;
    }
}

void swapColors(GLint* array,int gap,Cube *cubes)
{
    GLubyte temp[16];
    int tempqueue[56];
    for (int i=0; i<56; i+=8) {
        find(cubes, array[i]+gap, array[i+1], &tempqueue[i], &tempqueue[i+1]);
        find(cubes, array[i+2]+gap, array[i+3], &tempqueue[i+2], &tempqueue[i+3]);
        find(cubes, array[i+4]+gap, array[i+5], &tempqueue[i+4], &tempqueue[i+5]);
        find(cubes, array[i+6]+gap, array[i+7], &tempqueue[i+6], &tempqueue[i+7]); 
    }
    for (int i=0; i<56; i+=8) {
        changeColors(temp,0 ,cubes[tempqueue[i]]._colors,tempqueue[i+1]);
        changeColors(cubes[tempqueue[i]]._colors,tempqueue[i+1] ,cubes[tempqueue[i+2]]._colors,tempqueue[i+3]);
        changeColors(cubes[tempqueue[i+2]]._colors,tempqueue[i+3] ,cubes[tempqueue[i+4]]._colors,tempqueue[i+5]);
        changeColors(cubes[tempqueue[i+4]]._colors,tempqueue[i+5] ,cubes[tempqueue[i+6]]._colors,tempqueue[i+7]);
        changeColors(cubes[tempqueue[i+6]]._colors,tempqueue[i+7] ,temp,0);
    }
     
    GLbyte tr,tc,tl;
    int c1,f1,c2,f2,c3,f3,c4,f4;
    for (int i=0; i<16; i+=8) {
        find(cubes, array[i]+gap, array[i+1], &c1, &f1);
        find(cubes, array[i+2]+gap, array[i+3], &c2, &f2);
        find(cubes, array[i+4]+gap, array[i+5], &c3, &f3);
        find(cubes, array[i+6]+gap, array[i+7], &c4, &f4);
        
        tr= cubes[c1]._row; 
        tc = cubes[c1]._col; 
        tl = cubes[c1]._layer;
        
        cubes[c1]._row = cubes[c2]._row; 
        cubes[c1]._col = cubes[c2]._col; 
        cubes[c1]._layer = cubes[c2]._layer;
  
        cubes[c2]._row = cubes[c3]._row; 
        cubes[c2]._col = cubes[c3]._col; 
        cubes[c2]._layer = cubes[c3]._layer;
        
        cubes[c3]._row = cubes[c4]._row; 
        cubes[c3]._col = cubes[c4]._col; 
        cubes[c3]._layer = cubes[c4]._layer;
        
        cubes[c4]._row = tr; 
        cubes[c4]._col = tc; 
        cubes[c4]._layer = tl;
    }
}

+ (void)sliceRotateWith :(GLint)rcl rotationState:(GLint) rotationState cubes:(Cube *)cubes
{
    if (rotationState ==ROTATE_Z_ANTICLOCKWISE ) {
        GLint squence[56] = {1,5,3,3,7,4,5,1,
                             0,3,6,4,8,1,2,5,
                             0,5,6,3,8,4,2,1,
                             0,0,6,0,8,0,2,0,
                             1,0,3,0,7,0,5,0,
                             0,2,6,2,8,2,2,2,
                             1,2,3,2,7,2,5,2};  
        swapColors(squence,rcl*9,cubes);
    }else if(rotationState == ROTATE_Z_CLOCKWISE){
        GLint squence[56] = {1,5,5,1,7,4,3,3,
                             0,3,2,5,8,1,6,4,
                             0,5,2,1,8,4,6,3,
                             0,0,2,0,8,0,6,0,
                             1,0,5,0,7,0,3,0,
                             0,2,2,2,8,2,6,2,
                             1,2,5,2,7,2,3,2};  
        swapColors(squence,rcl*9,cubes);    
    }else if (rotationState ==ROTATE_Y_ANTICLOCKWISE ) {
        GLint squence[56] = {1,0,11,1,19,2,9,3,
                             0,3,2,0,20,1,18,2,
                             0,0,2,1,20,2,18,3,
                             1,5,11,5,19,5,9,5,
                             0,5,2,5,20,5,18,5,
                             1,4,11,4,19,4,9,4,
                             0,4,2,4,20,4,18,4};  
        swapColors(squence,rcl*3,cubes);
    }else if(rotationState ==ROTATE_Y_CLOCKWISE ){
        GLint squence[56] = {1,0,9,3,19,2,11,1,
                             0,3,18,2,20,1,2,0,
                             0,0,18,3,20,2,2,1,
                             1,5,9,5,19,5,11,5,
                             0,5,18,5,20,5,2,5,
                             1,4,9,4,19,4,11,4,
                             0,4,18,4,20,4,2,4};  
        swapColors(squence,rcl*3,cubes);    
    }else if (rotationState == ROTATE_X_ANTICLOCKWISE) {
        GLint squence[56] = {9,5,3,0,15,4,21,2,
                             6,4,24,2,18,5,0,0,
                             6,0,24,4,18,2,0,5,
                             3,3,15,3,21,3,9,3,
                             0,3,6,3,24,3,18,3,
                             3,1,15,1,21,1,9,1,
                             0,1,6,1,24,1,18,1};  
        swapColors(squence,rcl,cubes);
    }else if(rotationState ==ROTATE_X_CLOCKWISE ){
        GLint squence[56] = {9,5,21,2,15,4,3,0,
                             0,0,18,5,24,2,6,4,
                             0,5,18,2,24,4,6,0,
                             3,3,9,3,21,3,15,3,
                             0,3,18,3,24,3,6,3,
                             3,1,9,1,21,1,15,1,
                             0,1,18,1,24,1,6,1};  
        swapColors(squence,rcl,cubes);    
    }
}

+ (Boolean)isOK:(Cube*)cubes
{
    for (int i=0; i<27; i++) {
        if (cubes[i]._row*3+cubes[i]._col+cubes[i]._layer*9 != i) {
            return NO;
        }
    }
    return YES;
}


//int rotationAngle= 9;
//static int randcount = 0;
//if (randcount < 0) {
//    int i = arc4random()%3;
//    int j = arc4random()%3;
//    if (i==1) {
//        _rotationState =arc4random()%2+1;
//    }else if(i==0){
//        _rotationState =arc4random()%2+1+2;
//    }else if(i==2){
//        _rotationState =arc4random()%2+1+4;
//    }
//    _currentSlice[0]=_currentSlice[1]=_currentSlice[2]=-1;
//    _currentSlice[i] = j;
//    randcount ++;
//    rotationAngle = 9;
//    NSLog(@"%d,%d,%d",i,j,_rotationState);
//}
//NSLog(@"%d,%d,%d,%d",_currentSlice[0],_currentSlice[1],_currentSlice[2],_rotationState);



// Attribute index.
enum {
    ATTRIBUTE_SELECT_VERTEX,
    ATTRIBUTE_SELECT_COLOR,
    NUM_SELECT_ATTRIBUTES
};
GLint attributes[NUM_SELECT_ATTRIBUTES];
// Uniform index.
enum {
    UNIFORM_SELECT_MVP_MATRIX,
    UNIFORM_SELECT_TEXTURE,
    NUM_SELECT_UNIFORMS
};
GLint uniforms[NUM_SELECT_UNIFORMS];

+ (void)switchPrograme:(YHCOpenGLProgram *)program
{
    if (program) {
        [program release];
        program = nil;
    }
    program = [[YHCOpenGLProgram alloc] init];
    
    [program setVertexShader:@"SelectShader"];
    [program setFragmentShader:@"SelectShader"];
    
    [program addAttributeLocation:@"ATTRIBUTE_SELECT_VERTEX" forAttribute:@"position"];
    [program addAttributeLocation:@"ATTRIBUTE_SELECT_COLOR" forAttribute:@"color"];
    
    [program addUniformLocation:@"UNIFORM_SELECT_MVP_MATRIX" forUniform:@"mvp_matrix"];
    
    [program compileAndLink];
    
    attributes[ATTRIBUTE_SELECT_VERTEX] = [program getAttributeIDForIndex:@"ATTRIBUTE_SELECT_VERTEX"];
    attributes[ATTRIBUTE_SELECT_COLOR] = [program getAttributeIDForIndex:@"ATTRIBUTE_SELECT_COLOR"];
    
    uniforms[UNIFORM_SELECT_MVP_MATRIX] = [program getUniformIDForIndex:@"UNIFORM_SELECT_MVP_MATRIX"];
}



@end
