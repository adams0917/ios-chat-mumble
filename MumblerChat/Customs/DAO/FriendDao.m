//
//  FriendDao.m
//  MumblerChat
//

#import "FriendDao.h"
#import "ASAppDelegate.h"
#import "MumblerFriendship.h"
#import "UserDao.h"


@implementation FriendDao



-(void)addFriendships{
    
    NSLog(@"updateAddedFriends----");
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    for(id key in appDelegate.friendsToBeAddedDictionary) {
        
        /*ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
         for(int i=0; i<[appDelegate.friendsToBeAdded count]; i++){*/
        
        // Get user object for friend mumbler id
        
        // if user doesn't exist, then create user
        
        // Then insert friendship
        
        id value = [appDelegate.friendsToBeAddedDictionary objectForKey:key];
        
        NSLog(@" testing value %@",value);
        
        NSString *selectedFriendUserId =[NSString stringWithFormat:@"%@",[value valueForKey:@"userId"]];
        
        NSString *selectedFriendAlias =[NSString stringWithFormat:@"%@",[value valueForKey:@"alias"]];
        
        NSString *selectedFriendStatus =[NSString stringWithFormat:@"%@",[value valueForKey:@"myStatus"]];
        
        [self addFriendshipsForNewFriend:selectedFriendUserId :selectedFriendAlias :selectedFriendStatus];
        
        
         }
    
        [appDelegate.friendsToBeAddedDictionary removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"addedFriendsLabelUpdate" object:appDelegate.friendsToBeAddedDictionary];

    
    
}

-(void)addFriendshipsForNewFriend: (NSString *) friendMumblerUserId : (NSString *) friendMumblerUserName : (NSString *) friendMumblerUserProfileStatus{
    
    
    NSLog(@" addFriendshipsForNewFriend friendMumblerUserId %@",friendMumblerUserId);
    NSLog(@" addFriendshipsForNewFriend friendMumblerUserName %@",friendMumblerUserName);
    NSLog(@" addFriendshipsForNewFriend friendMumblerUserProfileStatus %@",friendMumblerUserProfileStatus);
    
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSString *mumblerUserId= [NSString stringWithFormat:@"%@",[NSUserDefaults.standardUserDefaults valueForKey:MUMBLER_USER_ID]];
    
    UserDao *userDao =[[UserDao alloc]init];
    
    User *me = [userDao getUserForId:mumblerUserId];
    
    User *friendUser = [userDao getUserForId:friendMumblerUserId];
    
    
    
    NSLog(@" friendMumblerUserId Friend dao%@",friendMumblerUserId);
    
    NSLog(@" friendUser dao%@",friendUser);
    
    
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    if (friendUser == nil) {
        
        NSLog(@" friendUser is nil ");
        
        friendUser = (User  *)[NSEntityDescription
                               insertNewObjectForEntityForName:@"User"inManagedObjectContext:managedObjectContext];
        friendUser.userId = friendMumblerUserId;
        friendUser.name = friendMumblerUserName;
        friendUser.userProfileStatus = friendMumblerUserProfileStatus;
        
        
    }else{
        friendUser.userId = friendMumblerUserId;
        friendUser.name = friendMumblerUserName;
        friendUser.userProfileStatus = friendMumblerUserProfileStatus;
        
        
    }
    
    //friendUser.name = friendMumblerUserName;
    
    
    // Check whethere there is an existing friendship
    MumblerFriendship *friendship = [self getFriendshipWith:friendMumblerUserId];
    
    // This will be empty most of the time
    if (friendship == nil) {
        
        NSLog(@" friendship is nil ");
        
        
        friendship = (MumblerFriendship  *)[NSEntityDescription
                                            insertNewObjectForEntityForName:@"MumblerFriendship"inManagedObjectContext:managedObjectContext];
        
    }
    
    friendship.friendMumblerUser = friendUser;
    friendship.mumblerUser = me;
    friendship.isSyncWithEjabbered=NO;
    friendship.isSyncWithServer=NO;
    friendship.friendshipStatus=FRIEND;
    
    
    NSLog(@" friendship.friendMumblerUser Id %@",friendUser.userId);
    NSLog(@" friendship.friendMumblerUser name%@",friendUser.name);
    
    NSLog(@" friendship.mumblerUser %@",me.userId);
    
    
    NSError *error;
    if([managedObjectContext save:&error] ) {
        NSLog(@"====RECORD SAVED");
        NSLog(@" friendship.friendMumblerUser %@",friendUser.userId);
        NSLog(@" friendship.mumblerUser %@",me.userId);
        
        
        
    } else {
        
        NSLog(@"====RECORD NOT SAVED %@",error);
        
    }
    
}

