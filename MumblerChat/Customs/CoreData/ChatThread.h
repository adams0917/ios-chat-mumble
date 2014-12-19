//
//  ChatThread.h
//  MumblerChat
//
//  Created by Ransika De Silva on 9/24/14.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface ChatThread : NSManagedObject

@property (nonatomic, retain) NSNumber * isGroupChat;
@property (nonatomic, retain) NSString * lastUpdatedDateTime;
@property (nonatomic, retain) NSNumber * readStatus;
@property (nonatomic, retain) NSString * threadId;
@property (nonatomic, retain) NSString * threadLastMessageOwnerId;
@property (nonatomic, retain) NSString * threadLastMessageMedium;
@property (nonatomic, retain) NSNumber * threadStatus;
@property (nonatomic, retain) NSNumber * unreadMessages;
@property (nonatomic, retain) NSString * threadLastMessageMediumTextType;
@property (nonatomic, retain) NSNumber * timeGivenToRespond;
@property (nonatomic, retain) NSString * lastReceivedMessageOpenedTime;
@property (nonatomic, retain) User *threadOwner;
@property (nonatomic, retain) User *recipient;

@end
