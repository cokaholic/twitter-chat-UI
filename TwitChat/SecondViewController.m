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
    
    self.title = @"フレンド";
    
    userImgArray = [NSMutableArray array];
    _userInfoFetchCounter = -1;
    
    cellNumberSet = [NSMutableSet set];
    
    followerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50) style:UITableViewStyleGrouped];
    followerTableView.delegate = self;
    followerTableView.dataSource = self;
    followerTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:followerTableView];
    [followerTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    // GTMOAuthAuthenticationインスタンス生成
    
    _auth = [AuthManager sharedManager].auth;

    [self asyncShowFriends];
    
    //tatsumi add>>
    //addボタン
    addButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                             target:self
                                                             action:@selector(addTalkGroup)];
    
    self.navigationItem.rightBarButtonItem = addButton;
    
    addButton.enabled = NO;
    
    //tatsumi add<<
    
    clearButton = [[UIBarButtonItem alloc]initWithTitle:@"Clear" style:UIBarButtonItemStylePlain
                                                                target:self
                                                                action:@selector(clearGroup)];
    
    self.navigationItem.leftBarButtonItem = clearButton;
    clearButton.enabled = NO;
    
    
}

- (void)clearGroup
{
    addButton.enabled = NO;
    clearButton.enabled = NO;
    
    [cellNumberSet removeAllObjects];
    [followerTableView reloadData];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return nil;
//    return @"Followers";
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

    //added
    NSNumber* rowNum = [NSNumber numberWithInteger:indexPath.row];
    if ([cellNumberSet containsObject:rowNum]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

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

    NSNumber* rowNum = [NSNumber numberWithInteger:indexPath.row];
    if ([cellNumberSet containsObject:rowNum]) {
        [cellNumberSet removeObject:rowNum];
    } else {
        [cellNumberSet addObject:rowNum];
    }
    
    if (cellNumberSet.count > 0) {
        addButton.enabled = YES;
        clearButton.enabled = YES;
    } else {
        addButton.enabled = NO;
        clearButton.enabled = NO;
    }
    
    [followerTableView reloadData];
    
    /*
    // グループ作成
    NSDictionary* friend = _friends[indexPath.row];
    
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    
    NSString* my_screen_name = [ud stringForKey:@"screen_name"];
    
    NSArray* names = @[my_screen_name, friend[@"screen_name"]];
    NSString* namesStr = [names componentsJoinedByString:@","];
    

    NSArray* twitterIDs = @[
                            [ud stringForKey:@"twitter_id"],
                            friend[@"id"]
                            ];
    NSString* twitterIDsStr = [twitterIDs componentsJoinedByString:@","];
    
    NSDictionary* param = @{
                            @"user_id" : twitterIDsStr,
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
    */
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//tatsumi add>>
//トークグループ追加
-(void)addTalkGroup{
    
    NSLog(@"%@",cellNumberSet);
    
    //選択数が１以上なら移動
    if (cellNumberSet.count!=0) {
        ConfirmViewController *vc = [[ConfirmViewController alloc]init];
        
        NSMutableArray* userIDs = [NSMutableArray array];
        NSMutableArray* userNames = [NSMutableArray array];
        NSMutableArray* userImages = [NSMutableArray array];
        
        NSArray* sorted = [[cellNumberSet allObjects] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1 compare:obj2];
        }];
        for (NSNumber* rowNum in sorted) {
            int row = [rowNum intValue];
            NSDictionary* friend = _friends[row];
            UITableViewCell* cell = [followerTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:row inSection:0]];
            [userImages addObject: cell.imageView.image];
            [userIDs addObject:friend[@"id"]];
            [userNames addObject:cell.textLabel.text];
        }
        
        _confirmUserIDs = [NSArray arrayWithArray:userIDs];
        vc.userIDs = [NSArray arrayWithArray:userIDs];
        vc.userNames = [NSArray arrayWithArray:userNames];
        vc.userImages = [NSArray arrayWithArray:userImages];
        
        vc.view.frame = CGRectMake(0, 0, self.view.bounds.size.width, 340.0f);
        vc.delegate = self;
        [self presentPopUpViewController:vc];
    }
}
//tatsumi add<<

-(void)confirmCancelTalk
{
    NSLog(@"cancel!");
    [self dismissPopUpViewControllerWithcompletion:nil];
}

-(void)confirmGoTalk
{
    NSLog(@"go talk!");
    NSString* twitterIDsStr = [_confirmUserIDs componentsJoinedByString:@","];
    
    NSDictionary* param = @{
                            @"user_id" : twitterIDsStr,
                            @"name" : @""
                            };
    
    [ServerManager serverRequest:@"POST" api:@"groups" param:param completionHandler:^(NSURLResponse *response, NSDictionary *dict) {
        NSNumber* numStatus = dict[@"status"];
        int status = [numStatus intValue];
        
        if (status == 200) {
            NSNumber* numGroupID = dict[@"group"][@"id"];
            int groupID = [numGroupID intValue];
            ChatRoomViewController* crvc = [[ChatRoomViewController alloc] initWithGroupID:groupID];
            UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:crvc];
            
            [self dismissPopUpViewControllerWithcompletion:nil];
            [self presentViewController:nvc animated:YES completion:nil];
            
            [self clearGroup];
        }
    }];
}


// デフォルトのタイムライン処理表示
- (void)asyncShowFriends
{
    __block int counter = 2;
    
    [AuthManager fetchFollowIDs:@"friends" withHandler:^(NSArray *twitter_ids) {
        _followingIDs = twitter_ids;
        counter--;
        if (counter == 0) {
            [self finishFetchFollowIDs];
        }
    }];
    [AuthManager fetchFollowIDs:@"followers" withHandler:^(NSArray *twitter_ids) {
        _followerIDs = twitter_ids;
        counter--;
        if (counter == 0) {
            [self finishFetchFollowIDs];
        }
    }];
}

- (void)finishFetchFollowIDs
{
    // 相互フォロー取得
    [self getFriend];
    // ユーザ情報取得
    [self fetchUserInfo];
}

- (void)getFriend
{
    NSMutableSet* followingSet = [NSMutableSet setWithArray:_followingIDs];
    NSMutableSet* followerSet = [NSMutableSet setWithArray:_followerIDs];
    [followingSet intersectSet:followerSet];
    _friendIDs = [followingSet allObjects];
}

- (void)fetchUserInfo
{
    [AuthManager fetchUserInfo:_friendIDs withHandler:^(NSArray *userInfos) {
        NSLog(@"finish!!!!!!");
        _friends = [NSMutableArray arrayWithArray:userInfos];
        [_friends sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [obj1[@"screen_name"] compare:obj2[@"screen_name"]];
        }];
        _userInfoFetchCounter = 0;
        
        _imageCompleted = [NSMutableArray array];
        
        for (int i=0; i<_friends.count; ++i) {
            [_imageCompleted addObject:@NO];
        }
        
        [followerTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
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
