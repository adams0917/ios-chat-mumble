//
//  Smiley.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Smiley : NSManagedObject

@property (nonatomic, retain) NSNumber * smileyId;
@property (nonatomic, retain) NSData * smileyIconByte;
@property (nonatomic, retain) NSString * smileyKey;

@end