-(void)blockFriend: (NSString *) friendMumblerUserId{
    
    // Check whethere there is an existing friendship
    
    MumblerFriendship *friendship = [self getFriendshipWith:friendMumblerUserId];
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    
    if(friendship != nil){
        friendship.friendshipStatus=BLOCKED_FRIEND;
          NSLog(@"====friendship.friendshipStatus=BLOCKED_FRIEND");
       

    }
    
    NSError *error;
    if([managedObjectContext save:&error] ) {
        NSLog(@"====RECORD SAVED BLOCKED_FRIEND");
        
    } else {
        
        NSLog(@"====RECORD NOT SAVED %@",error);
        
    }
    

   

}


-(void)updateFriendshipWithEjabberdStatusFor: (NSString *) friendUserId {
    
    NSLog(@"updateFriendshipWithEjabberdStatusFor----");
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    
    // Check whethere there is an existing friendship
    MumblerFriendship *friendship = [self getFriendshipWith:friendUserId];
    
    // This will be empty most of the time
    if (friendship != nil) {
        friendship.isSyncWithEjabbered = [NSNumber numberWithBool:YES];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        
        
        NSError *error;
        if([managedObjectContext save:&error] ) {
            NSLog(@"====RECORD SAVED ");
            
        } else {
            
            NSLog(@"====RECORD NOT SAVED %@",error);
            
        }
        
        
    }
    
    
    
}


//Delete Friend
-(void) deleteFriendWithFriendship:(NSString *) friendId{

    NSLog(@"deleteFriendWithFriendship friendId %@",friendId);
    
    
    
    //delete friendship
    // Check whethere there is an existing friendship
    MumblerFriendship *friendship = [self getFriendshipWith:friendId];
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
     NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    if(friendship != nil){
        
        NSString *mumblerUserId= [NSString stringWithFormat:@"%@",[NSUserDefaults.standardUserDefaults valueForKey:MUMBLER_USER_ID]];
        
        //delete friendship
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MumblerFriendship" inManagedObjectContext:managedObjectContext];
       
        [request setEntity:entityDesc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(mumblerUser.userId = %@) AND (friendMumblerUser.userId = %@)", mumblerUserId, friendId];
        [request setPredicate:predicate];
        NSError *error;
        NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
        
        
        for(MumblerFriendship *ct in objects){
            [managedObjectContext deleteObject:ct];
             NSLog(@"DELETE MumblerFriendship OBJECT");
        }
        
        
    }
    
    
    UserDao *userDao =[[UserDao alloc]init];
    
    User *friendUser = [userDao getUserForId:friendId];
    
    if(friendUser != nil){
        
        NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
        [request setEntity:entityDesc];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId = %@)",friendId];
        
        [request setPredicate:predicate];
        NSError *error;
        NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
        
        
        for(User *ct in objects){
            [managedObjectContext deleteObject:ct];
            NSLog(@"DELETE Mumbler Friend User OBJECT");
        }
        
        
    }
    
    NSError *error;

    if([managedObjectContext save:&error] ) {
         NSLog(@"DELETE MumblerFriendship  Mumbler Friend SAVED");
    } else {
        
        NSLog(@"DELETE MumblerFriendship  Mumbler Friend NOT SAVED");
        
        
    }
}




