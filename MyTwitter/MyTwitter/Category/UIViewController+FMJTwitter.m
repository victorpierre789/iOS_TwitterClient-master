//
//  UIViewController+FMJTwitter.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/26/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "UIViewController+FMJTwitter.h"

@implementation UIViewController (FMJTwitter)

-(void)setNavigationBarFontColor:(UIColor *)fontColor barBackgroundColor:(UIColor *)bgColor {
    NSArray *ver = [[UIDevice currentDevice].systemVersion componentsSeparatedByString:@"."];
    //ios 7+
    if ([[ver objectAtIndex:0] intValue] >= 7) {
        self.navigationController.navigationBar.barTintColor = bgColor;
        self.navigationController.navigationBar.translucent = NO;
        self.navigationController.navigationBar.tintColor = fontColor;
    }else{
        //ios 6 and older
        self.navigationController.navigationBar.tintColor = bgColor;
    }
}

-(void)setTitle:(NSString *)title withColor:(UIColor *)titleColor
{
    UILabel *titleView = (UILabel *)self.navigationItem.titleView;
    if (!titleView) {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        //titleView.font = [UIFont boldSystemFontOfSize:20.0];
        //titleView.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.5];
        
        titleView.textColor = titleColor; // Change to desired color
        
        self.navigationItem.titleView = titleView;
    }
    titleView.text = title;
    
    [titleView sizeToFit];
}

@end
