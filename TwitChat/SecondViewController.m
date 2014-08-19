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
    NSString *consumerKey = @"49mYoMGJDyrbjfQGhwfbCJDv0";
    NSString *consumerSecret = @"OEJXK8UXMJdnxkQvrB2IBPVLYFetmQ3AuHUkAkC8UhOtFE0kuc";
    _auth = [[GTMOAuthAuthentication alloc]
             initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
             consumerKey:consumerKey
             privateKey:consumerSecret];
    
    // 既にOAuth認証済みであればKeyChainから認証情報を読み込む
    BOOL authorized = [GTMOAuthViewControllerTouch
                       authorizeFromKeychainForName:kKeychainAppServiceName
                       authentication:_auth];
    
    if (authorized) {
        // 認証済みの場合はタイムライン更新
        [self asyncShowFriends];
        //[self getFriend];
    } else {
        // 未認証の場合は認証処理を実施
        [self asyncSignIn];
    }
    
    NSLog(@"%@\n%@", _auth.accessToken, _auth.tokenSecret);
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
        UIImage *placeholderImage = [UIImage imageNamed:@"hanayamata"];
        [cell.imageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage completed:
        ^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL){
            if (![_imageCompleted[indexPath.row] boolValue]) {
                _imageCompleted[indexPath.row] = [NSNumber numberWithBool:YES];
                
                [followerTableView reloadData];
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// 認証処理
- (void)asyncSignIn
{
    NSString *requestTokenURL = @"https://api.twitter.com/oauth/request_token";
    NSString *accessTokenURL = @"https://api.twitter.com/oauth/access_token";
    NSString *authorizeURL = @"https://api.twitter.com/oauth/authorize";
    
    _auth.serviceProvider = @"Twitter";
    _auth.callback = @"http://www.example.com/OAuthCallback";
    
    GTMOAuthViewControllerTouch *viewController;
    viewController = [[GTMOAuthViewControllerTouch alloc]
                      initWithScope:nil
                      language:nil
                      requestTokenURL:[NSURL URLWithString:requestTokenURL]
                      authorizeTokenURL:[NSURL URLWithString:authorizeURL]
                      accessTokenURL:[NSURL URLWithString:accessTokenURL]
                      authentication:_auth
                      appServiceName:kKeychainAppServiceName
                      delegate:self
                      finishedSelector:@selector(authViewContoller:finishWithAuth:error:)];
    [[self navigationController] pushViewController:viewController animated:YES];
}

// 認証エラー表示AlertViewタグ
static const int kMyAlertViewTagAuthenticationError = 1;

// 認証処理が完了した場合の処理
- (void)authViewContoller:(GTMOAuthViewControllerTouch *)viewContoller
           finishWithAuth:(GTMOAuthAuthentication *)auth
                    error:(NSError *)error
{
    if (error != nil) {
        // 認証失敗
        NSLog(@"Authentication error: %d.", (int)error.code);
        UIAlertView *alertView;
        alertView = [[UIAlertView alloc] initWithTitle:@"Error"
                                               message:@"Authentication failed."
                                              delegate:self
                                     cancelButtonTitle:@"Confirm"
                                     otherButtonTitles:nil];
        alertView.tag = kMyAlertViewTagAuthenticationError;
        [alertView show];
    } else {
        // 認証成功
        NSLog(@"Authentication succeeded.");
        // タイムライン表示
        [self asyncShowFriends];
    }
}

// UIAlertViewが閉じられた時
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    // 認証失敗通知AlertViewが閉じられた場合
    if (alertView.tag == kMyAlertViewTagAuthenticationError) {
        // 再度認証
        [self asyncSignIn];
    }
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
        [followerTableView reloadData];
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
