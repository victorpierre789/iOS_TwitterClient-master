//
//  FMJTweetCell.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/25/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "FMJTweetCell.h"
#import "FMJTwitterTweet.h"
#import "UIImageView+AFNetworking.h"
#import <NSDate+DateTools.h>
#import "UIImageView+FMJTwitter.h"
#import <AFNetworking.h>
#import "UIView+UpdateAutoLayoutConstraints.h"
#import <QuartzCore/QuartzCore.h>

@interface FMJTweetCell ()
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UILabel *screenName;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *text;

@property (weak, nonatomic) IBOutlet UIButton *replyButton;
@property (weak, nonatomic) IBOutlet UIButton *retweetButton;
@property (weak, nonatomic) IBOutlet UIButton *favButton;
@property (weak, nonatomic) IBOutlet UIImageView *mediaImageView;

@end

@implementation FMJTweetCell

-(void)initWithTweet:(FMJTwitterTweet*)tweet {
    if(_tweet != tweet) {
        _tweet = tweet;
        [_userImage setImageWithURL:[NSURL URLWithString:tweet.user.profileImgUrl]];
        if (tweet.mediaUrl) {
            [_mediaImageView hideByHeight:NO];
            [_mediaImageView setImageWithURL:[NSURL URLWithString:tweet.mediaUrl]];
            //[self downloadPhoto:tweet.mediaUrl];
            
            self.mediaImageView.layer.cornerRadius = 5;
            self.mediaImageView.clipsToBounds = YES;
            
        } else {
            _mediaImageView.image = nil;
            [_mediaImageView hideByHeight:YES];
        }
        
        
        [self setupProfileImage];
        
        _userName.text= tweet.user.username;
        _text.text = tweet.text;
        [_text sizeToFit];
        
        _screenName.text = [NSString stringWithFormat:@"@%@", tweet.user.screenName];
        
        NSDate *timeAgoDate = [NSDate dateWithString:tweet.createTime formatString:@"eee MMM dd HH:mm:ss ZZZZ yyyy"];
        
        _timeLabel.text = [timeAgoDate shortTimeAgoSinceNow];
        
        [self updateIconStates];
    }
}

//below code failed to update the tableview row.
//once it's displayed you can only call reloadRows, but it will
//cause the table view flashing and not good.
-(void)downloadPhoto:(NSString *)url {
    
    NSURL *URL = [NSURL URLWithString:_tweet.mediaUrl];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    AFHTTPRequestOperation *op = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    op.responseSerializer = [AFImageResponseSerializer serializer];
    [op setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage* image) {
        _mediaImageView.image = image;
        //[_mediaImageView setConstraintConstant:image.size.height forAttribute:NSLayoutAttributeHeight];
        CGRect frame = _mediaImageView.frame;
        CGFloat ratio = image.size.height / image.size.width;
        frame.size.height = frame.size.width * ratio;
        
        [_mediaImageView setConstraintConstant:frame.size.height forAttribute:NSLayoutAttributeHeight];
        [_delegate onUpdateCell:self];
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    [[NSOperationQueue mainQueue] addOperation:op];
}

- (IBAction)onTapFavorite:(id)sender {
    _tweet.faved = !_tweet.faved;
    
    [_delegate onFav:_tweet];
    
    [self updateIconStates];
}

- (IBAction)onTapRetweet:(id)sender {
    [_delegate onRetweet:_tweet];
    _tweet.retweeted = YES;
    [self updateIconStates];
}

- (IBAction)onTapReply:(id)sender {
    [_delegate onReply:_tweet];
    
}

-(void) setupProfileImage {
    [_userImage fmj_AvatarStyle];
    self.userImage.layer.cornerRadius = 30;
    self.userImage.clipsToBounds = YES;
}

-(void) updateIconStates {
    //fav icon
    if (_tweet.faved) {
        [_favButton setImage:[UIImage imageNamed:@"favorite_on.png"] forState:UIControlStateNormal];
    } else {
        [_favButton setImage:[UIImage imageNamed:@"favorite.png"] forState:UIControlStateNormal];
    }
    //retweeted icon
    if (_tweet.retweeted) {
        [_retweetButton setImage:[UIImage imageNamed:@"retweet_on.png"] forState:UIControlStateNormal];
    } else {
        [_retweetButton setImage:[UIImage imageNamed:@"retweet.png"] forState:UIControlStateNormal];
    }
}

@end
