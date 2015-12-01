//
//  FMJTwitterUser.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FMJTwitterUser : NSObject

@property NSString *username;
@property NSString *screenName;
@property NSString *profileImgUrl;
@property NSString *selfDesc;

+(FMJTwitterUser *)initWithJsonString:(NSDictionary *)json;

@end
