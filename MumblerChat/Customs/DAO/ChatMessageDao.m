
#import "ChatMessageDao.h"
#import "ASAppDelegate.h"
#import "UserDao.h"
#import "Constants.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import "User.h"
#import "ChatUtil.h"
#import "UserDao.h"


@implementation ChatMessageDao

-(void) clearHistory{
    
    
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    

    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ChatThread" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    for(ChatThread *ct in objects){
        
        NSLog(@"ct.recipient.userId  %@  ct.threadOwner.userId %@ %@",ct.recipient.userId, @" ",ct.threadOwner.userId);
        
        [managedObjectContext deleteObject:ct];
        NSLog(@"CHAT THREAD DELETED SUCCESSFULLY FOR");
        
    }

}

//deleting chatThread

-(void) removeChatThreadForDeletedUser:(NSString *)friendUserId myUserId:(NSString *) myUserId{
    
    NSLog(@"removeChatThreadForDeletedUser friendUserId myUserId %@%@",friendUserId,myUserId);
    
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    
    
    //delete Chat Thread
    NSArray *predicateArray = [[NSArray alloc]init];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ChatThread" inManagedObjectContext:managedObjectContext];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    

    NSPredicate *predicate1 = [NSPredicate predicateWithFormat:@"(recipient.userId = %@)",friendUserId];
    
    predicateArray = [predicateArray arrayByAddingObject:predicate1];
    
    NSPredicate *predicate2 = [NSPredicate predicateWithFormat:@"(threadOwner.userId = %@)",myUserId];
    
    predicateArray = [predicateArray arrayByAddingObject:predicate2];
    
    NSPredicate *predicate = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray];

    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    for(ChatThread *ct in objects){
        
        NSLog(@"ct.recipient.userId  %@  ct.threadOwner.userId %@ %@",ct.recipient.userId, @" ",ct.threadOwner.userId);
        
        [managedObjectContext deleteObject:ct];
        NSLog(@"CHAT THREAD DELETED SUCCESSFULLY FOR");
        
    }
    
   /*
    
    //delete Chat Messages
    NSEntityDescription *entityDescChatMessage = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
    
    [request setEntity:entityDescChatMessage];
    NSArray *predicateArray2 = [[NSArray alloc]init];
    

   NSPredicate *predicateNew1 = [NSPredicate predicateWithFormat:@"(messageSender = %@)",myUserId];
    [predicateArray2 arrayByAddingObject:predicateNew1];
    
    NSPredicate *predicateNew2 = [NSPredicate predicateWithFormat:@"(messageRecipient = %@)",friendUserId];
    [predicateArray arrayByAddingObject:predicateNew2];
    
    
    NSPredicate *predicateNew = [NSCompoundPredicate andPredicateWithSubpredicates:predicateArray2];
    
    [request setPredicate:predicateNew];
    
    NSError *error1;
    NSArray *objects1 = [managedObjectContext executeFetchRequest:request error:&error1];
    
    for(ChatMessage *ct in objects1){
        [managedObjectContext deleteObject:ct];
        NSLog(@"CHAT ChatMessage DELETED SUCCESSFULLY");
        
    }
*/
    if([managedObjectContext save:&error] ) {
        NSLog(@"CHAT THREAD DELETED SUCCESSFULLY SAVED");
        

       
    } else {
        
        NSLog(@"CHAT THREAD DELETED SUCCESSFULLY NOT SAVED");
        

    }

    
}





