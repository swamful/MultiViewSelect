//
//  ViewController.h
//  MultiViewSelect
//
//  Created by Seungpill Baik on 2014. 11. 25..
//  Copyright (c) 2014년 retix. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MultiWindowView.h"
@interface ViewController : UIViewController <MultiWindowViewDelegate>


@property (nonatomic) MultiWindowView *multiWindowView;
@property (nonatomic) UILabel *logLabel;
@end

