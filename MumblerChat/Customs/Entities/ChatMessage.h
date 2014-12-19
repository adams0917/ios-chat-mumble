//
//  ChatMessage.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatThread;

@interface ChatMessage : NSManagedObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSString * threadId;
@property (nonatomic, retain) NSString * imageString;
@property (nonatomic, retain) NSString * messageSender;
@property (nonatomic, retain) NSString * messageRecipient;
@property (nonatomic, retain) NSNumber * messageContentType;//for group -2, for single chat1
@property (nonatomic, retain) NSString * textMessage;
@property (nonatomic, retain) NSData * blobMessage;
@property (nonatomic, retain) NSString * messageDateTime;
@property (nonatomic, retain) NSString * messageDeliveredDateTime;
@property (nonatomic, retain) NSNumber * messageDelivered;
@property (nonatomic, retain) NSNumber * seenByUser;
@property (nonatomic, retain) NSNumber * sentMessage;
@property (nonatomic, retain) NSNumber * offlineSent;
@property (nonatomic, retain) NSNumber * messageType;
@property (nonatomic, retain) NSNumber * sentSeen;
@property (nonatomic, retain) NSString * packetId;
@property (nonatomic, retain) NSString * messageDescription;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * chatTypeString;// image, chat, voice, 
@property (nonatomic, retain) ChatThread *chatThread;

@end
