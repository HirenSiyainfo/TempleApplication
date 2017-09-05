//
//  PendingDeliveryPOCell_iPhone.h
//  RapidRMS
//
//  Created by Siya Infotech on 27/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PendingDeliveryPOCell_iPhone : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblPONumber;
@property (nonatomic, weak) IBOutlet UILabel *lblOrderNumber;
@property (nonatomic, weak) IBOutlet UILabel *lblDeliveryDate;
@property (nonatomic, weak) IBOutlet UILabel *lblDeliveryTime;
@property (nonatomic, weak) IBOutlet UIButton *btnPrint;
@property (nonatomic, weak) IBOutlet UIButton *btnClose;
@end
