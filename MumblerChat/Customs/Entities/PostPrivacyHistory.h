//
//  PostPrivacyHistory.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostPrivacyHistory : NSManagedObject

@property (nonatomic, retain) NSNumber * privacyHistoryId;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSNumber * privacyStatus;
@property (nonatomic, retain) NSDate * changedDate;

@end
