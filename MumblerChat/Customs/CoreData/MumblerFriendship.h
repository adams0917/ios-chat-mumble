//
//  MumblerFriendship.h
//  MumblerChat
//
//  Created by Ransika De Silva on 9/11/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface MumblerFriendship : NSManagedObject

@property (nonatomic, retain) NSNumber * isSyncWithEjabbered;
@property (nonatomic, retain) NSNumber * isSyncWithServer;
@property (nonatomic, retain) NSString * friendshipStatus;
@property (nonatomic, retain) User *friendMumblerUser;
@property (nonatomic, retain) User *mumblerUser;

@end
