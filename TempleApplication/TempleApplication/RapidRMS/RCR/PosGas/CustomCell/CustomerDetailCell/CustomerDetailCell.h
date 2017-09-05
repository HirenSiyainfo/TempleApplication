//
//  CustomerDetailCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 29/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomerDetailCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblFirstName;
@property (nonatomic, weak) IBOutlet UILabel *lblLastName;
@property (nonatomic, weak) IBOutlet UILabel *lblConatctNo;
@property (nonatomic, weak) IBOutlet UILabel *lblEmail;
@property (nonatomic, weak) IBOutlet UILabel *lblCity;
@property (nonatomic, weak) IBOutlet UILabel *lblZipCode;
@property (nonatomic, weak) IBOutlet UILabel *lblQRcode;
@property (nonatomic,weak) IBOutlet UIView *viewOperation;
@property (nonatomic,weak) IBOutlet UIButton *btnDelete;
@property (nonatomic,weak) IBOutlet UIButton *btnView;

@end
