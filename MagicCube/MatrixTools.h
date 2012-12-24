//
//  MatrixTools.h
//  MagicCube
//
//  Created by lihua liu on 12-8-8.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface MatrixTools : UIViewController

+ (void)copyMatrix:(GLfloat *)mSource to:(GLfloat *)mTarget;
+ (void)applyIdentity:(GLfloat *)m;
+ (void)multiplyMatrix:(GLfloat *)m1 by:(GLfloat *)m2 giving:(GLfloat *) m3;
+ (void)applyTranslation:(GLfloat *)m x:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;
+ (void)applyScale:(GLfloat *)m x:(GLfloat)x y:(GLfloat)y z:(GLfloat)z;
+ (void)applyRotation:(GLfloat *)m x:(GLfloat)x y:(GLfloat)y z:(GLfloat)z; 
+ (void)applyProjection:(GLfloat *)m fov:(GLfloat)fov aspect:(GLfloat)aspect near:(GLfloat)near far:(GLfloat)far ;

@end
