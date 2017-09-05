//
//  CL_HouseChargeListCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 18/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CL_HouseChargeListCell : UITableViewCell

@property (nonatomic , weak) IBOutlet UILabel *lblDateTime;
@property (nonatomic , weak) IBOutlet UILabel *lblInvoiceNo;
@property (nonatomic , weak) IBOutlet UILabel *lblDebit;
@property (nonatomic , weak) IBOutlet UILabel *lblCredit;
@property (nonatomic , weak) IBOutlet UILabel *lblBalance;

@end
