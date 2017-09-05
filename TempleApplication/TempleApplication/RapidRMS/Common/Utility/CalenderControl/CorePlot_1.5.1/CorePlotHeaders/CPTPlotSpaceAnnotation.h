#import "CPTAnnotation.h"

@class CPTPlotSpace;

@interface CPTPlotSpaceAnnotation : CPTAnnotation {
    @private
    NSArray *anchorPlotPoint;
    CPTPlotSpace *plotSpace;
}

@property (nonatomic, readwrite, copy) NSArray *anchorPlotPoint;
@property (nonatomic, readonly, retain) CPTPlotSpace *plotSpace;

-(instancetype)initWithPlotSpace:(CPTPlotSpace *)space anchorPlotPoint:(NSArray *)plotPoint;

@end