-(MumblerFriendship *) getFriendshipWith: (NSString *) friendMumblerUserId {
    
    NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
    NSString *mumblerUserId = [NSString stringWithFormat:@"%@", [userDefaults valueForKey:MUMBLER_USER_ID]];
    
    NSLog(@"getFriendshipWith %@, %@", friendMumblerUserId, mumblerUserId);
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext * managedObjectContext = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MumblerFriendship" inManagedObjectContext:managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(mumblerUser.userId = %@) AND (friendMumblerUser.userId = %@)", mumblerUserId, friendMumblerUserId];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    
    [request setPredicate:predicate];
    
    NSLog(@"getFriendshipWith %@, %@", friendMumblerUserId, mumblerUserId);
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"====%@====",objects);
    
    
    if ([objects count] == 1) {
        return [objects objectAtIndex:0];
    } else {
        return nil;
    }
    
    
    
}



-(MumblerFriendship *) getFriendship: (NSString *) friendshipId {
    NSLog(@"%@FriendshipId=====",friendshipId);
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MumblerFriendship" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId = %@)",friendshipId];
    
    [request setPredicate:predicate];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"%@========= object",objects);
    if ([objects count] == 1) {
        
        return [objects objectAtIndex:0];
    } else  {
        return nil;
    }
    
}


-(NSArray *) getFriendships: (NSString *) mumblerUserId {
    NSLog(@"getFriendships-------");
    
    
    //////fetch from db
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"MumblerFriendship" inManagedObjectContext:managedObjectContext];
    
    UserDao *userDao =[[UserDao alloc]init];
    User *me = [userDao getUserForId:mumblerUserId];
    
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(mumblerUser.userId = %@)",me.userId];
    
    // NSPredicate *predicate = [NSPredicate predicateWithFormat:@"friendMumblerId",mumblerUserId];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setPredicate:predicate];
    
    [request setEntity:entityDesc];
    
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"%@",objects);
    return objects;
    
}

/*-(NSArray*) getBestFriends: (NSString *) mumblerUserId {
 
 ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
 NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
 
 //
 NSFetchRequest* fetch = [NSFetchRequest fetchRequestWithEntityName:@"ChatMessage"];
 
 
 NSEntityDescription* entity = [NSEntityDescription entityForName:@"ChatMessage"
 inManagedObjectContext:managedObjectContext];
 NSAttributeDescription* statusDesc = [entity.attributesByName objectForKey:@"thread_id_str"];
 NSExpression *keyPathExpression = [NSExpression expressionForKeyPath: @"thread_id_str"]; // Does not really matter
 NSExpression *countExpression = [NSExpression expressionForFunction: @"count:"
 arguments: [NSArray arrayWithObject:keyPathExpression]];
 NSExpressionDescription *expressionDescription = [[NSExpressionDescription alloc] init];
 [expressionDescription setName: @"count"];
 [expressionDescription setExpression: countExpression];
 [expressionDescription setExpressionResultType: NSInteger32AttributeType];
 
 NSLog(@"getBestFriends 3");
 
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(message_owner_id = %@)", appDelegate.mumblerUserId];
 
 [fetch setPredicate:predicate];
 
 NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"thread_id_str.@count" ascending:NO];
 NSArray *descriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
 
 // [fetch setSortDescriptors:descriptors];
 
 [fetch setPropertiesToFetch:[NSArray arrayWithObjects:statusDesc, expressionDescription, nil]];
 [fetch setPropertiesToGroupBy:[NSArray arrayWithObject:statusDesc]];
 
 [fetch setResultType:NSDictionaryResultType];
 
 
 
 NSError* error = nil;
 NSArray *results = [managedObjectContext executeFetchRequest:fetch
 error:&error];
 
 NSMutableArray *friendships = [[NSMutableArray alloc] init];
 
 ChatMessageDao *chatMessageDao = [[ChatMessageDao alloc] init];
 NSMutableDictionary *friendsMumblerUserIds = [[NSMutableDictionary alloc] init];
 for (NSDictionary *data in results) {
 NSString *threadId = [data valueForKey:@"thread_id_str"];
 
 ChatThread *chatThread = [chatMessageDao getChatThread:threadId];
 NSString *friendMumblerUserId = chatThread.mumblerUserToBeUsedToDisplayDetailsOnThread.mumbler_user_id;
 if ([friendsMumblerUserIds valueForKey:friendMumblerUserId] == nil) {
 
 Friendship *friendship = [self getFriendshipWith:friendMumblerUserId];
 if (friendship) {
 
 if ([friendship.blocked_by_me isEqualToString:@"0"]) {
 [friendships addObject:friendship];
 [friendsMumblerUserIds setValue:friendMumblerUserId forKey:friendMumblerUserId];
 NSLog(@"thread ID %@ ", threadId);
 }
 }
 }
 }
 
 NSLog(@"LOG %@ ", results);
 
 
 return friendships;
 
 
 }*/


