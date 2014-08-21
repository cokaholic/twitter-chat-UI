//
//  ConfirmViewController.h
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/21.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *followerTableView;
    UIButton *goTalkButton;
    UIButton *cancelButton;
}

@property(nonatomic,retain)NSArray *userNames;
@property(nonatomic,retain)NSMutableArray *userImages;

@end
