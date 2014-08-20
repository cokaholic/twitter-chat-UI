//
//  ServerManager.h
//  TwitChat
//
//  Created by tamura on 2014/08/20.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AuthManager.h"

@interface ServerManager : NSObject

+ (void)serverRequest:(NSString*)method
                  api:(NSString *)api
                param:(NSDictionary *)param
    completionHandler:(void (^)(NSURLResponse* response, NSData* data, NSError* connectionError))handler;

@end
