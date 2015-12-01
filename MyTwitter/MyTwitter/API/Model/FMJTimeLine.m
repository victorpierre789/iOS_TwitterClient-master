//
//  FMJTimeLine.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "FMJTimeLine.h"
#import "Account.h"
#import "AccountManager.h"
#import "FMJTwitterTweet.h"
#import "STTwitterAPI.h"

#define kPageSize 20
#define kPageSizeString @"20"

@interface FMJTimeLine ()

@property NSString * lastID; //the current oldest tweet id fetched.
@property NSString * sinceID;
@property NSMutableArray *tmpArray;

@end

@implementation FMJTimeLine

-(FMJTimeLine *)init {
    self = [super init];
    if (self) {
        _homeTimeLine = [NSMutableArray array];
        _pendingTweets = [NSMutableArray array];
        _tmpArray = [NSMutableArray array];
    }
    return self;
}

-(id)initWithAccount:(Account *)account {
    self = [self init];
    if (self) {
        _account = account;
    }
    return self;
}

-(void)loadMore:(BOOL)refresh {
    Account * account = [AccountManager sharedInstance].activeAccount;
    
    [account.api getStatusesHomeTimelineWithCount:kPageSizeString
                                          sinceID:_sinceID
                                            maxID:_lastID
                                         trimUser:nil
                                   excludeReplies:nil
                               contributorDetails:nil
                                  includeEntities:nil
                                     successBlock:^(NSArray *statuses)
     {
         
         NSLog(@"Loaded count: %lu", statuses.count);
         
         _hasMore = kPageSize == statuses.count;
         
         [_tmpArray removeAllObjects];
         
         [statuses enumerateObjectsUsingBlock:^(NSDictionary *obj, NSUInteger idx, BOOL *stop) {
             FMJTwitterTweet *tweet = [FMJTwitterTweet initWithJsonString:obj];
             NSLog(@"Parsing Tweet: %@", tweet);
             [_tmpArray addObject:tweet];
         }];
         
         FMJTwitterTweet *lastOne = [_tmpArray lastObject];
         _lastID = lastOne.tweetID;
         
         if (refresh) {
             if (_hasMore) {
                 //clear the existing array
                 [_homeTimeLine removeAllObjects];

                 [_homeTimeLine addObjectsFromArray:_tmpArray];
             } else {
                 //insert to the front of current array
                 NSIndexSet *indexes = [NSIndexSet indexSetWithIndexesInRange:
                                        NSMakeRange(0,[_tmpArray count])];
                 [_homeTimeLine insertObjects:_tmpArray atIndexes:indexes];
             }
         } else {
             //append new array
             [_homeTimeLine addObjectsFromArray:_tmpArray];
         }
         
         [_delegate didUpdateTimeline:_hasMore];
         
     } errorBlock:^(NSError *error) {
         NSLog(@"Error getHomeTimeline: %@", [error userInfo]);
         
     }];
}

-(void)refresh {
    FMJTwitterTweet *first = [_homeTimeLine firstObject];
    _sinceID = first.tweetID;
    _lastID = nil;
    
    [self loadMore:YES];
}


-(void)newTweet:(NSString *)text successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock {
    [_account.api  postStatusUpdate:text
         inReplyToStatusID:nil
                  latitude:nil
                 longitude:nil
                   placeID:nil
        displayCoordinates:nil
                  trimUser:nil
              successBlock:^(NSDictionary *status) {
                  successblock(status);
                  
                  [self refresh];
              } errorBlock:^(NSError *error) {
                  errorBlock(error);
              }];
}

-(void)updateTweet:(FMJTwitterTweet *)tweet withAction:(FMJTweetAction)action  andObject:(id)obj successBlock:(void (^)(NSDictionary *))successblock errorBlock:(void (^)(NSError *))errorBlock{

    switch (action) {
        case kFavorite:{
            [_account.api postFavoriteState:tweet.faved forStatusID:tweet.tweetID  successBlock:^(NSDictionary *status) {
                successblock(status);
                //refresh the time line to get the latest results.
                [self refresh];
            } errorBlock:^(NSError *error) {
                errorBlock(error);
            }];
        }
            break;
        case kReply:{
            NSString *reply = (NSString *)obj;
            [_account.api postStatusUpdate:reply
                 inReplyToStatusID:tweet.tweetID
                          latitude:nil
                         longitude:nil
                           placeID:nil
                displayCoordinates:nil
                          trimUser:nil
                      successBlock:^(NSDictionary *status) {
                          successblock(status);
                          //refresh the time line to get the latest results.
                          [self refresh];
                      } errorBlock:^(NSError *error) {
                          errorBlock(error);
                      }];
        }
            break;
        case kRetweet:{
            [_account.api postStatusRetweetWithID:tweet.tweetID  successBlock:^(NSDictionary *status) {
                successblock(status);
                //refresh the time line to get the latest results.
                [self refresh];
            } errorBlock:^(NSError *error) {
                errorBlock(error);
            }];
        }
            break;
        default:
            break;
    }
}

@end
