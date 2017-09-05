//
//  POOpenOrder.h
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POmenuListDelegateVC.h"

@interface POOpenOrder : UIViewController

@property(nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;
@end
