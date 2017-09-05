//
//  ShiftHistoryCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/13/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ShiftHistoryCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblRegisterName;
@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblShiftCount;
@property (nonatomic, weak) IBOutlet UILabel *lblSales;
@property (nonatomic, weak) IBOutlet UILabel *lblTax;
@property (nonatomic, weak) IBOutlet UILabel *lblTotalSales;
@property (nonatomic, weak) IBOutlet UIImageView *backgroundImgView;
@property (nonatomic, weak) IBOutlet UILabel *lblRegName;
@property (nonatomic, weak) IBOutlet UILabel *lblCustDate;
@property (nonatomic, weak) IBOutlet UILabel *lblShift;
@property (nonatomic, weak) IBOutlet UILabel *lblCusSales;
@property (nonatomic, weak) IBOutlet UILabel *lblCusTax;
@property (nonatomic, weak) IBOutlet UILabel *lblToatalSales;

-(void)updateWithShiftDetailDict :(NSMutableDictionary *)shiftDict;

@end
