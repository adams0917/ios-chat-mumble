
#import "UserDao.h"
#import "ASAppDelegate.h"
#include "UIImage+Helpers.h"
#import "NSData+Base64.h"

@implementation UserDao

-(User *) updateUserByVcard :(NSString *) userId : (NSString *) imageByteString : (NSString *) name{
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
  User *user = [self getUserForId:userId];
    if(user){
        user.profileImageBytes=imageByteString;
        user.name=name;
    }
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
        NSLog(@"updateUserByVcard ---------------- saved");
    } else {
        
        NSLog(@"updateUserByVcard User --------- not saved");
    }

    return user;
}

-(User *) createUpdateUser :(NSDictionary *) userJson{
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    NSString *userId = [NSString stringWithFormat:@"%@",[userJson valueForKey:@"mumblerUserId"]];
    NSString *name= [userJson valueForKey:@"alias"];
    NSString *mobile= [NSString stringWithFormat:@"%@",[userJson valueForKey:@"phoneNumber"]];
    
    User *user = [self getUserForId:userId];
    if(user!=nil){
        
        
    } else {
        user = (User  *)[NSEntityDescription
                         insertNewObjectForEntityForName:@"User"
                         inManagedObjectContext:managedObjectContext];
        
        
        
    }
    user.userId = userId;
    user.name=name;
    user.mobile=mobile;
    user.alertsStatus=@"1";
    user.saveOutgoingMediaStatus=@"1";
    user.whoCanSendMeMessages=@"EVERYONE";
    user.userProfileStatus=@"Available";
    user.timeGivenToRenspond=@"21";

    
    NSError *error = nil;
    if([managedObjectContext save:&error] ) {
        NSLog(@"createUpdateUser ---------------- saved");
    } else {
        
        NSLog(@"createUpdateUser User --------- not saved");
    }
    
    return user;
    

}
    
-(BOOL) updateUserOnlineStatus: (NSString*) userId :(NSString *)onlineStatus :(NSString *)myStatus{
        NSLog(@"updateUserOnlineStatus to changing");
        
        ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
        NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
        
        User *user=[self getUserForId:userId];
        if(user!=nil){
            user.onlineStatus=onlineStatus;
            if(myStatus!=nil){
                user.userProfileStatus=myStatus;
                user.onlineStatus=onlineStatus;

            }
        }else{
            NSLog(@"updateUserOnlineStatus to creating new user;;;;;; with id==%@",userId);
            
            User *newUser=[self createUserContact :userId : nil : nil : nil : nil :nil];
            newUser.onlineStatus=onlineStatus;
            if(myStatus!=nil){
               // newUser.myStatus=myStatus;
                 user.onlineStatus=onlineStatus;
            }
            
        }
        
        NSError *error = nil;
        if([managedObjectContext save:&error] ) {
            NSLog(@"User updateUserOnlineStatus---------------- change");
        } else {
            
            NSLog(@"User updateUserOnlineStatus--------- not change");
        }
        
        
        return true;
    }


-(User *) createUserContact :(NSString *) userId : (NSString *) chatId : (NSString *) name : (NSString *) mobille : (NSString *) contactType : (NSString *) profileImageUrl {
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = [appDelegate managedObjectContext];
    
    User *user = nil;
    user=[self getUserForId:userId];
    if(user!=nil){
        
        user.userId = userId;
        user.name=name;
        user.mobile=mobille;
        user.chatId=chatId;
        user.contactType=contactType;
        user.profileImageUrl=profileImageUrl;
        
        if(profileImageUrl!=nil){
            NSURL *tempProfileImageUrl = [NSURL URLWithString:profileImageUrl];
            
            [UIImage loadFromURL:tempProfileImageUrl callback:^(UIImage *image) {
                
                if (image != nil) {
                    NSLog(@"createUserContact image ===  == =%@",image);
                    NSData *imageData =UIImageJPEGRepresentation(image, 90);
                    NSString *imagebase64String = [imageData base64EncodedString];
                    user.profileImageBytes=imagebase64String;
                    
                }
                
            }];
            
        }
        
        
        NSError *error = nil;
        if([managedObjectContext save:&error] ) {
            NSLog(@"UsercreateUserContact ---------------- saved");
        } else {
            
            NSLog(@"createUserContact User --------- not saved");
        }
        
        return user;
        
    }else{//create newUser
        User *newUser = (User  *)[NSEntityDescription
                                  insertNewObjectForEntityForName:@"User"
                                  inManagedObjectContext:managedObjectContext];
        
        newUser.userId = userId;
        newUser.name=name;
        newUser.mobile=mobille;
        newUser.chatId=chatId;
        newUser.contactType=contactType;
        user.profileImageUrl=profileImageUrl;
        
        if(profileImageUrl!=nil){
            NSURL *tempProfileImageUrl = [NSURL URLWithString:profileImageUrl];
            
            [UIImage loadFromURL:tempProfileImageUrl callback:^(UIImage *image) {
                
                if (image != nil) {
                    NSLog(@"createUserContact image ===  == =%@",image);
                    NSData *imageData =UIImageJPEGRepresentation(image, 90);
                    NSString *imagebase64String = [imageData base64EncodedString];
                    user.profileImageBytes=imagebase64String;
                    
                    NSError *error = nil;
                    if([managedObjectContext save:&error] ) {
                        NSLog(@"User createUserContact---------------- saved");
                    } else {
                        
                        NSLog(@"User createUserContact--------- not saved");
                    }
                    
                    
                }
                
            }];
            
        }else{
            
            NSError *error = nil;
            if([managedObjectContext save:&error] ) {
                NSLog(@"User createUserContact---------------- saved");
            } else {
                
                NSLog(@"User createUserContact--------- not saved");
            }
        }
        return newUser;
        
    }
    
}
-(User *) getUserForId : (NSString *)userId{
    
    NSLog(@"createUserContact====get User-------");
    
    ASAppDelegate *appDelegate = (ASAppDelegate*)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *managedObjectContext = nil;
    
    managedObjectContext = [appDelegate managedObjectContext];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:@"User" inManagedObjectContext:managedObjectContext];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(userId = %@)",userId];
    
    [request setPredicate:predicate];
    NSError *error;
    NSArray *objects = [managedObjectContext executeFetchRequest:request error:&error];
    
    NSLog(@"user object count == %lu",(unsigned long)[objects count]);
    
    if([objects count]>0){
        
        if ([objects count] == 1) {
            NSLog(@"Size 1 ");
            
            User *c = [objects objectAtIndex:0];
            
            return c;
            
        } else {
            return nil;
        }
    }else{
        return nil;
    }
    
}



@end