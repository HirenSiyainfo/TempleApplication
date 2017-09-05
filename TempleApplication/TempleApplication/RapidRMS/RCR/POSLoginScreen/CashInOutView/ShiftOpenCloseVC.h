//
//  ShiftOpenCloseVC.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiftOpenCloseVC : UIViewController
{
    
}

@property (assign, nonatomic) BOOL isfromDashBoard;
@property (assign, nonatomic) BOOL isShifInOutFromReport;
-(void)shiftPrint;
-(void)emailButtonPressed;

@end
