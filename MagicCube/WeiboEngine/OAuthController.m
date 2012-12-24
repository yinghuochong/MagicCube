//
//  OAuthController.m
//  BookShare
//
//  Created by Yang QianFeng on 02/07/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import "OAuthController.h"

@implementation OAuthController
@synthesize delegate = _delegate;
@synthesize weiboType = _weiboType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
    [super loadView];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.title = @"weibo";
    
    _webView = [[UIWebView alloc] initWithFrame:[self.view bounds]];
    [_webView setDelegate:self];
    
    weiboHttpManager = [[WeiboHTTPManager alloc] initWithDelegate:self];
    NSURL *url = nil;
    if (_weiboType == SINA_WEIBO)
        url = [weiboHttpManager getSinaOAuthCodeUrl];
    else if (_weiboType == TENCENT_WEIBO) {
        url = [weiboHttpManager getTencentOAuthCodeUrl];
    }
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [_webView loadRequest:request];
    [_webView setDelegate:self];
    [request release];
    
    [self.view addSubview:_webView];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelWeibo)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void) cancelWeibo {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    if ([_delegate respondsToSelector:@selector(oauthControllerDidCancel:)]) {
        [_delegate oauthControllerDidCancel:self];
    }
}

- (NSString *) getValueFromString:(NSString *)str withName:(NSString *)name {
    NSArray *array = [str componentsSeparatedByString:@"&"];
    for (NSString *s in array) {
        NSArray *subArray = [s componentsSeparatedByString:@"="];
        NSString *key = [subArray objectAtIndex:0];
        NSString *value = [subArray objectAtIndex:1];
        if ([key isEqualToString:name]) {
            return value;
        }
    }
    return nil;
}

- (void) sinaWeiboDidSucceed:(NSString *)params {
    NSString *q = params;
    NSString *token = [self getValueFromString:q withName:@"access_token"];
    NSString *oauth2String = [NSString stringWithFormat:@"access_token=%@", token];

    // 用户点取消 error_code=21330
    NSString *errorCode = [self getValueFromString:q withName:@"error_code"];
    if (errorCode != nil && [errorCode isEqualToString: @"21330"]) {
        [self cancelWeibo];
    }
    
    NSString *refreshToken = [self getValueFromString:q withName:@"refresh_token"];
    NSString *expTime = [self getValueFromString:q withName:@"expires_in"];
    NSString *uid = [self getValueFromString:q withName:@"uid"];
    //NSString *remindIn = [self getValueFromString:q withName:@"remind_in"];
    
    TokenModel *tokenModel = [[TokenModel alloc] init];
    tokenModel.weiboType = SINA_WEIBO;
    tokenModel.refreshToken = refreshToken;
    tokenModel.accessToken = token;
    tokenModel.userID = uid;
    tokenModel.expireTime = expTime;
    tokenModel.extraInfo = oauth2String;

    NSLog(@"token model is %@", tokenModel);
    if ([_delegate respondsToSelector:@selector(oauthControllerSaveToken:withTokenModel:)]) {
        [_delegate oauthControllerSaveToken:self withTokenModel:tokenModel];
    }
    [tokenModel release];

    [self cancelWeibo];
}
- (void) tencentWeiboDidSucceed:(NSString *)params {    
    NSString *code = [self getValueFromString:params withName:@"code"];
    NSString *openID = [self getValueFromString:params withName:@"openid"];
    NSString *openKey = [self getValueFromString:params withName:@"openkey"];
    
    NSString *getToken = [NSString stringWithFormat:
                          @"https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code&code=%@", 
                          TENCENT_APP_KEY, TENCENT_APP_SECRET, TENCENT_CALLBACK, code];
    NSLog(@"token url is %@", getToken);
    NSURL *getTokenURL = [NSURL URLWithString:getToken];
    NSString *tokenString = [NSString stringWithContentsOfURL:getTokenURL encoding:NSUTF8StringEncoding error:nil];
    // tokenString is access_token=7f2096d70b49a9ae70f8b7ec1eb93d10&expires_in=604800&refresh_token=0026fe6e66ac7d659dac47dfcac494d6&name=oyangjian001
    
    NSString *accessToken = [self getValueFromString:tokenString withName:@"access_token"];
    NSString *expTime = [self getValueFromString:tokenString withName:@"expires_in"];
    NSString *userName = [self getValueFromString:tokenString withName:@"name"];
    
    NSString *oauth2String = [NSString stringWithFormat:
                              @"name=%@&oauth_consumer_key=%@&access_token=%@&openid=%@&openkey=%@&oauth_version=2.a",
                              userName, TENCENT_APP_KEY, accessToken, openID, openKey, @"2.a"];
    TokenModel *tokenModel = [[TokenModel alloc] init];
    tokenModel.weiboType = TENCENT_WEIBO;
    tokenModel.accessToken = accessToken;
    tokenModel.expireTime = expTime;
    tokenModel.userName = userName;
    tokenModel.openID = openID;
    tokenModel.openKey = openKey;
    tokenModel.extraInfo = oauth2String;
    if ([_delegate respondsToSelector:@selector(oauthControllerSaveToken:withTokenModel:)]) {
        [_delegate oauthControllerSaveToken:self withTokenModel:tokenModel];
    }
    [tokenModel release];
    
    [self cancelWeibo];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    // 这里是几个重定向，将每个重定向的网址遍历，如果遇到＃号，则重定向到自己申请时候填写的网址，后面会附上access_token的值
    NSURL *url = [request URL];
    NSLog(@"webview's url = %@",url);
    
    if (_weiboType == TENCENT_WEIBO) 
    {
        // http://www.1000phone.com/?code=5b22f613ce98511ac6b1c1dccc35a1ee&openid=6E2D92FFD383EF67410284F536F832AA&openkey=1C8E1BF014179E4DB89D949005A72944
        // Tencent weibo
        
        if ([[url absoluteString] rangeOfString:@"code="].length > 0) {
            NSRange range = [[url absoluteString] rangeOfString:@"?"];
            NSString *params = [[url absoluteString] substringFromIndex:range.location+1];
            [self tencentWeiboDidSucceed:params];
            return NO;
        }
    } else if (_weiboType == SINA_WEIBO) {
        //https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=801124323&client_secret=9d19ed0ae00ef963d73c06e518a34d27&redirect_uri=http%3A%2F%2Fwww.1000phone.com&grant_type=authorization_code&code=2b7ddb8de2e50640de7ebb02e712ed1c
        
        NSArray *array = [[url absoluteString] componentsSeparatedByString:@"#"];
        if ([array count]>1) {
            // http://www.1000phone.com/#access_token=2.00d4s_SC6hIGaC3ab9a0af3aaRBAFC&remind_in=86399&expires_in=86399&uid=2102976985
            [self sinaWeiboDidSucceed:[array objectAtIndex:1]];
            return NO;
        }
    }
    return YES;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

- (void) dealloc {
    [_tokenModel release], _tokenModel = nil;
    [super dealloc];
}


@end
