//
//  MMDDiscountInfoPopupVC.h
//  RapidRMS
//
//  Created by Siya9 on 21/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"
typedef void (^RemoveDiscountAt)(NSInteger index);

#define isDaySelected(X, d) ((X & d) == d)

@interface MMDDiscountInfoPopupVC : PopupSuperVC

@property (nonatomic, weak) NSDictionary * dictMMDInfo;
@property (nonatomic) NSInteger index;
@property (nonatomic, strong) RemoveDiscountAt removeDiscountAt;


//-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView ArrowDirection:(UIPopoverArrowDirection)arrowDirection;
@end
