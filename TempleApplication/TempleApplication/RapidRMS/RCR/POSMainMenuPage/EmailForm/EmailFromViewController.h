//
//  EmailFromViewController.h
//  RapidRMS
//
//  Created by Siya on 04/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidCustomerLoyalty.h"

@protocol EmailFromViewControllerDelegate<NSObject>
-(void)didCancelEmail;

@end
@interface EmailFromViewController : UIViewController
{
    
}

@property (nonatomic,strong) NSMutableDictionary *dictParameter;
@property(nonatomic,strong)RapidCustomerLoyalty *rapidEmailCustomerLoyalty;

@property (nonatomic, weak) id<EmailFromViewControllerDelegate> emailFromViewControllerDelegate;


@end
