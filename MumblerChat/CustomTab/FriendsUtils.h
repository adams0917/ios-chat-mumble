//
//  FriendsUtils.h
//  MumblerChat
//
//  Created by Alex Muscar on 04/01/2015.
//
//

#import <Foundation/Foundation.h>
#import "AFHTTPRequestOperationManager.h"

@interface FriendsUtils : NSObject

+ (void)getFbFriendsMumblerUserIdsWithSuccess:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                                      failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;
+ (void)getMumblerUserObjectsForFBFriends:(NSMutableArray *)fbFriends;

@end
