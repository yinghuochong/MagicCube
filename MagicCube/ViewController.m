//
//  ViewController.m
//  MagicCube
//
//  Created by lihua liu on 12-9-10.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "ViewController.h"
#import "YHCOpenGLTools.h"
#import "MatrixTools.h"
#import "GameLogic.h"
#import "StartViewController.h"


#define RAND_STEPS 0

@interface ViewController()

- (void)drawFrame;
- (void)rotateCubeAroundX:(float)x andY:(float)y;
- (void)selectSlice :(CGPoint)point1 : (CGPoint) point2;
@end

// Attribute index.
enum {
    ATTRIBUTE_VERTEX,
    ATTRIBUTE_COLOR,
    ATTRIBUTE_TEXTURE_COORD=1,
    NUM_ATTRIBUTES
};
GLint attributes[NUM_ATTRIBUTES];
// Uniform index.
enum {
    UNIFORM_MVP_MATRIX,
    UNIFORM_TEXTURE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];


@implementation ViewController

//存储显示的27个方块,一直放在内存中
static Cube cubes[27];
static int randcount = 0;

- (void)viewDidLoad
{
    [super viewDidLoad];
    //为视图控制器 添加一个自定义的视图
    EAGLView *eaglView = [[EAGLView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.view = eaglView;
    [eaglView release];
    
    EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    if (!aContext)
        NSLog(@"Failed to create ES context");
    else if (![EAGLContext setCurrentContext:aContext])
        NSLog(@"Failed to set ES context current");
	_context = aContext;
    [(EAGLView *)self.view setContext:_context];
    [(EAGLView *)self.view setFramebuffer];
    [aContext release];
    
    //计算frame的 高宽比
    GLint framebufferWidth, framebufferHeight; 
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_WIDTH, &framebufferWidth);  
    glGetRenderbufferParameteriv(GL_RENDERBUFFER, GL_RENDERBUFFER_HEIGHT, &framebufferHeight);     
    GLfloat aspectRatio = (GLfloat)framebufferHeight / (GLfloat)framebufferWidth;
    
    //标准化矩阵
    [MatrixTools applyIdentity:_scaleMatrix]; 
    [MatrixTools applyIdentity:_rotationMatrix]; 
    [MatrixTools applyIdentity:_translationMatrix];
    [MatrixTools applyIdentity:_projectionMatrix];
    int x = arc4random()%360;
    int y = arc4random()%360;
    [MatrixTools applyRotation:_rotationMatrix x:(GLfloat)x y:(GLfloat)y z:0.0f];
    
    //初始化 显示变换 
    _lastZoomDistance = -15.0f;
    [MatrixTools applyTranslation:_translationMatrix x:0.0f y:0.0f z:_lastZoomDistance];
    [MatrixTools applyProjection:_projectionMatrix fov:45.0f aspect:aspectRatio near:0.1 far:100.0f];
    
    //加载贴图
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [YHCOpenGLTools loadTexture:&_textureName fromFile:[ud objectForKey:@"texture"]];
    
    //初始化cubes
    for (int i=0; i<3; i++) {
        for (int j=0; j<3; j++) {
            for (int k =0; k<3; k++) {
                [GameLogic initVecteAndTextCoord:&cubes[i*3+j+k*9] :i :j :k];
            }
        }
    }
    [GameLogic clearColor:cubes];
    _rotationState = ROTATE_NONE;
    _isSelectMode = false;
    _currentSlice[0] = _currentSlice[1] =_currentSlice[2] =-1;
    _sliceRotateAngle = 0;
    _isOK = YES;
   
    //文字
    _textManager = [[YHCTextStringManager alloc] initWithCharacterSheetName:@"FontChalkduster.png"];
    //用时
    _startTime = time(0);
    _consumeTime = 0;
    NSString *timeText = [NSString stringWithFormat:@"%02d:%02d:%02d",(_consumeTime/60)/60,(_consumeTime/60)%60, _consumeTime%60];
    _timeLabel = [[YHCTextString alloc] initWithString:timeText];
    [_timeLabel setPositionX:10 andY:40 andZ:0];
    [_timeLabel setSize:25.0f];
    [_timeLabel setCentered:NO];
    [_timeLabel setColorRed:255 andGreen:255 andBlue:255];
    [_textManager addTextString:_timeLabel];
    [_timeLabel release];
     //旋转次数
      _stepCount = 0;
    _stepLable = [[YHCTextString alloc] initWithString:[NSString stringWithFormat:@"steps: %d",_stepCount]];
    [_stepLable setPositionX:140 andY:40 andZ:0];
    [_stepLable setSize:25.0f];
    [_stepLable setCentered:NO];
    [_stepLable setColorRed:255 andGreen:255 andBlue:255];
    [_textManager addTextString:_stepLable];
    [_stepLable release];
    
    
    NSString *tipText = @"when success , you can disorder ";
    YHCTextString *tipString = [[YHCTextString alloc] initWithString:tipText];
    [tipString setPositionX:15 andY:400 andZ:0];
    [tipString setSize:20.0f];
    [tipString setCentered:NO];
    [tipString setColorRed:255 andGreen:255 andBlue:255];
    [tipString setLifespan:500 withDecayAt:300];
    [_textManager addTextString:tipString];
    [tipString release];
    tipText = @" by shake your iphone . . .";
    tipString = [[YHCTextString alloc] initWithString:tipText];
    [tipString setPositionX:15 andY:440 andZ:0];
    [tipString setSize:20.0f];
    [tipString setCentered:NO];
    [tipString setColorRed:255 andGreen:255 andBlue:255];
    [tipString setLifespan:500 withDecayAt:300];
    [_textManager addTextString:tipString];
    [tipString release];

    
    //_background = [[YHCScrollingBackground alloc] init];
    
    //暂停按钮
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(280,8, 32, 32);
    [self.view addSubview:button];
    [button setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(pauseButtonClick) forControlEvents:UIControlEventTouchUpInside];

    //监听摇晃动作
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userShaked) name:@"shake" object:nil];
    //开始绘制
    [self startDraw];
}

