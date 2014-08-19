//
//  ThirdViewController.h
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface ThirdViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UIScrollView *backScrollView;
    UIImageView *profileImgView;
    UILabel *userNameLabel;
    UITableView *settingTableView;
    NSMutableArray *settingArray;
}
@end
