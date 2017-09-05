//
//  RIMSupplierVendorCell.h
//  RapidRMS
//
//  Created by Siya9 on 22/04/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RIMSupplierVendorCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel * lblName;
@property (nonatomic, weak) IBOutlet UILabel * lblEmail;
@property (nonatomic, weak) IBOutlet UILabel * lblContect;
@property (nonatomic, weak) IBOutlet UILabel * lblPosion;
@property (nonatomic, weak) IBOutlet UIImageView * imgIsSelected;
@property (nonatomic, weak) IBOutlet UIButton * btnAction;
@end
