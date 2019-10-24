//
//  WZPDatePickerView.m
//  WZPDatePicker
//
//  Created by mac on 2019/10/22.
//  Copyright © 2019年 mac. All rights reserved.
//

#import "WZPDatePickerView.h"
#import <Masonry/Masonry.h>

typedef NS_ENUM(NSInteger, WZPDatePickerChangeType)
{
    WZPDatePickerChangeTypeLast = 0,    // 上一个
    WZPDatePickerChangeTypeNext         // 下一个
};

@interface WZPDatePickerView()<UIPickerViewDelegate,UIPickerViewDataSource>

@end

@implementation WZPDatePickerView{
    UIButton *_lastBtn;
    UIButton *_nextBtn;
    UIButton *_yearMonthDayBtn;
    NSDate *_currentDate;
    NSCalendar *_greCalendar;
    NSDateFormatter *_dateFormatter;
    UIView *_bottomBgView;
    UIDatePicker *_bottomDatePicker;
    UIPickerView *_bottomPicker;
    NSDate *_minimumDate;
    NSDate *_maximumDate;
    //  pickerView相关
    NSMutableArray *_yearData;
    NSArray *_monthData;
    NSInteger _currentYearIndex;
    NSInteger _currentMonthIndex;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        _currentDate = [NSDate date];
        _greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _dateFormatter = [[NSDateFormatter alloc]init];
        [_dateFormatter setDateFormat: @"yyyy年MM月dd日"];
        self.datePickerType = WZPDatePickerTypeDefault;
        [self initTopView];
    }
    return self;
}

