//
//  OpenOrder_iPhone.h
//  RapidRMS
//
//  Created by Siya Infotech on 26/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OpenOrder_iPhone : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *btnPrint;
@property (nonatomic, weak) IBOutlet UIButton *btnDelivery;
@property (nonatomic, weak) IBOutlet UILabel *lblItemName;
@property (nonatomic, weak) IBOutlet UILabel *lblPONumber;
@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;

@end
