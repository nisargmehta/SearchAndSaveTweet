//
//  SavedTweetsList.h
//  SearchAndSaveTweet
//
//  Created by Nisarg Mehta on 9/30/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SavedTweetsList : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

@end
