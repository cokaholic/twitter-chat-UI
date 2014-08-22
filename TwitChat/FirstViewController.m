//
//  FirstViewController.m
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "FirstViewController.h"
#import "UIViewController+ENPopUp.h"
#import "SecondViewController.h"

@interface FirstViewController ()

@end

@implementation FirstViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"トーク";
    
    groupArray = [[NSMutableArray alloc] init];
    
    groupTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50)
                                                 style:UITableViewStyleGrouped];
    groupTableView.delegate = self;
    groupTableView.dataSource = self;
    groupTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:groupTableView];
    [groupTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    //Backボタン
//    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
//                                                                           target:self
//                                                                           action:@selector(addTalkGroup)];
    UIBarButtonItem *reloadButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                                                                                  target:self
                                                                                  action:@selector(reloadGroupsData)];
    
//    self.navigationItem.rightBarButtonItem = addBtn;
    self.navigationItem.leftBarButtonItem = reloadButton;
    _needReloadGroupData = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AuthManager sharedManager].auth == nil) {
        
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:[[SigninViewController alloc]init]];
        [self presentViewController:navc animated:YES completion:nil];
        
    } else if (_needReloadGroupData) {
        _needReloadGroupData = NO;
        [self reloadGroupsData];
    }
    
}

- (void)reloadGroupsData
{
    NSDictionary* param = @{};
    [ServerManager serverRequest:@"GET" api:@"groups" param:param completionHandler:^(NSURLResponse *response, NSDictionary *dict) {
        int status = [dict[@"status"] intValue];
        if (status == 200) {
            groupArray = [NSMutableArray arrayWithArray: dict[@"groups"]];
            
            _userInfoDic = [NSMutableDictionary dictionary];
            
            _imageCompleted = [NSMutableArray array];
            for (int i=0; i<groupArray.count; ++i) {
                [_imageCompleted addObject:@NO];
            }
            
            [self setCellName];
            [groupTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            
            [self fetchUserInfo];
        }
    }];
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Groups";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return groupArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    NSDictionary* group = groupArray[indexPath.row];
    cell.textLabel.text = group[@"cell_name"];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize]-3];
    cell.backgroundColor = [UIColor clearColor];
    
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString* myID = [ud stringForKey:@"twitter_id"];
    
    //画像
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 22.0f;
    
    NSArray* users = group[@"users"];
    for (NSDictionary* user in users) {
        NSString* uid = user[@"twitter_id"];
        if ([uid isEqualToString:myID]) continue; // 自分はスルー
        NSDictionary* uinfo = _userInfoDic[uid];
        if (uinfo) {
            NSURL* imageURL = [NSURL URLWithString:uinfo[@"profile_image_url"]];
            UIImage *placeholderImage = [UIImage imageNamed:@"icon_hana"];
            [cell.imageView sd_setImageWithURL:imageURL placeholderImage:placeholderImage completed:
             ^(UIImage* image, NSError* error, SDImageCacheType cacheType, NSURL* imageURL){
                 if (![_imageCompleted[indexPath.row] boolValue]) {
                     _imageCompleted[indexPath.row] = [NSNumber numberWithBool:YES];
                     [groupTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                 }
             }];
            break;
        }
    }
    
    return cell;
}

#pragma mark - UITableView Delegate

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //セルの選択を解除（青くなるのを消す）
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNumber* numGroupID = groupArray[indexPath.row][@"id"];
    ChatRoomViewController* crvc = [[ChatRoomViewController alloc] initWithGroupID:[numGroupID intValue]];
    UINavigationController* nvc = [[UINavigationController alloc] initWithRootViewController:crvc];
    crvc.title = [tableView cellForRowAtIndexPath:indexPath].textLabel.text;
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma mark - Private Methods

-(void)addTalkGroup{
    
    SecondViewController *vc = [[SecondViewController alloc]init];
    vc.view.frame = CGRectMake(0, 0, 270.0f, 340.0f);
    [self presentPopUpViewController:vc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)fetchUserInfo
{
    NSMutableSet* IDset = [NSMutableSet set];
    for (NSDictionary* group in groupArray) {
        NSArray* users = group[@"users"];
        for (NSDictionary* user in users) {
            [IDset addObject:user[@"twitter_id"]];
        }
    }
    NSArray* userIDs = [IDset allObjects];
    [AuthManager fetchUserInfo:userIDs withHandler:^(NSArray *userInfos) {
        _userInfoDic = [NSMutableDictionary dictionary];
        for (NSDictionary* userInfo in userInfos) {
            _userInfoDic[userInfo[@"id"]] = userInfo;
        }
        //[self setCellName];
        [groupTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    }];
}

- (void)setCellName
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSString* myID = [ud stringForKey:@"twitter_id"];
    
    for (int i=0; i<groupArray.count; ++i) {
        
        NSMutableDictionary* group = [NSMutableDictionary dictionaryWithDictionary:groupArray[i]];
        NSString* name = group[@"name"];
        if (![name isEqualToString:@""]) {
            group[@"cell_name"] = name;
        } else {
            NSMutableArray* userNames = [NSMutableArray array];
            for (NSDictionary* user in group[@"users"]) {
                NSString* userID = user[@"twitter_id"];
                if ([userID isEqualToString:myID]) continue;
                NSDictionary* userInfo = _userInfoDic[userID];
                NSString* userName;
                if (userInfo) {
                    userName = userInfo[@"screen_name"];
                } else {
                    userName = userID;
                }
                [userNames addObject:userName];
            }
            
            group[@"cell_name"] = [userNames componentsJoinedByString:@","];
        }
        groupArray[i] = [NSDictionary dictionaryWithDictionary:group];
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
