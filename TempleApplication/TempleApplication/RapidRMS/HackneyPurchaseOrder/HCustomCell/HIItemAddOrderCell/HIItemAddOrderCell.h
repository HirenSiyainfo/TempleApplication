//
//  HIItemAddOrderCell.h
//  RapidRMS
//
//  Created by Siya on 10/02/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HIItemAddOrderCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *btnUnitMinus;
@property (nonatomic, weak) IBOutlet UITextField *txtUnit;
@property (nonatomic, weak) IBOutlet UIButton *btnUnitPlus;

@property (nonatomic, weak) IBOutlet UIButton *btnCaseMinus;
@property (nonatomic, weak) IBOutlet UITextField *txtCase;
@property (nonatomic, weak) IBOutlet UIButton *btnCasePlus;

@property (nonatomic, weak) IBOutlet UILabel *lblTotalCost;
@property (nonatomic, weak) IBOutlet UIButton *btnAddtoOrder;

@end
