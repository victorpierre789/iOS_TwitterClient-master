//
//  FMJTwitterUser.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "FMJTwitterUser.h"

@implementation FMJTwitterUser

+(FMJTwitterUser *)initWithJsonString:(NSDictionary *)json {
    FMJTwitterUser * user = [[FMJTwitterUser alloc] init];
    user.username = json[@"name"];
    user.screenName = json[@"screen_name"];
    user.profileImgUrl = json[@"profile_image_url"];
    user.selfDesc = json[@"description"];
    
    return user;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"name=%@\n\tscreen_name=%@", _username, _screenName];
}

@end