-(ChatMessage *) saveChatMessageWithThreadId:(NSString *) threadId messageId:(NSString *)messageId senderUser:(User *) sender recipient:(User *) recipient messageMedium:(NSString *) messageMedium messageContent : (NSString *)  messageContent messageDateTime :(NSString *) messageDateTime deliveredDateTime :(NSString *) deliveredDateTime messageDelivered :(NSNumber *) messageDelivered imageEncodedString :(NSString *) imageEncodedString sentSeen : (NSNumber *) sentSeen threadLastMessage : (NSString *) threadLastMessage receiveType:(NSString *) receiveType timeGivenToRespond :(NSNumber *)timeGivenToRespond chatTextType:(NSString *) chatTextType
{
    
    DDLogVerbose(@"%@: %@: FOUND CHAT THREAD messageMedium=%@", THIS_FILE, THIS_METHOD,messageMedium);
    
    DDLogVerbose(@"%@: %@: FOUND CHAT THREAD threadId=%@", THIS_FILE, THIS_METHOD,threadId);
    
    
    NSString *recipientEjabberdId=[NSString stringWithFormat:@"%@%@",recipient.userId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
    
    NSString *senderEjabberdId=[NSString stringWithFormat:@"%@%@",sender.userId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
    
    
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    ChatMessage *chatMessage = (ChatMessage  *)[NSEntityDescription
                                                insertNewObjectForEntityForName:@"ChatMessage"inManagedObjectContext:managedObjectContext];
    
    ChatThread *chatThread  = [self getChatThread:threadId];
    
    if(chatThread !=nil){ //existing thread
        chatThread.threadLastMessageOwnerId = threadLastMessage;
        chatThread.lastUpdatedDateTime = messageDateTime;
        chatThread.threadOwner=sender;
        chatThread.recipient=recipient;
        chatThread.threadStatus=[NSNumber numberWithInt:ACTIVE_THREAD];
        chatThread.threadLastMessageMedium=messageMedium;
        
        if([messageMedium isEqualToString:MESSAGE_MEDIUM_TEXT]){
            chatThread.threadLastMessageMediumTextType = chatTextType;
        }
        if([receiveType isEqualToString:RECEIVE_TYPE_INCOMING]){
            chatThread.lastReceivedMessageOpenedTime=@"";
            chatThread.timeGivenToRespond=timeGivenToRespond;
        }
       
         chatThread.readStatus =[NSNumber numberWithInt:0];
        
        
        DDLogVerbose(@"%@: %@: CHAT THREAD IS NOT NIL threadId=%@", THIS_FILE, THIS_METHOD,threadId);
        
        
        DDLogVerbose(@"%@: %@: FOUND CHAT THREAD threadOwner=%@", THIS_FILE, THIS_METHOD,sender);
        
        
        if([receiveType isEqualToString:RECEIVE_TYPE_INCOMING]){
            int num= [chatThread.unreadMessages intValue];
            num++;
            chatThread.unreadMessages=[NSNumber numberWithInt:num];
        }else{
            chatThread.unreadMessages=[NSNumber numberWithInt:0];
        }
        
        
    }
    //new message
    else{
        
        DDLogVerbose(@"%@: %@: CHAT THREAD IS NIL threadId=%@", THIS_FILE, THIS_METHOD,threadId);
        
        
        
        
       /* chatThread = [self createThread:threadId  :messageContent :messageDateTime : recipientEjabberdId :recipient :[NSNumber numberWithInt:0]:receiveType];*/
        
        
       
        
         chatThread = [self createThread:threadId lastTextMessage:messageContent messageTime:messageDateTime friend:recipient isGroupChat:[NSNumber numberWithInt:0] chatType:messageMedium];
        
        
        
        
        chatThread.threadLastMessageOwnerId = threadLastMessage;
        chatThread.lastUpdatedDateTime = messageDateTime;
        chatThread.threadOwner=sender;
        chatThread.recipient=recipient;
         chatThread.timeGivenToRespond=timeGivenToRespond;
        chatThread.threadLastMessageMedium=messageMedium;
        chatThread.threadStatus=[NSNumber numberWithInt:ACTIVE_THREAD];
        if([messageMedium isEqualToString:MESSAGE_MEDIUM_TEXT]){
            chatThread.threadLastMessageMediumTextType = chatTextType;
        }
        chatThread.readStatus =[NSNumber numberWithInt:0];
        if([receiveType isEqualToString:RECEIVE_TYPE_INCOMING]){
            chatThread.lastReceivedMessageOpenedTime=@"";
        }
        
        
    }
    
    if([receiveType isEqualToString:RECEIVE_TYPE_INCOMING]){
        
        chatMessage.messageRecipient=senderEjabberdId;
        chatMessage.messageSender=recipientEjabberdId;
    }else{
        chatMessage.messageSender=senderEjabberdId;
        chatMessage.messageRecipient=recipientEjabberdId;
    }
    chatMessage.messageDeliveredDateTime=deliveredDateTime;
    chatMessage.textMessageType=chatTextType;
    //chatMessage.messageSender=senderEjabberdId;
    //chatMessage.messageRecipient=recipientEjabberdId;
    chatMessage.textMessage=messageContent;
    chatMessage.messageId=messageId;
    chatMessage.messageDateTime=messageDateTime;
    chatMessage.chatThread=chatThread;
    chatMessage.threadId=chatThread.threadId;
    chatMessage.messageMediumType=messageMedium;
    chatMessage.threadState=imageEncodedString;
    chatMessage.sentSeen=sentSeen;//2 for yes
    chatMessage.timeGivenToRespond=timeGivenToRespond;
    
    
    
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
       // DDLogVerbose(@"%@: %@: CHAT MESSAGE SAVED %@", THIS_FILE, THIS_METHOD,chatMessage);
        
        NSLog(@"saveChatMessageWithThreadId CHAT MESSAGE SAVED %@",chatMessage);
        
    } else {
        NSLog(@"saveChatMessageWithThreadId CHAT MESSAGE NOT SAVED");
        
        
       // DDLogVerbose(@"%@: %@: CHAT MESSAGE NOT SAVED", THIS_FILE, THIS_METHOD);
        
    }
    return chatMessage;
    
    
}

-(ChatMessage *) saveChatMessageWithOutFriend:(NSString *) threadId messageId:(NSString *)messageId senderEjabberdId:(NSString *) senderEjabberdId messageMedium:(NSString *) messageMedium messageContent : (NSString *)  messageContent messageDateTime :(NSString *) messageDateTime deliveredDateTime :(NSString *) deliveredDateTime messageDelivered :(NSNumber *) messageDelivered imageEncodedString :(NSString *) imageEncodedString  receiveType:(NSString *) receiveType timeGivenToRespond :(NSNumber *)timeGivenToRespond chatTextType:(NSString *) chatTextType {
    
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    ChatMessage *chatMessage = (ChatMessage  *)[NSEntityDescription
                                                insertNewObjectForEntityForName:@"ChatMessage"inManagedObjectContext:managedObjectContext];
    

    chatMessage.messageDeliveredDateTime=deliveredDateTime;
    chatMessage.textMessageType=chatTextType;
    chatMessage.messageSender=senderEjabberdId;
    chatMessage.textMessage=messageContent;
    chatMessage.messageDateTime=messageDateTime;
    chatMessage.threadId=threadId;
    chatMessage.messageId=messageId;
    chatMessage.messageMediumType=messageMedium;
    chatMessage.threadState=imageEncodedString;
    chatMessage.timeGivenToRespond=timeGivenToRespond;
    
   
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
        DDLogVerbose(@"%@: %@: CHAT MESSAGE SAVED saveChatMessageWithOutFriend %@", THIS_FILE, THIS_METHOD,chatMessage);
        
    } else {
        
        DDLogVerbose(@"%@: %@: CHAT MESSAGE NOT SAVED saveChatMessageWithOutFriend", THIS_FILE, THIS_METHOD);
        
    }
    return chatMessage;

}


