//
//  Favorite.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Favorite : NSManagedObject

@property (nonatomic, retain) NSString * messageId;
@property (nonatomic, retain) NSNumber * type;
@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSString * userId;
@property (nonatomic, retain) NSNumber * time;

@end
