//
//  RapidCreditBatchDetailCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 2/20/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RapidCreditBatchDetailCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *lblDate;
@property(nonatomic,weak) IBOutlet UILabel *accountNo;
@property(nonatomic,weak) IBOutlet UILabel *cardType;
@property(nonatomic,weak) IBOutlet UILabel *amount;
@property(nonatomic,weak) IBOutlet UILabel *authCode;
@property(nonatomic,weak) IBOutlet UILabel *invoice;

@end
