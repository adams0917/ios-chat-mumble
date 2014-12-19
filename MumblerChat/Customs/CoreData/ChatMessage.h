
#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatThread;

@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSData * blobMessage;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * messageContentType;
@property (nonatomic, retain) NSString * messageDateTime;
@property (nonatomic, retain) NSNumber * messageDelivered;
@property (nonatomic, retain) NSString * messageDeliveredDateTime;
@property (nonatomic, retain) NSString * messageDescription;
@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * messageRecipient;
@property (nonatomic, retain) NSString * messageSender;
@property (nonatomic, retain) NSNumber * messageType;//1 for single, 2 for group
@property (nonatomic, retain) NSNumber * offlineSent;
@property (nonatomic, retain) NSString * packetId;
@property (nonatomic, retain) NSNumber * seenByUser;
@property (nonatomic, retain) NSNumber * sentMessage;
@property (nonatomic, retain) NSNumber * sentSeen;
@property (nonatomic, retain) NSString * textMessage;
@property (nonatomic, retain) NSString * threadId;
@property (nonatomic, retain) NSString * messageMediumType;

@property (nonatomic, retain) NSString * threadState;
@property (nonatomic, retain) NSString * textMessageType;
@property (nonatomic, retain) NSNumber * timeGivenToRespond;

@property (nonatomic, retain) ChatThread *chatThread;

@end