-(void) saveComposedChatMessageWithFriends:(ChatMessage *) chatMessage{
    
    NSLog(@"saveComposedChatMessageWithFriends %@=",chatMessage);
    
    ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    
    NSString *meMumblerUserId= [NSString stringWithFormat:@"%@",[[NSUserDefaults standardUserDefaults] valueForKey:MUMBLER_USER_ID]];
    
    User *userMe = [self getUserForId:meMumblerUserId];
    
    NSString * meEjabberdId=[NSString stringWithFormat:@"%@%@",meMumblerUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
    
    NSString *timeToRespond= [chatMessage.timeGivenToRespond stringValue];
    
    for(id key in appDelegate.friendsToBeAddedToComposeTheMessageDictionary) {

        id recipient = [appDelegate.friendsToBeAddedToComposeTheMessageDictionary objectForKey:key];
        NSLog(@" testing value %@",recipient);
        
          NSString *selectedFriendUserId =[NSString stringWithFormat:@"%@",[recipient valueForKey:@"userId"]];
        
         User *userFriend = [self getUserForId:selectedFriendUserId];
       NSString *friendEjabberdId=[NSString stringWithFormat:@"%@%@",selectedFriendUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
        
        
        
        NSTimeInterval  timeInMillis = [[NSDate date] timeIntervalSince1970] * 1000;
        long long integerMilliSeconds = timeInMillis;
        NSString *timeInMillisStr = [NSString stringWithFormat:@"%lld", integerMilliSeconds];
        
        NSString *chatThreadId=[NSString stringWithFormat:@"%@_%@_%@",meEjabberdId, friendEjabberdId,timeInMillisStr];
        
        
        
        
        //XMPP SEND
        
        NSString *timeInMiliseconds = [ChatUtil getTimeInMiliSeconds:[NSDate date]];
        
        NSXMLElement *message = [NSXMLElement elementWithName:@"message"];
        NSXMLElement *body = [NSXMLElement elementWithName:@"body"];
        NSXMLElement *received = [NSXMLElement elementWithName:@"request" URI:@"urn:xmpp:receipts"];
        
        NSXMLElement *extras=[NSXMLElement elementWithName:@"extras" URI:@"urn:xmpp:extras"];
        
        NSString *messageId=[NSString stringWithFormat:@"%@%@%@",@"ios_",timeInMiliseconds,meEjabberdId];
        
        
        [body setStringValue:chatMessage.textMessage];
        [message addAttributeWithName:@"type" stringValue:@"chat"];
        [message addAttributeWithName:@"id" stringValue:messageId];
        [message addAttributeWithName:@"to" stringValue:friendEjabberdId];
        
        [extras addAttributeWithName:MESSAGE_MEDIUM stringValue:chatMessage.messageMediumType];
        [extras addAttributeWithName:THREAD_ID stringValue:chatThreadId];
        [extras addAttributeWithName:SENDER_USERNAME stringValue:userMe.name];
        [extras addAttributeWithName:TIME_GIVEN_TO_RESPOND stringValue:timeToRespond];
        [extras addAttributeWithName:TEXT_TYPE stringValue:chatMessage.textMessageType];
        [message addChild:extras ];
        [message addChild:body];
        [message addChild:received];
        DDLogVerbose(@"%@: %@: messaged Typed =%@ ", THIS_FILE, THIS_METHOD,message);
        
        [appDelegate.xmppStream sendElement:message];

        
                
        
        //DB SAVE
      
        //get current time, thread id should be unique
       
        
        
        ASAppDelegate *appDelegate = (ASAppDelegate *)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        ChatMessage *chatMessageNew = (ChatMessage  *)[NSEntityDescription
                                                    insertNewObjectForEntityForName:@"ChatMessage"inManagedObjectContext:managedObjectContext];
        
        ChatThread *chatThread;
        if(chatThread == nil){
            
            chatThread = [self createThread:chatThreadId lastTextMessage:chatMessage.textMessage messageTime:chatMessage.messageDateTime friend:userFriend isGroupChat:[NSNumber numberWithInt:0] chatType:chatMessage.messageMediumType];
            
            chatThread.threadLastMessageOwnerId = meEjabberdId;
            chatThread.lastUpdatedDateTime = chatMessage.messageDateTime;
            chatThread.threadOwner=userMe;
            chatThread.recipient=recipient;
            chatThread.timeGivenToRespond=chatMessage.timeGivenToRespond;
            chatThread.threadLastMessageMedium=chatMessage.messageMediumType;
            chatThread.threadStatus=[NSNumber numberWithInt:ACTIVE_THREAD];
            if([chatMessage.messageMediumType isEqualToString:MESSAGE_MEDIUM_TEXT]){
                chatThread.threadLastMessageMediumTextType = chatMessage.textMessageType;
            }
            
            
            
        }
        
        
        chatMessageNew.messageDeliveredDateTime=chatMessage.messageDeliveredDateTime;
        chatMessageNew.textMessageType=chatMessage.textMessageType;
        chatMessageNew.messageSender=meMumblerUserId;
        chatMessageNew.messageRecipient=friendEjabberdId;
        chatMessageNew.textMessage=chatMessage.textMessage;
        chatMessageNew.messageDateTime=chatMessage.messageDateTime;
        chatMessageNew.chatThread=chatThread;
        chatMessageNew.threadId=chatThreadId;
        chatMessage.messageId=chatMessage.messageId;
        chatMessageNew.messageMediumType=chatMessage.messageMediumType;
        chatMessageNew.threadState=chatMessage.threadState;
        chatMessageNew.sentSeen=chatMessage.sentSeen;//2 for yes
        chatMessage.timeGivenToRespond=chatMessage.timeGivenToRespond;
        
        
        NSError *error = nil;
        if([managedObjectContext save:&error] ) {
           // DDLogVerbose(@"%@: %@: CHAT MESSAGE SAVED saveComposedChatMessageWithFriends %@", THIS_FILE, THIS_METHOD,chatMessage);
            
            NSLog(@"CHAT MESSAGE SAVED saveComposedChatMessageWithFriends %@=",chatMessage);
            
        } else {
            
               NSLog(@"CHAT MESSAGE NOT SAVED saveComposedChatMessageWithFriends");
           // DDLogVerbose(@"%@: %@: CHAT MESSAGE NOT SAVED saveComposedChatMessageWithFriends ", THIS_FILE, THIS_METHOD);
            
        }
        
        
    }
    
}



-(User *) getUserForId : (NSString *)userId{
    
    NSLog(@"createUserContact====get User-------");
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = nil;
    
    managedObjectContext = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId = %@)",userId];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"user object count == %lu",(unsigned long)[objects count]);
    
    if([objects count]>0){
        
        if ([objects count] == 1) {
            NSLog(@"Size 1 ");
            
            User *c = [objects objectAtIndex:0];
            
            return c;
            
        } else {
            return nil;
        }
    }else{
        return nil;
    }
    
}




-(ChatThread *) getChatThread: (NSString *) threadId {
    
    NSLog(@"====getChatThread-------");
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = nil;
    
    managedObjectContext = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ChatThread" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(threadId = %@)",threadId];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"threads object count == %lu",(unsigned long)[objects count]);
    
    if ([objects count] == 1) {
        NSLog(@"Size 1 ");
        
        ChatThread *c = [objects objectAtIndex:0];
        
        return c;
        
    } else {
        return nil;
    }
}


