//
//  ItemTicketValidation.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemTicketValidationDelegate <NSObject>

-(void)hideItemTicketValidation;

@end

@interface ItemTicketValidation : UIViewController

@property (nonatomic, weak) id<ItemTicketValidationDelegate> itemTicketValidationDelegate;

@end
