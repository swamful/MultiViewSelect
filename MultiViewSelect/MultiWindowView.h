//
//  MultiWindowView.h
//  MultiViewSelect
//
//  Created by Seungpill Baik on 2014. 10. 31..
//  Copyright (c) 2014년 retix. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol MultiWindowViewDelegate <NSObject>
- (void) selectViewWithIndex:(NSInteger) index;
@end
@interface MultiWindowView : UIView <UIGestureRecognizerDelegate> {
    CGPoint forePoint;
    BOOL _isAnimating;
}

@property (nonatomic) id<MultiWindowViewDelegate> delegate;
@property (nonatomic) NSMutableArray *btnImgList;
@property (nonatomic) UIView *contentsView;
- (void) setImgList:(NSMutableArray*) imgList;
@end
