//
//  PostAlbum.h
//  Zobi
//
//  Created by Ransika De Silva on 7/11/14.
//  Copyright (c) 2014 Adnan Siddiq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface PostAlbum : NSManagedObject

@property (nonatomic, retain) NSString * albumId;
@property (nonatomic, retain) NSString * userId;

@end
