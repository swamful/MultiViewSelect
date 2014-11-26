//
//  MultiWindowView.m
//  MultiViewSelect
//
//  Created by Seungpill Baik on 2014. 10. 31..
//  Copyright (c) 2014년 retix. All rights reserved.
//

#import "MultiWindowView.h"
#define DEGREES_TO_RADIANS(d) (d * M_PI / 180)
#define RADIANS_TO_DEGREE(ANGLE) (ANGLE * 180) / M_PI
#define UIColorFromRGB(rgbValue, alphaDegree) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:alphaDegree]
@implementation MultiWindowView
@synthesize btnImgList = _btnImgList;
@synthesize delegate = _delegate;
@synthesize contentsView = _contentsView;
const float imgScale = 0.33;
const int zGap=310;
const int centerGap=80;
const int layerGap=80;
const float twistedRate=0.011;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor grayColor];
        self.btnImgList = [NSMutableArray array];
        
        self.contentsView = [[UIView alloc] initWithFrame:self.bounds];
        self.contentsView.layer.sublayerTransform = [self getTransForm3DIdentity];
        [self addSubview:self.contentsView];
        
        UIPanGestureRecognizer *panRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        panRecognizer.minimumNumberOfTouches = 1;
        [self addGestureRecognizer:panRecognizer];
        

    }
    return self;
}


- (CATransform3D) getTransForm3DIdentity {
    CATransform3D transform = CATransform3DIdentity;
    transform.m34 = - 1.0f/ 1000.0f;
    return transform;
}

- (CATransform3D) initLayerTransform{
    CATransform3D transform = [self getTransForm3DIdentity];
    transform = CATransform3DScale(transform, imgScale, imgScale, imgScale);
    transform = CATransform3DRotate(transform, DEGREES_TO_RADIANS(-24), 0, 1, 0);
    transform = CATransform3DRotate(transform, DEGREES_TO_RADIANS(-22), 1, 0, 0);
    transform = CATransform3DRotate(transform, DEGREES_TO_RADIANS(5), 0, 0, 1);
    return transform;
}

- (CGFloat) getZGap:(CALayer *)layer {
    return [[layer valueForKeyPath:@"transform.translation.z"] floatValue];
}

- (NSInteger) margin {
    return CGRectGetWidth(self.frame) * 0.15;
}

- (void) initLayer {
    
    for (int i =0 ; i < [self.btnImgList count]; i ++) {
        CALayer *layer = [[self.btnImgList objectAtIndex:i] layer];
        layer.name = [NSString stringWithFormat:@"%d", i];

        layer.anchorPointZ = -900;
        layer.anchorPoint = CGPointMake(0, 0);
        
        layer.transform = [self initLayerTransform];

        layer.transform = CATransform3DTranslate(layer.transform, 0, 0, - i * zGap);
        layer.position = CGPointMake(self.center.x - pow([self getZGap:layer] * twistedRate, 2) + [self margin], self.center.y /2 - [self margin]);
        
        
    }
}



- (UIButton *) getBtn {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.layer.transform = [self getTransForm3DIdentity];
    btn.layer.shouldRasterize = YES;
    btn.layer.rasterizationScale = 0.9;
    btn.layer.edgeAntialiasingMask = kCALayerLeftEdge | kCALayerRightEdge | kCALayerBottomEdge | kCALayerTopEdge;
    btn.layer.masksToBounds = NO;
    btn.layer.cornerRadius = 1.0f;
    [btn addTarget:self action:@selector(pressBtn:) forControlEvents:UIControlEventTouchUpInside];
    
    return btn;
}

- (void) pressBtn:(UIButton *) btn {
    [_delegate selectViewWithIndex:btn.tag];
}

- (void) setImgList:(NSMutableArray*) imgList {
    for (int i = 0; i < [imgList count]; i++) {
        UIImage *tmpImg = [imgList objectAtIndex:i];
        UIButton *btn = [self getBtn];
        btn.frame = CGRectMake(-self.frame.size.width/2, 0, self.frame.size.width, self.frame.size.height);
        if (CGSizeEqualToSize(tmpImg.size, CGSizeZero) || !tmpImg) {
            btn.backgroundColor = [UIColor whiteColor];
        } else {
            btn.layer.contents = (__bridge id)(tmpImg.CGImage);
        }
        
        btn.tag = i;
        
        
        [self.contentsView insertSubview:btn atIndex:0];
        [self.btnImgList addObject:btn];
        
        
    }
    [self initLayer];
}


