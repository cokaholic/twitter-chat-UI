//
//  ConfirmViewController.m
//  TwitChat
//
//  Created by Keisuke_Tatsumi on 2014/08/21.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "ConfirmViewController.h"

@interface ConfirmViewController ()

@end

@implementation ConfirmViewController

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
    
    self.userNames = [NSArray array];
    self.userImages = [NSMutableArray array];
    
    //トークメンバー配列
    self.userNames = @[@"ゆっちー",@"ティム",@"たつみん"];
    
    //トークメンバー画像配列
    NSArray *imgNames = @[@"icon_hana",@"icon_naru",@"icon_yaya"];
    for (NSString *imgName in imgNames) {
        
        //NSMutableArrayです
        [self.userImages addObject:[UIImage imageNamed:imgName]];
    }
    
    followerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 290.0f) style:UITableViewStyleGrouped];
    followerTableView.delegate = self;
    followerTableView.dataSource = self;
    followerTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:followerTableView];
    [followerTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    goTalkButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    goTalkButton.frame = CGRectMake(0, followerTableView.bounds.size.height, self.view.bounds.size.width/2, 50);
    [goTalkButton setTitle:@"Talk" forState:UIControlStateNormal];
    goTalkButton.tintColor = [UIColor blueColor];
    goTalkButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:goTalkButton];
    
    cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelButton.frame = CGRectMake(self.view.bounds.size.width/2, followerTableView.bounds.size.height, self.view.bounds.size.width/2, 50);
    [cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
    cancelButton.tintColor = [UIColor redColor];
    cancelButton.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:cancelButton];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"トークメンバー";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.userNames.count;
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
    
    cell.textLabel.text = self.userNames[indexPath.row];
    cell.imageView.image = self.userImages[indexPath.row];
    cell.userInteractionEnabled = NO;
    
    return cell;
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
