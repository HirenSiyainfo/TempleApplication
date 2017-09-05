//
//  OfflineRecordCustomCell.h
//  RapidRMS
//
//  Created by Siya on 08/09/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfflineRecordCustomCell : UITableViewCell
{
     UILabel *lblBillAmount;
     UILabel *lblRegInvoiceNo;
     UILabel *lblPaymentType;
    
}
@property(nonatomic,strong)IBOutlet UILabel *lblBillAmount;
@property(nonatomic,strong)IBOutlet UILabel *lblRegInvoiceNo;
@property(nonatomic,strong)IBOutlet UILabel *lblPaymentType;
@property(nonatomic,strong)IBOutlet UILabel *lblInvoiceDate;
@property(nonatomic,weak)IBOutlet UIButton *btnPrint;


@end
