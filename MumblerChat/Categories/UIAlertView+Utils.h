//
//  NSAlertView+utils.h
//  MumblerChat
//
//  Created by Alex Muscar on 19/12/2014.
//
//

#import <Foundation/Foundation.h>

@interface UIAlertView (Utils)

+(void) showWithError:(NSError *)error;

+(void) showWithTitle:(NSString *)title
              message:(NSString *)message
    cancelButtonTitle:(NSString *)cancelButtonTitle;

+(void) showWithTitle:(NSString *)title
              message:(NSString *)message
             delegate:(id<UIAlertViewDelegate>)delegate
    cancelButtonTitle:(NSString *)cancelButtonTitle;

+(void) showWithTitle:(NSString *)title
              message:(NSString *)message
             delegate:(id<UIAlertViewDelegate>)delegate
    cancelButtonTitle:(NSString *)cancelButtonTitle
    otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
