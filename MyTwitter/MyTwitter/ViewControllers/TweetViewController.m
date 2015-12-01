//
//  TweetViewController.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/27/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "TweetViewController.h"
#import "FMJTwitterTweet.h"
#import "UIImageView+AFNetworking.h"
#import <NSDate+DateTools.h>
#import "UIImageView+FMJTwitter.h"
#import "Account.h"
#import "AccountManager.h"
#import "ComposerViewController.h"
#import "FMJTimeLine.h"

@interface TweetViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *text;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;

@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;

@property (weak, nonatomic) IBOutlet UILabel *favCountLabel;
@property (weak, nonatomic) IBOutlet UILabel *retweetCountLabel;

@property Account* activeAccount;

@end

@implementation TweetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _activeAccount = [AccountManager sharedInstance].activeAccount;
    [self updateWithTweet:_tweet];
}

-(void)updateWithTweet:(FMJTwitterTweet*)tweet {

    [_userImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImgUrl]];
    if (tweet.mediaUrl) {
        _mediaImageView.hidden = NO;
        [_mediaImageView setImageWithURL:[NSURL URLWithString:tweet.mediaUrl]];
        
    } else {
        _mediaImageView.image = nil;
        _mediaImageView.hidden = YES;
    }
    
    
    [self setupProfileImage];
    
    _userName.text= tweet.user.username;
    _text.text = tweet.text;
    [_text sizeToFit];
    
    _screenName.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
    
    _timeLabel.text = tweet.createTime;
    _retweetCountLabel.text = [NSString stringWithFormat: @"%ld", tweet.retweetCount];
    _favCountLabel.text = [NSString stringWithFormat: @"%ld", tweet.favCount];
    
    [self updateIconStates];
}

- (IBAction)onTapFavorite:(id)sender {
    _tweet.faved = !_tweet.faved;
    
    [self updateIconStates];
    
    [_activeAccount.timeline updateTweet:_tweet withAction:kFavorite  andObject:nil successBlock:^(NSDictionary *response) {
        NSLog(@"reply: %@", response);
    } errorBlock:^(NSError *error){
        NSLog(@"error: %@", [error userInfo]);
    }];
}

- (IBAction)onTapRetweet:(id)sender {
    [_activeAccount.timeline updateTweet:_tweet withAction:kRetweet andObject:nil successBlock:^(NSDictionary *response) {
        NSLog(@"reply: %@", response);
    } errorBlock:^(NSError *error){
        NSLog(@"error: %@", [error userInfo]);
    }];
    
    _tweet.retweeted = YES;
    [self updateIconStates];
}

- (IBAction)onTapReply:(id)sender {
    ComposerViewController *composer = [[ComposerViewController alloc] init];
    composer.replyTo = _tweet;
    
    [self.navigationController pushViewController:composer animated:YES];
}

-(void) setupProfileImage {
    [_userImage fmj_AvatarStyle];
}

-(void) updateIconStates {
    _retweetButton.selected = _tweet.retweeted;
    _favButton.selected = _tweet.faved;
}

@end
