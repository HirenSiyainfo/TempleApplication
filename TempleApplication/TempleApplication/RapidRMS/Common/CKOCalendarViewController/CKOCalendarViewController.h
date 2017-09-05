//
//  globalCalendarVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 17/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"

@interface CKOCalendarViewController : PopupSuperVC <UIPopoverControllerDelegate>

@property (nonatomic, retain) UIPopoverController *calendarPopover;

@end
