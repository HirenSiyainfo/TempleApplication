//
//  CloseOrderPo_iPhone.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CloseOrderPo_iPhone : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblPONumber;
@property (nonatomic, weak) IBOutlet UILabel *lblInvoiceNumber;
@property (nonatomic, weak) IBOutlet UILabel *lblDeliveryDate;
@property (nonatomic, weak) IBOutlet UILabel *lblDeliveryTime;
@property (nonatomic, weak) IBOutlet UILabel *lblCloseOrderDate;
@property (nonatomic, weak) IBOutlet UILabel *lblCloseOrderTime;
@property (nonatomic, weak) IBOutlet UIButton *btnPrint;

@end
