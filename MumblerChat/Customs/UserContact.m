
#import "UserContact.h"

@implementation UserContact


@synthesize userId;
@synthesize chatId;
@synthesize name;
@synthesize gender;
@synthesize profileImageBytes;
@synthesize onlineStatus;
@synthesize contactType;
@synthesize imageByteString;
@synthesize mobileNo;
@synthesize jid;
@synthesize profileImageUrl;

#if TARGET_OS_IPHONE
@synthesize photo;
#else
@synthesize photo;
#endif

@end
