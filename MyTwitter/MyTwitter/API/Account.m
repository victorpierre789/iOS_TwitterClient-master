//
//  Account.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/23/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "Account.h"
#import <STTWitter.h>
#import <UIKit/UIKit.h>
#import "AccountManager.h"
#import <Accounts/Accounts.h>
#import "WebViewController.h"
#import "HomeViewController.h"
#import "FMJTimeLine.h"
#import "FMJTwitterTweet.h"

@interface Account () 

@end

@implementation Account

-(id)init {
    self = [super init];
    if (self) {
        [AccountManager sharedInstance].activeAccount = self;   
        _timeline = [[FMJTimeLine alloc] initWithAccount:self];
        
    }

    return self;
}

-(void)logout {
    _api = nil;
    
    //Shall we remove access_tokens ?
}

-(void)getUserInfo:(NSString *)userID {
    
    [_api getUserInformationFor:userID successBlock:^(NSDictionary *user) {
        self.user = [FMJTwitterUser initWithJsonString:user];
        NSLog(@"Active user: %@", user);
        
    } errorBlock:^(NSError *error) {
        NSLog(@"Fetching user info failed: %@", [error userInfo]);
        
    }];
}


@end
