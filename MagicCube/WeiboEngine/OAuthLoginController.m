//
//  OAuthWebView.m
//  weibo
//
//  Created by Yang QianFeng on 29/06/2012.
//  Copyright (c) 2012 千锋3G www.mobiletrain.org. All rights reserved.
//

#import "OAuthLoginController.h"
#import "WeiboHTTPManager.h"

static UIViewController *s;
static OAuthLoginController *root;
@implementation OAuthLoginController
@synthesize delegate = _delegate;

@synthesize openID, openKey, accessToken, expTime, userName;

+ (id) sharedOAuthController {
    if (s == nil) {
        root = [[[self class] alloc] init];
        s = [[UINavigationController alloc] initWithRootViewController:root];
    }
    return s;
}
+ (id) sharedController {
    return root;
}


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

- (void) loadView
{
    [super loadView];
    
    self.title = @"weibo";
    
    webV = [[UIWebView alloc] initWithFrame:[self.view bounds]];
    [webV setDelegate:self];
    
    weiboHttpManager = [[WeiboHTTPManager alloc] initWithDelegate:self];
//    NSURL *url = [weiboHttpManager getOauthCodeUrl];
    NSURL *url = [weiboHttpManager getTencentOauthCodeUrl];

    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
    [webV loadRequest:request];
    [request release];
    
    [self.view addSubview:webV];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelWeibo)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    [cancelButton release];
}
- (void) closeView {
    UIViewController *wv = [OAuthLoginController sharedOAuthController];

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

- (void) cancelWeibo {
    [self closeView];

    if ([_delegate respondsToSelector:@selector(didCancelOauthController:)]) {
        [_delegate didCancelOauthController:self];
    }
}

+ (void) logout {
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TENCENT_USER_STORE_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TENCENT_USER_STORE_USER_ID];
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:TENCENT_USER_STORE_EXPIRATION_DATE];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (NSString *) getStringFromUrl: (NSString*) url needle:(NSString *) needle {
    NSString * str = nil;
    NSRange start = [url rangeOfString:needle];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = end.location == NSNotFound
        ? [url substringFromIndex:offset]
        : [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    return str;
}

- (void) dialogDidSucceed:(NSURL*)url {
    NSString *q = [url absoluteString];
    token = [self getStringFromUrl:q needle:@"access_token="];
    
    // 用户点取消 error_code=21330
    NSString *errorCode = [self getStringFromUrl:q needle:@"error_code="];
    if (errorCode != nil && [errorCode isEqualToString: @"21330"]) {
        [self cancelWeibo];
    }
    
    NSString *refreshToken = [self getStringFromUrl:q needle:@"refresh_token="];
    NSString *expTime = [self getStringFromUrl:q needle:@"expires_in="];
    NSString *uid = [self getStringFromUrl:q needle:@"uid="];
    NSString *remindIn = [self getStringFromUrl:q needle:@"remind_in="];
    
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:TENCENT_USER_STORE_ACCESS_TOKEN];
    [[NSUserDefaults standardUserDefaults] setObject:uid forKey:TENCENT_USER_STORE_USER_ID];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    NSDate *expirationDate =nil;
    NSLog(@"qianfeng \n\ntoken=%@\nrefreshToken=%@\nexpTime=%@\nuid=%@\nremindIn=%@\n\n",token,refreshToken,expTime,uid,remindIn);
    if (expTime != nil) {
        int expVal = [expTime intValue]-3600;
        if (expVal) {
            expirationDate = [NSDate dateWithTimeIntervalSinceNow:expVal];
            [[NSUserDefaults standardUserDefaults]setObject:expirationDate forKey:TENCENT_USER_STORE_EXPIRATION_DATE];
            [[NSUserDefaults standardUserDefaults] synchronize];
            NSLog(@"qianfeng time = %@",expirationDate);
        } 
    } 
    if (token) {
        [self closeView];
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType{
    
    // 这里是几个重定向，将每个重定向的网址遍历，如果遇到＃号，则重定向到自己申请时候填写的网址，后面会附上access_token的值
    NSURL *url = [request URL];
    NSLog(@"webview's url = %@",url);
    {
        // http://www.1000phone.com/?code=5b22f613ce98511ac6b1c1dccc35a1ee&openid=6E2D92FFD383EF67410284F536F832AA&openkey=1C8E1BF014179E4DB89D949005A72944
        // Tencent weibo
        
        
        if ([[url absoluteString] rangeOfString:@"openkey="].length > 0) {
            
            NSRange range = [[url absoluteString] rangeOfString:@"?"];
            NSString *params = [[url absoluteString] substringFromIndex:range.location+1];
            
            NSArray *array = [params componentsSeparatedByString:@"&"];
            NSString *code = nil;
            for (NSString *s in array) {
                NSArray *subArray = [s componentsSeparatedByString:@"="];
                NSString *name = [subArray objectAtIndex:0];
                NSString *value = [subArray objectAtIndex:1];
                if ([name isEqualToString:@"code"]) {
                    code = value;
                }
                if ([name isEqualToString:@"openid"]) {
                    openID = value;
                }
                if ([name isEqualToString:@"openkey"]) {
                    openKey = value;
                }
            }
            // https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=APP_KEY&client_secret=APP_SECRET&redirect_uri=http://www.myurl.com/example&grant_type=authorization_code&code=CODE
            NSString *getToken = [NSString stringWithFormat:
                    @"https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=%@&client_secret=%@&redirect_uri=%@&grant_type=authorization_code&code=%@", 
                                  TENCENT_APP_KEY, TENCENT_APP_SECRET, TENCENT_CALLBACK, code];
            NSLog(@"token url is %@", getToken);
            NSURL *getTokenURL = [NSURL URLWithString:getToken];
            NSString *tokenString = [NSString stringWithContentsOfURL:getTokenURL encoding:NSUTF8StringEncoding error:nil];
            // tokenString is access_token=7f2096d70b49a9ae70f8b7ec1eb93d10&expires_in=604800&refresh_token=0026fe6e66ac7d659dac47dfcac494d6&name=oyangjian001
            
            array = [tokenString componentsSeparatedByString:@"&"];
            for (NSString *s in array) {
                NSArray *subArray = [s componentsSeparatedByString:@"="];
                NSString *name = [subArray objectAtIndex:0];
                NSString *value = [subArray objectAtIndex:1];
                if ([name isEqualToString:@"access_token"]) {
                    accessToken = value;
                }
                if ([name isEqualToString:@"expires_in"]) {
                    expTime = value;
                }
                if ([name isEqualToString:@"name"]) {
                    userName = value;
                }
            }
            
            NSString *oauth2String = [NSString stringWithFormat:
                        @"name=%@&oauth_consumer_key=%@&access_token=%@&openid=%@&openkey=%@&oauth_version=2.a",
                            userName, TENCENT_APP_KEY, accessToken, openID, openKey, @"2.a"];
            [[NSUserDefaults standardUserDefaults] setObject:accessToken 
                                            forKey:TENCENT_USER_STORE_ACCESS_TOKEN];
            [[NSUserDefaults standardUserDefaults] setObject:expTime 
                                            forKey:TENCENT_USER_STORE_EXPIRATION_DATE];
            [[NSUserDefaults standardUserDefaults] setObject:userName 
                                            forKey:TENCENT_USER_STORE_USER_NAME];
            [[NSUserDefaults standardUserDefaults] setObject:userName 
                                            forKey:TENCENT_USER_STORE_USER_ID];
            [[NSUserDefaults standardUserDefaults] setObject:openID 
                                            forKey:TENCENT_USER_STORE_OPENID];
            [[NSUserDefaults standardUserDefaults] setObject:openKey 
                                            forKey:TENCENT_USER_STORE_OPENKEY];
            [[NSUserDefaults standardUserDefaults] setObject:oauth2String 
                                            forKey:TENCENT_USER_STORE_OAUTH2];
            [[NSUserDefaults standardUserDefaults] synchronize];

#if 0
            
            NSString *getPublic = [NSString stringWithFormat:
                                   @"https://open.t.qq.com/api/statuses/home_timeline?format=json&pageflag=0&reqnum=20&pagetime=0&type=0x1&contenttype=1"];
            NSDictionary *oauth = [[NSDictionary alloc] initWithObjectsAndKeys:
                    @"oyangjian001", @"name", 
                    @"801124323", @"oauth_consumer_key",
                    @"7f2096d70b49a9ae70f8b7ec1eb93d10", @"access_token",
                    @"6E2D92FFD383EF67410284F536F832AA", @"openid",
                    @"1C8E1BF014179E4DB89D949005A72944", @"openkey",
                    @"2.a", @"oauth_version", 
                    nil];
            NSString *test = @"https://open.t.qq.com/api/statuses/home_timeline?format=json&pageflag=0&reqnum=20&pagetime=0&type=0x1&contenttype=1&name=oyangjian001&oauth_consumer_key=801124323&access_token=7f2096d70b49a9ae70f8b7ec1eb93d10&openid=6E2D92FFD383EF67410284F536F832AA&openkey=1C8E1BF014179E4DB89D949005A72944&oauth_version=2.a";
#endif
            [self closeView];

            return NO;
        }
    }
    //https://open.t.qq.com/cgi-bin/oauth2/access_token?client_id=801124323&client_secret=9d19ed0ae00ef963d73c06e518a34d27&redirect_uri=http%3A%2F%2Fwww.1000phone.com&grant_type=authorization_code&code=2b7ddb8de2e50640de7ebb02e712ed1c
    
    NSArray *array = [[url absoluteString] componentsSeparatedByString:@"#"];
    if ([array count]>1) {
        // http://www.1000phone.com/#access_token=2.00d4s_SC6hIGaC3ab9a0af3aaRBAFC&remind_in=86399&expires_in=86399&uid=2102976985
        [self dialogDidSucceed:url];
        return NO;
    }
    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidStartLoad ");
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSLog(@"webViewDidFinishLoad ");
}

+ (void) launchLoginUI {
    UIViewController *wv = [OAuthLoginController sharedOAuthController];

    UIWindow* wnd = [[UIApplication sharedApplication] keyWindow];
    CGRect windowRect = wnd.frame;
    
    CGRect origRect = windowRect;
    origRect.origin.y += windowRect.size.height;
    [wv.view setFrame:origRect];

    [wnd addSubview:wv.view];

	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.5];
	wv.view.frame = windowRect;
	[UIView commitAnimations];
}

+ (NSString *) getCurrentAccount {
    OAuthLoginController *currLogin = root;

    [[NSUserDefaults standardUserDefaults] synchronize];
    currLogin.accessToken = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_ACCESS_TOKEN];
    currLogin.expTime = [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_EXPIRATION_DATE];
    currLogin.userName = 
    [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_USER_NAME];
    currLogin.openID = 
    [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_OPENID];
    currLogin.openKey = 
    [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_OPENKEY];
    
    return [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_USER_ID];
}
+ (NSString *) getCurrentToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:TENCENT_USER_STORE_ACCESS_TOKEN];
}


@end
