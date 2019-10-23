//
//  WZPDatePickerView.h
//  WZPDatePicker
//
//  Created by mac on 2019/10/22.
//  Copyright © 2019年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

//选择日期控件类型
typedef NS_ENUM(NSInteger, WZPDatePickerType)
{
    WZPDatePickerTypeDefault = 0,   //默认 显示年月日
    WZPDatePickerTypeYearAndMonth,  //只显示年月
    WZPDatePickerTypeYear,          //只显示年
};

@interface WZPDatePickerView : UIView


/**
 初始化方法

 @param type 选择日期控件类型
 @return 控件实例
 */
- (id)initWithDatePickerType:(WZPDatePickerType)type;

//- (void)setMinimum:(NSInteger)min andMaximum:(NSInteger)max;

/** 选择日期控件类型 */
@property (nonatomic,  assign) WZPDatePickerType datePickerType;

typedef void(^WZPDateChanged)(id date);
@property (nonatomic,   copy) WZPDateChanged dateChanged;

//  往前范围
@property (nonatomic,  assign) NSInteger minimum;
//  往后范围
@property (nonatomic,  assign) NSInteger maximum;

@end
