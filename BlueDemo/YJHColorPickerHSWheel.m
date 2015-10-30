//
//  YJHColorPickerHSWheel.m
//  BlueDemo
//
//  Created by piglikeyoung on 15/10/30.
//  Copyright © 2015年 pikeYoung. All rights reserved.
//

#import "YJHColorPickerHSWheel.h"
#import "UIImage+ColorAtPixel.h"

#define kAlphaVisibleThreshold (0.1f)

@interface YJHColorPickerHSWheel()

@property (nonatomic, assign) CGPoint previousTouchPoint;
@property (nonatomic, assign) BOOL previousTouchHitTestResponse;

@end

@implementation YJHColorPickerHSWheel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self resetHitTestCache];
    }
    return self;
}




- (id)initWithCoder:(NSCoder *)decoder
{
    self = [super initWithCoder:decoder];
    if (self) {
        [self resetHitTestCache];
    }
    return self;
}


#pragma mark - Hit testing

- (BOOL)isAlphaVisibleAtPoint:(CGPoint)point forImage:(UIImage *)image
{
    // Correct point to take into account that the image does not have to be the same size
    // as the button. See https://github.com/ole/OBShapedButton/issues/1
    CGSize iSize = image.size;
    CGSize bSize = self.bounds.size;
    point.x *= (bSize.width != 0) ? (iSize.width / bSize.width) : 1;
    point.y *= (bSize.height != 0) ? (iSize.height / bSize.height) : 1;
    
    CGColorRef pixelColor = [[image colorAtPixel:point] CGColor];
    CGFloat alpha = CGColorGetAlpha(pixelColor);
    return alpha >= kAlphaVisibleThreshold;
}


// UIView uses this method in hitTest:withEvent: to determine which subview should receive a touch event.
// If pointInside:withEvent: returns YES, then the subview’s hierarchy is traversed; otherwise, its branch
// of the view hierarchy is ignored.
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    // Return NO if even super returns NO (i.e., if point lies outside our bounds)
    BOOL superResult = [super pointInside:point withEvent:event];
    if (!superResult) {
        return superResult;
    }
    
    // Don't check again if we just queried the same point
    // (because pointInside:withEvent: gets often called multiple times)
    if (CGPointEqualToPoint(point, self.previousTouchPoint)) {
        return self.previousTouchHitTestResponse;
    } else {
        self.previousTouchPoint = point;
    }
    
    // We can't test the image's alpha channel if the button has no image. Fall back to super.
    UIImage *currentImage = self.image;
    
    BOOL response = NO;
    
    if (currentImage == nil) {
        response = YES;
    }
    else if (currentImage != nil) {
        response = [self isAlphaVisibleAtPoint:point forImage:currentImage];
    }
    else {
        if ([self isAlphaVisibleAtPoint:point forImage:currentImage]) {
            response = YES;
        } else {
            response = [self isAlphaVisibleAtPoint:point forImage:currentImage];
        }
    }
    
    self.previousTouchHitTestResponse = response;
    return response;
}

- (void)setImage:(UIImage *)image {
    [super setImage:image];
    [self resetHitTestCache];
}

- (void)resetHitTestCache
{
    self.previousTouchPoint = CGPointMake(CGFLOAT_MIN, CGFLOAT_MIN);
    self.previousTouchHitTestResponse = NO;
}

@end
