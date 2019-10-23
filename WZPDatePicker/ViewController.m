//
//  ViewController.m
//  WZPDatePicker
//
//  Created by mac on 2019/10/22.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "ViewController.h"
#import <Masonry/Masonry.h>
#import "WZPDatePickerView.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    WZPDatePickerView *datePicker = [[WZPDatePickerView alloc]init];
    datePicker.datePickerType = WZPDatePickerTypeDefault;
//    datePicker.minimum = 3;
//    datePicker.maximum = 4;
    [datePicker setMinimum:33 andMaximum:40];
    [self.view addSubview:datePicker];
    datePicker.dateChanged = ^(id date) {
        NSLog(@"%@",date);
    };
    [datePicker mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(40);
        make.left.right.equalTo(self.view);
        make.height.mas_equalTo(40);
    }];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
