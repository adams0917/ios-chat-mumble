//
//  Friendship.h
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 4/1/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MumblerUser;

@interface Friendship : NSManagedObject

@property (nonatomic, retain) NSString * alerts_from_me;
@property (nonatomic, retain) NSString * alerts_to_me;
@property (nonatomic, retain) NSString * blocked_by_friend;
@property (nonatomic, retain) NSString * blocked_by_me;
@property (nonatomic, retain) NSString * friendship_id;
@property (nonatomic, retain) NSDate * last_update_time;
@property (nonatomic, retain) MumblerUser *friendMumblerUser;
@property (nonatomic, retain) MumblerUser *mumblerUser;

@end
