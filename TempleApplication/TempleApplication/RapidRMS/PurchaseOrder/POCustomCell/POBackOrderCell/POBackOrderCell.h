//
//  POBackOrderCell.h
//  RapidRMS
//
//  Created by Siya10 on 16/10/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface POBackOrderCell : UITableViewCell

@property(nonatomic,weak) IBOutlet UILabel *itemName;
@property(nonatomic,weak) IBOutlet UILabel *barcode;
@property(nonatomic,weak) IBOutlet UILabel *soldQty;
@property(nonatomic,weak) IBOutlet UILabel *availabeQty;
@property(nonatomic,weak) IBOutlet UILabel *singleQty;
@property(nonatomic,weak) IBOutlet UILabel *caseQty;
@property(nonatomic,weak) IBOutlet UILabel *packQty;
@property(nonatomic,weak) IBOutlet UIImageView *imgSelection;
@end
