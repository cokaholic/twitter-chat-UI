//
//  AuthManager.h
//  TwitChat
//
//  Created by tamura on 2014/08/19.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"

@interface AuthManager : NSObject

@property(nonatomic, retain) GTMOAuthAuthentication* auth;

+ (AuthManager*)sharedManager;

+ (void)fetchUserInfo:(NSArray*)userIDs withHandler:(void(^)(NSArray* userInfos))handler;
+ (void)fetchFollowIDs:(NSString*)method withHandler:(void(^)(NSArray* twitter_ids))handler;

@end
