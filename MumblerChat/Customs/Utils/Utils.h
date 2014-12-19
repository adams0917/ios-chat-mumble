//
//  Utils.h
//  mapper
//
//  Created by Tope Abayomi on 15/08/2013.
//
//

#import <Foundation/Foundation.h>

@interface Utils : NSObject

+(BOOL)isVersion6AndBelow;

+(UIImage*)createSolidColorImageWithColor:(UIColor*)color andSize:(CGSize)size;
@end
