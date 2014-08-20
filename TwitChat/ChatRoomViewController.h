//
//  ChatRoomViewController.h
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/19.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "UIBubbleTableViewDataSource.h"
#import "JSQMessagesViewController/JSQMessages.h"    // import all headers

@class ChatRoomViewController;


@protocol ChatRoomControllerDelegate <NSObject>

- (void)didDismissJSQDemoViewController:(ChatRoomViewController*)vc;

@end

@interface ChatRoomViewController : JSQMessagesViewController

@property (weak, nonatomic) id<ChatRoomControllerDelegate> delegateModal;

@property (strong, nonatomic) NSMutableArray *messages;
@property (copy, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) UIImageView *outgoingBubbleImageView;
@property (strong, nonatomic) UIImageView *incomingBubbleImageView;

- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

- (void)setupTestModel;

@end
