//
//  HomeViewController.m
//  MyTwitter
//
//  Created by Cristan Zhang on 9/23/15.
//  Copyright (c) 2015 FSManJi. All rights reserved.
//

#import "HomeViewController.h"
#import "Account.h"
#import "AccountManager.h"
#import <STTWitter.h>
#import "FMJTweetCell.h"
#import "FMJTwitterTweet.h"
#import "FMJTimeLine.h"
#import "MBProgressHUD.h"
#import "ComposerViewController.h"
#import "UIViewController+FMJTwitter.h"
#import "TweetViewController.h"
#import "SVPullToRefresh.h"
#import <UIColor+HexString.h>

@interface HomeViewController () <FMJTweetCellDelegate>

@property (weak, nonatomic) Account *activeAccount;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property UIRefreshControl* refreshControl;

@end

@implementation HomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    //listen to login
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserLogin:)
                                                 name:kEventUserLogin
                                               object:nil];
    //listen to logout
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUserLogout:)
                                                 name:kEventUserLogout
                                               object:nil];
    
    [self styleNavigationBar];
    
    [self setupTableView];
}

-(void)viewDidAppear:(BOOL)animated {
    [_tableView reloadData];
}

- (void)setupTableView {
    _tableView.dataSource = self;
    _tableView.delegate = self;
    
    [_tableView setEstimatedRowHeight:236];
    [_tableView setRowHeight:UITableViewAutomaticDimension];
    
    //add a PTR control
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];
    
    //add inifite scroll spinner
    [_tableView addInfiniteScrollingWithActionHandler:^{
        // append data to data source, insert new cells at the end of table view
        // call [tableView.infiniteScrollingView stopAnimating] when done
        
        [_activeAccount.timeline loadMore:NO];
    }];
    
    //register cell xib
    UINib *nib = [UINib nibWithNibName:[FMJTweetCell description] bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:[FMJTweetCell description]];
    
}

- (void)styleNavigationBar {
    UIColor *white = [UIColor whiteColor];
    UIColor * const navBarBgColor = [UIColor colorWithHexString:@"#4474B6"];
    
    //1. color the navigation bar as light blue
    [self setNavigationBarFontColor:white barBackgroundColor:navBarBgColor];
    
    //2. add left button
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"user"] style:UIBarButtonItemStylePlain target:self action:@selector(logout:)];

    //3. add right button
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCompose target:self action:@selector(newPost:)];
    
    //4. title
    [self setTitle:@"Fil" withColor:white];
    
}

- (void)onRefresh:(id)sender {
    if ([[AccountManager sharedInstance] isLoggedIn]) {
        [_activeAccount.timeline refresh];
        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    } else
        NSLog(@"Error: no acitve account to use.");
}

#pragma MARK delegate from timeline

-(void)didUpdateTimeline:(BOOL)hasMore {
    [self.refreshControl endRefreshing];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    [_tableView.infiniteScrollingView stopAnimating];
    
    [_tableView reloadData];
}

#pragma Notification from Account Manager

- (void)onUserLogin:(id) sender {
    _activeAccount = [AccountManager sharedInstance].activeAccount;
    [_activeAccount.timeline refresh];
}

- (void)onUserLogout:(id) sender {
    /*FiltersViewController* filtersPage = [[FiltersViewController alloc] init];
     filtersPage.delegate = self;
     [self.navigationController pushViewController:filtersPage animated:YES];*/
    
    //reload home with null data
    _activeAccount = nil;
    [_tableView reloadData];
}

- (void)logout:(id) sender {
    if (_activeAccount) {
        [[AccountManager sharedInstance] logout];
        _activeAccount = nil;
        
        //self.navigationItem.leftBarButtonItem.title = @"Sign In";
        
    } else {
        
        [[AccountManager sharedInstance] restoreUserSession];
        _activeAccount = [AccountManager sharedInstance].activeAccount;
        
        if (_activeAccount == nil) {
            _activeAccount  = [[AccountManager sharedInstance] accountWithWebLoginFromViewControler:self];
            //_activeAccount = [Account initWithiOSAccountFromView:self.view];
        }
        
        //self.navigationItem.leftBarButtonItem.title = @"Sign Out";
        _activeAccount.timeline.delegate = self;
    }
    
}

- (void)newPost:(id) sender {
    if (_activeAccount) {
        ComposerViewController *composer = [[ComposerViewController alloc] init];
        [self.navigationController pushViewController:composer animated:YES];
    } else
        NSLog(@"Error: no acitve account to use.");

}

#pragma MARK - FMJTwitterCellDelegate

-(void)onReply:(FMJTwitterTweet *)tweet {
    ComposerViewController *composer = [[ComposerViewController alloc] init];
    composer.replyTo = tweet;
    
    [self.navigationController pushViewController:composer animated:YES];
}

-(void)onRetweet:(FMJTwitterTweet *)tweet {
    [_activeAccount.timeline updateTweet:tweet withAction:kRetweet andObject:nil successBlock:^(NSDictionary *response) {
        NSLog(@"reply: %@", response);
    } errorBlock:^(NSError *error){
        NSLog(@"error: %@", [error userInfo]);
    }];
}

-(void)onFav:(FMJTwitterTweet *)tweet {
    [_activeAccount.timeline updateTweet:tweet withAction:kFavorite  andObject:nil successBlock:^(NSDictionary *response) {
        NSLog(@"reply: %@", response);
    } errorBlock:^(NSError *error){
        NSLog(@"error: %@", [error userInfo]);
    }];
}

-(void)onUpdateCell:(UITableViewCell *)cell {
    NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
    if (!indexPath) {
        return;
    }
    NSArray * indexPaths = @[indexPath];
    [_tableView beginUpdates];
    [_tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
    [_tableView endUpdates];
}

#pragma Tableview datasource

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _activeAccount.timeline.homeTimeLine.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *simpleTableIdentifier = [FMJTweetCell description];
    
    FMJTweetCell *cell = (FMJTweetCell *)[tableView dequeueReusableCellWithIdentifier:simpleTableIdentifier];
    if (cell == nil)
    {
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed:simpleTableIdentifier owner:self options:nil];
        cell = [nib objectAtIndex:0];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


- (void)configureCell:(FMJTweetCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSArray* timeline = _activeAccount.timeline.homeTimeLine;
    FMJTwitterTweet* tweet = timeline[row];
    [cell initWithTweet:tweet];
    
    cell.delegate = self;
}


#pragma tableview delegate
-(CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger row = indexPath.row;
    NSArray* timeline = _activeAccount.timeline.homeTimeLine;
    FMJTwitterTweet* tweet = timeline[row];
    if (tweet.mediaUrl) {
        return 300;
    } else {
        return 120;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TweetViewController *vc = [[TweetViewController alloc] init];
    vc.tweet = _activeAccount.timeline.homeTimeLine[indexPath.row];;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) dealloc
{
    // If you don't remove yourself as an observer, the Notification Center
    // will continue to try and send notification objects to the deallocated
    // object.
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
