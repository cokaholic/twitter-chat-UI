//
//  SecondViewController.m
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "SecondViewController.h"

@interface SecondViewController ()

@end

@implementation SecondViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

// KeyChain登録サービス名
static NSString *const kKeychainAppServiceName = @"DMchat";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"フォロワー";
    
    userImgArray = [NSMutableArray array];
    _userInfoFetchCounter = -1;
    
    followerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50) style:UITableViewStyleGrouped];
    followerTableView.delegate = self;
    followerTableView.dataSource = self;
    followerTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:followerTableView];
    [followerTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    // GTMOAuthAuthenticationインスタンス生成
    
    _auth = [AuthManager sharedManager].auth;

    [self asyncShowFriends];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Followers";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    // ユーザ情報を全て
    if (_userInfoFetchCounter == 0) return _friends.count;
    else return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.numberOfLines = 0;
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize]-3];
    cell.backgroundColor = [UIColor clearColor];
    
    //プロフィール画像を円形に
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 22.0f;

    
    // 対象インデックスのユーザ情報を取り出す
    NSObject *obj = [_friends objectAtIndex:indexPath.row];
    
    if ([obj isKindOfClass:[NSDictionary class]]) {
        // ユーザ情報
        NSDictionary* user = (NSDictionary*)obj;
        NSString* content = [NSString stringWithFormat:@"%@ @%@", user[@"name"], user[@"screen_name"]];
        cell.textLabel.text = content;
        // 画像
        NSURL *imageURL = [NSURL URLWithString:_friends[indexPath.row][@"profile_image_url"]];
        UIImage *placeholderImage = [UIImage imageNamed:@"icon_hana"];
        [cell.imageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage completed:
        ^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL){
            if (![_imageCompleted[indexPath.row] boolValue]) {
                _imageCompleted[indexPath.row] = [NSNumber numberWithBool:YES];
                [followerTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }];
    } else {
        cell.textLabel.text = @"";
    }
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    // テキストサイズでテーブルセルの高さを調整
//    NSString *content = [NSString stringWithFormat:@"%@", [_friends objectAtIndex:indexPath.row]];
//    CGSize labelSize = [content boundingRectWithSize:CGSizeMake(227, 1000)
//                                             options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin
//                                          attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:12]} context:nil].size;
//    
//    return labelSize.height + 25;
//}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //セルの選択を解除（青くなるのを消す）
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    // グループ作成
    NSDictionary* friend = _friends[indexPath.row];
    
    NSString* my_screen_name = @"sune232002";
    NSArray* names = @[my_screen_name, friend[@"screen_name"]];
    NSString* namesStr = [names componentsJoinedByString:@","];
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    
    NSArray* twitterIDs = @[
                            [ud stringForKey:@"twitter_id"],
                            friend[@"id"]
                            ];
    NSString* twitterIDsStr = [twitterIDs componentsJoinedByString:@","];
    
    NSDictionary* param = @{
                            @"screen_name" : namesStr,
                            @"name" : namesStr
                            };
    
    [ServerManager serverRequest:@"POST" api:@"groups" param:param completionHandler:^(NSURLResponse *response, NSDictionary *dict) {
        NSNumber* numStatus = dict[@"status"];
        int status = [numStatus intValue];
        
        if (status == 200) {
            NSNumber* numGroupID = dict[@"group"][@"id"];
            int groupID = [numGroupID intValue];
            ChatRoomViewController* crvc = [[ChatRoomViewController alloc] initWithGroupID:groupID];
            UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:crvc];
            crvc.title = namesStr;
            [self presentViewController:nvc animated:YES completion:nil];

        }
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// デフォルトのタイムライン処理表示
- (void)asyncShowFriends
{
    [self fetchFollowIDs:@"friends"];
    [self fetchFollowIDs:@"followers"];
}

// クエリのエンコード
-(NSString*)getQueryStringByDic:(NSDictionary*)dic
{
    NSArray*keys = [dic allKeys];
    NSMutableArray*tmp=[NSMutableArray array];
    for (NSString*key in keys) {
        [tmp addObject:[NSString stringWithFormat:@"%@=%@",key,dic[key]]];
    }
    return [tmp componentsJoinedByString:@"&"];
}

// URLで取得
- (void)fetchWithURL:(NSString*)urlStr didFinishSelector:(SEL)selector userData:(id)data {
    // 要求を準備
    NSURL *url = [NSURL URLWithString:urlStr];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    [request setHTTPMethod:@"GET"];
    
    // 要求に署名情報を付加
    [_auth authorizeRequest:request];
    
    // 非同期通信による取得開始
    GTMHTTPFetcher *fetcher = [GTMHTTPFetcher fetcherWithRequest:request];
    [fetcher beginFetchWithDelegate:self
                  didFinishSelector:selector];
    fetcher.userData = data;
}

// フォロワー/フォロワーID 取得
- (void)fetchFollowIDs:(NSString*)method
{
    NSString* baseUrlStr = [NSString stringWithFormat:@"https://api.twitter.com/1.1/%@/ids.json?", method];
    NSDictionary* params = @{ @"count" : @"5000" };
    NSString* urlStr = [baseUrlStr stringByAppendingString:[self getQueryStringByDic:params]];
    [self fetchWithURL:urlStr
     didFinishSelector:@selector(followIDsFetcher:finishedWithData:error:)
              userData:method];
}

// フォロー/フォロワーID 取得応答時
- (void)followIDsFetcher:(GTMHTTPFetcher *)fetcher
        finishedWithData:(NSData *)data
                   error:(NSError *)error
{
    if (error != nil) {
        NSLog(@"Fetching %@/ids error: %d", fetcher.userData, (int)error.code);
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
    if ([fetcher.userData isEqualToString:@"friends"]) {
        _followingIDs = [dict objectForKey:@"ids"];
    } else {
        _followerIDs = [dict objectForKey:@"ids"];
    }
    
    if (_followerIDs != nil && _followingIDs != nil) {
        // 相互フォロー取得
        [self getFriend];
        // ユーザ情報取得
        [self fetchUserInfo];
    }
}

- (void)getFriend
{
    NSMutableSet* followingSet = [NSMutableSet setWithArray:_followingIDs];
    NSMutableSet* followerSet = [NSMutableSet setWithArray:_followerIDs];
    [followingSet intersectSet:followerSet];
    _friendIDs = [followingSet allObjects];
}

// ユーザ情報取得
- (void)fetchUserInfo
{
    NSString* baseUrlStr = @"https://api.twitter.com/1.1/users/lookup.json?";
    _friends = [[NSMutableArray alloc] init];
    _imageCompleted = [[NSMutableArray alloc] init];
    _userInfoFetchCounter = 0;
    for (int i=0; i<_friendIDs.count; i+=100) {
        NSMutableArray* tmpArray = [[NSMutableArray alloc] init];
        for (int j=i; j<MIN(i+100, _friendIDs.count); ++j) {
            [tmpArray addObject:[_friendIDs objectAtIndex:j]];
        }
        NSDictionary* params = @{ @"user_id" : [tmpArray componentsJoinedByString:@","] };
        NSString* urlStr = [baseUrlStr stringByAppendingString:[self getQueryStringByDic:params]];
        [self fetchWithURL:urlStr
         didFinishSelector:@selector(userInfoFetcher:finishedWithData:error:)
                  userData:[NSNumber numberWithInt:i]];
        _userInfoFetchCounter++;
    }
}


// ユーザ情報 取得応答時
- (void)userInfoFetcher:(GTMHTTPFetcher *)fetcher
       finishedWithData:(NSData *)data
                  error:(NSError *)error
{
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
    for (int i=0; i<users.count; ++i) {
        [_friends addObject:[users[i] dictionaryWithValuesForKeys:@[@"screen_name",
                                                                    @"name",
                                                                    @"profile_image_url",
                                                                    @"id"]]];
        [_imageCompleted addObject:[NSNumber numberWithBool:NO]];
    }
    
    _userInfoFetchCounter--;
    if (_userInfoFetchCounter == 0) {
        // テーブルを更新
        NSLog(@"user info fetched");
        [_friends sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1[@"screen_name"] compare:obj2[@"screen_name"]];
        }];
        [followerTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
