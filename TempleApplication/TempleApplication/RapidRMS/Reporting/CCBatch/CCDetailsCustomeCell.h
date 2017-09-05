//
//  CCDetailsCustomeCell.h
//  RapidRMS
//
//  Created by Siya-mac5 on 27/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCDetailsCustomeCellDelegate <NSObject>
-(void)didSelectRecordForTipAdjustmentAtIndexPath:(NSIndexPath *)indexpath;
@end

@interface CCDetailsCustomeCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblDateAndTime;
@property (nonatomic, weak) IBOutlet UILabel *lblCardNumber;
@property (nonatomic, weak) IBOutlet UILabel *lblCradType;
@property (nonatomic, weak) IBOutlet UILabel *lblAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblTips;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalAmount;
@property (nonatomic, weak) IBOutlet UILabel *lblAuth;
@property (nonatomic, weak) IBOutlet UILabel *lblInvoiceNo;
@property (nonatomic, weak) IBOutlet UILabel *lblTransactionStatus;

@property (nonatomic, weak) IBOutlet UIButton *btnTips;

@property (nonatomic, strong) NSIndexPath *indexPathForCell;

@property (nonatomic, weak) id <CCDetailsCustomeCellDelegate> cCDetailsCustomeCellDelegate;

@end
