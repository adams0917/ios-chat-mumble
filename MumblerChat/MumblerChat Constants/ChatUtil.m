//
//  ChatUtil.m
//  MumblerChat
//
//  Created by Ransika De Silva on 9/18/14.
//
//

#import "ChatUtil.h"
#import "Constants.h"

@implementation ChatUtil
+(NSString *)getTextType:(NSString *) textMessage{
    
    NSString *textType;
    
    if ([textMessage rangeOfString:@"?"].location == NSNotFound) {
        textType=TEXT_TYPE_STATEMENT;
    } else {
        textType=TEXT_TYPE_QUESTION;
    }
    return textType;
}

+(NSString *)getTimeInMiliSeconds:(NSDate *) date{
    
    NSTimeInterval  timeInMillis = [date timeIntervalSince1970] * 1000;
    long long integerMilliSeconds = timeInMillis;
    NSString *timeInMillisStr = [NSString stringWithFormat:@"%lld", integerMilliSeconds];
    
    return timeInMillisStr;
    
}


+(NSString *)getDate :(NSString *) date inFormat:(NSString *) format{
    
    long long timeInSeconds = [date longLongValue]/1000;
    NSDate *tr = [NSDate dateWithTimeIntervalSince1970:timeInSeconds];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSString *messageDate= [formatter stringFromDate:tr];
    return messageDate;
    
}



@end
