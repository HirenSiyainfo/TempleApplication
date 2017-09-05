#import <UIKit/UIKit.h>

@interface XReportBarChart : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate>
{
    float ymax;
    NSMutableArray *times;
    NSMutableArray *sortedTimes;
    NSArray *nsarrSortHours;
}

@property(nonatomic,strong) NSMutableArray *arrXRepHours;

@end
