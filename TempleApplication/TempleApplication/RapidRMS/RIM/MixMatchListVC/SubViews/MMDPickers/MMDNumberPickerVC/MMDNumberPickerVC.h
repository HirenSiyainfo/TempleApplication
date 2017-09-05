//
//  MMDNumberPickerVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef NS_ENUM(NSUInteger, NumberPickerTypes)
{
    NumberPickerTypesQTY,
    NumberPickerTypesPrice,
    NumberPickerTypesPercentage,
};
@protocol MMDNumberPickerVCDelegate<NSObject>
    -(void)didEnterNumber:(NSNumber *) number inputView:(id) inputView withPickerType:(NumberPickerTypes) pickerType;
    -(void)didCancelEditItemPopOver;
@end
@interface MMDNumberPickerVC : UIViewController

@property(nonatomic, weak) id<MMDNumberPickerVCDelegate> Delegate;
@property(nonatomic, weak) id inputView;

@property(nonatomic) NumberPickerTypes pickerType;

@property(nonatomic, strong) NSNumber * maxInput;
@property(nonatomic, strong) NSString * strTitle;

@end
