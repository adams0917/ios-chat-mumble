//
//  FriendGroupMember.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FriendGroupMember : NSManagedObject

@property (nonatomic, retain) NSString * friendGroupMemberId;
@property (nonatomic, retain) NSString * friendGroupId;
@property (nonatomic, retain) NSString * friendId;

@end
