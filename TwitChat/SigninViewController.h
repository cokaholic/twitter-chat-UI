//
//  SigninViewController.h
//  TwitChat
//
//  Created by tamura on 2014/08/19.
//  Copyright (c) 2014年 Keisuke Tatsumi. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuthAuthentication.h"
#import "GTMOAuthViewControllerTouch.h"
#import "AuthManager.h"
#import "ServerManager.h"

@interface SigninViewController : UIViewController
{
    GTMOAuthAuthentication* _auth;
}
@end