-(void)updateLastMessageOpenedTime :(NSString *)threadId  threadLastmessageOpenedTime:(NSString *) threadLastmessageOpenedTime{
    
    NSLog(@"====updateLastMessageOpenedTime------%@",threadLastmessageOpenedTime);
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    ChatThread *chatThread  = [self getChatThread:threadId];
    
    if(chatThread!=nil){ //existing thread
        chatThread.lastReceivedMessageOpenedTime =threadLastmessageOpenedTime;
        
    }
    
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
        NSLog(@"Chat updateLastMessageOpenedTime saved");
    } else {
        
        NSLog(@"Chat updateLastMessageOpenedTime not saved");
        
    }

    
}


-(void)updateChatThreadReadStatus :(NSString *)threadId threadStatus:(NSNumber *)threadStatus{
    
    NSLog(@"====updateChatThreadReadStatus------");
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    ChatThread *chatThread1  = [self getChatThread:threadId];
    
    if(chatThread1 !=nil){ //existing thread
        chatThread1.readStatus =[NSNumber numberWithInt:1];
        
        }
    
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
        NSLog(@"Chat updateChatThreadReadStatus saved");
    } else {
        
        NSLog(@"Chat updateChatThreadReadStatus not saved");
        
    }
    
   
}

-(void) updateThreadInActiveStatus:(NSString *)threadId{
    
    NSLog(@"====updateThreadInActiveStatus------");
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    ChatThread *chatThread  = [self getChatThread:threadId];
    
    if(chatThread !=nil){ //existing thread
         chatThread.threadStatus=[NSNumber numberWithInt:IN_ACTIVE_THREAD];
        
    }
    
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
        NSLog(@"ChatThread updateThreadInActiveStatus saved");
    } else {
        
        NSLog(@"ChatThread updateThreadInActiveStatus  not saved");
        
    }
    

}






