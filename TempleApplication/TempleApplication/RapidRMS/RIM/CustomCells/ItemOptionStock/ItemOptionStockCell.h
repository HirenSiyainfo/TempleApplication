//
//  ItemOptionStockCell.h
//  RapidRMS
//
//  Created by Siya on 24/06/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemOptionStockCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lbltitle1;
@property (nonatomic, weak) IBOutlet UILabel *lbltitle2;
@property (nonatomic, weak) IBOutlet UITextField *textValue1;
@property (nonatomic, weak) IBOutlet UITextField *textValue2;
@property (nonatomic, weak) IBOutlet UIButton *btnSearch;
@end
