//
//  MEReceivingDateVC.h
//  RapidRMS
//
//  Created by Siya Infotech on 6/20/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol MEReceivingDateVCDelegate
-(void)didSelectDate:(NSString *) selectedDate;
-(void)didCloseReceivingDate;

@end

@interface MEReceivingDateVC : UIViewController


@property (nonatomic,weak) id<MEReceivingDateVCDelegate> meReceivingDateVCDelegate;


@end
