//
//  TokenModel.h
//  BookShare
//
//  Created by Yang QianFeng on 03/07/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeiboHTTPManager.h"

@interface TokenModel : NSObject {
    WeiboType _weiboType;
    NSString *_accessToken;
    NSString *_refreshToken;
    
    NSString *_expireTime;
    NSString *_userName;
    NSString *_userID;
    
    NSString *_openID;
    NSString *_openKey;
    
    NSString *_extraInfo;
}
@property (nonatomic, assign) WeiboType weiboType;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *refreshToken;

@property (nonatomic, retain) NSString *expireTime;
@property (nonatomic, retain) NSString *userName;
@property (nonatomic, retain) NSString *userID;
@property (nonatomic, retain) NSString *openID;
@property (nonatomic, retain) NSString *openKey;
@property (nonatomic, retain) NSString *extraInfo;

@end
