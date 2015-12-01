//
//  FMJTimeLine.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FMJTweetAction) {
    kReply,
    kRetweet,
    kFavorite
};

@protocol FMJTimeLineDelegate <NSObject>

@optional
-(void)didUpdateTimeline:(BOOL)hasMore;

//use below to show the loading spinner
-(void)willLoadMoreTimeline;

//action feedback
-(void)didFavorite:(NSString *)statusID;
-(void)didRetweet:(NSString *)statusID;
-(void)didReply:(NSString *)replyToID;

@end

@class Account;
@class FMJTwitterTweet;

@interface FMJTimeLine : NSObject

@property NSMutableArray *homeTimeLine;//home time line
@property NSMutableArray *userTimeLine;//user's own time line, include only user's tweets & replies
@property NSMutableArray *pendingTweets;
@property (nonatomic, weak) Account *account;
@property BOOL hasMore;

@property (nonatomic, weak) id<FMJTimeLineDelegate> delegate;

-(id)initWithAccount:(Account *)account;

-(void)loadMore:(BOOL)refresh;
-(void)refresh;

-(void)newTweet:(NSString *)text successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock;

-(void)updateTweet:(FMJTwitterTweet *)tweet withAction:(FMJTweetAction)action andObject:(id)obj successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock;

@end
