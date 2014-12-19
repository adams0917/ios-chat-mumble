
#import <Foundation/Foundation.h>

#import "ChatMessage.h"
#import "User.h"
#import "ChatThread.h"

@interface ChatMessageDao : NSObject

-(void) clearHistory;


-(ChatMessage *) saveChatMessageWithThreadId:(NSString *) threadId messageId:(NSString *)messageId senderUser:(User *) sender recipient:(User *) recipient messageMedium:(NSString *) messageMedium messageContent : (NSString *)  messageContent messageDateTime :(NSString *) messageDateTime deliveredDateTime :(NSString *) deliveredDateTime messageDelivered :(NSNumber *) messageDelivered imageEncodedString :(NSString *) imageEncodedString sentSeen : (NSNumber *) sentSeen threadLastMessage : (NSString *) threadLastMessage receiveType:(NSString *) receiveType timeGivenToRespond :(NSNumber *)timeGivenToRespond chatTextType:(NSString *) chatTextType;

-(ChatMessage *) saveChatMessageWithOutFriend:(NSString *) threadId messageId:(NSString *)messageId senderEjabberdId:(NSString *) senderEjabberdId messageMedium:(NSString *) messageMedium messageContent : (NSString *)  messageContent messageDateTime :(NSString *) messageDateTime deliveredDateTime :(NSString *) deliveredDateTime messageDelivered :(NSNumber *) messageDelivered imageEncodedString :(NSString *) imageEncodedString  receiveType:(NSString *) receiveType timeGivenToRespond :(NSNumber *)timeGivenToRespond chatTextType:(NSString *) chatTextType;


-(void) saveComposedChatMessageWithFriends:(ChatMessage *) chatMessage;


-(void) removeChatThreadForDeletedUser:(NSString *)friendUserId myUserId:(NSString *) myUserId;




- (ChatThread *) createThread :(NSString *)threadId lastTextMessage:(NSString *) latsTextMessage messageTime:(NSString *) messageTime friend : (User *) threadOwner isGroupChat:  (NSNumber *) isGroupChat chatType: (NSString *) chatType;

-(void)updateChatThreadReadStatus :(NSString *)threadId threadStatus:(NSNumber *)threadStatus;

-(void)updateLastMessageOpenedTime :(NSString *)threadId  threadLastmessageOpenedTime:(NSString *) threadLastmessageOpenedTime;
    
-(void) updateThreadInActiveStatus:(NSString *)threadId;



-(ChatThread *) getChatThread: (NSString *) threadId;
-(void) changeUnreadMessageCount : (NSString *) threadId;
-(void)updateMessageSeenState :(NSString *)messageId;
-(void)updateMessageImageStringForMessageId:(NSString *)messageId imageString:(NSString *)imageString;
@end