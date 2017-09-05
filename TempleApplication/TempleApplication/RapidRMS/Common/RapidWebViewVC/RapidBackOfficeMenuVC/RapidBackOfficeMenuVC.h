//
//  RapidBackOfficeMenuVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PageId)
{
    PageIdDashboard = 1,
    PageIdGroup = 2,
    PageIdManagerReports = 3,
    PageIdChangeGroupPrice = 7,
    PageIdCaptureAmount = 8,
};

@protocol RapidWebManuSelecteItemDelegate
    -(void)didSelectionChangeManu:(PageId)setPage;
@end

@interface RapidBackOfficeMenuVC : UIViewController<UIGestureRecognizerDelegate>{

}
@property (nonatomic,weak) id<RapidWebManuSelecteItemDelegate> rapidWebMenuVDelegate;
-(IBAction)showMenu:(id)sender;
@end
