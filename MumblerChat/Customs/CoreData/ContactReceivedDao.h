//
//  ContactReceivedDao.h
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 3/13/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ContactReceived.h"
@interface ContactReceivedDao : NSObject
-(NSArray *) getPendingContactForwards;

-(BOOL) removePendingContactFriendship: (NSArray *) friendships;
@end