//摇动打乱
- (void)userShaked
{
    if (_isOK) {
        randcount = -10;
        _stepCount = 0;
        _startTime = time(0);
        NSLog(@"shaked...................");
    }
}

- (void)pauseButtonClick
{
    [self stopDraw];
    [self dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
    NSLog(@"dealloc");
    if (_program) {
        [_program release];
    }
    [GameLogic resetColorFlag];
    randcount = 0;
    // 销毁context
    if ([EAGLContext currentContext] == _context)
        [EAGLContext setCurrentContext:nil];
    [_textManager release];
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self startDraw];
    [super viewWillAppear:animated];
}
- (void) viewDidDisappear:(BOOL)animated
{
    [self stopDraw];
    [super viewWillDisappear:animated];
}

- (void)startDraw
{
    if (!drawing) {
        CADisplayLink *displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(drawFrame)];
        [displayLink setFrameInterval:1];
        _displayLink = displayLink;
        [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        drawing = TRUE;
    }
}

- (void)stopDraw
{
    if (drawing) {
        [_displayLink invalidate];
        _displayLink = nil;
        drawing = FALSE;
    }
}

- (void)drawFrame 
{
    // 打乱  随机走 RAND_STEP 步
    int rotationAngle= 10;
    if (randcount < RAND_STEPS) {
        int i = arc4random()%3;
        int j = arc4random()%3;
        if (i==1) {
            _rotationState =arc4random()%2+1;
        }else if(i==0){
            _rotationState =arc4random()%2+1+2;
        }else if(i==2){
            _rotationState =arc4random()%2+1+4;
        }
        _currentSlice[0]=_currentSlice[1]=_currentSlice[2]=-1;
        _currentSlice[i] = j;
        randcount ++;
        rotationAngle = 90;
    }
    
    //统计时间
    time_t temp = time(0)-_startTime+_consumeTime;
    [_timeLabel setString: [NSString stringWithFormat:@"%02d:%02d:%02d",(temp/60)/60,(temp/60)%60, temp%60]];
    [_stepLable setString: [NSString stringWithFormat:@"steps: %d",_stepCount]];
    
//    [(EAGLView *)self.view setFramebuffer];
//    glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
//    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    
  
    //开始准备绘制
    static GLfloat mvpMatrix[16];
    if (_isSelectMode) {
        glClearColor(255, 0, 0, 0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    }else{
        [(EAGLView *)self.view setFramebuffer];
        glClearColor(0, 104.0/255.0, 55.0/255.0, 1.0);
        glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
        //[_background draw];

        if (_program) {
            [_program release];
            _program = nil;
        }
        _program = [[YHCOpenGLProgram alloc] init];
        [_program setVertexShader:@"Shader"];
        [_program setFragmentShader:@"Shader"];
        [_program addAttributeLocation:@"ATTRIBUTE_VERTEX" forAttribute:@"position"];
        [_program addAttributeLocation:@"ATTRIBUTE_TEXTURE_COORD" forAttribute:@"texture_coord"];
        [_program addUniformLocation:@"UNIFORM_MVP_MATRIX" forUniform:@"mvp_matrix"];
        [_program addUniformLocation:@"UNIFORM_TEXTURE" forUniform:@"texture"];
        [_program compileAndLink];
        
        attributes[ATTRIBUTE_VERTEX] = [_program getAttributeIDForIndex:@"ATTRIBUTE_VERTEX"];
        attributes[ATTRIBUTE_TEXTURE_COORD] = [_program getAttributeIDForIndex:@"ATTRIBUTE_TEXTURE_COORD"];
        uniforms[UNIFORM_MVP_MATRIX] = [_program getUniformIDForIndex:@"UNIFORM_MVP_MATRIX"];
        uniforms[UNIFORM_TEXTURE] = [_program getUniformIDForIndex:@"UNIFORM_TEXTURE"];
    }
    
    if ([_context API] == kEAGLRenderingAPIOpenGLES2){
        if (!_isSelectMode) {
            glEnable(GL_BLEND);
            glEnable(GL_TEXTURE_2D);

            glBindTexture(GL_TEXTURE_2D, _textureName);
        }
        glUseProgram(_program.programId);
        
        if(_rotationState == ROTATE_X_CLOCKWISE || _rotationState == ROTATE_Y_CLOCKWISE || _rotationState == ROTATE_Z_CLOCKWISE){
            _sliceRotateAngle += rotationAngle;
        }else if(_rotationState == ROTATE_X_ANTICLOCKWISE || _rotationState == ROTATE_Y_ANTICLOCKWISE || _rotationState == ROTATE_Z_ANTICLOCKWISE){
            _sliceRotateAngle += -rotationAngle;
        }else{
            _sliceRotateAngle = 0;
        }
        for (int i= 0; i<27; i++) {
            
            glVertexAttribPointer(ATTRIBUTE_VERTEX, 3, GL_FLOAT, 0, 0, cubes[i]._vertices);
            glEnableVertexAttribArray(ATTRIBUTE_VERTEX);
            if (_isSelectMode) {
                glVertexAttribPointer(ATTRIBUTE_COLOR, 4, GL_UNSIGNED_BYTE, 1, 0, cubes[i]._colors);
                glEnableVertexAttribArray(ATTRIBUTE_COLOR);
            }else{
                glVertexAttribPointer(ATTRIBUTE_TEXTURE_COORD, 2, GL_FLOAT, 0, 0, cubes[i]._textureCoords);
                glEnableVertexAttribArray(ATTRIBUTE_TEXTURE_COORD);
            }
            //进行变换
            [MatrixTools applyIdentity:mvpMatrix];
            [MatrixTools applyIdentity:_translationMatrix];
            [MatrixTools applyTranslation:_translationMatrix x:0 y:0 z:_lastZoomDistance];
            [MatrixTools multiplyMatrix:cubes[i]._rotateMatrix by:mvpMatrix giving:mvpMatrix];
            // z axis
            if (_currentSlice[2]>=0 && cubes[i]._layer == _currentSlice[2] ) {
                [MatrixTools applyIdentity:_sliceRotationMatrix];
                [MatrixTools applyRotation:_sliceRotationMatrix x:0 y:0 z:_sliceRotateAngle*M_PI/180.0f];
                [MatrixTools multiplyMatrix:_sliceRotationMatrix by:mvpMatrix giving:mvpMatrix];
                if (fabs(_sliceRotateAngle)>=90) {
                    for (int m=0; m<27; m++) {
                        if (cubes[m]._layer == _currentSlice[2]) {
                            [MatrixTools multiplyMatrix:_sliceRotationMatrix by:cubes[m]._rotateMatrix giving:cubes[m]._rotateMatrix];
                        }
                    }
                    [GameLogic sliceRotateWith:_currentSlice[2] rotationState:_rotationState cubes:cubes]; 
                    _sliceRotateAngle = 0;
                    _currentSlice[0] = _currentSlice[1] = _currentSlice[2] = -1;
                    _rotationState = ROTATE_NONE;
                    _stepCount += randcount>=RAND_STEPS?1:0;
                    _isOK = [GameLogic isOK:cubes];
                }
            }
            // y axis
            if (cubes[i]._row == _currentSlice[0] && _currentSlice[0]>=0) {
                [MatrixTools applyIdentity:_sliceRotationMatrix];
                [MatrixTools applyRotation:_sliceRotationMatrix x:0 y:_sliceRotateAngle*M_PI/180.0f z:0];
                [MatrixTools multiplyMatrix:_sliceRotationMatrix by:mvpMatrix giving:mvpMatrix];
                if (fabs(_sliceRotateAngle)>=90) {
                    for (int m=0; m<27; m++) {
                        if (cubes[m]._row == _currentSlice[0]) {
                            [MatrixTools multiplyMatrix:_sliceRotationMatrix by:cubes[m]._rotateMatrix giving:cubes[m]._rotateMatrix];
                        }
                    }
                    [GameLogic sliceRotateWith:_currentSlice[0] rotationState:_rotationState cubes:cubes]; 
                    _sliceRotateAngle = 0;
                    _currentSlice[0] = _currentSlice[1] = _currentSlice[2] = -1;
                    _rotationState = ROTATE_NONE;
                    _stepCount += randcount>=RAND_STEPS?1:0;   
                    _isOK = [GameLogic isOK:cubes];
                }
            }
            // x axis
            if (cubes[i]._col == _currentSlice[1] && _currentSlice[1]>=0) {
                [MatrixTools applyIdentity:_sliceRotationMatrix];
                [MatrixTools applyRotation:_sliceRotationMatrix x:_sliceRotateAngle*M_PI/180.0f y:0 z:0];
                [MatrixTools multiplyMatrix:_sliceRotationMatrix by:mvpMatrix giving:mvpMatrix];
                if (fabs(_sliceRotateAngle)>=90) {
                    for (int m=0; m<27; m++) {
                        if (cubes[m]._col == _currentSlice[1]) {
                            [MatrixTools multiplyMatrix:_sliceRotationMatrix by:cubes[m]._rotateMatrix giving:cubes[m]._rotateMatrix];
                        }
                    }
                    [GameLogic sliceRotateWith:_currentSlice[1] rotationState:_rotationState cubes:cubes]; 
                    _sliceRotateAngle = 0;
                    _currentSlice[0] = _currentSlice[1] = _currentSlice[2] = -1;
                    _rotationState = ROTATE_NONE;
                    _stepCount += randcount>=RAND_STEPS?1:0;   
                    _isOK = [GameLogic isOK:cubes];
                }
            }
            [MatrixTools multiplyMatrix:_rotationMatrix by:mvpMatrix giving:mvpMatrix]; 
            [MatrixTools multiplyMatrix:_scaleMatrix by:mvpMatrix giving:mvpMatrix]; 
            [MatrixTools multiplyMatrix:_translationMatrix by:mvpMatrix giving:mvpMatrix];
            [MatrixTools multiplyMatrix:_projectionMatrix by:mvpMatrix giving:mvpMatrix];
            
            glUniformMatrix4fv(uniforms[UNIFORM_MVP_MATRIX], 1, 0, mvpMatrix);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 26);
        }
         if (!_isSelectMode) {
             [_textManager drawAllTextString];
             //[_background draw];
         }

#if defined(DEBUG)
        if (![_program validate]) {
            NSLog(@"Failed to validate program: %d", _program.programId);
            return;
        }
#endif
    }
       // 开始渲染
    [(EAGLView *)self.view presentFramebuffer];
}

