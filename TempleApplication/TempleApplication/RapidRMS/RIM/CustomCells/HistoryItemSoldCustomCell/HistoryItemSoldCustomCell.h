//
//  DiscountSelectionCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 13/06/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HistoryItemSoldCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * lblTitle;
@property (nonatomic, weak) IBOutlet UILabel * lblValue1;// singleQty
@property (nonatomic, weak) IBOutlet UILabel * lblValue2;// caseQty
@property (nonatomic, weak) IBOutlet UILabel * lblValue3;// packQty;

@end