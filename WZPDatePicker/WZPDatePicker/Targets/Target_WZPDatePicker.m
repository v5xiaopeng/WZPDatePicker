//
//  Target_WZPDatePicker.m
//  WZPDatePicker
//
//  Created by mac on 2019/10/22.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "Target_WZPDatePicker.h"
#import <UIKit/UIKit.h>
#import "WZPDatePickerView.h"

static WZPDatePickerView *__datePickerView;
@implementation Target_WZPDatePicker

/**
 初始化只显示年份的日期选择器
 
 @param params nil
 @return 日期选择器实例
 */
- (UIView *)Action_initYearDatePickerView:(NSDictionary *)params{
    __datePickerView = [[WZPDatePickerView alloc]initWithDatePickerType:WZPDatePickerTypeYear];
    
    return __datePickerView;
}

/**
 初始化显示年月的日期选择器
 
 @param params nil
 @return 日期选择器实例
 */
- (UIView *)Action_initYearAndMonthDatePickerView:(NSDictionary *)params{
    __datePickerView = [[WZPDatePickerView alloc]initWithDatePickerType:WZPDatePickerTypeYearAndMonth];
    
    return __datePickerView;
}

/**
 初始化显示年月日的日期选择器

 @param params nil
 @return 日期选择器实例
 */
- (UIView *)Action_initDefaultDatePickerView:(NSDictionary *)params{
    __datePickerView = [[WZPDatePickerView alloc]initWithDatePickerType:WZPDatePickerTypeDefault];
    
    return __datePickerView;
}

/**
 设定日期选择范围

 @param params 范围键值 根据WZPDatePickerType单位分别为 年/月/日
 */
- (void)Action_setMinimumAndMaximum:(NSDictionary *)params{
    NSInteger minimumInt = [params[@"minimum"] integerValue];
    NSInteger maximumInt = [params[@"maximum"] integerValue];
    __datePickerView.minimum = minimumInt;
    __datePickerView.maximum = maximumInt;
}

/**
 日期变动block  上一个、下一个和确认按钮事件触发

 @param params 日期变动block
 */
- (void)Action_datePickerViewDateChanged:(NSDictionary *)params{
    __datePickerView.dateChanged = params[@"dateChangedBlock"];
}

@end
