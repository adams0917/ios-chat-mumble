//
//  Utils.m
//  mapper
//
//  Created by Tope Abayomi on 15/08/2013.
//
//

#import "Utils.h"

@implementation Utils

+(BOOL)isVersion6AndBelow {
    
    return floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1;
}

+(UIImage*)createSolidColorImageWithColor:(UIColor*)color andSize:(CGSize)size{
    
    CGFloat scale = [[UIScreen mainScreen] scale];
    UIGraphicsBeginImageContextWithOptions(size, NO, scale);
    
    CGContextRef currentContext = UIGraphicsGetCurrentContext();
    CGRect fillRect = CGRectMake(0,0,size.width,size.height);
    CGContextSetFillColorWithColor(currentContext, color.CGColor);
    CGContextFillRect(currentContext, fillRect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
