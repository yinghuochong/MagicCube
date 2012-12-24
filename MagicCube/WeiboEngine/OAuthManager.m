//
//  OAuthManager.m
//  BookShare
//
//  Created by Yang QianFeng on 02/07/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import "OAuthManager.h"
#import "OAuthController.h"

@implementation OAuthManager
@synthesize tokenModel = _tokenModel;
@synthesize delegate = _delegate;

- (id) initWithOAuthManager:(WeiboType)weiboType {
    self = [super init];
    if (self) {
        _weiboType = weiboType;
        _oauthController = [[OAuthController alloc] init];
        [_oauthController setDelegate:self];
        [_oauthController setWeiboType:weiboType];
        _navController = [[UINavigationController alloc] initWithRootViewController:_oauthController];
        self.tokenModel = [self readTokenFromStorage];
    }
    return self;
}
- (void) logout {
    
}

- (void) showUI {
    UIViewController *wv = _navController;
    
    UIWindow* wnd = [[UIApplication sharedApplication] keyWindow];
    CGRect windowRect = wnd.frame;
    
    CGRect origRect = windowRect;
    origRect.origin.y += windowRect.size.height;
    [wv.view setFrame:origRect];
    
    [wnd addSubview:wv.view];
    
    [UIView animateWithDuration:0.5 animations:^(void){
        [wv.view setFrame:windowRect];
    }];
}
- (void) hiddenUI {
    UIViewController *wv = _navController;
    
    CGRect rect = wv.view.frame;
    CGRect newRect = rect;
    newRect.origin.y += newRect.size.height;
    [UIView animateWithDuration:0.5 animations:^(void){
            wv.view.frame = newRect;
        } completion:^(BOOL finished) {
            [wv.view removeFromSuperview];
        }
     ];    

}

- (void) login {
    [self showUI];
}

- (void) oauthControllerDidFinished:(OAuthController *)oauthController {
    [self hiddenUI];
}
- (void) oauthControllerDidCancel:(OAuthController *)oauthController {
    [self hiddenUI];
}
- (void) oauthControllerSaveToken:(OAuthController *)oauthController withTokenModel:(TokenModel *)tokenModel {
    NSLog(@"token is save token %@ %@", tokenModel, tokenModel.accessToken);
    self.tokenModel = tokenModel;
    [self writeTokenToStorage:tokenModel];
    [_delegate loginFinished:self];
}

- (void) writeTokenToStorage:(TokenModel *)tokenModel {
    if (tokenModel.weiboType == TENCENT_WEIBO) {
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.accessToken 
                                                  forKey:TENCENT_USER_STORE_ACCESS_TOKEN];
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.expireTime 
                                                  forKey:TENCENT_USER_STORE_EXPIRATION_DATE];
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.userName 
                                                  forKey:TENCENT_USER_STORE_USER_NAME];
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.userID 
                                                  forKey:TENCENT_USER_STORE_USER_ID];
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.openID 
                                                  forKey:TENCENT_USER_STORE_OPENID];
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.openKey 
                                                  forKey:TENCENT_USER_STORE_OPENKEY];
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.extraInfo 
                                                  forKey:TENCENT_USER_STORE_OAUTH2];
    } else if (tokenModel.weiboType == SINA_WEIBO) {
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.accessToken 
                                                  forKey:SINA_USER_STORE_ACCESS_TOKEN];
        [[NSUserDefaults standardUserDefaults] setObject:tokenModel.expireTime 
                                                  forKey:SINA_USER_STORE_EXPIRATION_DATE];
        
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (TokenModel *) readTokenFromStorage {
    TokenModel *tokenModel = [[[TokenModel alloc] init] autorelease];
    
    [[NSUserDefaults standardUserDefaults] synchronize];
    if (_weiboType == TENCENT_WEIBO) {
        tokenModel.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_ACCESS_TOKEN];
        tokenModel.expireTime = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_EXPIRATION_DATE];
        tokenModel.userName = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_USER_NAME];
        tokenModel.userID = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_USER_ID];
        tokenModel.openID = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_OPENID];
        tokenModel.openKey = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_OPENKEY];
        tokenModel.extraInfo = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_OAUTH2];
    } else if (tokenModel.weiboType == SINA_WEIBO) {
        tokenModel.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_USER_STORE_ACCESS_TOKEN];
        tokenModel.expireTime = [[NSUserDefaults standardUserDefaults] objectForKey:SINA_USER_STORE_EXPIRATION_DATE];
    }
    if (tokenModel.accessToken == nil || [tokenModel.accessToken isEqualToString:@""])
        return nil;
    return tokenModel;
}

- (BOOL) isAlreadyLogin {
    return _tokenModel.accessToken?YES:NO;
}
- (NSDictionary *) getCommonParams {
    NSDictionary *dict = nil;
    if (_weiboType == SINA_WEIBO) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                _tokenModel.accessToken, @"access_token", 
                nil];
    } else if (_weiboType == TENCENT_WEIBO) {
        dict = [NSDictionary dictionaryWithObjectsAndKeys:
                _tokenModel.userName, @"name", 
                _tokenModel.accessToken, @"access_token",
                _tokenModel.openID, @"openid",
                _tokenModel.openKey, @"openkey",
                TENCENT_APP_KEY, @"oauth_consumer_key",
                @"2.a", @"oauth_version",
                @"221.223.249.130", @"clientip",
                nil];
    }
    return dict;
}
- (void) addPrivatePostParamsForASI:(ASIFormDataRequest *)request {
    NSDictionary *dict = [self getCommonParams];
    NSArray *keyArray = [dict allKeys];
    NSArray *valueArray = [dict allValues];
    for (int i = 0; i < [keyArray count]; i++) {
        [request setPostValue:[valueArray objectAtIndex:i] forKey:[keyArray objectAtIndex:i]];
    }
}

- (NSString *) getOAuthDomain {
    if (_weiboType == SINA_WEIBO) {
        return SINA_V2_DOMAIN;
    } else if(_weiboType == TENCENT_WEIBO) {
        return TENCENT_V2_DOMAIN;
    }
    return nil;
}

- (void) dealloc {
    [_oauthController release], _oauthController = nil;
    [_navController release], _navController = nil;

    self.tokenModel= nil;
    [super dealloc];
}
@end
