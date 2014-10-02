//
//  SavedTweetsList.m
//  SearchAndSaveTweet
//
//  Created by Nisarg Mehta on 9/30/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "SavedTweetsList.h"
#import "AppDelegate.h"
#import "Tweet.h"
#import "Constants.h"
#import "DetailsViewController.h"
#import <UIImageView+WebCache.h>

@interface SavedTweetsList ()

@end

@implementation SavedTweetsList
{
    NSMutableArray *_savedTweets;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    self.tableView.rowHeight = 70.0;
    
    [self getSavedTweets];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getSavedTweets
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:kTweet inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSError *error;
    NSArray *fetchedObjects = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSMutableArray *tweets = [[NSMutableArray alloc] init];
    for (NSManagedObject *info in fetchedObjects)
    {
        Tweet *saved = [[Tweet alloc] init];
        saved.text = [info valueForKey:kText];
        saved.fromUser = [info valueForKey:kFromUser];
        saved.location = [info valueForKey:kLocation];
        saved.profileUrl = [info valueForKey:kProfileUrl];
        saved.dateCreated = [info valueForKey:kCreatedAt];
        [tweets addObject:saved];
    }
    _savedTweets = tweets;
    [self.tableView reloadData];
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
    return _savedTweets.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"savedTweet";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    Tweet *tweet = [_savedTweets objectAtIndex:indexPath.row];
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

-(NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kRemove;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        // http://stackoverflow.com/questions/10482311/delete-an-object-in-core-data
        
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:kTweet inManagedObjectContext:self.managedObjectContext]];
        
        Tweet *deleteTweet = [_savedTweets objectAtIndex:indexPath.row];
        NSString *user = deleteTweet.fromUser;
        NSString *date = deleteTweet.dateCreated;
        
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"fromUser == %@ AND createdAt == %@", user, date]];
        NSError* error = nil;
        NSArray* results = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
        
        for (NSManagedObject *managed in results)
        {
            [self.managedObjectContext deleteObject:managed];
        }
        NSError *saveError = nil;
        if ([self.managedObjectContext save:&saveError] == NO) {
            NSAssert(NO, @"Save should not fail\n%@", [saveError localizedDescription]);
            abort();
            return;
        }
        [_savedTweets removeObjectAtIndex:indexPath.row];
        // delete the row
        [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self performSegueWithIdentifier:kFromSavedToDetails sender:indexPath];
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:kFromSavedToDetails])
    {
        DetailsViewController *detail = segue.destinationViewController;
        NSIndexPath *indexPath = (NSIndexPath*)sender;
        Tweet *tw = [_savedTweets objectAtIndex:indexPath.row];
        detail.tweet = tw;
    }
}


@end
