
#import <Foundation/Foundation.h>
#import "XMPP.h"

@interface UserContact : NSObject

@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSString * chatId;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * gender;
@property (nonatomic, retain) NSString * profileImageBytes;
@property (nonatomic, retain) NSString * profileImageUrl;

@property (nonatomic, retain) NSString * onlineStatus;
@property (nonatomic, retain) NSString *contactType; 
@property (nonatomic, retain) NSString * imageByteString;
@property (nonatomic, retain) NSString * mobileNo;
@property (nonatomic, strong) XMPPJID *jid;


#if TARGET_OS_IPHONE
@property (nonatomic, strong) UIImage *photo;
#else
@property (nonatomic, strong) NSImage *photo;
#endif

@end
