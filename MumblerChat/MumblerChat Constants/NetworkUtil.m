//
//  NetworkUtil.m
//  MumblerChat
//
//  Created by Ransika De Silva on 9/12/14.
//
//

#import "NetworkUtil.h"
#import "Reachability.h"
#import "Constants.h"

@implementation NetworkUtil
+(NSString *)checkInternetConnectivity{
    
    NSString *connectivityAvailable;
    Reachability *networkReachability = [Reachability reachabilityForInternetConnection];
    NetworkStatus networkStatus = [networkReachability currentReachabilityStatus];
    if (networkStatus == NotReachable) {
        NSLog(@"There IS NO internet connection");
        connectivityAvailable = INTERNET_CONNECTION_NOT_AVAILABLE;
    } else {
        NSLog(@"There IS internet connection");
        connectivityAvailable = INTERNET_CONNECTION_AVAILABLE;
    }
    
    return connectivityAvailable;
}

@end
