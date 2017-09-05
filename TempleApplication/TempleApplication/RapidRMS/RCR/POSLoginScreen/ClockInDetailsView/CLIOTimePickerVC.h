//
//  CLIOTimePickerVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 27/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol CLIOTimePickerVCDelegate<NSObject>
    -(void)didUpdateClockInOutTime:(NSDictionary *)clockInOutTime;
    -(void)didCancelUpdateClockInOutTime;
@end

@interface CLIOTimePickerVC : UIViewController

@property (nonatomic, weak) id<CLIOTimePickerVCDelegate> cLIOTimePickerVCDelegate;

@property (nonatomic, strong) NSDictionary *clockInOutTimeDictionary;

@property (nonatomic, assign) BOOL isNewEntry;

@end
