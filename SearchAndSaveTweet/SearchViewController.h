//
//  SearchViewController.h
//  SearchAndSaveTweet
//
//  Created by Nisarg Mehta on 9/29/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate>
{
    NSMutableData *_responseData;
    UIActivityIndicatorView *activity;
}

@property(nonatomic,retain) IBOutlet UITableView *tableView;
@property(nonatomic,retain) IBOutlet UISearchBar *searchBar;

@end
