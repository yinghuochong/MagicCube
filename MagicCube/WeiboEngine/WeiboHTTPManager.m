//
//  WeiboHTTPManager.m
//  weibo
//
//  Created by Yang QianFeng on 29/06/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import "WeiboHTTPManager.h"

@implementation WeiboHTTPManager
@synthesize delegate;
@synthesize authToken;

- (id)initWithDelegate:(id)theDelegate {
    self = [super init];
    if (self) {
        self.delegate = theDelegate;
    }
    return self;
}

- (NSURL*)generateURL:(NSString*)baseURL params:(NSDictionary*)params {
	if (params) {
		NSMutableArray* pairs = [NSMutableArray array];
		for (NSString* key in params.keyEnumerator) {
			NSString* value = [params objectForKey:key];
			NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                    NULL, /* allocator */
                                    (CFStringRef)value,
                                    NULL, /* charactersToLeaveUnescaped */
                                    (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                    kCFStringEncodingUTF8);
            
            [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, value]];
			[escaped_value release];
		}
		
		NSString* query = [pairs componentsJoinedByString:@"&"];
		NSString* url = [NSString stringWithFormat:@"%@?%@", baseURL, query];
		return [NSURL URLWithString:url];
	} else {
		return [NSURL URLWithString:baseURL];
	}
}

#pragma mark - Http Operate
// 获取auth_code or access_token
-(NSURL*)getSinaOAuthCodeUrl //留给webview用
{
    // https://api.weibo.com/oauth2/authorize
    
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                SINA_APP_KEY, @"client_id", //申请的appkey
                @"token", @"response_type", //access_token
                SINA_CALLBACK, @"redirect_uri", //申请时的重定向地址
                @"mobile", @"display", //web页面的显示方式
                nil];
	
	NSURL *url = [self generateURL:SINA_V2_AUTHORIZE params:params];
	NSLog(@"url= %@",url);
    return url;
}
-(NSURL*)getTencentOAuthCodeUrl //留给webview用
{
    // https://api.weibo.com/oauth2/authorize
    // https://open.t.qq.com/cgi-bin/oauth2/authorize?client_id=APP_KEY&response_type=code&redirect_uri=http://www.myurl.com/example
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   TENCENT_APP_KEY, @"client_id", //申请的appkey
                                   @"code", @"response_type", //access_token
                                   TENCENT_CALLBACK, @"redirect_uri", //申请时的重定向地址
                                   @"mobile", @"display", //web页面的显示方式
                                   nil];
	
	NSURL *url = [self generateURL:TENCENT_V2_AUTHORIZE params:params];
	NSLog(@"url= %@",url);
    return url;
    // http://www.1000phone.com/?code=5b22f613ce98511ac6b1c1dccc35a1ee&openid=6E2D92FFD383EF67410284F536F832AA&openkey=1C8E1BF014179E4DB89D949005A72944
}


@end
