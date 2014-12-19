//
//  PostComment.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostComment : NSManagedObject

@property (nonatomic, retain) NSNumber * commentId;
@property (nonatomic, retain) NSString * postId;
@property (nonatomic, retain) NSDate * commentDateTime;
@property (nonatomic, retain) NSString * commentedText;
@property (nonatomic, retain) NSString * commentedBy;

@end
