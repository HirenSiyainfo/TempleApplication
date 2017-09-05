//
//  DeviceBatchSummaryCustomeCell.h
//  RapidRMS
//
//  Created by Siya-mac5 on 28/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceBatchSummaryCustomeCell : UICollectionViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblSalesAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblReturnAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblAuthAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblForceAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblPostAuthAmount;

@property (nonatomic, weak) IBOutlet UILabel *lblTotalAmount;

@property (nonatomic, weak) IBOutlet UILabel *lblSalesCount;
@property (nonatomic, weak) IBOutlet UILabel *lblReturnCount;
@property (nonatomic, weak) IBOutlet UILabel *lblAuthCount;
@property (nonatomic, weak) IBOutlet UILabel *lblPostAuthCount;
@property (nonatomic, weak) IBOutlet UILabel *lblForceCount;

@property (nonatomic, weak) IBOutlet UILabel *lblTotalCount;

@property (nonatomic, weak) IBOutlet UIView *salesDetailsView;
@property (nonatomic, weak) IBOutlet UILabel *lblPaymentType;


@end
