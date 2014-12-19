//
//  ContactReceived.h
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 4/1/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class MumblerUser;

@interface ContactReceived : NSManagedObject

@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSDate * date_of_birth;
@property (nonatomic, retain) NSString * device_id;
@property (nonatomic, retain) NSString * device_type;
@property (nonatomic, retain) NSString * facebook_id;
@property (nonatomic, retain) NSString * forwarded_to;
@property (nonatomic, retain) NSDate * join_date;
@property (nonatomic, retain) NSString * mumbler_user_id;
@property (nonatomic, retain) NSString * my_status;
@property (nonatomic, retain) NSString * online_status;
@property (nonatomic, retain) NSString * phonenumber;
@property (nonatomic, retain) NSString * profile_image_url;
@property (nonatomic, retain) NSString * pushtoken;
@property (nonatomic, retain) NSString * recieved_from;
@property (nonatomic, retain) MumblerUser *mumblerUser;

@end
