//
//  WebViewController.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/24/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "AccountManager.h"

@interface WebViewController : UIViewController <Account3LeggedOAuthDelegate>

-(void)sendRequest:(NSURLRequest *)request;

@end
