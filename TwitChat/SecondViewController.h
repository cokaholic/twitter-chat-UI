//
//  SecondViewController.h
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *followerTableView;
    NSMutableArray *followerArray;
    NSMutableArray *userImgArray;
    BOOL imgLoadFlag;
}
@end
