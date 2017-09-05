//
//  PODateSelection.h
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"

@protocol PODateSelectionDelegate <NSObject>

-(void)didSubmitwithDate:(NSString *)fromDate toDate:(NSString *)toDate;
-(void)didSubmitwithTimeRange:(NSString *)timeRange;
-(void)didCancelDateRange;
@end

@interface PODateSelection : UIViewController


@property(nonatomic, weak) id<PODateSelectionDelegate> pODateSelectionDelegate;
@end
