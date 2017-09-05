//
//  GenerateOrderPoCell.h
//  RapidRMS
//
//  Created by Siya on 27/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GenerateOrderPoCell : UITableViewCell
{
    
    
}
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblBarcode;

@property (nonatomic, weak) IBOutlet UILabel *lblsoldqty;
@property (nonatomic, weak) IBOutlet UILabel *lblavailableqty;
@property (nonatomic, weak) IBOutlet UILabel *lblmax;
@property (nonatomic, weak) IBOutlet UILabel *lblmin;

@property (nonatomic, weak) IBOutlet UITextField *txtReorder;

@property (nonatomic, weak) IBOutlet UIButton *btnItemInfo;

@end
