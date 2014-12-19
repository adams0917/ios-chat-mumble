//
//  PostMention.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostMention : NSManagedObject

@property (nonatomic, retain) NSNumber * mentionId;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * userId;

@end
