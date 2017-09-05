//
//  TicketValidationDetail.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidPass.h"

typedef NS_ENUM(NSInteger, TicketValidationDetailType)
{
    TicketValidationPassDetails,
    TicketValidationDate,
    TicketValidationPurchaseDate,
    TicketValidationLastVisitDate,
    TicketValidationRemark,
};

typedef NS_ENUM(NSInteger, PassStatus)
{
    Valid = 1,
    Invalid,
    SameDay,
    Expired,
};

@protocol TicketValidationDetailDelegate <NSObject>

-(void)hideTicketValidationDetail;

@end


@interface TicketValidationDetail : UIViewController

@property (nonatomic,strong) RapidPass *validationDetailRapidPass;
@property (nonatomic, weak) id<TicketValidationDetailDelegate> ticketValidationDetailDelegate;

@end