- (id)initWithDatePickerType:(WZPDatePickerType)type{
    self = [super init];
    if (self) {
        _currentDate = [NSDate date];
        _greCalendar = [[NSCalendar alloc]initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        _dateFormatter = [[NSDateFormatter alloc]init];
        self.datePickerType = type;
        if (_datePickerType == WZPDatePickerTypeYear) {
            [_dateFormatter setDateFormat: @"yyyy年"];
            _yearData = [[NSMutableArray alloc]initWithCapacity:0];
        }else if (_datePickerType == WZPDatePickerTypeYearAndMonth){
            [_dateFormatter setDateFormat: @"yyyy年MM月"];
            _yearData = [[NSMutableArray alloc]initWithCapacity:0];
            _monthData = @[@"1月",@"2月",@"3月",@"4月",@"5月",@"6月",@"7月",@"8月",@"9月",@"10月",@"11月",@"12月"];
        }else{
            [_dateFormatter setDateFormat: @"yyyy年MM月dd日"];
        }
        [self initTopView];
    }
    return self;
}

//  获取年份数据
- (void)getYearDateWithType{
    NSDateComponents *minimumCom = [self dateToComponents:_minimumDate];
    NSDateComponents *maximumCom = [self dateToComponents:_maximumDate];
    [_yearData removeAllObjects];
    for (int i = 0; i < (maximumCom.year - minimumCom.year + 1); i++) {
        [_yearData addObject:[NSString stringWithFormat:@"%ld年",(long)minimumCom.year + i]];
    }
}

#pragma mark - 一些属性的set方法
- (void)setDatePickerType:(WZPDatePickerType)datePickerType{
    _datePickerType = datePickerType;
    if (_datePickerType == WZPDatePickerTypeYear) {
        [_dateFormatter setDateFormat: @"yyyy年"];
        [_lastBtn setTitle:@"上一年" forState:UIControlStateNormal];
        [_nextBtn setTitle:@"下一年" forState:UIControlStateNormal];
    }else if (_datePickerType == WZPDatePickerTypeYearAndMonth){
        [_dateFormatter setDateFormat: @"yyyy年MM月"];
        [_lastBtn setTitle:@"上一月" forState:UIControlStateNormal];
        [_nextBtn setTitle:@"下一月" forState:UIControlStateNormal];
    }else{
        [_dateFormatter setDateFormat: @"yyyy年MM月dd日"];
        [_lastBtn setTitle:@"上一天" forState:UIControlStateNormal];
        [_nextBtn setTitle:@"下一天" forState:UIControlStateNormal];
    }
    [self reloadCurrentDateYearMonthDay];
}
- (void)setDateChanged:(WZPDateChanged)dateChanged{
    _dateChanged = dateChanged;
}

/**
 设置日期选择范围
 
 @param min 往前多少 根据WZPDatePickerType单位分别为 年/月/日
 @param max 往后多少 根据WZPDatePickerType单位分别为 年/月/日
 */
- (void)setMinimum:(NSInteger)min andMaximum:(NSInteger)max{
    NSDateComponents *components = [self dateToComponents:[NSDate date]];
    if (_datePickerType == WZPDatePickerTypeYear) {
        components.year -= min;
        _minimumDate = [self componentsToDate:components];
        components.year += min;
        components.year += max;
        _maximumDate = [self componentsToDate:components];
    }else if (_datePickerType == WZPDatePickerTypeYearAndMonth){
        components.month -= min;
        _minimumDate = [self componentsToDate:components];
        components.month += min;
        components.month += max;
        _maximumDate = [self componentsToDate:components];
    }else{
        components.day -= min;
        _minimumDate = [self componentsToDate:components];
        components.day += min;
        components.day += max;
        _maximumDate = [self componentsToDate:components];
    }
}

#pragma mark - UI初始化
//  初始化顶部view
- (void)initTopView{
    UIView *topBgView = [[UIView alloc]init];
    topBgView.backgroundColor = [UIColor whiteColor];
    [self addSubview:topBgView];
    [topBgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.right.equalTo(self);
//        make.height.mas_equalTo(self.mas_height);
    }];
    
    //  上一天（月/年）
    _lastBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_lastBtn setTitle:@"上一天" forState:UIControlStateNormal];
    [_lastBtn addTarget:self action:@selector(lastButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_lastBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _lastBtn.backgroundColor = [UIColor lightGrayColor];
    _lastBtn.layer.borderColor = [UIColor grayColor].CGColor;
    _lastBtn.layer.borderWidth = 0.5;
    [topBgView addSubview:_lastBtn];
    
    NSString *todayStr = [_dateFormatter stringFromDate:_currentDate];
    //  当前年月日
    _yearMonthDayBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_yearMonthDayBtn setTitle:todayStr forState:UIControlStateNormal];
    [_yearMonthDayBtn addTarget:self action:@selector(yearMonthDayButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_yearMonthDayBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _yearMonthDayBtn.backgroundColor = [UIColor whiteColor];
    _yearMonthDayBtn.layer.borderColor = [UIColor grayColor].CGColor;
    _yearMonthDayBtn.layer.borderWidth = 0.5;
    [topBgView addSubview:_yearMonthDayBtn];
    
    //  下一天（月/年）
    _nextBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_nextBtn setTitle:@"下一天" forState:UIControlStateNormal];
    [_nextBtn addTarget:self action:@selector(nextButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [_nextBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _nextBtn.backgroundColor = [UIColor lightGrayColor];
    _nextBtn.layer.borderColor = [UIColor grayColor].CGColor;
    _nextBtn.layer.borderWidth = 0.5;
    [topBgView addSubview:_nextBtn];
    [_yearMonthDayBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(3.0);
        make.bottom.mas_equalTo(-3.0);
        make.centerX.equalTo(topBgView.mas_centerX);
        make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width/2.0);
    }];
    [_lastBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(3.0);
        make.left.mas_equalTo(3.0);
        make.bottom.mas_equalTo(-3.0);
        make.right.equalTo(self->_yearMonthDayBtn.mas_left).offset(-3.0);
    }];
    [_nextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(3.0);
        make.left.equalTo(self->_yearMonthDayBtn.mas_right).offset(3.0);
        make.bottom.mas_equalTo(-3.0);
        make.right.mas_equalTo(-3.0);
    }];
}

#pragma mark - actions
- (void)lastButtonClick{
    _currentDate = [self getChangedDateWithType:WZPDatePickerChangeTypeLast];
    
//    NSString *dateStr = [_dateFormatter stringFromDate:_currentDate];
    [self reloadCurrentDateYearMonthDay];
    if (self.dateChanged) {
        self.dateChanged(_currentDate);
    }
}
- (void)nextButtonClick{
    _currentDate = [self getChangedDateWithType:WZPDatePickerChangeTypeNext];
    
//    NSString *dateStr = [_dateFormatter stringFromDate:_currentDate];
    [self reloadCurrentDateYearMonthDay];
    if (self.dateChanged) {
        self.dateChanged(_currentDate);
    }
}

//  切换年份、月份、日期
- (NSDate *)getChangedDateWithType:(WZPDatePickerChangeType)type{
    NSDateComponents *components = [self dateToComponents:_currentDate];
    
    if (type == WZPDatePickerChangeTypeNext) {
        if (self.datePickerType == WZPDatePickerTypeYear) {
            components.year += 1;
        }else if (self.datePickerType == WZPDatePickerTypeYearAndMonth){
            components.month += 1;
        }else{
            components.day += 1;
        }
    }else if (type == WZPDatePickerChangeTypeLast) {
        if (self.datePickerType == WZPDatePickerTypeYear) {
            components.year -= 1;
        }else if (self.datePickerType == WZPDatePickerTypeYearAndMonth){
            components.month -= 1;
        }else{
            components.day -= 1;
        }
    }
    NSDate *date = [self componentsToDate:components];
    //  超出范围返回原值
    if ([date compare:_minimumDate] >= 0 && [date compare:_maximumDate] <= 0) {
        return date;
    }
    return _currentDate;
}

