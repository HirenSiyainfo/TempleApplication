//
//  ManualOptionCell_iPad.h
//  RapidRMS
//
//  Created by Siya on 21/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ManualOptionCell_iPad : UITableViewCell
{
    
}
@property (nonatomic, weak) IBOutlet UILabel *lblTitle;
@property (nonatomic, weak) IBOutlet UILabel *lblBarcode;
@property (nonatomic, weak) IBOutlet UILabel *lblsoldqty;
@property (nonatomic, weak) IBOutlet UILabel *lblavailableqty;
@property (nonatomic, weak) IBOutlet UILabel *lblreorder;
@property (nonatomic, weak) IBOutlet UILabel *lblmax;
@property (nonatomic, weak) IBOutlet UILabel *lblmin;

@property (nonatomic, weak) IBOutlet UIImageView *imgCheck;
@end
