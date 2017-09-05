//
//  ZRequiredViewController.h
//  POSFrontEnd
//
//  Created by Nirav Patel on 08/11/12.
//
//

#import <UIKit/UIKit.h>
#import "POSLoginView.h"
#import "ReportViewController.h"
@interface ZRequiredViewController : UIViewController<UIPrintInteractionControllerDelegate>
{
    POSLoginView *objPL;
    ReportViewController *objReport;
}
@property(nonatomic,strong)NSMutableArray *arrayResponse;
@property(nonatomic,weak)UIButton *btnOpeningAmt;
@property(nonatomic,strong) NSString *strmanageArray;
@property(nonatomic,strong)POSLoginView *objPL;
@property(nonatomic,strong )  ReportViewController *objReport;


-(IBAction)OpeningAmt:(id)sender;
-(IBAction)cancel:(id)sender;
@end