#pragma mark - 底部UIDatePicker
//  当前日期点击Action，选择日期
- (void)yearMonthDayButtonClick{
    NSLog(@"选择日期");
    if (!_bottomBgView) {
        _bottomBgView = [[UIView alloc]init];
        _bottomBgView.backgroundColor = [UIColor whiteColor];
        [self.superview addSubview:_bottomBgView];
        [_bottomBgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.superview.mas_bottom).offset(280);
            make.left.right.equalTo(self.superview);
            make.height.mas_equalTo(280);
        }];
        
        UILabel *upLineLb = [[UILabel alloc]init];
        upLineLb.backgroundColor = [UIColor lightGrayColor];
        [_bottomBgView addSubview:upLineLb];
        [upLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self->_bottomBgView);
            make.height.mas_equalTo(0.5);
        }];
        
        UIButton *cancelBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
        [cancelBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        cancelBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [cancelBtn addTarget:self action:@selector(bottomCancelButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBgView addSubview:cancelBtn];
        [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.top.equalTo(self->_bottomBgView);
            make.width.mas_equalTo(45);
            make.height.mas_equalTo(45);
        }];
        UIButton *confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
        [confirmBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        confirmBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        [confirmBtn addTarget:self action:@selector(bottomConfirmButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_bottomBgView addSubview:confirmBtn];
        [confirmBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-20);
            make.top.equalTo(self->_bottomBgView);
            make.width.mas_equalTo(45);
            make.height.mas_equalTo(45);
        }];
        
        UILabel *downLineLb = [[UILabel alloc]init];
        downLineLb.backgroundColor = [UIColor lightGrayColor];
        [_bottomBgView addSubview:downLineLb];
        [downLineLb mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(44.5);
            make.left.right.equalTo(self->_bottomBgView);
            make.height.mas_equalTo(0.5);
        }];
        
        if (_datePickerType == WZPDatePickerTypeYearAndMonth || _datePickerType == WZPDatePickerTypeYear) {
            //  年月类型和年类型，用UIPickerView
            [self getYearDateWithType];
            _bottomPicker = [[UIPickerView alloc]init];
            _bottomPicker.delegate = self;
            _bottomPicker.dataSource = self;
            
            //设置pickerView默认选中当前时间
            NSDateComponents *currentCom = [self dateToComponents:_currentDate];
            NSDateComponents *minimumCom = [self dateToComponents:_minimumDate];
            [_bottomPicker selectRow:currentCom.year - minimumCom.year inComponent:0 animated:YES];
            _currentYearIndex = currentCom.year - minimumCom.year;
            if (_datePickerType == WZPDatePickerTypeYearAndMonth) {
                [_bottomPicker selectRow:currentCom.month - 1 inComponent:1 animated:YES];
                _currentMonthIndex = currentCom.month - 1;
            }
            
            [_bottomBgView addSubview:_bottomPicker];
            [_bottomPicker mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(self->_bottomBgView);
                make.height.mas_equalTo(235);
            }];
        }else{
            //  年月日类型，用系统UIDatePicker
            //  日期选择器
            _bottomDatePicker = [[UIDatePicker alloc]init];
            [_bottomDatePicker setDate:_currentDate animated:YES];
            _bottomDatePicker.datePickerMode = UIDatePickerModeDate;
            //设置地区: zh-中国
            _bottomDatePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh"];
            //  设置范围
            _bottomDatePicker.minimumDate = _minimumDate;
            _bottomDatePicker.maximumDate = _maximumDate;
            [_bottomBgView addSubview:_bottomDatePicker];
            [_bottomDatePicker mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.bottom.right.equalTo(self->_bottomBgView);
                make.height.mas_equalTo(235);
            }];
        }
        
        //  刷新位置
        [self.superview layoutIfNeeded];
        [UIView animateWithDuration:0.5 animations:^{
            [self->_bottomBgView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(self.superview.mas_bottom);
            }];
            [self.superview layoutIfNeeded];
        } completion:^(BOOL finished) {
            self.userInteractionEnabled = NO;
        }];
    }else{
//        [self closeBottomDatePicker];
    }
}

