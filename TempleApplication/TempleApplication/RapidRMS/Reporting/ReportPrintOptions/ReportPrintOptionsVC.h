//
//  ReportPrintOptionsVC.h
//  RapidRMS
//
//  Created by Siya-mac5 on 24/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM (NSUInteger, PrintOption)
{
    PrintOptionShiftReport = 0,
    PrintOptionZReport,
    PrintOptionCentralizedZReport,
    PrintOptionZZReport,
    PrintOptionNone,
};

@protocol ReportPrintOptionsVCDelegate

- (void)didSelectPrinterOption:(PrintOption)printOption;
- (void)didCancelPrinterOption;

@end

@interface ReportPrintOptionsVC : UIViewController

@property (nonatomic, strong) NSArray *arrPrintOptions;
@property (nonatomic, weak) id <ReportPrintOptionsVCDelegate> reportPrintOptionsVCDelegate;
@property (nonatomic ,assign) BOOL enableShiftPrintingOption;

@end


#pragma mark - PrintOptionsCell 

@interface PrintOptionsCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel *lblReportName;
@property (nonatomic, weak) IBOutlet UIButton *btnReportPrint;

@end