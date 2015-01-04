//
//  FriendsUtils.m
//  MumblerChat
//
//  Created by Alex Muscar on 04/01/2015.
//
//

#import "FriendsUtils.h"
#import "ASAppDelegate.h"
#import "FriendDao.h"

#import "NSObject+SBJson.h"

#import "Constants.h"

@implementation FriendsUtils

+ (void)getFbFriendsMumblerUserIdsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    ASAppDelegate *appDelegate = (ASAppDelegate *) UIApplication.sharedApplication.delegate;
    NSDictionary *fbIdsNSDic = [NSDictionary dictionaryWithObjectsAndKeys:appDelegate.addedFriendsInFaceBook, @"fbIds", nil];
    NSLog(@"fb friends to server -=== %@", [fbIdsNSDic JSONRepresentation]);
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    NSDictionary *parameters = @{@"json":[fbIdsNSDic JSONRepresentation]};
    NSString *url = [NSString stringWithFormat:@"%@%@", BASE_URL, @"mumblerUser/getMumblerUsersForFbIds.htm"];
    
    [manager GET:url
      parameters:parameters
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             success(operation, responseObject);
             DDLogVerbose(@"%@: %@: getMumblerUsersForFbIds responseObject=%@ ", THIS_FILE, THIS_METHOD,responseObject);
             
             NSString *status = [responseObject valueForKey:@"status"];
             
             if([status isEqualToString:@"success"]) {
                 NSDictionary *data = [responseObject valueForKey:@"data"];
                 NSMutableArray *mumblerUsersArray=[data valueForKey:@"mumbler_users"];
                 
                 DDLogVerbose(@"%@: %@: mumblerUsersArray =%@", THIS_FILE, THIS_METHOD,mumblerUsersArray);
                 
                 if (mumblerUsersArray.count > 0) {
                     [self getMumblerUserObjectsForFBFriends:mumblerUsersArray];
                 } else {
                     DDLogVerbose(@"%@: %@: EmptyArray with FBID", THIS_FILE, THIS_METHOD);
                     if(appDelegate.friendsToBeAddedDictionary.count > 0){
                         [NSUserDefaults.standardUserDefaults setBool:true forKey:IS_FRIENDS_ADDED];
                         [NSUserDefaults.standardUserDefaults synchronize];
                         [NSUserDefaults.standardUserDefaults setBool:true forKey:IS_FRIENDS_ADDED];
                         [NSUserDefaults.standardUserDefaults synchronize];
                         
                         double delayInSeconds = 0.25;
                         dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                         dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                             // code to be executed on the main queue after delay
                             [self updateAddedFriends];
                         });
                     }
                 }
             }
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             DDLogVerbose(@"%@: %@: Error =%@", THIS_FILE, THIS_METHOD,error);
             failure(operation, error);
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Alert!"
                                                             message:[error localizedDescription]
                                                            delegate:self
                                                   cancelButtonTitle:@"OK"
                                                   otherButtonTitles:nil];
             [alert show];
         }];
}

+ (void)getMumblerUserObjectsForFBFriends:(NSMutableArray *)fbFriends
{
    ASAppDelegate *appDelegate = (ASAppDelegate *) UIApplication.sharedApplication.delegate;
    for (NSDictionary*friend in  fbFriends) {
        NSLog(@"getMumblerUserObjectsForFBFriends fbFriends");
        
        if ([friend objectForKey:@"mumblerUserId"] != nil && [friend objectForKey:@"alias"] != nil ) {
            NSString * userId=[friend objectForKey:@"mumblerUserId"];
            
            //added friends
            if([appDelegate.friendsToBeAddedDictionary objectForKey:userId] == nil){
                NSLog(@"ADDING FB FRIEND OBJECT%@",friend);
                [appDelegate.friendsToBeAddedDictionary setObject:friend forKey:userId];
            }
        } else {
            NSLog(@"FRIEND DATA IS NOT THERE");
        }
    }
    
    //Calling Friend Dao
    if (appDelegate.friendsToBeAddedDictionary.count > 0) {
        [NSUserDefaults.standardUserDefaults setBool:true forKey:IS_FRIENDS_ADDED];
        [NSUserDefaults.standardUserDefaults synchronize];
        
        double delayInSeconds = 0.25;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            // code to be executed on the main queue after delay
            [self updateAddedFriends];
        });
    }
}

+ (void)updateAddedFriends
{
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    FriendDao *objFriendsDao=[[FriendDao alloc]init];
    [objFriendsDao addFriendships];
    [self addFriendsToEjabberedServer];
    DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    
}

+ (void)addFriendsToEjabberedServer
{
    ASAppDelegate *appDelegate = (ASAppDelegate *) UIApplication.sharedApplication.delegate;
    DDLogVerbose(@"%@: %@: START ", THIS_FILE, THIS_METHOD);
    
    for (id key in appDelegate.friendsToBeAddedDictionary) {
        id value = [appDelegate.friendsToBeAddedDictionary objectForKey:key];
        NSString *selectedUserId =[NSString stringWithFormat:@"%@",[value valueForKey:@"mumblerUserId"]];
        NSString *selectedUseName =[NSString stringWithFormat:@"%@",[value valueForKey:@"alias"]];
        
        selectedUserId=[NSString stringWithFormat:@"%@%@",selectedUserId,MUMBLER_CHAT_EJJABBERD_SERVER_NAME];
        
        XMPPJID *newBuddy = [XMPPJID jidWithString:selectedUserId];
        [appDelegate.xmppRoster addUser:newBuddy withNickname:selectedUseName];
        
        DDLogVerbose(@"%@: %@: END ", THIS_FILE, THIS_METHOD);
    }
}

@end
