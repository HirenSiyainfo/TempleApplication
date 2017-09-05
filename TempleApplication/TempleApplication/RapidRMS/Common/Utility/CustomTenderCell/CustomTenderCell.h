//
//  CustomTenderCell.h
//  POSRetail
//
//  Created by Keyur Patel on 14/06/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AsyncImageWithOutLoding.h"
@interface CustomTenderCell : UITableViewCell
{
   
 
    IBOutlet UIImageView *cellBackground;
    IBOutlet UIButton *btnClickCell1;
    IBOutlet UIButton *btnClickCell2;
    
    IBOutlet UILabel *lblPayId;
    IBOutlet UILabel *lblPaymentName;
    IBOutlet UILabel *lblAmount;
    
}
@property(nonatomic,retain)IBOutlet AsyncImageWithOutLoding *payImage;
@property(nonatomic,retain)IBOutlet UILabel *lblPaymentName;
@property(nonatomic,retain)IBOutlet UILabel *lblAmount;
@property(nonatomic,retain)IBOutlet UIImageView *cellBackground;
@property(nonatomic,retain)IBOutlet UIButton *btnClickCell1;
@property(nonatomic,retain)IBOutlet UIButton *btnClickCell2;
@property(nonatomic,retain)IBOutlet UILabel *lblPayId;
@property(nonatomic,retain)IBOutlet UIButton *addPaymentMode;
@property(nonatomic,retain)IBOutlet UIButton *btnCancel;


@end
