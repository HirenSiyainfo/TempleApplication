//
//  POGenerateOrder.h
//  RapidRMS
//
//  Created by Siya10 on 13/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "POmenuListDelegateVC.h"

typedef NS_ENUM(NSUInteger, GenerateOrder)
{
    VEDNOR,
    ORDERTYPE,
    FROMDATE,
    TODATE,
    ISMINIMUMQTY,
    MINIMUMQTY,
};

@interface POGenerateOrder : UIViewController

@property(nonatomic, weak) id<POmenuListVCDelegate> pOmenuListVCDelegate;
@end
