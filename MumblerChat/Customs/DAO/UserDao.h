

#import <Foundation/Foundation.h>
#import "User.h"

@interface UserDao : NSObject

-(User *) createUpdateUser : (NSDictionary *) userJson;

-(BOOL) updateUserOnlineStatus: (NSString*) userId :(NSString *)onlineStatus :(NSString *)myStatus;
-(User *) createUserContact :(NSString *) userId : (NSString *) chatId : (NSString *) name : (NSString *) mobille : (NSString *) contactType : (NSString *) profileImageUrl;
-(User *) getUserForId : (NSString *)userId;

-(User *) updateUserOnlineStatusWithUser: (NSString*) userId :(NSString *)onlineStatus ;
-(User *) updateUserByVcard :(NSString *) userId : (NSString *) imageByteString : (NSString *) name;
@end
