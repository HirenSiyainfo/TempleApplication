#import <UIKit/UIKit.h>
#import "ReportViewController.h"

@interface XReportPieChart : UIViewController <CPTPlotDataSource>

@property(nonatomic,strong) NSMutableArray *arrXRepDepartment;
@property(nonatomic,strong) NSString *StrLableName;
@property (nonatomic,strong) ReportViewController *objReportView;

@end