- (void) handlePan:(UIGestureRecognizer *) recognizer {
    
    UIPanGestureRecognizer *pan = (UIPanGestureRecognizer *) recognizer;
    CGPoint velocity = [pan velocityInView:pan.view];
    
    CGPoint location = [pan locationInView:pan.view];
    CGPoint direction = [pan translationInView:pan.view];
    CGFloat deltaX = 0;
    CGFloat deltaY = 0;
    if (pan.state == UIGestureRecognizerStateBegan) {
        _isAnimating = YES;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(btnListTouchEnableWithNSNumber:) object:[NSNumber numberWithBool:YES]];
        [self btnListTouchEnable:NO];
    } else if (pan.state == UIGestureRecognizerStateChanged) {
        deltaX = forePoint.x - location.x;
        deltaY = forePoint.y - location.y;
        CGFloat hypotenuse = sqrt(deltaX * deltaX + deltaY * deltaY);

        if (deltaX * deltaY  < 0) {
            if (deltaX > 0  && deltaY < 0) {
                hypotenuse = hypotenuse * -1;
            }
        } else if ( deltaX * deltaY != 0){
            forePoint = location;
            return;
        }
        hypotenuse *= 3;
//        NSLog(@"deltaX : %f deltaY : %f", deltaX, deltaY);
//        NSLog(@"direction x : %f direction y : %f", direction.x, direction.y);
//        NSLog(@"hypotenuse : %f", hypotenuse);
        CGFloat firstLayerZGap = [self getZGap:[[_btnImgList objectAtIndex:0] layer]];
        CGFloat finalLayerZGap = [self getZGap:[[_btnImgList lastObject] layer]];
        
        if (firstLayerZGap < 0 || finalLayerZGap > 0 || firstLayerZGap - hypotenuse < 0 || finalLayerZGap - hypotenuse > 0) {
            hypotenuse *= 0.1;
        }
        

        for (int i =0 ; i < [self.btnImgList count]; i ++) {
            
            CALayer *layer = [[self.btnImgList objectAtIndex:i] layer];
            layer.transform = CATransform3DTranslate(layer.transform, 0, 0, -hypotenuse);
            layer.position = CGPointMake(self.center.x - pow([self getZGap:layer] * twistedRate, 2) + [self margin], layer.position.y);
        }
        
        
        
    } else if (pan.state >= UIGestureRecognizerStateEnded) {
        CGFloat hypotenuse = sqrt(velocity.x * velocity.x + velocity.y * velocity.y);

        if (direction.x * direction.y  < 0) {
            if (direction.x < 0 ) {
                hypotenuse = hypotenuse * -1;
            }
        } else {
            forePoint = location;
            [self btnListTouchEnable:YES];
            _isAnimating = NO;
            return;
        }

//        if (velocity.x < 0) {
//            hypotenuse = hypotenuse * -1;
//        }
        hypotenuse *= 0.5;
        if (fabs(hypotenuse) < 40) {
            [self checkLimitZgap];
            forePoint = location;
            return;
        }

        CGFloat firstLayerZGap = [self getZGap:[[_btnImgList objectAtIndex:0] layer]];
        CGFloat finalLayerZGap = [self getZGap:[[_btnImgList lastObject] layer]];
        if (firstLayerZGap - hypotenuse < 0 || finalLayerZGap - hypotenuse > 0) {
            if (firstLayerZGap < 0 || finalLayerZGap > 0) {
                hypotenuse *= 0.5;
            }
            hypotenuse *= 0.5;
        }
//        
//        NSLog(@"hypotenuse : %f", hypotenuse);
        [UIView animateWithDuration:MIN(0.3, fabs(hypotenuse) * 0.0008) delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            for (int i =0 ; i < [self.btnImgList count]; i ++) {
                
                CALayer *layer = [[self.btnImgList objectAtIndex:i] layer];
                layer.transform = CATransform3DTranslate(layer.transform, 0, 0, -hypotenuse);                
                layer.position = CGPointMake(self.center.x - pow([self getZGap:layer] * twistedRate, 2) + [self margin], layer.position.y);
            }
        } completion:^(BOOL finished){
            [self checkLimitZgap];
        }];
    }
    forePoint = location;
    
}

- (void)btnListTouchEnableWithNSNumber:(NSNumber *) number {
    if (_isAnimating) {
        return;
    }
    [self btnListTouchEnable:[number boolValue]];
}

- (void)btnListTouchEnable:(BOOL) enable {
    for (UIButton *btn in _btnImgList) {
        btn.userInteractionEnabled = enable;

    }
}

- (void) checkLimitZgap {
    CGFloat firstLayerZGap = [self getZGap:[[_btnImgList objectAtIndex:0] layer]];
    CGFloat finalLayerZGap = [self getZGap:[[_btnImgList lastObject] layer]];
    if (firstLayerZGap < 0) {
        [UIView animateWithDuration:0.25 animations:^{
            for (int i =0; i < [_btnImgList count]; i++) {
                CALayer *layer = [[_btnImgList objectAtIndex:i] layer];
                layer.transform = CATransform3DTranslate([self initLayerTransform] , 0, 0, - i * zGap);
                layer.position = CGPointMake(self.center.x - pow([self getZGap:layer] * twistedRate, 2) + [self margin], self.center.y /2 - [self margin]);
            }

        } completion:^(BOOL finished) {
            _isAnimating = NO;
            [self btnListTouchEnable:YES];
        }];
    } else if (finalLayerZGap >= 0) {
        [UIView animateWithDuration:0.25 animations:^{
            for (unsigned long i = [self.btnImgList count]; i > 0; i--) {
                CALayer *layer = [[self.btnImgList objectAtIndex:i - 1] layer];
                layer.transform = CATransform3DTranslate([self initLayerTransform] , 0, 0, ([_btnImgList count] - i) * zGap);
                layer.position = CGPointMake(self.center.x - pow([self getZGap:layer] * twistedRate, 2) + [self margin], self.center.y /2 - [self margin]);
            }
        } completion:^(BOOL finished) {
            _isAnimating = NO;
            [self btnListTouchEnable:YES];
        }];
    } else {
        _isAnimating = NO;
        [self performSelector:@selector(btnListTouchEnableWithNSNumber:) withObject:[NSNumber numberWithBool:YES] afterDelay:0.35];
    }
}



- (void) animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    NSString *value = [anim valueForKey:@"animation"];
    if ([value isEqualToString:[NSString stringWithFormat:@"moving%lu",([self.btnImgList count]-1)]]) {
        //        [self checkSelectedLayer];
    }
}




@end
