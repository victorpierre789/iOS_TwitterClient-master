//
//  WebViewController.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/24/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "WebViewController.h"

@interface WebViewController ()
@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation WebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}


- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)sendRequest:(NSURLRequest *)request{
    [_webView loadRequest:request];
}



#pragma Mark - Account3LeggedOAuthDelegate
- (void)on3LeggedOAuthCallback {
    // in case the user has just authenticated through WebViewVC
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
