//
//  ThirdViewController.h
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GTMOAuthViewControllerTouch.h"
#import "SigninViewController.h"
#import "AuthManager.h"
#import "UIImageView+WebCache.h"

@interface ThirdViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UIScrollView *backScrollView;
    UIImageView *profileImgView;
    UILabel *screenNameLabel;
    UILabel *nameLabel;
    UITableView *settingTableView;
    NSMutableArray *settingArray;
}
@end
