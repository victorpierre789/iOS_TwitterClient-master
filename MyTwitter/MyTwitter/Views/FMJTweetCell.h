//
//  FMJTweetCell.h
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import <UIKit/UIKit.h>
@class FMJTwitterTweet;

@protocol FMJTweetCellDelegate <NSObject>

-(void)onReply:(FMJTwitterTweet *)tweet;
-(void)onRetweet:(FMJTwitterTweet *)tweet;
-(void)onFav:(FMJTwitterTweet *)tweet;

-(void)onUpdateCell:(UITableViewCell *)sender;

@end

@interface FMJTweetCell : UITableViewCell

@property (nonatomic, readonly)FMJTwitterTweet *tweet;
@property id<FMJTweetCellDelegate> delegate;

-(void)initWithTweet:(FMJTwitterTweet*)tweet;

@end
