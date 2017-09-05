//
//  ShiftInOutPopOverVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/10/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol ShiftInOutPopOverDelegate<NSObject>
-(void)shiftIn_OutSuccessfullyDone;
-(void)ShiftIn_OutProcessFailed;
-(void)dismissShiftIn_OutController;
-(void)didFailToPrintShiftReport;
@end

@interface ShiftInOutPopOverVC : UIViewController

@property (nonatomic, weak) id<ShiftInOutPopOverDelegate> shiftInOutPopOverDelegate;

@property (nonatomic,strong) NSString *strType;
@property (nonatomic,strong) NSString *strZprint;
@property (nonatomic,strong) NSString *strReportType;

-(void)LastEmpoyeeShiftWithZid :(NSString *)Zid;
- (void)printShiftReport;
@end
