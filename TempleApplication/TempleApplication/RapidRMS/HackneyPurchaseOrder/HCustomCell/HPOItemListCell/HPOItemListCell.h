//
//  HPOItemListCell.h
//  RapidRMS
//
//  Created by Siya on 25/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HPOItemListCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblitemName;
@property (nonatomic, weak) IBOutlet UILabel *lblUPC;

@property (nonatomic, weak) IBOutlet UILabel *lblPrice;
@property (nonatomic, weak) IBOutlet UILabel *lblCaseCount;
@property (nonatomic, weak) IBOutlet UILabel *lblUnitCount;

@property (nonatomic, weak) IBOutlet UILabel *lblCasePrice;
@property (nonatomic, weak) IBOutlet UILabel *lblUnitPrice;

@property (nonatomic, weak) IBOutlet UIView *viewCase;
@property (nonatomic, weak) IBOutlet UIView *viewUnit;

@end
