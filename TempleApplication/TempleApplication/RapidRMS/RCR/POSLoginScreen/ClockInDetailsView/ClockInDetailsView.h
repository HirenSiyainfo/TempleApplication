//
//  RootViewController.h
//  tableStracture
//
//  Created by Triforce consultancy on 26/03/12.
//  Copyright 2012 Triforce consultancy . All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, ClockInOutDetails)
{
    ClockInOutDetailsForAllUsers = 101,
    ClockInOutDetailsForCurrentUser,
    ClockInOutDetailsForOtherUser,
};

typedef NS_ENUM (NSUInteger, TabOption)
{
    TabOptionClockInOut = 101,
    TabOptionClockInOutHistory,
};

@interface ClockInDetailsView : UIViewController
{

}

@end
