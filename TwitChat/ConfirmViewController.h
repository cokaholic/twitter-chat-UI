//
//  ConfirmViewController.h
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/21.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChatRoomViewController.h"

@protocol ConfirmProtocol <NSObject>

- (void)confirmGoTalk;
- (void)confirmCancelTalk;

@end

@interface ConfirmViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *followerTableView;
    UIButton *goTalkButton;
    UIButton *cancelButton;
    
}

@property(nonatomic,retain)id<ConfirmProtocol> delegate;
@property(nonatomic,retain)NSArray *userIDs;
@property(nonatomic,retain)NSArray *userNames;
@property(nonatomic,retain)NSArray *userImages;

@end
