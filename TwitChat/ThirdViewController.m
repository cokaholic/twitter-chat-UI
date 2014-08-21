//
//  ThirdViewController.m
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/18.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "ThirdViewController.h"

@interface ThirdViewController ()

@end

@implementation ThirdViewController

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
    
    self.title = @"設定";
    
    settingArray = [NSMutableArray arrayWithObjects:@"ログアウト",@"アプリ内サウンド",@"Twitter",@"ヘルプ", nil];
    
    backScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50)];
    backScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, 44*settingArray.count+380);
    backScrollView.showsVerticalScrollIndicator = NO;
    backScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:backScrollView];
    
    profileImgView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 200, 200)];
    profileImgView.center = CGPointMake(self.view.bounds.size.width/2, 200);
    profileImgView.backgroundColor = [UIColor clearColor];
    profileImgView.layer.masksToBounds = YES;
    profileImgView.layer.cornerRadius = 100.0f;
    [backScrollView addSubview:profileImgView];
    
    userNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 80)];
    userNameLabel.center = CGPointMake(self.view.bounds.size.width/2, profileImgView.center.y + profileImgView.frame.size.height/2+userNameLabel.frame.size.height/2);
    userNameLabel.backgroundColor = [UIColor clearColor];
    userNameLabel.text = @"@TK_u_nya";
    userNameLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize]+10];
    userNameLabel.textAlignment = NSTextAlignmentCenter;
    [backScrollView addSubview:userNameLabel];
    
    settingTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 380, self.view.bounds.size.width, 44*settingArray.count)];
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor whiteColor];
    [backScrollView addSubview:settingTableView];
    [settingTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
}

-(void)viewDidAppear:(BOOL)animated{
    
    NSURL * imageURL = [NSURL URLWithString:@"http://hanayamata.com/assets/images/special/02.png"];
    NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
    profileImgView.image = [UIImage imageWithData:imageData];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return settingArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = settingArray[indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize]-3];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //セルの選択を解除（青くなるのを消す）
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if ([settingArray[indexPath.row] isEqualToString:@"ログアウト"]) {
        [self logout];
    }
}

- (void)logout
{
    [AuthManager sharedManager].auth = nil;
    [GTMOAuthViewControllerTouch removeParamsFromKeychainForName:kKeychainAppServiceName];
    UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:[[SigninViewController alloc]init]];
    [self presentViewController:navc animated:YES completion:nil];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
