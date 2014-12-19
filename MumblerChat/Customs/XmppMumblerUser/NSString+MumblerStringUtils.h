//
//  NSString+MumblerStringUtils.h
//  Mumbler
//
//  Created by Ransika De Silva on 1/3/14.
//  Copyright (c) 2014 Visni (Pvt) Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MumblerStringUtils)

+(NSString *)decodeString:(NSString *)string;
+(NSString *)encodeString:(NSString *)string;
+(NSDictionary *)getJSONDictionaryFromString:(NSString *)string;
+(NSString *)trimString:(NSString *)string;

@end
