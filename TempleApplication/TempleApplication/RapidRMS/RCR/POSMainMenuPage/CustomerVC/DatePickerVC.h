//
//  DatePickerVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 8/24/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerDelegate <NSObject>

-(void)didSelectDate:(NSString *)selectedDate;
-(void)didCancelDatePicker;
-(void)didClearDatePicker;

@end

@interface DatePickerVC : UIViewController

@property (nonatomic,weak) id <DatePickerDelegate>datePickerDelegate;

@end
