//
//  SecondViewController.h
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"

@interface SecondViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *followerTableView;
    NSMutableArray *userImgArray;
    BOOL imgLoadFlag;
    
    GTMOAuthAuthentication* _auth;
    NSArray* _followerIDs;
    NSArray* _followingIDs;
    NSArray* _friendIDs;
    NSMutableArray* _friends;
    
    int _userInfoFetchCounter;
}
@end
