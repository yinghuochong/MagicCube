//
//  YHCShaderAttribute.m
//  TouchTargets
//
//  Created by lihua liu on 12-8-27.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "YHCShaderAttribute.h"

@implementation YHCShaderAttribute

@synthesize attributeId = _attributeId;
@synthesize attributeName = _attributeName;

- (YHCShaderAttribute *)initAttributeWithID:(GLuint)newAttributeId andName:(NSString *)newAttributeName
{
    if (self = [super init]) {
        _attributeId = newAttributeId;
        self.attributeName = newAttributeName;
    }
    return self;
}

- (void)dealloc {
    self.attributeName = nil;
    [super dealloc];
}


@end










































