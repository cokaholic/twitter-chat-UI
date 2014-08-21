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
    UIBarButtonItem *addBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd
                                                                           target:self
                                                                           action:@selector(addTalkGroup)];
    
    self.navigationItem.rightBarButtonItem = addBtn;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if ([AuthManager sharedManager].auth == nil) {
        
        UINavigationController *navc = [[UINavigationController alloc]initWithRootViewController:[[SigninViewController alloc]init]];
        [self presentViewController:navc animated:YES completion:nil];
        
    } else {
        
        NSDictionary* param = @{};
        [ServerManager serverRequest:@"GET" api:@"groups" param:param completionHandler:^(NSURLResponse *response, NSDictionary *dict) {
            int status = [dict[@"status"] intValue];
            if (status == 200) {
                groupArray = dict[@"groups"];
                [groupTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];

                NSLog(@"finished");
            }
        }];
        
    }
    
}

#pragma mark - UITableView DataSource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return @"Groups";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSLog(@"cell number %d\n", (int)groupArray.count);
    return groupArray.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.textLabel.text = groupArray[indexPath.row][@"name"];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:[UIFont labelFontSize]-3];
    cell.backgroundColor = [UIColor clearColor];
    
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