- (void)rotateCubeAroundX:(float)x andY:(float)y 
{
    GLfloat totalXRotation = x * M_PI / 180.0f;
    GLfloat totalYRotation = y * M_PI / 180.0f;
    if (_rotationState == ROTATE_ALL) {
        [MatrixTools applyRotation:_rotationMatrix x:totalXRotation y:totalYRotation z:0.0];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    if (allTouches.count == 1) {
        _lastTouchPosition = [[touches anyObject] locationInView:self.view];  
        _firstPostion = _lastTouchPosition;
        _sliceRotateAngle = 0;
        _rotationState = ROTATE_NONE;
        _isCheck = true;
        
    }else if(allTouches.count == 2){
        UITouch *touch1 = [[allTouches allObjects] objectAtIndex:0];
        UITouch *touch2 = [[allTouches allObjects] objectAtIndex:1];
        
        CGPoint point1 = [touch1 locationInView:self.view];
        CGPoint point2 = [touch2 locationInView:self.view];
        
        float x = point1.x - point2.x;
        float y = point1.y - point2.y;
        
        _lastPinchDistance = sqrtf(x*x+y*y);
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSSet *allTouches = [event allTouches];
    if (allTouches.count == 1) {
        
        CGPoint currentPostion = [[touches anyObject] locationInView:self.view];
        float xMovement = _lastTouchPosition.x - currentPostion.x;
        float yMovement = _lastTouchPosition.y - currentPostion.y;
        
        if (_isCheck) {
            NSLog(@"befor select rotationState = %d",_rotationState);
            
            _isSelectMode = true;
            [self selectSlice:_lastTouchPosition :currentPostion];
            _isSelectMode = false;
            _isCheck = false;
            
            NSLog(@"after select rotationState = %d",_rotationState);
        }
        _lastTouchPosition = currentPostion;
        [self rotateCubeAroundX:yMovement andY:xMovement];
        
    }else if([allTouches count] == 2) {
        UITouch *t1 = [[allTouches allObjects] objectAtIndex:0];
        UITouch *t2 = [[allTouches allObjects] objectAtIndex:1];
        
        CGPoint p1 = [t1 locationInView:self.view];
        CGPoint p2 = [t2 locationInView:self.view];
        
        float x = p1.x - p2.x;
        float y = p1.y - p2.y;
        
        float currPinchDistance = sqrtf(x * x + y * y);
        float zoomDistance = _lastPinchDistance - currPinchDistance;
        _lastZoomDistance = _lastZoomDistance - (zoomDistance / 100);
        //判断不要放的太大了 
        _lastZoomDistance = _lastZoomDistance >-10?-10:_lastZoomDistance;
        _lastPinchDistance = currPinchDistance;
    }
}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
#if 0
    //成功啦
    _isOK = FALSE;
    if ([GameLogic isOK:cubes] && _stepCount!=0) {

        YHCTextString *startText = [[YHCTextString alloc] initWithString:@"You Win"];
        [startText setPositionX:320/2.0f andY:480/2.0f andZ:0];
        [startText setSize:40.0f];
        [startText setCentered:YES];
        [startText setColorRed:255 andGreen:0 andBlue:0];
        [startText setLifespan:150 withDecayAt:30];
        [_textManager addTextString:startText];
        [startText release];

        _isOK = TRUE;
    }
#endif
}

//选择一面转动
- (void)selectSlice :(CGPoint)point1 : (CGPoint) point2
{
    _rotationState = ROTATE_NONE;
    GLint viewport[4];
    
    if (_program) {
        [_program release];
        _program = nil;
    }
    _program = [[YHCOpenGLProgram alloc] init];
    glDisable(GL_TEXTURE_2D);
    glDisable(GL_BLEND);
    [_program setVertexShader:@"SelectShader"];
    [_program setFragmentShader:@"SelectShader"];
    [_program addAttributeLocation:@"ATTRIBUTE_VERTEX" forAttribute:@"position"];
    [_program addAttributeLocation:@"ATTRIBUTE_COLOR" forAttribute:@"color"];
    [_program addUniformLocation:@"UNIFORM_MVP_MATRIX" forUniform:@"mvp_matrix"];
    [_program compileAndLink];
    
    attributes[ATTRIBUTE_VERTEX] = [_program getAttributeIDForIndex:@"ATTRIBUTE_VERTEX"];
    attributes[ATTRIBUTE_COLOR] = [_program getAttributeIDForIndex:@"ATTRIBUTE_COLOR"];
    uniforms[UNIFORM_MVP_MATRIX] = [_program getUniformIDForIndex:@"UNIFORM_MVP_MATRIX"];
    
    GLubyte pixelColor[4] = {0};
    GLubyte tempPixelColor [4]={0};
    GLuint colorRenderbuffer;
    GLuint framebuffer;
    GLuint depthbuffer;
    GLint face1=FACE_NONE,face2=FACE_NONE;
    
    glGetIntegerv(GL_VIEWPORT, viewport);
    
    glGenFramebuffers(1, &framebuffer);
    glBindFramebuffer(GL_FRAMEBUFFER, framebuffer);
    glGenRenderbuffers(1, &colorRenderbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, colorRenderbuffer);
    
    glRenderbufferStorage(GL_RENDERBUFFER, GL_RGBA8_OES, viewport[2],viewport[3]);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_RENDERBUFFER, colorRenderbuffer);
    
    glGenRenderbuffers(1, &depthbuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, depthbuffer);
    glRenderbufferStorage(GL_RENDERBUFFER,
                          GL_DEPTH_COMPONENT16, viewport[2],viewport[3]);
    glFramebufferRenderbuffer(GL_FRAMEBUFFER, GL_DEPTH_ATTACHMENT, GL_RENDERBUFFER, depthbuffer);
    glEnable(GL_DEPTH_TEST);
    
    GLenum status = glCheckFramebufferStatus(GL_FRAMEBUFFER);
    if (status != GL_FRAMEBUFFER_COMPLETE) {
        NSLog(@"select framebuffer status: %x",(int)status);
        return;
    }
    
    [self drawFrame];
    glReadPixels(point1.x,viewport[3]-point1.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, pixelColor);
    Cube *cube = nil;
    face1 = FACE_NONE;
    for (int i=0; i<sizeof(cubes)/sizeof(cubes[0]); i++) {
        for (int j=0; j<80; j+=16) {
            if (cubes[i]._colors[j]==pixelColor[0]) {
                cube = &cubes[i];
                face1 =  (pixelColor[0]-1)%6;
                break;
            }
        }  
        if (cube == nil && cubes[i]._colors[88]==pixelColor[0]) {
            cube = &cubes[i];
            face1 =  (pixelColor[0]-1)%6;
        }
        if (cube != nil) {
            NSLog(@"cubes 1 values : %d",i);
            break;
        }
    }
    if (cube == nil) {
        _rotationState = ROTATE_ALL;
        _currentSlice[0] = _currentSlice[1] =_currentSlice[2] =-1;
    }else{
        int inc=0;int flag = 1;
        CGPoint nextPoint;
        do{
            if(point2.x == 0) break;
            [GameLogic getNextPoint:point1 point2:point2 nextPoint:&nextPoint inc:inc flag:flag];
            glReadPixels(nextPoint.x,viewport[3]-nextPoint.y, 1, 1, GL_RGBA, GL_UNSIGNED_BYTE, tempPixelColor);
            inc += flag;
            if (pixelColor[0] == tempPixelColor[0]) {
                continue;
            }
            
            if (tempPixelColor[0] == 255 && tempPixelColor[1] == 0
                && tempPixelColor[2] == 0&& tempPixelColor[3] == 0) {
                if (inc>0) {
                    inc = 0;
                    flag = -1;
                }else{
                    break;
                }
            }
            face2 = FACE_NONE;
            for (int i=0; i<sizeof(cubes)/sizeof(cubes[0]); i++) {
                for (int j=0; j<80; j+=16) {
                    if (cubes[i]._colors[j]==tempPixelColor[0]) {
                        face2 =  (tempPixelColor[0]-1)%6;
                        break;
                    }
                }  
                if (face2 == FACE_NONE && cubes[i]._colors[88]==tempPixelColor[0]) {
                    face2 =  (tempPixelColor[0]-1)%6;
                }
                if (face2 != FACE_NONE) {
                    NSLog(@"cube1: %d,%d,%d   face1:%d     cube2 : %d,%d,%d   face2 : %d",cube->_row,cube->_col,cube->_layer,face1, cubes[i]._row,cubes[i]._col,cubes[i]._layer , face2);
                    [GameLogic checkRotationState:&_rotationState currentSlice:_currentSlice cube1:cube face1:face1 cube2:&cubes[i] face2:face2 flag:flag];
                    break;
                }
            }
        }while (_rotationState == ROTATE_NONE);        
    }
    glDeleteRenderbuffers(1, &depthbuffer);
    glDeleteRenderbuffers(1, &colorRenderbuffer);
    glDeleteRenderbuffers(1, &framebuffer);
}

@end