- (ChatThread *) createThread :(NSString *)threadId lastTextMessage:(NSString *) latsTextMessage messageTime:(NSString *) messageTime friend : (User *) threadOwner isGroupChat:  (NSNumber *) isGroupChat chatType: (NSString *) chatType{
    
    NSLog(@"====createThread------");
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    ChatThread *chatThread = (ChatThread  *)[NSEntityDescription
                                             insertNewObjectForEntityForName:@"ChatThread"inManagedObjectContext:managedObjectContext];
    
    chatThread.threadId = threadId;
    
    chatThread.threadLastMessageOwnerId = latsTextMessage;
    chatThread.threadLastMessageMedium = chatType;
    //chatThread.threadOwner = threadOwner.userId;
    chatThread.threadOwner = threadOwner;
    chatThread.lastUpdatedDateTime = messageTime;
    chatThread.isGroupChat=isGroupChat;
    chatThread.threadStatus =[NSNumber numberWithInt:1];
    if([chatType isEqualToString:@"incomming"]){
        
        //chatThread.unreadMessages=[NSNumber numberWithInt:1];
    }else{
       // chatThread.unreadMessages=[NSNumber numberWithInt:0];
        
    }
    
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
        NSLog(@"Chat thread saved");
    } else {
        
        NSLog(@"Chat thread not saved");
        
    }
    
    return chatThread;
    
    
}
-(void) changeUnreadMessageCount : (NSString *) threadId{
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = nil;
    
    managedObjectContext = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ChatThread" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(threadId = %@)",threadId];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"threads object count == %lu",(unsigned long)[objects count]);
    
    if ([objects count] == 1) {
        NSLog(@"Size 1 ");
        
        ChatThread *c = [objects objectAtIndex:0];
        c.unreadMessages=[NSNumber numberWithInt:0];
        
        NSError *error = nil;
        if([managedObjectContext save:&error] ) {
            NSLog(@"Chat thread edited with 0 unread messages");
        } else {
            
            NSLog(@"Chat thread not edited with 0 unread messages");
            
        }
        
        
    } else {
    }
    
    
}

