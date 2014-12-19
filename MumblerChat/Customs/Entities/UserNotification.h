//
//  UserNotification.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserNotification : NSManagedObject

@property (nonatomic, retain) NSNumber * userNotificationId;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * messageAlertStatus;
@property (nonatomic, retain) NSNumber * soundAlertStatus;
@property (nonatomic, retain) NSNumber * vibrateStatus;
@property (nonatomic, retain) NSString * notificationSound;
@property (nonatomic, retain) NSString * notificationTimingStart;
@property (nonatomic, retain) NSString * notificationTimingEnd;
@property (nonatomic, retain) NSNumber * otherFutureAlertStatus;

@end
