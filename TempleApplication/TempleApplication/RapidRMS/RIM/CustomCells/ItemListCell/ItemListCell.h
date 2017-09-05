//
//  ItemListCell.h
//  RapidRMS
//
//  Created by Siya on 15/07/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemListCell : UITableViewCell


@property (nonatomic, weak) IBOutlet UILabel *lblBarcode;
@property (nonatomic, weak) IBOutlet UILabel *lblItemName;

@end
