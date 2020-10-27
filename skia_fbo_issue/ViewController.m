//
//  ViewController.m
//  skia_fbo_issue
//
//  Created by ghostshi(施啸天) on 9/4/20.
//  Copyright © 2020 ghostshi(施啸天). All rights reserved.
//

#import "ViewController.h"
#import "SkiaView.h"

@interface ViewController ()

@property SkiaView* skia_view_;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, 100)];
    
    [button setTitleColor:[UIColor colorWithRed:36/255.0 green:71/255.0 blue:113/255.0 alpha:1.0] forState:UIControlStateNormal];
    [button setTitle:@"click to reproduce" forState:UIControlStateNormal];
    
    [button addTarget:self action:@selector(onButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [[self view] addSubview:button];
    
    self.skia_view_ = [[SkiaView alloc] initWithFrame:CGRectMake(0, 100, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height - 100)];
    
    [[self view] addSubview:self.skia_view_];
}

- (void)onButtonClicked {
    [self.skia_view_ reproductIssue];
}


@end
