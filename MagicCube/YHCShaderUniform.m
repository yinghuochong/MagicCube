//
//  YHCShaderUniform.m
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
// 

#import "YHCShaderUniform.h"

@implementation YHCShaderUniform

@synthesize unifromId = _uniformId;
@synthesize uniformName = _unifromName;
@synthesize uniformLocation = _uniformLocation;

- (YHCShaderUniform *)initUniformWithID:(GLuint)newUniformId andName:(NSString *)newUniformName
{
    if (self = [super init]) {
        _uniformId = newUniformId;
        self.uniformName = newUniformName;
        _uniformLocation = 0;
    }
    return  self;
}

- (void)dealloc {
    self.uniformName = nil;
    [super dealloc];
}


@end
