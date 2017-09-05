//
//  TaxMasterCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 25/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TaxMasterCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblName;
@property (nonatomic, weak) IBOutlet UILabel *lblAmount;

@property (nonatomic, weak) IBOutlet UIButton *btnDelete;
@property (nonatomic, weak) IBOutlet UIView *viewOperation;

@end
