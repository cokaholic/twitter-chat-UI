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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"フォロワー";
    
    followerArray = [NSMutableArray arrayWithObjects:@"ゆっちー",@"たつみん",@"ティム", nil];
    userImgArray = [NSMutableArray array];
    imgLoadFlag = FALSE;
    
    followerTableView = [[UITableView alloc]initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height-50) style:UITableViewStyleGrouped];
    followerTableView.delegate = self;
    followerTableView.dataSource = self;
    followerTableView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:followerTableView];
    [followerTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // バックグランドでAPIなどを実行
        
        for (int i=0; i<followerArray.count; i++) {
            
            //セル画像の追加
            NSURL * imageURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://hanayamata.com/assets/images/special/0%d.png",i+1]];
            NSData * imageData = [NSData dataWithContentsOfURL:imageURL];
            [userImgArray addObject:[UIImage imageWithData:imageData]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            // メインスレッドで処理をしたい内容、UIを変更など。
            imgLoadFlag = TRUE;
            [followerTableView reloadData];
        });
    });
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Followers";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return followerArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = followerArray[indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize]-3];
    cell.backgroundColor = [UIColor clearColor];
    
    //取得が完了したらセル画像を適用
    if (imgLoadFlag) {
        cell.imageView.image = userImgArray[indexPath.row];
    }
    
    //プロフィール画像を円形に
    cell.imageView.layer.masksToBounds = YES;
    cell.imageView.layer.cornerRadius = 22.0f;
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //セルの選択を解除（青くなるのを消す）
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
