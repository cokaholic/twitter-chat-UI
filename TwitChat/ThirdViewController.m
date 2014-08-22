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
    backScrollView.showsVerticalScrollIndicator = NO;
    backScrollView.showsHorizontalScrollIndicator = NO;
    [self.view addSubview:backScrollView];
    
    CGFloat wid = self.view.bounds.size.width;
    const CGFloat kImageSize = 48;
    int curY = 0;
    profileImgView = [[UIImageView alloc]initWithFrame:CGRectMake(wid/2-kImageSize/2, curY + 30, kImageSize, kImageSize)];
    curY += 30 + kImageSize;
    profileImgView.backgroundColor = [UIColor clearColor];
    profileImgView.layer.masksToBounds = YES;
    profileImgView.layer.cornerRadius = kImageSize/2;
    [backScrollView addSubview:profileImgView];
    

    nameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, curY + 10, wid, 20)];
    curY += 10 + nameLabel.frame.size.height;
    nameLabel.backgroundColor = [UIColor clearColor];
    nameLabel.font = [UIFont systemFontOfSize:16];
    nameLabel.textAlignment = NSTextAlignmentCenter;
    [backScrollView addSubview:nameLabel];

    screenNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, curY, wid, 20)];
    curY += screenNameLabel.frame.size.height;
    screenNameLabel.backgroundColor = [UIColor clearColor];
    screenNameLabel.font = [UIFont systemFontOfSize:12];
    screenNameLabel.textAlignment = NSTextAlignmentCenter;
    [backScrollView addSubview:screenNameLabel];
    
    settingTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, curY, self.view.bounds.size.width, 44*settingArray.count)];
    curY += settingTableView.frame.size.height;
    settingTableView.delegate = self;
    settingTableView.dataSource = self;
    settingTableView.backgroundColor = [UIColor whiteColor];
    [backScrollView addSubview:settingTableView];
    [settingTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    backScrollView.contentSize = CGSizeMake(self.view.bounds.size.width, curY);
}

-(void)viewDidAppear:(BOOL)animated{
    [self setUserInfo];
}


- (void)setUserInfo
{
    NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
    screenNameLabel.text = [NSString stringWithFormat:@"@%@", [ud stringForKey:@"screen_name"]];
    nameLabel.text = [ud stringForKey:@"name"];

    NSURL * imageURL = [NSURL URLWithString:[ud stringForKey:@"profile_image_url"]];
    NSLog(@"%@", imageURL);
    [profileImgView sd_setImageWithURL:imageURL placeholderImage:[UIImage imageNamed:@"icon_hana"] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        NSLog(@"image loaded");
    }];
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
