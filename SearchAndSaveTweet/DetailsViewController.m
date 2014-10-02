//
//  DetailsViewController.m
//  SearchAndSaveTweet
//
//  Created by Nisarg Mehta on 9/30/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "DetailsViewController.h"
#import "Constants.h"
#import "AppDelegate.h"
#import <UIImageView+WebCache.h>

@interface DetailsViewController ()

@end

@implementation DetailsViewController

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
    
    AppDelegate* appDelegate = [UIApplication sharedApplication].delegate;
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    self.details.text = [self appendText];
    [self.profile sd_setImageWithURL:[NSURL URLWithString:self.tweet.profileUrl] placeholderImage:[UIImage imageNamed:@"Blank.png"]];
    
    if([self isSaved])
    {
        [self.saveButton setTitle:kSaved forState:UIControlStateNormal];
        self.saveButton.enabled = false;
    }
    else
    {
        self.saveButton.enabled = true;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)isSaved
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:[NSEntityDescription entityForName:kTweet inManagedObjectContext:self.managedObjectContext]];
    [request setPredicate:[NSPredicate predicateWithFormat:@"fromUser == %@ AND createdAt == %@", self.tweet.fromUser, self.tweet.dateCreated]];
    NSError *error = nil;
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:&error];
    if (results.count > 0)
        return true;
    else
        return false;
}

-(void)savePressed
{
    if (self.saveButton.enabled)
    {
        self.saveButton.enabled = false;
        [self.saveButton setTitle:kSaved forState:UIControlStateNormal];
    }
    
    // save to core data
    NSManagedObjectContext *context = [self managedObjectContext];
    NSManagedObject *tweet = [NSEntityDescription insertNewObjectForEntityForName:kTweet inManagedObjectContext:context];
    [tweet setValue:self.tweet.text forKey:kText];
    [tweet setValue:self.tweet.location forKey:kLocation];
    [tweet setValue:self.tweet.fromUser forKey:kFromUser];
    [tweet setValue:self.tweet.dateCreated forKey:kCreatedAt];
    [tweet setValue:self.tweet.profileUrl forKey:kProfileUrl];
    
    NSError *error;
    if (![context save:&error]) {
        NSLog(@"couldn't save: %@", [error localizedDescription]);
    }
}

-(NSString*)appendText
{
    return [NSString stringWithFormat:@"From: %@\n\nTweet: %@\n\nLocation: %@\n\nDateCreated: %@\n\n",self.tweet.fromUser,self.tweet.text,self.tweet.location,self.tweet.dateCreated];
}

@end
