//
//  StartViewController.h
//  MagicCube
//
//  Created by lihua liu on 12-9-11.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthManager.h"

@interface StartViewController : UIViewController<UITableViewDelegate,UITableViewDataSource,OAuthManagerDelegate>
{
    int selectedRow;
    NSMutableArray *magicPicArray;
    OAuthManager *tencentOAuthManager;
    UIActivityIndicatorView *indicatorView;
}

@end
