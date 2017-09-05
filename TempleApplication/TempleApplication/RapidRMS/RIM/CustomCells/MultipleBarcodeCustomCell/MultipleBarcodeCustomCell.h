//
//  TenderItemTableCustomCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 01/07/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MultipleBarcodeCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *barcode;
@property (nonatomic, weak) IBOutlet UILabel *alreadyExist;
@property (nonatomic, weak) IBOutlet UIButton *deleteBarcode;

@end
