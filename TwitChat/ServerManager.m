//
//  ServerManager.m
//  TwitChat
//
//  Created by tamura on 2014/08/20.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "ServerManager.h"

@implementation ServerManager


// クエリのエンコード
+(NSString*)getQueryStringByDic:(NSDictionary*)dic
{
    NSArray*keys = [dic allKeys];
    NSMutableArray*tmp=[NSMutableArray array];
    for (NSString*key in keys) {
        [tmp addObject:[NSString stringWithFormat:@"%@=%@",key,dic[key]]];
    }
    return [tmp componentsJoinedByString:@"&"];
}

+ (void)serverRequest:(NSString*)method
                  api:(NSString *)api
                param:(NSDictionary *)param
    completionHandler:(void (^)(NSURLResponse *, NSDictionary *))handler {
    
    //リクエスト用のパラメータを設定
    NSString *url  = [NSString stringWithFormat:@"http://twitter-chat.herokuapp.com/api/%@.json", api];
    
    NSMutableDictionary* mutableParam = [NSMutableDictionary dictionaryWithDictionary:param];
    
    if (![api isEqualToString:@"sessions"]) {
        NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
        mutableParam[@"token"] = [ud stringForKey:@"remember"];
    }
    
    NSString *paramStr = [self getQueryStringByDic:mutableParam];
    
    NSLog(@"url   : %@", url);
    NSLog(@"param : %@", paramStr);
    
    //リクエストを生成
    NSMutableURLRequest *req;
    req = [[NSMutableURLRequest alloc] init];
    [req setHTTPMethod:method];
    [req setCachePolicy:NSURLRequestReloadIgnoringLocalCacheData];
    [req setTimeoutInterval:20];
    [req setHTTPShouldHandleCookies:FALSE];
    
    if ([method isEqualToString:@"POST"]) {
        [req setHTTPBody:[paramStr dataUsingEncoding:NSUTF8StringEncoding]];
    } else {
        url = [NSString stringWithFormat:@"%@?%@", url, paramStr];
    }
    
    [req setURL:[NSURL URLWithString:url]];
    
    //非同期通信で送信
    [NSURLConnection sendAsynchronousRequest:req queue:[[NSOperationQueue alloc] init]
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
                               if (connectionError != nil) {
                                   NSLog(@"Error! : %@", connectionError);
                                   return;
                               }
                               NSError *error = nil;
                               NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
                               if (connectionError != nil) {
                                   NSLog(@"JSON Parse Error! : %@", connectionError);
                                   return;
                               }
                               handler(response, dict);
                           }];
    
}


@end
