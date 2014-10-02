//
//  DetailsViewController.h
//  SearchAndSaveTweet
//
//  Created by Nisarg Mehta on 9/30/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Tweet.h"

@interface DetailsViewController : UIViewController

@property(nonatomic,retain) IBOutlet UITextView *details;
@property(nonatomic,retain) IBOutlet UIImageView *profile;
@property(nonatomic,retain) IBOutlet UIButton *saveButton;
@property (strong, nonatomic) Tweet *tweet;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;

-(IBAction)savePressed;

@end
