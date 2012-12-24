//
//  OAuthController.h
//  BookShare
//
//  Created by Yang QianFeng on 02/07/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WeiboHTTPManager.h"
#import "TokenModel.h"

@protocol OAuthControllerDelegate;
@class TokenModel;
@interface OAuthController : UIViewController 
<UIWebViewDelegate>
{
    TokenModel *_tokenModel;
    
    UIWebView *_webView;
    WeiboHTTPManager *weiboHttpManager;
    
    id <OAuthControllerDelegate> _delegate;
    
    WeiboType _weiboType;
}
@property (nonatomic, assign) WeiboType weiboType;
@property (nonatomic, assign) id <OAuthControllerDelegate> delegate;

@end

@protocol OAuthControllerDelegate <NSObject>

- (void) oauthControllerDidFinished:(OAuthController *)oauthController;
- (void) oauthControllerDidCancel:(OAuthController *)oauthController;
- (void) oauthControllerSaveToken:(OAuthController *)oauthController withTokenModel:(TokenModel *)tokenModel;

@end
