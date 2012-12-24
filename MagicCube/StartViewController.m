//
//  StartViewController.m
//  MagicCube
//
//  Created by lihua liu on 12-9-11.
//  Copyright (c) 2012年 yinghuochong. All rights reserved.
//

#import "StartViewController.h"
#import "ViewController.h"
#define NUM_OF_TEXTURE 6


@implementation StartViewController
- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    selectedRow = 0;
    
    tencentOAuthManager = [[OAuthManager alloc] initWithOAuthManager:TENCENT_WEIBO];
    tencentOAuthManager.delegate = self;
    
    magicPicArray = [[NSMutableArray alloc] initWithCapacity:0];
    for (int i=0; i<NUM_OF_TEXTURE; i++) {
        [magicPicArray addObject:[NSString stringWithFormat:@"m%d",i+1]];
    }
   
    UIImageView *imageview = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"start.png"]];
    [self.view addSubview:imageview];
    [imageview release];

    
    CGSize winSize = self.view.bounds.size;
    
       UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startButton setImage:[UIImage imageNamed:@"startMenu.png"] forState:UIControlStateNormal];
    startButton.frame = CGRectMake(winSize.width/2.0f-60, winSize.height/2.0f+120, 120,40);
    [startButton addTarget:self action:@selector(startClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:startButton];
    
    UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(200, 450, 70, 30)];
    lable.backgroundColor= [UIColor clearColor];
    lable.font= [UIFont systemFontOfSize:15];
    lable.textColor = [UIColor whiteColor];
    lable.text = @"分享到 : ";
    [self.view addSubview:lable];
    [lable release];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    shareButton.frame = CGRectMake(250, 450, 30, 30);
    [shareButton setImage:[UIImage imageNamed:@"btn_share_weibo.png"] forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"btn_share_weibo_selected.png"] forState:UIControlStateSelected];
    [shareButton addTarget:self action:@selector(shareButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:shareButton];
   
    UITableView *tableView = [[UITableView alloc] initWithFrame:CGRectMake(50, 120, 220, 220) style:UITableViewStylePlain];
    [self.view addSubview:tableView];
    tableView.backgroundColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    [tableView release];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return magicPicArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellID = @"cellID";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellID] autorelease];
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.frame = CGRectMake(0, 0, 220, 43);
        imageView.tag = 100;
        [cell addSubview:imageView];
        [imageView release];
    }
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    NSString *str = [NSString stringWithFormat:@"%@.png",[magicPicArray objectAtIndex:indexPath.row]];
    [imageView setImage:[UIImage imageNamed:str]];
    return cell;  
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    printf("row: %d,Section : %d\n",indexPath.row,indexPath.section);
    
    for (int i=0; i<magicPicArray.count; i++) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
        UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
        NSString *str = [NSString stringWithFormat:@"%@.png",[magicPicArray objectAtIndex:i]];
        imageView.image =  [UIImage imageNamed:str];
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:100];
    NSString *str = [NSString stringWithFormat:@"%@2.png",[magicPicArray objectAtIndex:indexPath.row]];
    imageView.image =  [UIImage imageNamed:str];
    selectedRow = indexPath.row;
}



- (void)loginFinished:(OAuthManager *)manager
{
    if ([tencentOAuthManager isAlreadyLogin]) {
        indicatorView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
        indicatorView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
        [indicatorView startAnimating];
        [self.view addSubview:indicatorView];
        [indicatorView release];
        
        UIImage *image = [UIImage imageNamed:@"share3.png"];
        NSString * text = @"这个3d魔方游戏太有意思啦，还能换各种材质有木有啊.... --萤火虫作品";
        NSData *data = UIImageJPEGRepresentation(image, 0.8);
        NSURL *url = [NSURL URLWithString:@"https://open.t.qq.com/api/t/add_pic"];
        ASIFormDataRequest *postPicWeibo = [ASIFormDataRequest requestWithURL:url];
        
        [postPicWeibo setPostValue:@"json" forKey:@"format"];
        [postPicWeibo setPostValue:text forKey:@"content"];
        [postPicWeibo addData:data withFileName:@"test2xx.jpg" andContentType:@"image/png" forKey:@"pic"];
        [postPicWeibo setPostValue:[NSString stringWithFormat:@"%d",arc4random()%180-90] forKey:@"latitude"];
        [postPicWeibo setPostValue:[NSString stringWithFormat:@"%d",arc4random()%360-180] forKey:@"longitude"];
        [postPicWeibo setPostValue:@"0" forKey:@"syncflag"];
        [postPicWeibo setPostValue:@"221.223.249.130" forKey:@"clientip"];
        [tencentOAuthManager addPrivatePostParamsForASI:postPicWeibo];
        
        [postPicWeibo setDelegate:self];
        postPicWeibo.tag = 102;
        [postPicWeibo startAsynchronous];
    }
}

-(void)shareButtonClick
{
    if (![tencentOAuthManager isAlreadyLogin]) {
        [tencentOAuthManager login];
        [UIColor underPageBackgroundColor];
        return;
    } else{
        [self loginFinished:tencentOAuthManager];
    }
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    [indicatorView removeFromSuperview];
    NSLog(@"error info : %@",[request error]);
}
- (void)requestFinished:(ASIHTTPRequest *)request
{
    [indicatorView removeFromSuperview];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"分享到微博" message:@"分享成功" delegate:self cancelButtonTitle:@"知道了" otherButtonTitles:nil, nil];
    [alertView show];
    [alertView release];
    NSLog(@"post pic: %@",[request responseString]); 
}

- (void)startClick
{
     NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    [ud setObject:[NSString stringWithFormat:@"%@1.png",[magicPicArray objectAtIndex:selectedRow]] forKey:@"texture"];
     ViewController *vc = [[ViewController alloc] init];
    [self presentModalViewController:vc animated:YES];
    [vc release];
}

- (void)dealloc {
    [tencentOAuthManager release];
    [magicPicArray release];
    [super dealloc];
}
@end
