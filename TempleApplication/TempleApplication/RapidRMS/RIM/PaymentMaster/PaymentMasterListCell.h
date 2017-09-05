//
//  PaymentMasterListCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 9/25/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PaymentMasterListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *paymentName;
@property (nonatomic, weak) IBOutlet UILabel *paymentCode;
@property (nonatomic, weak) IBOutlet AsyncImageView *paymentImage;

@end
