//
//  MMDNumberPickerVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 28/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"
typedef NS_ENUM(NSUInteger, NumberPadPickerTypes)
{
    NumberPadPickerTypesQTY,
    NumberPadPickerTypesQTYFloat,//item qty case pack
    NumberPadPickerTypesFloat,
    NumberPadPickerTypesPrice,
    NumberPadPickerTypesPercentage,
    NumberPadPickerTypesWeightScale,
};

typedef void (^RIMNumberPadCompleteInput)(NSNumber * numInput,NSString * strInput,id inputView);
typedef void (^RIMNumberPadColseInput)(UIViewController * popUpVC);

@interface RIMNumberPadPopupVC : PopupSuperVC


@property(nonatomic, weak) id inputView;
@property(nonatomic) NumberPadPickerTypes pickerType;

@property(nonatomic, strong) NSNumber * maxInput;
@property(nonatomic, strong) NSNumber * multiplierUnit;

@property (nonatomic, strong) RIMNumberPadCompleteInput numberPadCompleteInput;
@property (nonatomic, strong) RIMNumberPadColseInput numberPadColseInput;

@property(nonatomic) BOOL isAutoClose;

+(instancetype)getInputPopupWith:(NumberPadPickerTypes) pickerType NumberPadCompleteInput:(RIMNumberPadCompleteInput)CompleteInput NumberPadColseInput:(RIMNumberPadColseInput)ColseInput;

@end
