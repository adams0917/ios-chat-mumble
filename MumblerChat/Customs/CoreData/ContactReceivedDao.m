//
//  ContactReceivedDao.m
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 3/13/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import "ContactReceivedDao.h"
#import "ASAppDelegate.h"
#import "ContactReceived.h"
@implementation ContactReceivedDao

-(NSArray *) getPendingContactForwards {
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"ContactReceived" inManagedObjectContext:managedObjectContext];
    //NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(mumblerUser.mumbler_user_id = %@)",mumblerUserId];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    //[request setPredicate:predicate];
    [request setEntity:entityDesc];
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    NSLog(@"%@",objects);
    return objects;

}
-(BOOL) removePendingContactFriendship: (NSArray *) contactReceivedArray
{

    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];

    NSManagedObjectContext *context = [appDelegate managedObjectContext];
    
    for (ContactReceived *contactReceived in contactReceivedArray) {
        
        [context deleteObject:contactReceived];

    }
    return YES;
}

@end
