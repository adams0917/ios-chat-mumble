//
//  NSString+MumblerStringUtils.m
//  Mumbler
//
//  Created by Ransika De Silva on 1/3/14.
//  Copyright (c) 2014 Visni (Pvt) Ltd. All rights reserved.
//

#import "NSString+MumblerStringUtils.h"

@implementation NSString (MumblerStringUtils)

#pragma mark - Encoding / UnEncoding

+ (NSString *)decodeString:(NSString *)string
{
    NSString *result = [string stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    
    CFStringRef s = CFURLCreateStringByReplacingPercentEscapesUsingEncoding(NULL,(CFStringRef)result,(CFStringRef)@"",kCFStringEncodingUTF8 );
    NSString * unEncodedString = [NSString stringWithFormat:@"%@",(__bridge_transfer NSString *)s];
    //CFRelease(s);
    NSString *last = [unEncodedString stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    NSString *crRemovedText = [last stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    return crRemovedText;
}

+ (NSString *)encodeString:(NSString *)string
{
    CFStringRef s = CFURLCreateStringByAddingPercentEscapes(NULL,(CFStringRef)string,NULL,(CFStringRef)@"!*’();:@&=+$,/?%#[]",kCFStringEncodingUTF8 );
    NSString * encodedString = [NSString stringWithFormat:@"%@",(__bridge_transfer NSString *)s];
    //CFRelease(s);
    return encodedString;
}

#pragma mark - JSON String to Dictionary

+(NSDictionary *)getJSONDictionaryFromString:(NSString *)string
{
    NSData *jsonData = [string dataUsingEncoding:NSUTF8StringEncoding];
    NSError *e = nil;
    return [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&e];
}

#pragma mark - WhiteSpaces Trim

+ (NSString *)trimString:(NSString *)string
{
    return [[NSString stringWithFormat:@"%@",string] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
}

@end
