//
//  UIImageView+FMJTwitter.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/26/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "UIImageView+FMJTwitter.h"

@implementation UIImageView (FMJTwitter)

-(void)fmj_AvatarStyle {
    self.layer.cornerRadius = 10.0f;
    self.clipsToBounds = YES;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.0f;
}

@end
