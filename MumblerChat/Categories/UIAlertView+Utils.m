//
//  NSAlertView+utils.m
//  MumblerChat
//
//  Created by Alex Muscar on 19/12/2014.
//
//

#import "UIAlertView+Utils.h"

@implementation UIAlertView (Utils)

+(void) showWithTitle:(NSString *)title
              message:(NSString *)message
             delegate:(id<UIAlertViewDelegate>)delegate
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    [[[UIAlertView alloc] initWithTitle:title
                                message:message
                               delegate:delegate
                      cancelButtonTitle:cancelButtonTitle
                      otherButtonTitles:otherButtonTitles, nil]
     show];
}

+(void) showWithTitle:(NSString *)title
              message:(NSString *)message
             delegate:(id<UIAlertViewDelegate>)delegate
    cancelButtonTitle:(NSString *)cancelButtonTitle
{
    [UIAlertView showWithTitle:title
                       message:message
                      delegate:delegate
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:nil];
}

+(void) showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle
{
    [UIAlertView showWithTitle:title
                       message:message
                      delegate:nil
             cancelButtonTitle:cancelButtonTitle
             otherButtonTitles:nil];
}

+(void) showWithError:(NSError *)error
{
    [UIAlertView showWithTitle:@"Error"
                       message:error.localizedDescription
                      delegate:nil
             cancelButtonTitle:@"Ok"
             otherButtonTitles:nil];
}

@end
