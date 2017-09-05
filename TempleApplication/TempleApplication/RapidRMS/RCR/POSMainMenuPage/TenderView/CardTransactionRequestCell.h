//
//  CardTransactionRequestCell.h
//  RapidRMS
//
//  Created by Siya Infotech on 5/10/17.
//  Copyright © 2017 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CardTransactionRequestCell : UITableViewCell

@property(nonatomic,strong)IBOutlet UILabel *lblInvoice;
@property(nonatomic,strong)IBOutlet UILabel *lblTransactionID;
@property(nonatomic,strong)IBOutlet UILabel *lblAmount;
@property(nonatomic,strong)IBOutlet UILabel *lblTransType;
@property(nonatomic,strong)IBOutlet UILabel *statusLabel;
@property(nonatomic,strong)IBOutlet UIButton *btnVoid;


@end
