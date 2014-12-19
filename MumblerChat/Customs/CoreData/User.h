//
//  User.h
//  MumblerChat
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class ChatThread;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * chatId;
@property (nonatomic, retain) NSString * contactType;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * emailVerificationStatus;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * mobile;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * onlineStatus;
@property (nonatomic, retain) NSString * profileImageBytes;
@property (nonatomic, retain) NSString * profileImageUrl;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * userFBId;
@property (nonatomic, retain) NSString * userProfileStatus;
@property (nonatomic, retain) NSString * whoCanSendMeMessages;
@property (nonatomic, retain) NSString * alertsStatus;//1 or 0
@property (nonatomic, retain) NSString * saveOutgoingMediaStatus;//1 or 0
@property (nonatomic, retain) NSString * timeGivenToRenspond;//1 or 0
@property (nonatomic, retain) NSString * myStatus;



@property (nonatomic, retain) ChatThread *chatThread;

@end
