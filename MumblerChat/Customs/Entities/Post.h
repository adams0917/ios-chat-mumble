//
//  Post.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Post : NSManagedObject

@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSString * postText;
@property (nonatomic, retain) NSString * postBy;
@property (nonatomic, retain) NSString * albumId;
@property (nonatomic, retain) NSDate * postedDateTime;
@property (nonatomic, retain) NSString * postedLocation;
@property (nonatomic, retain) NSNumber * privacyStatus;
@property (nonatomic, retain) NSNumber * postStatus;
@property (nonatomic, retain) NSNumber * hasSent;

@end
