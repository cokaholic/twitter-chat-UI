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

+ (void)fetchWithURL:(NSString*)urlStr withHandler:(void(^)(NSData *data, NSError *error))handler
{
    // 要求を準備
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];

    // 要求に署名情報を付加
    [[self sharedManager].auth authorizeRequest:request];
    
    // 非同期通信による取得開始
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithCompletionHandler:handler];
}

//+ (void)fetchWithURL:(NSString*)urlStr didFinishSelector:(SEL)selector userData:(id)data {
//    // 要求を準備
//    NSURL *url = [NSURL URLWithString:urlStr];
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
//    [request setHTTPMethod:@"GET"];
//    
//    // 要求に署名情報を付加
//    [_auth authorizeRequest:request];
//    
//    // 非同期通信による取得開始
//    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
//    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
//        <#code#>
//    }]
//    [fetcher beginFetchWithDelegate:self
//                  didFinishSelector:selector];
//    fetcher.userData = data;
//}

// ユーザ情報取得
+ (void)fetchUserInfo:(NSArray*)userIDs withHandler:(void(^)(NSArray* userInfos))handler
{
    NSString* baseUrlStr = @"https://api.twitter.com/1.1/users/lookup.json?";
    
    NSMutableArray* infos = [[NSMutableArray alloc] init];
    __block int counter = ((int)userIDs.count + 99) / 100;
    for (int i=0; i<userIDs.count; i+=100) {
        NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
        for (int j=i; j<MIN(i+100, userIDs.count); ++j) {
            [tmpArray addObject:userIDs[j]];
        }
        NSDictionary* params = @{ @"user_id" : [tmpArray componentsJoinedByString:@","] };
        NSString* urlStr = [baseUrlStr stringByAppendingString:[self getQueryStringByDic:params]];
        NSLog(@"%@", urlStr);
        [self fetchWithURL:urlStr withHandler:^(NSData *data, NSError *error) {
            if (error != nil) {
                NSLog(@"Fetching users/lookup error: %d", (int)error.code);
                return;
            }
            
            // JSONデータをパース
            NSError *jsonError = nil;
            NSArray* users = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&jsonError];
            // JSONデータのパースエラー
            if (users == nil) {
                NSLog(@"JSON Parser error: %d", (int)jsonError.code);
                return;
            }
            
            // データを保持
            for (NSDictionary* user in users) {
                NSMutableDictionary* tmp = [[NSMutableDictionary alloc] initWithDictionary:
                                                [user dictionaryWithValuesForKeys:@[@"screen_name",
                                                                                    @"name",
                                                                                    @"profile_image_url"]]];
                tmp[@"id"] = user[@"id_str"];
                [infos addObject:tmp];
            }
            counter--;
            
            if (counter == 0) {
                // テーブルを更新
                NSLog(@"user info fetched");
                handler(infos);
            }
        }];
    }
}

// フォロワー/フォロワーID 取得
+ (void)fetchFollowIDs:(NSString*)method withHandler:(void(^)(NSArray* twitter_ids))handler
{
    NSString* baseUrlStr = [NSString stringWithFormat:@"https://api.twitter.com/1.1/%@/ids.json?", method];
    NSDictionary* params = @{ @"count" : @"5000" };
    NSString* urlStr = [baseUrlStr stringByAppendingString:[self getQueryStringByDic:params]];
    [self fetchWithURL:urlStr
           withHandler:^(NSData *data, NSError *error) {
               if (error != nil) {
                   NSLog(@"Fetching %@/ids error: %d", method, (int)error.code);
                   return;
               }
               // JSONデータをパース
               NSError *jsonError = nil;
               NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data
                                                                    options:0
                                                                      error:&jsonError];
               
               // JSONデータのパースエラー
               if (dict == nil) {
                   NSLog(@"JSON Parser error: %d", (int)jsonError.code);
                   return;
               }
               
               // データを保持
               handler([dict objectForKey:@"ids"]);
           }];
}

// フォロー/フォロワーID 取得応答時
- (void)followIDsFetcher:(GTMHTTPFetcher *)fetcher
        finishedWithData:(NSData *)data
                   error:(NSError *)error
{
    
}

@end
