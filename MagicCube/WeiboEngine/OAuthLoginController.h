//
//  OAuthWebView.h
//  weibo
//
//  Created by Yang QianFeng on 29/06/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WeiboHTTPManager.h"

@protocol OAuthLoginDelegate;
@interface OAuthLoginController : UIViewController 
<UIWebViewDelegate, WeiboHTTPDelegate>
{
    UIWebView *webV;
    NSString *token;
    
    NSString *openID;
    NSString *openKey;
    NSString *accessToken;
    NSString *expTime;
    NSString *userName;
    
    WeiboHTTPManager *weiboHttpManager;
    
    id <OAuthLoginDelegate> _delegate;
}
@property (nonatomic, assign) id <OAuthLoginDelegate> delegate;
@property (nonatomic, retain) NSString *openID;
@property (nonatomic, retain) NSString *openKey;
@property (nonatomic, retain) NSString *accessToken;
@property (nonatomic, retain) NSString *expTime;
@property (nonatomic, retain) NSString *userName;

+ (id) sharedOAuthController;
+ (id) sharedController;
+ (void) launchLoginUI;
+ (NSString *) getCurrentAccount;
+ (NSString *) getCurrentToken;
+ (void) logout;

@end

@protocol OAuthLoginDelegate <NSObject>

- (void) didFinishedOauthController:(OAuthLoginController *)controller;
- (void) didCancelOauthController:(OAuthLoginController *)controller;

@end

