//
//  ComposerViewController.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/26/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "ComposerViewController.h"
#import "Account.h"
#import "FMJTimeLine.h"
#import "AccountManager.h"
#import "UIImageView+AFNetworking.h"
#import "FMJTwitterUser.h"
#import "UIImageView+FMJTwitter.h"
#import "UIViewController+FMJTwitter.h"

@interface ComposerViewController () <UITextViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *avatarView;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *screenNameLabel;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property UIBarButtonItem* countDownLabel;

@end

#define kMaxTweetLength 140

@implementation ComposerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self styleNavigationBar];
    [self setupComposerHeader];
}

- (void)styleNavigationBar {
    
    UIColor *white = [UIColor whiteColor];
    
    //3. add right button
    UIBarButtonItem* doneBtn = [[UIBarButtonItem alloc] initWithTitle:@"Tweet" style:UIBarButtonItemStylePlain target:self action:@selector(onDone:)];
    if (_replyTo) {
        doneBtn.title = @"Reply";
    }
    _countDownLabel = [[UIBarButtonItem alloc] initWithTitle:@"140" style:UIBarButtonItemStylePlain target:nil action:nil];
    _countDownLabel.tintColor = [UIColor whiteColor];
    
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects: doneBtn,_countDownLabel,nil]];
    
    //4. title
    [self setTitle:@"Nouveau tweet" withColor:white];
    
}

-(void)setupComposerHeader {
    FMJTwitterUser *activeUser = [AccountManager sharedInstance].activeAccount.user;
    [_avatarView setImageWithURL:[NSURL URLWithString:activeUser.profileImgUrl]];
    _nameLabel.text = activeUser.username;
    _screenNameLabel.text = [NSString stringWithFormat:@"@%@", activeUser.screenName];
    
    [_avatarView fmj_AvatarStyle];
    
    _textView.delegate = self;
}

-(void)onCancel:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)onDone:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
    NSString *text = _textView.text;
    if (_replyTo) {
        [[AccountManager sharedInstance].activeAccount.timeline updateTweet:_replyTo withAction:kReply  andObject:text successBlock:^(NSDictionary *response) {
            NSLog(@"reply: %@", response);
        } errorBlock:^(NSError *error){
            NSLog(@"error: %@", [error userInfo]);
        }];

    } else {
        [[AccountManager sharedInstance].activeAccount.timeline newTweet:text successBlock:^(NSDictionary * response) {
            NSLog(@"NewTeet posted: %@", response);
            
        } errorBlock:^(NSError *error) {
            NSLog(@"NewTweet failed: %@", [error userInfo]);
        }];

    }
}

#pragma MARK - UITextViewDelegate

-(BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range   replacementText:(NSString *)text
{
    NSUInteger newLength = [textView.text length] + [text length] - range.length;
    return (newLength > kMaxTweetLength) ? NO : YES;
}

-(void)textViewDidChange:(UITextView *)textView
{
    int charsLeft = kMaxTweetLength - [textView.text length];
    
    if(charsLeft == 0) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No more characters"
                                                         message:[NSString stringWithFormat:@"You have reached the character limit of %d.",kMaxTweetLength]
                                                        delegate:nil
                                               cancelButtonTitle:@"Ok"
                                               otherButtonTitles:nil];
        [alert show];
    }
    
    self.countDownLabel.title = [NSString stringWithFormat:@"%d",charsLeft];
}

@end
