//
//  DrawingView.m
//  Mumbler
//
//  Created by Ransika De Silva on 12/10/13.
//  Copyright (c) 2013 Visni (Pvt) Ltd. All rights reserved.
//

#import "DrawingView.h"

@implementation DrawingView

@synthesize drawingPointsArray;
@synthesize drawingColorsArray;
@synthesize isDrawingEnabled;
@synthesize drawingViewController;
@synthesize undoFlagTurnedOn;
@synthesize touchOnPalette;
@synthesize cropRect;

@synthesize getButton;




- (id)initWithFrame:(CGRect)frame
{
    NSLog(@"initwithframe drawingview");
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.drawingPointsArray = [NSMutableArray new];
        self.drawingColorsArray = [NSMutableArray new];
    }
    self.isDrawingEnabled = NO;
    self.undoFlagTurnedOn = NO;
    self.touchOnPalette = NO;
    // default color
    self.drawingColor = [UIColor redColor];
    
    // set backgroundcolor
    self.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"photo_cropper_bg.png"]];
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.


- (void)drawRect:(CGRect)rect
{
    
    // Drawing code
    NSLog(@"drawRect------------------------drawinfview");
    if(!self.drawingPointsArray)
    {
        self.drawingPointsArray = [[NSMutableArray alloc] initWithCapacity:0];
    }
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    if( self.image != nil)
    {
        // get screen width
//        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//        CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
        
       /* if(self.image.size.width > screenWidth)
        {
            // get the scale factors
            float uiViewHeight = self.frame.size.height;
            float imageHeight = self.image.size.height;
            float heightScaleFactor = uiViewHeight/imageHeight;
            
            float uiViewWidth = self.frame.size.width;
            float imageWidth = self.image.size.width;
            float widthScaleFactor = uiViewWidth/imageWidth;
            
            CGFloat scaleFactor = 0;
            CGSize scaledSize = CGSizeMake(0, 0);
            // scale image
            if(self.image.size.width > self.image.size.height)
            {
                scaleFactor = self.image.size.width/self.image.size.height;
                scaledSize.width = self.frame.size.width;
                scaledSize.height = self.frame.size.height / scaleFactor;
            }
            else
            {
                scaleFactor = self.image.size.height / self.image.size.width;
                scaledSize.height = self.frame.size.height;
                scaledSize.width = self.frame.size.width / scaleFactor;
            }
            
            CGFloat strechRatio = self.frame.size.height/ scaledSize.height;
            
            self.cropRect = CGRectMake(0, 0, scaledSize.width * strechRatio, scaledSize.height * strechRatio);
            [self.image drawInRect:self.cropRect];
           
        }
        else
        {
            self.cropRect = CGRectMake(screenWidth/2 - self.image.size.width/2, screenHeight/2 - self.image.size.height/2, (self.image.size.width), (self.image.size.height));
            // image width is small than screen
            [self.image drawInRect:self.cropRect];
            
        }*/
        self.cropRect = rect;
        [self.image drawInRect:rect];
    }
    
    if([self.drawingPointsArray count] > 0)
    {
        CGContextSetLineWidth(ctx, 5);
        for(int i =0; i < [self.drawingPointsArray count]; i++)
        {
            NSArray * drawingPath = [drawingPointsArray objectAtIndex:i];
            if([drawingPath count] > 2)
            {
                float pointX = [[drawingPath objectAtIndex:0] floatValue];
                float pointY = [[drawingPath objectAtIndex:1] floatValue];
                CGContextBeginPath(ctx);
                NSLog(@"move to x %f y %f",pointX,pointY);
                CGContextMoveToPoint(ctx, pointX, pointY);
                if(self.undoFlagTurnedOn && (([self.drawingPointsArray count] - 1 )== i))
                {
                    CGContextSetStrokeColorWithColor(ctx, [UIColor clearColor].CGColor);
                }
                else
                {
                    CGContextSetStrokeColorWithColor(ctx, ((UIColor *)[self.drawingColorsArray objectAtIndex:i]).CGColor);
                }
                for(int j = 2; j < [drawingPath count]; j+= 2)
                {
                    pointX = [[drawingPath objectAtIndex:j] floatValue];
                    pointY = [[drawingPath objectAtIndex:j+1] floatValue];
                     NSLog(@"Add line to point x %f y %f",pointX,pointY);
                    CGContextAddLineToPoint(ctx, pointX, pointY);
                }
                CGContextStrokePath(ctx);
            }
            
            if(self.undoFlagTurnedOn && (([self.drawingPointsArray count] - 1 )== i))
            {
               [self.drawingPointsArray removeObjectAtIndex:i];
               [self.drawingColorsArray removeObjectAtIndex:i];
                self.undoFlagTurnedOn = NO;
            }
        }
    }
    
    [self.drawingViewController upDateUndoButtonVisibility];
}

#pragma mark === get drawing ===
-(UIImage *)getDrawing
{
    NSLog(@"getDrawing------");
    UIGraphicsBeginImageContext(self.frame.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage * drawing = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // crop the image to required size
    CGImageRef imageRef = CGImageCreateWithImageInRect([drawing CGImage], cropRect);
    UIImage * croppedDrawing  = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    return croppedDrawing;
}

#pragma mark === draw image ===
-(void)drawImage:(UIImage *)image
{
    NSLog(@"drawImage------");
    if (image != nil) {
        NSLog(@"not null");
    }
    NSLog(@"draw image ");
    self.image = image;
    [self setNeedsDisplay];
}


#pragma mark ==== drawing on Image ===
-(void) touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touches began");
    if(self.isDrawingEnabled && !self.touchOnPalette)
    {
        // add drawing color
        [self.drawingColorsArray addObject:self.drawingColor];
        
        [self.drawingPointsArray addObject:[[NSMutableArray alloc] initWithCapacity:4]];
        CGPoint curPoint = [[touches anyObject] locationInView:self];
        [[self.drawingPointsArray lastObject] addObject:[NSNumber numberWithFloat:curPoint.x]];
        [[self.drawingPointsArray lastObject] addObject:[NSNumber numberWithFloat:curPoint.y]];
    }
}


-(void) touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesMoved");

    if(self.isDrawingEnabled && !self.touchOnPalette)
    {
        CGPoint curPoint = [[touches anyObject] locationInView:self];
        [[self.drawingPointsArray lastObject] addObject:[NSNumber numberWithFloat:curPoint.x]];
        [[self.drawingPointsArray lastObject] addObject:[NSNumber numberWithFloat:curPoint.y]];
        [self setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesEnded");
    
    if(self.isDrawingEnabled && !self.touchOnPalette)
    {
        CGPoint curPoint = [[touches anyObject] locationInView:self];
        [[self.drawingPointsArray lastObject] addObject:[NSNumber numberWithFloat:curPoint.x]];
        [[self.drawingPointsArray lastObject] addObject:[NSNumber numberWithFloat:curPoint.y]];
        [self setNeedsDisplay];
        [self.getButton setHidden:NO];
       
        
    }
}

-(void) cancelDrawing
{
    [self.drawingPointsArray removeAllObjects];
    [self setNeedsDisplay];
}

-(void) enableDrawing
{
    self.isDrawingEnabled = YES;
}

-(void) disableDrawing
{
    self.isDrawingEnabled = NO;
}

-(void)undo
{
    self.undoFlagTurnedOn = YES;
    [self setNeedsDisplay];
}

@end
