//
//  CCbatchReportCell.h
//  RapidRMS
//
//  Created by siya-IOS5 on 6/27/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CCbatchReportCellDelegate<NSObject>
-(void)didSelectTransactionAtIndexPath :(NSIndexPath *)indexpath;
-(void)didSelectForceTransactionAtIndexPath :(NSIndexPath *)indexpath;
-(void)didSelectVoidTransactionAtIndexPath :(NSIndexPath *)indexpath;

@end


@interface CCbatchReportCell : UITableViewCell
@property(nonatomic,weak) IBOutlet UILabel *lblDate;
@property(nonatomic,weak) IBOutlet UILabel *accountNo;
@property(nonatomic,weak) IBOutlet UILabel *cardType;
@property(nonatomic,weak) IBOutlet UILabel *amount;
@property(nonatomic,weak) IBOutlet UILabel *authCode;
@property(nonatomic,weak) IBOutlet UILabel *invoice;
@property(nonatomic,weak) IBOutlet UIImageView *bgImageView;
@property(nonatomic,weak) IBOutlet UILabel *tipsAmount;
@property(nonatomic,weak) IBOutlet UILabel *totalAmount;
@property(nonatomic,weak) IBOutlet UIButton *totalTips;
@property(nonatomic,weak) IBOutlet UIButton *buttonTransType;
@property(nonatomic,weak) IBOutlet UIButton *voidButton;
@property(nonatomic,weak) IBOutlet UIButton *forceButton;


@property (nonatomic, strong) NSIndexPath *indexPathForCell;

@property (nonatomic, weak) id<CCbatchReportCellDelegate> ccbatchReportCellDelegate;

@end
