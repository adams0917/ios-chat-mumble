//
//  FriendDao.h
//  MumblerChat
//
//  Created by Ransika De Silva on 9/5/14.
//
//

#import <Foundation/Foundation.h>
#import "Friendship.h"
#import "Constants.h"
//#import "ContactReceived.h"


@interface FriendDao : NSObject

-(void)addFriendships;
-(void)updateFriendshipWithEjabberdStatusFor: (NSString *) friendUserId;
//-(void)addFriendshipsForNewFriend;
/*-(void)addFriendshipsForNewFriend: (NSString *) friendMumblerUserId : (NSString *) friendMumblerUserName;*/
-(void)addFriendshipsForNewFriend: (NSString *) friendMumblerUserId : (NSString *) friendMumblerUserName : (NSString *) friendMumblerUserProfileStatus;
    

-(void)blockFriend: (NSString *) friendMumblerUserId;







//-(NSArray*) getBestFriends: (NSString *) mumblerUserId;

//Delete Friend
-(void) deleteFriendWithFriendship:(NSString *) friendId;







//-(void)addOrUpdateFriendships: (NSString *)mumblerUserId :(NSArray*) friendships;
//-(Friendship *)addOrUpdateFriendship: (MumblerUser *)mumblerUser :(NSDictionary*) friendship;
-(Friendship *) getFriendship: (NSString *) friendshipId;
-(NSArray *) getFriendships: (NSString *) mumblerUserId;


//-(NSArray*)getFriendshipsByBlockedByMeState: (NSString *)mumblerUserId :(int)yesNoStatus;

//-(BOOL) removeFriendship: (Friendship *) friendship;
//-(BOOL) addNewContact: (NSDictionary *) mumblerUser :(NSString *) mumblerUserId :(NSString *)from;
//-(BOOL) changeAlertsStatus: (NSString *) friendMumblerUserId :(NSString*) changeAlertStatus;
//-(BOOL) changeFriendshipStatus: (NSString *) friendMumblerUserId :(NSString*) blockUnblockStatus :(BOOL)isBlocked_By_Me;
//-(ContactReceived*)addForwadedContact :(NSDictionary *) mumblerUser :(NSString *)mumblerUserId;
//-(Friendship *) getFriendshipWith: (NSString *) friendMumblerUserId;
//-(NSArray*) getFriendsWhoWantsAlertsFromMe: (NSString *) mumblerUserId;


@end
