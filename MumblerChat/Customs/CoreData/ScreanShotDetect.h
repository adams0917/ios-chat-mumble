//
//  ScreanShotDetect.h
//  MumblerChat
//
//  Created by Tharaka Dushmantha on 4/1/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ScreanShotDetect : NSManagedObject

@property (nonatomic, retain) NSString * threadId;
@property (nonatomic, retain) NSString * mumblerUserId;
@property (nonatomic, retain) NSString * takenBy;
@property (nonatomic, retain) NSDate * takenDate;

@end
