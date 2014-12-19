//
//  ChatUtil.h
//  MumblerChat
//
//  Created by Ransika De Silva on 9/18/14.
//
//

#import <Foundation/Foundation.h>

@interface ChatUtil : NSObject
+(NSString *)getTextType:(NSString *) textMessage;
+(NSString *)getTimeInMiliSeconds:(NSDate *) date;
+(NSString *)getDate :(NSString *) date inFormat:(NSString *) format;
@end
