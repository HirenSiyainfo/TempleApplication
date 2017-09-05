//
//  POVendorSelectionCell.h
//  RapidRMS
//
//  Created by Siya10 on 14/11/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POVendorSelectionCell : UITableViewCell

@property(nonatomic,strong)IBOutlet UILabel *vendorName;
@property(nonatomic,strong)IBOutlet UIButton *selectVendor;
@property (nonatomic, weak) IBOutlet UIView *viewBorder;

@end
