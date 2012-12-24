//
//  YHCOpenGLTools.m
//  TouchTargets
//
//  Created by lihua liu on 12-8-28.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "YHCOpenGLTools.h"

@implementation YHCOpenGLTools

+ (void)loadTexture:(GLuint *)textureName fromFile:(NSString *)fileName
{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
    CGImageRef imageRef = [image CGImage];
    if (imageRef) {
        size_t imageWidth = CGImageGetWidth(imageRef);
        size_t imageHeight = CGImageGetHeight(imageRef);
        
        GLubyte *imageData = (GLubyte *)malloc(imageWidth*imageHeight*4);
        memset(imageData, 0,imageWidth *imageHeight*4);
        
        CGContextRef imageContextRef = CGBitmapContextCreate(imageData, imageWidth, imageHeight, 8, imageWidth*4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
        
        CGContextTranslateCTM(imageContextRef, 0, imageHeight);
        CGContextScaleCTM(imageContextRef, 1.0, -1.0); 
        
        CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)imageWidth, (CGFloat)imageHeight), imageRef);
        
        CGContextRelease(imageContextRef);
        glGenTextures(1, textureName);
        glBindTexture(GL_TEXTURE_2D, *textureName);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        free(imageData);
        
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
        glEnable(GL_BLEND);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        
        glGenerateMipmap(GL_TEXTURE_2D);
        glEnable(GL_TEXTURE_2D);
    }
    [image release];
}
#if 0
+ (void)loadTexture:(GLuint *)newTextureName fromFile:(NSString *)fileName
{
    UIImage *image = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:fileName ofType:nil]];
    CGImageRef imageRef = [image CGImage];
    if (imageRef) {
        size_t imageWidth = CGImageGetWidth(imageRef);
        size_t imageHeight = CGImageGetHeight(imageRef);
        
        GLubyte *imageData = (GLubyte *)malloc(imageWidth*imageHeight*4);
        memset(imageData, 0,imageWidth *imageHeight*4);
        
        CGContextRef imageContextRef = CGBitmapContextCreate(imageData, imageWidth, imageHeight, 8, imageWidth*4, CGImageGetColorSpace(imageRef), kCGImageAlphaPremultipliedLast);
        
        CGContextTranslateCTM(imageContextRef, 0, imageHeight);
        CGContextScaleCTM(imageContextRef, 1.0, -1.0); 
        
        CGContextDrawImage(imageContextRef, CGRectMake(0.0, 0.0, (CGFloat)imageWidth, (CGFloat)imageHeight), imageRef);
        
        CGContextRelease(imageContextRef);
        glGenTextures(1, newTextureName);
        glBindTexture(GL_TEXTURE_2D, *newTextureName);
        glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imageWidth, imageHeight, 0, GL_RGBA, GL_UNSIGNED_BYTE, imageData);
        free(imageData);
        
        glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    }
    [image release];
}
#endif
@end