//
//  FirstViewController.h
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SigninViewController.h"
#import "AuthManager.h"

@interface FirstViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *groupTableView;
    NSMutableArray *groupArray;
    GTMOAuthAuthentication* _auth;
}

@end
