//
//  TicketValidationPassDetail.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RapidPass.h"

@interface TicketValidationPassDetail : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *invoiceNo;
@property (nonatomic, weak) IBOutlet UILabel *passNo;
@property (nonatomic, weak) IBOutlet UILabel *typeOfPass;
@property (nonatomic, weak) IBOutlet UILabel *availbleDay;
@property (nonatomic, weak) IBOutlet UILabel *availbleExpiryDays;
@property (nonatomic, weak) IBOutlet UIImageView *qrCodeImage;

-(void)updateCellWithPassDetail:(RapidPass *)passDetail;

@end
