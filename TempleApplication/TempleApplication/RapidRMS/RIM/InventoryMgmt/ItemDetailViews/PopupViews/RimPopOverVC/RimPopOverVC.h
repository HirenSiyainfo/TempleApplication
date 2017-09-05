//
//  popOverController.h
//  POSFrontEnd
//
//  Created by Minesh Purohit on 04/12/11.
//  Copyright 2011 Home. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ItemInfoEditVC.h"
#import "ManualItemReceiveVC.h"


typedef void (^DidEnterAmount)(NSString*, NSDictionary*);

@interface RimPopOverVC : UIViewController <UITextFieldDelegate> 

@property (nonatomic, strong) DidEnterAmount didEnterAmountBlock;
@property (nonatomic, strong) NSDictionary * userInfo;
@property (nonatomic, strong) NSString * notificationName;
@end
