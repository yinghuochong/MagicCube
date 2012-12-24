//
//  TokenModel.m
//  BookShare
//
//  Created by Yang QianFeng on 03/07/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import "TokenModel.h"

@implementation TokenModel
@synthesize weiboType = _weiboType;
@synthesize accessToken = _accessToken;
@synthesize refreshToken = _refreshToken;
@synthesize expireTime = _expireTime;
@synthesize userName = _userName;
@synthesize userID = _userID;
@synthesize openID = _openID;
@synthesize openKey = _openKey;
@synthesize extraInfo = _extraInfo;
- (void) dealloc {
    self.refreshToken = nil;
    self.accessToken = nil;
    self.expireTime = nil;
    self.userID = nil;
    self.userName = nil;
    self.openID = nil;
    self.openKey = nil;
    
    [super dealloc];
}
- (NSString *) description {
    NSString *s = [NSString stringWithFormat:@"accessToken:%@ userID:%@ userName:%@", _accessToken, _userID, _userName];
    return s;
}
@end
