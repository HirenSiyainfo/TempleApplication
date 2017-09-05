//
//  ManagerReportDetailsCell.h
//  RapidRMS
//
//  Created by Siya-mac5 on 18/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManagerReportDetailsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblReportDate;
@property (nonatomic, weak) IBOutlet UILabel *lblRegisterName;
@property (nonatomic, weak) IBOutlet UILabel *lblBatchNumber;
@property (nonatomic, weak) IBOutlet UILabel *lblSalesAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblTaxAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalSalesAmount;

@end
