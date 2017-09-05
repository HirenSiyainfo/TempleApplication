//
//  InvnetoryInCustomCell.h
//  I-RMS
//
//  Created by Siya Infotech on 17/09/13.
//  Copyright (c) 2013 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SupplierMasterCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblCompanyName;
@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblPhone;

@property (nonatomic, weak) IBOutlet UIImageView *imgBackGround;

@end