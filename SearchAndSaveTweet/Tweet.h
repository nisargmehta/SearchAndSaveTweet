//
//  Tweet.h
//  SearchAndSaveTweet
//
//  Created by Nisarg Mehta on 9/30/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tweet : NSObject

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary;

@property (copy) NSString *fromUser;
@property (copy) NSString *profileUrl;
@property (copy) NSString *text;
@property (copy) NSString *location;
@property (copy) NSString *dateCreated;

@end
