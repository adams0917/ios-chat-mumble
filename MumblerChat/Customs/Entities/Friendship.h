//
//  Friendship.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Friendship : NSManagedObject

@property (nonatomic, retain) NSString * friendshipId;
@property (nonatomic, retain) NSString * friendId;
@property (nonatomic, retain) NSString * recordOwnerId;
@property (nonatomic, retain) NSString * friendshipStatus;
@property (nonatomic, retain) NSNumber * doNotShareStatus;
@property (nonatomic, retain) NSNumber * blockedStatus;
@property (nonatomic, retain) NSNumber * hiddenStatus;

@end
