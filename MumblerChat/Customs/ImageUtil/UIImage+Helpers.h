//
//  UIImage+Helpers.h
//  MumblerChat
//
//  Created by Ransika De Silva on 3/5/14.
//  Copyright (c) 2014 AppDesignVault. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UIImage (Helpers)

+ (void) loadFromURL: (NSURL*) url callback:(void (^)(UIImage *image))callback;

@end
