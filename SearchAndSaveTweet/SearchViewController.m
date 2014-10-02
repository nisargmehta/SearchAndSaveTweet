//
//  SearchViewController.m
//  SearchAndSaveTweet
//
//  Created by Nisarg Mehta on 9/29/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "SearchViewController.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>
#import "Tweet.h"
#import "Constants.h"
#import "DetailsViewController.h"
#import "Reachability.h"
#import <UIImageView+WebCache.h>

@interface SearchViewController ()
{
    NSArray *_tweets;
}

@property (nonatomic,strong) ACAccountStore *accountStore;
@property (nonatomic,strong) NSURLConnection *connection;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.searchBar.delegate = self;
    self.tableView.rowHeight = 70.0;
    _tweets = [[NSArray alloc] init];
    
    activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    activity.hidesWhenStopped = YES;
    CGRect frame = activity.frame;
    frame.origin.x = self.view.frame.size.width / 2 - frame.size.width / 2;
    frame.origin.y = self.view.frame.size.height / 2 - frame.size.height / 2;
    activity.frame = frame;
    [self.view addSubview:activity];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshResults) forControlEvents:UIControlEventValueChanged];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self cancelConnection];
}

- (ACAccountStore *)accountStore
{
    if (_accountStore == nil)
    {
        _accountStore = [[ACAccountStore alloc] init];
    }
    return _accountStore;
}

-(void)refreshResults
{
    [self cancelConnection];
    [self fetchTweets];
}

-(BOOL)checkConnectivity
{
    Reachability *reachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [reachability currentReachabilityStatus];
    return !(networkStatus == NotReachable);
}

-(void)fetchTweets
{
    if ([self.searchBar.text  isEqual: @""])
    {
        [self showAlert:@"Enter a valid query" withTitle:kWarning];
        [self.refreshControl endRefreshing];
        [activity stopAnimating];
        return;
    }
    
    if(![self checkConnectivity])
    {
        [self showAlert:@"No internet conenction!" withTitle:kWarning];
        return;
    }
    
    NSString *encodedQuery = [self.searchBar.text stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    [self.accountStore requestAccessToAccountsWithType:accountType
                                               options:NULL
                                            completion:^(BOOL granted, NSError *error)
     {
         if (granted)
         {
             NSURL *url = [NSURL URLWithString:kTwitterQuery];
             NSDictionary *parameters = @{@"count" : kCount,
                                          @"q" : encodedQuery};
             
             SLRequest *slRequest = [SLRequest requestForServiceType:SLServiceTypeTwitter
                                                       requestMethod:SLRequestMethodGET
                                                                 URL:url
                                                          parameters:parameters];
             
             NSArray *accounts = [self.accountStore accountsWithAccountType:accountType];
             slRequest.account = [accounts lastObject];
             NSURLRequest *request = [slRequest preparedURLRequest];
             dispatch_async(dispatch_get_main_queue(), ^{
                 if (accounts.count == 0)
                 {
                     [self showAlert:@"Go to settings and Enter your twitter details" withTitle:kWarning];
                 }
                 else
                 {
                     [activity startAnimating];
                     self.connection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
                 }
             });
         }
         else
         {
             dispatch_async(dispatch_get_main_queue(), ^{
                 [self showAlert:@"Access denied to twitter" withTitle:kWarning];
                 [self.tableView reloadData];
             });
         }
     }];
}

-(void)showAlert:(NSString*)message withTitle:(NSString*)title
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title
                                                        message:message
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - NSURLConnection delegate
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
    int responseStatusCode = (int)[httpResponse statusCode];
    if (responseStatusCode == 200)
    {
        _responseData = [[NSMutableData alloc] init];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [_responseData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [activity stopAnimating];
    self.connection = nil;
    _responseData = nil;
    [self showAlert:@"Failed to get tweets" withTitle:kError];
    // load saved contacts
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    self.connection = nil;
    NSLog(@"Succeeded! Received %lu bytes of data",(unsigned long)[_responseData
                                                                   length]);
    if ([_responseData length] > 0)
    {
        _tweets = [[NSArray alloc] init];
        NSMutableArray *tweets = [[NSMutableArray alloc] init];
        NSDictionary *jsonDictionary = [NSJSONSerialization JSONObjectWithData:_responseData options:0 error:nil];
        NSArray *array = [jsonDictionary valueForKeyPath:@"statuses"];
        if ([array count] == 0)
        {
            [self showAlert:@"No tweets found" withTitle:kWarning];
        }
        for(NSDictionary *dict in array) {
            // Create a new contact object for each one and initialise it with information in the dictionary
            Tweet *tweet = [[Tweet alloc] initWithJSONDictionary:dict];
            [tweets addObject:tweet];
        }
        _tweets = tweets;
        [self.tableView reloadData];
    }
    else
    {
        [self showAlert:@"No data received." withTitle:kWarning];
    }
    _responseData = nil;
    [self.refreshControl endRefreshing];
    [self.tableView flashScrollIndicators];
    [activity stopAnimating];
}

- (void)cancelConnection
{
    if (self.connection != nil)
    {
        [self.connection cancel];
        self.connection = nil;
        _responseData = nil;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return _tweets.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"tweetCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Tweet *tweet = [_tweets objectAtIndex:indexPath.row];
    cell.textLabel.text = tweet.text;
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
	cell.textLabel.font = [UIFont systemFontOfSize:12];
	cell.textLabel.numberOfLines = 4;
    cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
    
    cell.detailTextLabel.text = tweet.fromUser;
    cell.detailTextLabel.font = [UIFont systemFontOfSize:10];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    
    [cell.imageView sd_setImageWithURL:[NSURL URLWithString:tweet.profileUrl] placeholderImage:[UIImage imageNamed:@"Blank.png"]];
    
    cell.accessoryType = UITableViewCellSelectionStyleNone;
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"Selected %@",indexPath);
    [self.searchBar resignFirstResponder];
    [self performSegueWithIdentifier:kToDetailsView sender:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    if ([segue.identifier isEqualToString:kToDetailsView])
    {
        DetailsViewController *details = segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        Tweet *tw = [_tweets objectAtIndex:indexPath.row];
        details.tweet = tw;
    }
}

#pragma mark - Search Bar
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self fetchTweets];
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    [self cancelConnection];
}

@end
