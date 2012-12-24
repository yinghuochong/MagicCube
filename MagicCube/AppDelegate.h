//
//  AppDelegate.h
//  MagicCube
//
//  Created by lihua liu on 12-9-10.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PaintingWindow.h"

@class StartViewController;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) PaintingWindow *window;

@property (strong, nonatomic) StartViewController *viewController;

@end