//  取消/确定按钮 Action
- (void)bottomCancelButtonClick{
    [self closeBottomDatePicker];
}
- (void)bottomConfirmButtonClick{
    //  点击确定按钮，更新当前日期刷新相关UI显示
    if (_datePickerType == WZPDatePickerTypeYear || _datePickerType == WZPDatePickerTypeYearAndMonth) {
        NSDateComponents *minimumCom = [self dateToComponents:_minimumDate];
        NSDateComponents *currentCom = [[NSDateComponents alloc]init];
        currentCom.year = minimumCom.year + _currentYearIndex;
        if (_datePickerType == WZPDatePickerTypeYearAndMonth) {
            currentCom.month = _currentMonthIndex + 1;
        }
        _currentDate = [self componentsToDate:currentCom];
    }else{
        _currentDate = _bottomDatePicker.date;
    }
    [self closeBottomDatePicker];
//    NSString *dateStr = [_dateFormatter stringFromDate:_currentDate];
    [self reloadCurrentDateYearMonthDay];
    if (self.dateChanged) {
        self.dateChanged(_currentDate);
    }
}

//  关闭底部日期选择器
- (void)closeBottomDatePicker{
    [UIView animateWithDuration:0.5 animations:^{
        [self->_bottomBgView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.superview.mas_bottom).offset(280);
        }];
        [self.superview layoutIfNeeded];
    } completion:^(BOOL finished) {
        [self->_bottomDatePicker removeFromSuperview];
        [self->_bottomPicker removeFromSuperview];
        [self->_bottomBgView removeFromSuperview];
        self->_bottomPicker = nil;
        self->_bottomDatePicker = nil;
        self->_bottomBgView = nil;
        self.userInteractionEnabled = YES;
    }];
}
//  刷新当前日期显示
- (void)reloadCurrentDateYearMonthDay{
    NSString *todayStr = [_dateFormatter stringFromDate:_currentDate];
    [_yearMonthDayBtn setTitle:todayStr forState:UIControlStateNormal];
}

#pragma mark - UIPickerViewDataSource UIPickerViewDelegate
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (_datePickerType == WZPDatePickerTypeYear) {//只选择年
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (_datePickerType == WZPDatePickerTypeYear) {//只选择年
        return _yearData.count;
    } else {
        if (component == 0) {
            return _yearData.count;
        } else {
            return _monthData.count;
        }
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (_datePickerType == WZPDatePickerTypeYear) {//只选择年
        return _yearData[row];
    } else {
        if (component == 0) {
            return _yearData[row];
        } else {
            return _monthData[row];
        }
    }
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (_datePickerType == WZPDatePickerTypeYear) {//只选择年
        NSLog(@"%@",_yearData[row]);
        _currentYearIndex = row;
    } else {
        if (component == 0) {
            NSLog(@"%@",_yearData[row]);
            [pickerView reloadComponent:1];
            _currentYearIndex = row;
        } else {
            NSLog(@"%@",_monthData[row]);
            _currentMonthIndex = row;
        }
        NSDateComponents *minimumCom = [self dateToComponents:_minimumDate];
        NSDateComponents *maximumCom = [self dateToComponents:_maximumDate];
        NSDateComponents *currentCom = [[NSDateComponents alloc]init];
        currentCom.year = minimumCom.year + _currentYearIndex;
        if (_datePickerType == WZPDatePickerTypeYearAndMonth) {
            currentCom.month = _currentMonthIndex + 1;
        }
        NSDate *currentDate = [self componentsToDate:currentCom];
        if ([currentDate compare:_minimumDate] < 0) {
            [_bottomPicker selectRow:minimumCom.month - 1 inComponent:1 animated:YES];
            _currentMonthIndex = minimumCom.month - 1;
        }
        if ([currentDate compare:_maximumDate] > 0) {
            [_bottomPicker selectRow:maximumCom.month - 1 inComponent:1 animated:YES];
            _currentMonthIndex = maximumCom.month - 1;
        }
    }
}
#pragma mark - NSDate和NSCompontents转换
- (NSDateComponents *)dateToComponents:(NSDate *)date{
    NSDateComponents *components = [_greCalendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond) fromDate:date];
    return components;
}

- (NSDate *)componentsToDate:(NSDateComponents *)components{
    // 不区分时分秒
    components.hour = 0;
    components.minute = 0;
    components.second = 0;
    if (_datePickerType == WZPDatePickerTypeYear) {
        components.month = 1;
        components.day = 1;
    }else if (_datePickerType == WZPDatePickerTypeYearAndMonth){
        components.day = 1;
    }
    NSDate *date = [_greCalendar dateFromComponents:components];
    return date;
}

@end
