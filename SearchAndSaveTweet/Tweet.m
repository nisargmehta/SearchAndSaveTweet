//
//  Tweet.m
//  SearchAndSaveTweet
//
//  Created by Nisarg Mehta on 9/30/14.
//  Copyright (c) 2014 OpenSource. All rights reserved.
//

#import "Tweet.h"

@implementation Tweet

- (id)initWithJSONDictionary:(NSDictionary *)jsonDictionary {
    if(self = [self init]) {
        _fromUser = [jsonDictionary valueForKeyPath:@"user.name"];
        _profileUrl = [jsonDictionary valueForKeyPath:@"user.profile_image_url"];
        _location = [jsonDictionary valueForKeyPath:@"user.location"];
        _dateCreated = [jsonDictionary valueForKeyPath:@"created_at"];
        _text = [jsonDictionary valueForKeyPath:@"text"];
    }
    return self;
}

- (id)init
{
    self = [super init];
    if (self)
    {
        
    }
    return self;
}

@end