/*NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Image" inManagedObjectContext:managedObjectContext];
 NSFetchRequest *request = [[NSFetchRequest alloc] init];
 [request setEntity:entityDesc];
 
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(addedDate = %@)",imageDate];
 
 [request setPredicate:predicate];
 NSError *error;
 NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
 
 NSLog(@"threads object count == %lu",(unsigned long)[objects count]);
 NSLog(@"threads object count == %@",objects);
 
 if([objects count] > 0){
 NSUInteger count =[objects count];
 
 for(int i=0; i<count; i++){
 
 //[imagesStringsArray addObject:[objects objectAtIndex:i]];
 
 Image *returedImage=[objects objectAtIndex:i];
 
 NSData *data = [NSData dataFromBase64String:returedImage.imageName];
 [imagesStringsArray addObject:data];
 
 
 }
 }*/




/*-(void)addOrUpdateFriendships: (NSString *)mumblerUserId :(NSArray*) friendships
 {
 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 NSManagedObjectContext *context = [appDelegate managedObjectContext];
 
 
 NSArray *objects = [self getFriendships:mumblerUserId];
 
 
 if ([objects count]!=[friendships count])
 {
 
 // Remove all the previous friendships
 for(Friendship *friendship in objects) {
 
 [context deleteObject:friendship];
 }
 
 }
 UserDao *userDao =  [[UserDao alloc] init];
 MumblerUser *meMumblerUser = [userDao getMumblerUser:mumblerUserId];
 NSLog(@"mumbler user id in addOrUpdateFriendships %@ ", meMumblerUser.mumbler_user_id);
 for (NSDictionary *friendship in friendships) {
 
 [self addOrUpdateFriendship: meMumblerUser : friendship];
 }
 }*/

/*-(Friendship *)addOrUpdateFriendship: (MumblerUser *)mumblerUser :(NSDictionary*) friendship
 {
 NSLog(@"inside addOrUpdateFriendship-----");
 AppDelegate *appDelegate = (AppDelegate *) [UIApplication sharedApplication].delegate;
 NSManagedObjectContext *context = [appDelegate managedObjectContext];
 
 // Get the friendship object from the local db
 NSString *friendshipId = [friendship valueForKey:@"friendshipId"];
 
 Friendship *friendshipObj = [self getFriendship:friendshipId];
 
 // In both cases, we need to call the addOrUpdateMumblerUserDetails
 UserDao *userDaoObj=[[UserDao alloc]init];
 
 
 BOOL isNew = NO;
 if (friendshipObj == nil) {
 
 // Create a friendship object
 
 friendshipObj= (Friendship  *)[NSEntityDescription
 insertNewObjectForEntityForName:@"Friendship"inManagedObjectContext:context];
 isNew = YES;
 }
 
 NSString *alerts_from_me = [NSString stringWithFormat:@"%@",[friendship valueForKey:@"allowAlertsToFriend"]];
 NSString *alerts_to_me = [NSString stringWithFormat:@"%@",[friendship valueForKey:@"allowAlertsFromFriend"] ];
 NSString *blocked_by_friend = [NSString stringWithFormat:@"%@",[friendship valueForKey:@"blockedByFriend"]];
 NSString *blocked_by_me = [NSString stringWithFormat:@"%@",[friendship valueForKey:@"blockedByUser"]];
 NSString *friendship_id = [NSString stringWithFormat:@"%@",[friendship valueForKey:@"friendshipId"]] ;
 
 MumblerUser *friendMumblerUserObj = [userDaoObj addOrUpdateMumblerUserDetails:[friendship valueForKey:@"friend"]];
 
 friendshipId = [NSString stringWithFormat:@"%@",friendship_id];
 friendshipObj.alerts_from_me = alerts_from_me;
 friendshipObj.alerts_to_me=alerts_to_me;
 friendshipObj.blocked_by_friend = blocked_by_friend;
 friendshipObj.blocked_by_me=blocked_by_me;
 friendshipObj.friendship_id = friendshipId;
 friendshipObj.friendMumblerUser = friendMumblerUserObj;
 friendshipObj.mumblerUser = mumblerUser;
 
 if (isNew) {
 [appDelegate addFriend:friendMumblerUserObj.mumbler_user_id alias:friendMumblerUserObj.alias];
 }
 
 NSError *error=nil;
 if([context save:&error] ) {
 NSLog(@"addOrUpdateFriendship Saved *********");
 
 
 } else {
 
 NSLog(@"NOT Saved********");
 
 }
 
 NSLog(@"%@======print Friendship Obj=====",friendMumblerUserObj);
 return friendshipObj;
 }*/


