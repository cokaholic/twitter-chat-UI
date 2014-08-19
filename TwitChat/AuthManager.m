//
//  AuthManager.m
//  TwitChat
//
//  Created by tamura on 2014/08/19.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "AuthManager.h"

@implementation AuthManager

static AuthManager* manager;

+ (AuthManager*)sharedManager {
    @synchronized(self) {
        if (manager == nil) {
            manager = [[self alloc] init];
        }
    }
    return manager;
}

@end