-(void)updateMessageSeenState:(NSString *)messageId{
    
    if(messageId.length>1){
        
        NSManagedObjectContext *managedObjectContext = nil;
        ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
        managedObjectContext = [appDelegate managedObjectContext];
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageId = %@)", messageId];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDateTime" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        // NSArray *objects = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
        NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
        
        if (objects.count >=1) {
            
            NSLog(@"objects====%@",objects);//seenByUser=1
            
            ChatMessage *c = [objects lastObject];
            NSLog(@"chat messag ==== %@",c);
            c.sentSeen=[NSNumber numberWithInt:2];
            //[c setValue:[NSNumber numberWithInt:2] forKey:@"sentSeen"];
            
            
            //yourManagedObject.date = [(UIDatePicker *)sender date];
            
            NSError *error=nil;
            //            if([managedObjectContext save:&error]){
            //                NSLog(@"didn't save %@",error);
            //            }
            [managedObjectContext save:&error];
            
            
        } else {
            NSLog(@"objects are nil====");
        }
    }else{
        NSLog(@"updateMessageSeenState message id is null====");
    }
    
}

-(void)updateMessageImageStringForMessageId:(NSString *)messageId imageString:(NSString *)imageString{
    if(messageId.length>1){
        NSLog(@"updateMessageImageString updateMessageImageString");
        NSManagedObjectContext *managedObjectContext = nil;
        ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
        
        
        managedObjectContext = [appDelegate managedObjectContext];
        
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ChatMessage" inManagedObjectContext:managedObjectContext];
        
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(messageId = %@)", messageId];
        NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"messageDateTime" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
        
        
        NSFetchRequest *request = [[NSFetchRequest alloc] init];
        [request setEntity:entityDesc];
        [request setPredicate:predicate];
        [request setSortDescriptors:sortDescriptors];
        
        NSError *error;
        // NSArray *objects = [appDelegate.managedObjectContext executeFetchRequest:request error:&error];
        NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
        
        if (objects.count >=1) {
            
            NSLog(@"updateMessageImageString objects====%@",objects);//seenByUser=1
            
            ChatMessage *c = [objects lastObject];
            NSLog(@"updateMessageImageString chat messag ==== %@",c);
            c.threadState=imageString;
            
            NSError *error=nil;
            [managedObjectContext save:&error];
        } else {
            NSLog(@"updateMessageImageString objects are nil====");
        }
    }else{
        NSLog(@"updateMessageImageString message id is null====");
    }
    
}



@end
