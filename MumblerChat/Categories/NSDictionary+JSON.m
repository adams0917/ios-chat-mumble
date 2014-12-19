//
//  NSDictionary+JSON.m
//  MumblerChat
//
//  Created by Alex Muscar on 19/12/2014.
//
//

#import "NSDictionary+JSON.h"

@implementation NSDictionary (JSON)

-(NSString*) jsonStringWithPrettyPrint:(BOOL) prettyPrint
{
    NSError *error;
    NSJSONWritingOptions writingOptions = (NSJSONWritingOptions) (prettyPrint ? NSJSONWritingPrettyPrinted : 0);
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:writingOptions
                                                         error:&error];
    
    if (! jsonData) {
        NSLog(@"bv_jsonStringWithPrettyPrint: error: %@", error.localizedDescription);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}

@end
