//
//  AccountManager.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kConsumerKey @"Z6wRBswlWtdf1CZnGsyNOUVa4"
#define kConsumerSecret @"pE1PXeyTLIoKgKgXRKch1PETSyoepT5mYZ7T2sjyFuSkKmBbi1"

#define kTwitterOauthAccessTokenKey @"TwitterOauthAccessTokenKey"
#define kTwitterOauthAccessTokenSecretKey @"TwitterOauthAccessTokenSecretKey"

#define kCallbackURL @"myapp://twitter_access_tokens/"

#define kEventUserLogout @"event_user_logged_out"
#define kEventUserLogin @"event_user_logged_in"

@class  Account;
@class NSURL;
@class UIView;
@class HomeViewController;

//delegate for the embedded webview controller
@protocol Account3LeggedOAuthDelegate <NSObject>
-(void)on3LeggedOAuthCallback;
@end


@interface AccountManager : NSObject

@property Account* activeAccount;
@property id<Account3LeggedOAuthDelegate> delegate;
@property  (nonatomic, weak) HomeViewController* parentViewController;

+ (AccountManager *) sharedInstance;

- (Account *)accountWithUsername:(NSString *)username password:(NSString *)password;
- (Account *)accountWithAccessToken:(NSString *)accessToken tokenSecret:(NSString *)secret;
- (Account *)accountWithWebLoginFromViewControler:(HomeViewController *)viewcontroller;
- (Account *)accountWithiOSAccountFromView:(UIView *)parentview;

-(BOOL)handleOpenURL:(NSURL *)url;
-(void)restoreUserSession;
-(void)logout;

-(BOOL)isLoggedIn;

@end
