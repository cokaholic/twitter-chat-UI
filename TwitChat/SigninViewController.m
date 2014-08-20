//
//  SigninViewController.m
//  TwitChat
//
//  Created by tamura on 2014/08/19.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import "SigninViewController.h"

@interface SigninViewController ()

@end

@implementation SigninViewController

// KeyChain登録サービス名
static NSString *const kKeychainAppServiceName = @"DMchat";

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"サインイン";
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
        [self getRememberToken];
    } else {
        // 未認証の場合は認証処理を実施
        [self asyncSignIn];
    }
    
    NSLog(@"%@\n%@", _auth.accessToken, _auth.tokenSecret);
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
        [self getRememberToken];
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

- (void)getRememberToken
{
    NSDictionary* param = @{
                            @"access_token": _auth.accessToken,
                            @"access_token_secret": _auth.tokenSecret
                            };
    [ServerManager serverRequest:@"POST"
                             api:@"sessions"
                           param:param
               completionHandler:^(NSURLResponse *response, NSDictionary *dict) {
                   NSUserDefaults* ud = [NSUserDefaults standardUserDefaults];
                   NSString* remember = dict[@"user"][@"remember_token"];
                   NSString* twitter_id = dict[@"user"][@"twitter_id"];
                   NSLog(@"remember token = %@", remember);
                   NSLog(@"twitter id = %@", twitter_id);
                   [ud setObject:remember forKey:@"remember"];
                   [ud setObject:twitter_id forKey:@"twitter_id"];
                   [AuthManager sharedManager].auth = _auth;
                   [self dismissViewControllerAnimated:YES completion:nil];
               }];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
    
@end
