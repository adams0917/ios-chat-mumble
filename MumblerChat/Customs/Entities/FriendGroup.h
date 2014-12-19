//
//  FriendGroup.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FriendGroup : NSManagedObject

@property (nonatomic, retain) NSString * friendGroupId;
@property (nonatomic, retain) NSString * friendGroupName;
@property (nonatomic, retain) NSString * chatRoomName;
@property (nonatomic, retain) NSString * recordOwnerId;

@end
