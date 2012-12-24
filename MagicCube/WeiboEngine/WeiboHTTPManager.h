//
//  WeiboHTTPManager.h
//  weibo
//
//  Created by Yang QianFeng on 29/06/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "WeiboApiAccount.h"

typedef enum {
    SINA_WEIBO,
    TENCENT_WEIBO,
    MAX_WEIBO
} WeiboType;

#define SINA_V2_DOMAIN              @"https://api.weibo.com/2"
#define SINA_V2_AUTHORIZE          @"https://api.weibo.com/oauth2/authorize"
#define SINA_V2_ACCESS_TOKEN       @"https://api.weibo.com/oauth2/access_token"

#ifndef SINA_APP_KEY
#define SINA_APP_KEY @"2365677171"
#define SINA_APP_SECRET @"f74d6b37719c6e6682a2ceb73e9902b3"
#define SINA_CALLBACK @"http://www.1000phone.com"
#endif

#define SINA_USER_STORE_ACCESS_TOKEN     @"SinaAccessToken"
#define SINA_USER_STORE_EXPIRATION_DATE  @"SinaExpirationDate"
#define SINA_USER_STORE_USER_ID          @"SinaUserID"
#define SINA_USER_STORE_USER_NAME        @"SinaUserName"


#define TENCENT_V2_DOMAIN       @"https://open.t.qq.com/api"
#define TENCENT_V2_AUTHORIZE    @"https://open.t.qq.com/cgi-bin/oauth2/authorize"
#define TENCENT_V2_ACCESS_TOKEN @"https://open.t.qq.com/cgi-bin/oauth2/access_token"

#ifndef TENCENT_APP_KEY
#define TENCENT_APP_KEY @"801124323"
#define TENCENT_APP_SECRET @"9d19ed0ae00ef963d73c06e518a34d27"
#define TENCENT_CALLBACK @"http://www.1000phone.com"
#endif

#define TENCENT_USER_STORE_ACCESS_TOKEN     @"TencentAccessToken"
#define TENCENT_USER_STORE_EXPIRATION_DATE  @"TencentExpirationDate"
#define TENCENT_USER_STORE_USER_ID          @"TencentUserID"
#define TENCENT_USER_STORE_USER_NAME        @"TencentUserName"
#define TENCENT_USER_STORE_OPENID           @"TencentOpenID"
#define TENCENT_USER_STORE_OPENKEY          @"TencentOpenKey"
#define TENCENT_USER_STORE_OAUTH2           @"TencentOAuth2Str"

@protocol WeiboHTTPDelegate;
@interface WeiboHTTPManager : NSObject <ASIHTTPRequestDelegate>
{
    id <WeiboHTTPDelegate> delegate;
    NSString *authToken;
}
@property (nonatomic, assign) id <WeiboHTTPDelegate> delegate;
@property (nonatomic, retain) NSString *authToken;

- (id)initWithDelegate:(id)theDelegate;
- (NSURL*)getSinaOAuthCodeUrl;
- (NSURL*)getTencentOAuthCodeUrl;

@end

@protocol WeiboHTTPDelegate <NSObject>

@end