/*-(NSArray*)getFriendshipsByBlockedByMeState: (NSString *)mumblerUserId :(int)yesNoStatus
 {
 NSLog(@"getFriendshipsByBlockedByMeState");
 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
 NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Friendship" inManagedObjectContext:managedObjectContext];
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(mumblerUser.mumbler_user_id = %@) AND (blocked_by_me = %@)", mumblerUserId,yesNoStatus];
 NSFetchRequest *request = [[NSFetchRequest alloc] init];
 NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"friendMumblerUser.alias" ascending:YES];
 NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, nil];
 [request setPredicate:predicate];
 [request setSortDescriptors:sortDescriptors];
 [request setEntity:entityDesc];
 NSError *error;
 NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
 NSLog(@"===================object=============%@",objects);
 return objects;
 
 
 }
 -(BOOL) removeFriendship: (Friendship *) friendship
 {
 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 NSManagedObjectContext *context = [appDelegate managedObjectContext];
 
 NSString *friendMumblerUserId = friendship.friendMumblerUser.mumbler_user_id;
 
 NSLog(@"removeFriendship dao %@ ", friendMumblerUserId);
 
 if (friendship != nil) {
 
 NSLog(@"Removing the friendship after finding");
 [context deleteObject:friendship];
 
 NSError *error;
 
 [context save:&error];
 
 // Removing the xmpp friendship
 [appDelegate removeFriend:friendMumblerUserId];
 
 return YES;
 
 } else {
 NSLog(@"Friendship not found to remove");
 return NO;
 }
 }
 -(BOOL) changeFriendshipStatus: (NSString *) friendMumblerUserId :(NSString*) blockUnblockStatus :(BOOL)isBlocked_By_Me
 {
 NSLog(@"changeFriendshipStatus-----------");
 Friendship *friendship = [self getFriendshipWith:friendMumblerUserId];
 
 if (friendship != nil) {
 NSLog(@"friendship not null %@, %@", friendship.mumblerUser.mumbler_user_id, friendship.friendMumblerUser.mumbler_user_id);
 
 if (isBlocked_By_Me)
 {
 
 friendship.blocked_by_me=blockUnblockStatus;
 }
 else
 {
 
 friendship.blocked_by_friend=blockUnblockStatus;
 }
 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
 
 NSError *error;
 
 [managedObjectContext save:&error];
 
 return YES;
 } else {
 NSLog(@"friendship  null");
 
 return NO;
 }
 }
 
 -(BOOL) changeAlertsStatus: (NSString *) friendMumblerUserId :(NSString*) changeAlertStatus
 {
 Friendship *friendship = [self getFriendshipWith:friendMumblerUserId];
 
 if (friendship != nil) {
 
 friendship.alerts_to_me=changeAlertStatus;
 
 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
 
 NSError *error;
 
 if(![managedObjectContext save:&error]){
 
 NSLog(@"alerts------%@",error);
 
 }
 
 return YES;
 } else {
 return NO;
 }
 
 }
 
 -(Friendship *) getFriendshipWith: (NSString *) friendMumblerUserId {
 
 NSUserDefaults *userDefaults = NSUserDefaults.standardUserDefaults;
 NSString *mumblerUserId = [NSString stringWithFormat:@"%@", [userDefaults valueForKey:@"mumbler_user_id"]];
 
 NSLog(@"getFriendshipWith %@, %@", friendMumblerUserId, mumblerUserId);
 
 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 NSManagedObjectContext * managedObjectContext = [appDelegate managedObjectContext];
 
 NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"Friendship" inManagedObjectContext:managedObjectContext];
 NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(mumblerUser.mumbler_user_id = %@) AND (friendMumblerUser.mumbler_user_id = %@)", mumblerUserId, friendMumblerUserId];
 NSFetchRequest *request = [[NSFetchRequest alloc] init];
 
 [request setPredicate:predicate];
 
 NSLog(@"getFriendshipWith %@, %@", friendMumblerUserId, mumblerUserId);
 [request setEntity:entityDesc];
 NSError *error;
 NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
 NSLog(@"====%@====",objects);
 
 NSLog(@"getFriendshipWith %@, %@ %i", friendMumblerUserId, mumblerUserId, [objects count]);
 if ([objects count] == 1) {
 return [objects objectAtIndex:0];
 } else {
 return nil;
 }
 
 
 
 }
 -(BOOL) addNewContact: (NSDictionary *) mumblerUser :(NSString *) mumblerUserId :(NSString *)from
 {
 // Check whether the mumbler user forwarded is already a friend
 
 //mumblerUserSetting
 NSString *friendMumblerUserId=[mumblerUser valueForKey:@"mumblerUserId"];
 Friendship *forwardedFriendship = [self getFriendshipWith:friendMumblerUserId];
 
 
 // Not a friend
 if (forwardedFriendship==nil) {
 // Check the user who sent the details is a friend
 Friendship *fromFriendship = [self getFriendshipWith:from];
 if (fromFriendship) {
 // Yes the user is a friend
 // Save the details of the forwarded contact to the ContactReceived table
 [self addForwadedContact:mumblerUser :mumblerUserId];
 
 }
 // No the user is not a friend
 else
 {
 // Check my who can send me messages value
 NSUserDefaults *userDefalt=NSUserDefaults.standardUserDefaults;
 NSData *userSettingData = [userDefalt valueForKey:@"mumbler_user_setting_json"];
 NSDictionary *settingDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:userSettingData];
 NSString *whoCanSendMeMessage=[settingDictionary valueForKey:@"whoCanSendMeMessage"];
 // If everyone,
 
 if ([whoCanSendMeMessage isEqualToString:@"EVERYONE"]) {
 SearchFriendsViewController *objSearchViewController=[[SearchFriendsViewController alloc]init];
 [objSearchViewController addMumblerUserAsAFriend:from];
 [self addForwadedContact:mumblerUser :mumblerUserId];
 // Create friendship between me and from
 // Save the details of the forwarded contact to the contact received table
 }
 else
 {
 // If friends only, don't do anything
 }
 }
 
 }
 
 else
 {
 // The user already have this friend
 }
 
 
 return YES;
 }
 -(ContactReceived *)addForwadedContact :(NSDictionary *) mumblerUser :(NSString *)mumblerUserId
 {
 NSLog(@"addForwadedContact");
 ContactReceived *contactReceivedObj;
 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 NSManagedObjectContext *context = [appDelegate managedObjectContext];
 NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ContactReceived" inManagedObjectContext:context];
 NSFetchRequest *request = [[NSFetchRequest alloc] init];
 UserDao *objUser=[[UserDao alloc]init];
 MumblerUser *objMumbler=[objUser getMumblerUser:mumblerUserId];
 
 [request setEntity:entityDesc];
 NSError *error;
 NSArray *objects = [context executeFetchRequest:request error:&error];
 NSLog(@"===================object=============%@",objects);
 
 NSString *alias = [mumblerUser valueForKey:@"alias"];
 NSNumber *date_of_birth = [mumblerUser valueForKey:@"date_of_birth"] ;
 NSString *device_type = [mumblerUser valueForKey:@"device_type"];
 NSString *facebook_id = [mumblerUser valueForKey:@"facebookId"];
 NSNumber *join_date = [mumblerUser valueForKey:@"join_date"];
 NSString *mumbler_user_id = [NSString stringWithFormat:@"%@", [mumblerUser valueForKey:@"mumblerUserId"] ];
 NSString *my_status = [mumblerUser valueForKey:@"my_status"];
 NSString *phonenumber = [mumblerUser valueForKey:@"phonenumber"] ;
 NSString *pushtoken = [mumblerUser valueForKey:@"pushtoken"];
 NSString *profileimageurl=[mumblerUser valueForKey:@"profile_image_url"];
 NSString *device_Id=[mumblerUser valueForKey:@"device_id"];
 NSString *online_status=[mumblerUser valueForKey:@"online_status"];
 NSTimeInterval dateOfBirthSeconds = [date_of_birth doubleValue] / 1000;
 NSDate *convertDateOfBirth = [NSDate dateWithTimeIntervalSince1970:dateOfBirthSeconds];
 NSTimeInterval joinDate = [join_date doubleValue] / 1000;
 NSDate *convertJoinDate = [NSDate dateWithTimeIntervalSince1970:joinDate];
 
 contactReceivedObj= (ContactReceived  *)[NSEntityDescription
 insertNewObjectForEntityForName:@"ContactReceived"inManagedObjectContext:context];
 contactReceivedObj.alias = alias;
 contactReceivedObj.date_of_birth=convertDateOfBirth;
 contactReceivedObj.device_type = device_type;
 if ([facebook_id isKindOfClass:[NSNull class]]) {
 facebook_id=@"";
 contactReceivedObj.facebook_id=facebook_id;
 }
 else
 {
 contactReceivedObj.facebook_id=facebook_id;
 }
 if ([pushtoken isKindOfClass:[NSNull class]]) {
 pushtoken=@"";
 contactReceivedObj.pushtoken = pushtoken;
 }
 else
 {
 contactReceivedObj.pushtoken = pushtoken;
 }
 contactReceivedObj.join_date = convertJoinDate;
 contactReceivedObj.mumbler_user_id=mumbler_user_id;
 contactReceivedObj.my_status = my_status;
 contactReceivedObj.phonenumber=phonenumber;
 contactReceivedObj.device_id = device_Id;
 contactReceivedObj.online_status=online_status;
 
 
 if ([profileimageurl isKindOfClass:[NSNull class]]) {
 profileimageurl=@"";
 contactReceivedObj.profile_image_url=profileimageurl;
 }
 else
 {
 contactReceivedObj.profile_image_url=profileimageurl;
 }
 NSLog(@"insert Value====%@",contactReceivedObj);
 
 if([context save:&error] ) {
 NSLog(@"Saved");
 } else {
 
 NSLog(@"NOT Saved");
 
 }
 
 contactReceivedObj.mumblerUser=objMumbler;
 NSLog(@"======%@======",contactReceivedObj);
 return contactReceivedObj;
 }
 
 -(NSArray*)getFriendsWhoWantsAlertsFromMe: (NSString *) mumblerUserId{
 //kanishka
 NSLog(@"getFriendsWhoWantsAlertsFromMe---");
 
 AppDelegate *appDelegate = (AppDelegate*)[[UIApplication sharedApplication] delegate];
 NSFetchRequest *fetchRequest=[[NSFetchRequest alloc] init];
 NSManagedObjectContext *context=[appDelegate managedObjectContext];
 NSEntityDescription *description=[NSEntityDescription entityForName:@"Friendship" inManagedObjectContext:context];
 [fetchRequest setEntity:description];
 NSPredicate *predictate=[NSPredicate predicateWithFormat:@"mumblerUser.mumbler_user_id = %@ AND alerts_from_me = %@",mumblerUserId,@"1"];
 [fetchRequest setPredicate:predictate];
 NSError *error;
 NSArray *results=[context executeFetchRequest:fetchRequest error:&error];
 
 NSLog(@"getFriendsWhoWantsAlertsFromMe---%@",results);
 
 for (Friendship *f in results) {
 
 NSLog(@"getFriendsWhoWantsAlertsFromMe----%@",f.friendMumblerUser.alias);
 NSLog(@"getFriendsWhoWantsAlertsFromMe----%@",f.friendMumblerUser.online_status);
 }
 
 if ([results count]>0) {
 
 return results;
 
 }else{
 
 return 0;
 
 }
 
 }*/
@end
