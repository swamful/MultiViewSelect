//
//  ViewController.m
//  MultiViewSelect
//
//  Created by Seungpill Baik on 2014. 11. 25..
//  Copyright (c) 2014년 retix. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize multiWindowView = _multiWindowView;
@synthesize logLabel = _logLabel;
- (void)viewDidLoad {
    [super viewDidLoad];
    self.multiWindowView = [[MultiWindowView alloc] initWithFrame:self.view.bounds];
    self.multiWindowView.delegate = self;
    [self.multiWindowView setImgList:[self tmpImgList]];
    [self.view addSubview:self.multiWindowView];
    
    self.logLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 30, 30)];
    [self.view addSubview:self.logLabel];
}

#pragma mark -MultiWindowViewDelegate
- (void) selectViewWithIndex:(NSInteger)index {
    [self.logLabel setText:[NSString stringWithFormat:@"%ld", (long)index]];
}

- (NSMutableArray *) tmpImgList {
    NSMutableArray *tmpList = [NSMutableArray array];
    for (int i = 0; i < 25; i++) {
        [tmpList addObject:[UIImage imageNamed:@"tmp.jpg"]];
    }
    return tmpList;
}

@end
