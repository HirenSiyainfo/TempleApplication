//
//  MMDDateTimePickerVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 27/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMDDateTimePickerVCDelegate<NSObject>
    -(void)didEnterNewDate:(NSDate *)date withInputView:(id) inputView;
    -(void)didCancelEditItemPopOver;
@end

@interface MMDDateTimePickerVC : UIViewController
@property (nonatomic, weak) id<MMDDateTimePickerVCDelegate> Delegate;
@property (nonatomic, weak) IBOutlet UIDatePicker * datePicker;

@property (nonatomic, strong) NSString * strTitle;
@property (nonatomic, strong) id inputView;

@end
