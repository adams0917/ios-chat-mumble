//
//  PostShareWith.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostShareWith : NSManagedObject

@property (nonatomic, retain) NSNumber * shareWithId;
@property (nonatomic, retain) NSString * groupId;
@property (nonatomic, retain) NSString * postId;

@end
