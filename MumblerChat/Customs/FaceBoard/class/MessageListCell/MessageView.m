//
//  MessageView.m
//  FaceBoardDome
//
//  Created by kangle1208 on 13-12-12.
//  Copyright (c) 2013年 Blue. All rights reserved.
//

#import "MessageView.h"

#import "FaceBoard.h"


#define FACE_ICON_NAME      @"^[0][0-8][0-5]$"


@implementation MessageView

@synthesize data;

- (id)initWithFrame:(CGRect)frame {

    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)showMessage:(NSArray *)message {

    self.data = (NSMutableArray *)message;

    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {

	if ( data ) {

        NSDictionary *faceMap = [[NSUserDefaults standardUserDefaults] objectForKey:@"FaceMap"];

        UIFont *font = [UIFont systemFontOfSize:16.0f];

        isLineReturn = NO;

        upX = VIEW_LEFT;
        upY = VIEW_TOP;

		for (int index = 0; index < [data count]; index++) {

			NSString *str = [data objectAtIndex:index];
			if ( [str hasPrefix:FACE_NAME_HEAD] ) {

				//NSString *imageName = [str substringWithRange:NSMakeRange(1, str.length - 2)];

                NSArray *imageNames = [faceMap allKeysForObject:str];
                NSString *imageName = nil;
                
                if ( imageNames.count > 0 ) {
                    
                    imageName = [imageNames objectAtIndex:0];
                }

                UIImage *image = [UIImage imageNamed:imageName];

                if ( image ) {

//                    if ( upX > ( VIEW_WIDTH_MAX - KFacialSizeWidth ) ) {
                    if ( upX > ( VIEW_WIDTH_MAX ) ) {

                        isLineReturn = YES;

                        upX = VIEW_LEFT;
                        upY += VIEW_LINE_HEIGHT;
                    }

                    [image drawInRect:CGRectMake(upX, upY, KFacialSizeWidth, KFacialSizeHeight)];

                    upX += KFacialSizeWidth;

                    lastPlusSize = KFacialSizeWidth;
                }
                else {

                    [self drawText:str withFont:font];
                }
			}
            else {

                [self drawText:str withFont:font];
			}
        }
	}
}

- (void)drawText:(NSString *)string withFont:(UIFont *)font{

    for ( int index = 0; index < string.length; index++) {

        NSString *character = [string substringWithRange:NSMakeRange( index, 1 )];

        CGSize size = [character sizeWithFont:font
                            constrainedToSize:CGSizeMake(VIEW_WIDTH_MAX, VIEW_LINE_HEIGHT * 1.5)];

        if ( upX > ( VIEW_WIDTH_MAX - KCharacterWidth ) ) {

            isLineReturn = YES;

            upX = VIEW_LEFT;
            upY += VIEW_LINE_HEIGHT;
        }

        [character drawInRect:CGRectMake(upX, upY, size.width, self.bounds.size.height) withFont:font];

        upX += size.width;

        lastPlusSize = size.width;
    }
}

/**
 * 判断字符串是否有效
 */
- (BOOL)isStrValid:(NSString *)srcStr forRule:(NSString *)ruleStr {
    
    NSRegularExpression *regularExpression = [[NSRegularExpression alloc] initWithPattern:ruleStr
                                                                                  options:NSRegularExpressionCaseInsensitive
                                                                                    error:nil];
    
    NSUInteger numberOfMatch = [regularExpression numberOfMatchesInString:srcStr
                                                                  options:NSMatchingReportProgress
                                                                    range:NSMakeRange(0, srcStr.length)];
    //[regularExpression ];
    
    return ( numberOfMatch > 0 );
}

- (void)dealloc {

   // [super dealloc];
}

@end
