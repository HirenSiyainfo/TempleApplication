//
//  CPDSecondViewController.m
//  CorePlotDemo
//
//  Created by Fahim Farook on 19/5/12.
//  Copyright (c) 2012 RookSoft Pte. Ltd. All rights reserved.
//

#import "XReportBarChart.h"


@interface XReportBarChart ()

@property (nonatomic, strong) IBOutlet CPTGraphHostingView *hostView;
@property (nonatomic, strong) CPTBarPlot *aaplPlot;
@property (nonatomic, strong) CPTBarPlot *googPlot;
@property (nonatomic, strong) CPTBarPlot *msftPlot;
@property (nonatomic, strong) CPTPlotSpaceAnnotation *priceAnnotation;

-(void)initPlot;
-(void)configureGraph;
-(void)configurePlots;
-(void)configureAxes;

@end

@implementation XReportBarChart

CGFloat const CPDBarWidth = 0.25f;
CGFloat const CPDBarInitialX = 0.25f;

@synthesize hostView    = hostView_;
@synthesize aaplPlot    = aaplPlot_;
@synthesize googPlot    = googPlot_;
@synthesize msftPlot    = msftPlot_;
@synthesize priceAnnotation = priceAnnotation_;
@synthesize arrXRepHours;

#pragma mark - Rotation
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft);
}

#pragma mark - UIViewController lifecycle methods
-(void)viewDidLoad {
    
   

    [super viewDidLoad];
    
    for (int iHr=0; iHr<arrXRepHours.count; iHr++)
    {
        NSMutableDictionary *HourRptDisc=arrXRepHours[iHr];
        NSString *stringFromDate;
        if ([[HourRptDisc valueForKey:@"Hours"] isEqualToString:@"0.00"]) {
            stringFromDate=@"";
            NSMutableDictionary *dict = [(self.arrXRepHours)[iHr]mutableCopy];
            dict[@"Hours"] = stringFromDate;
            (self.arrXRepHours)[iHr] = dict;
        }
        else
        {
            NSString *stringFromDate;
            if([self checkisJSonDate:[HourRptDisc valueForKey:@"Hours"]]){

                NSDate *date=[self jsonStringToNSDate:[HourRptDisc valueForKey:@"Hours"]];
                NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
                formatter.timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
                formatter.dateFormat = @"hh:mm a";
                stringFromDate = [formatter stringFromDate:date];
            }
            else{
                stringFromDate = [HourRptDisc valueForKey:@"Hours"];
            }
           
            
            
            NSMutableDictionary *dict = [(self.arrXRepHours)[iHr] mutableCopy];
            dict[@"Hours"] = stringFromDate;
            (self.arrXRepHours)[iHr] = dict;
        }
     
    }
    
    // descending array to get max coustomer count
    
    NSMutableArray *arrTempRepHours = [self.arrXRepHours mutableCopy];
    NSSortDescriptor *CustCount = [[NSSortDescriptor alloc] initWithKey:@"Count" ascending:YES];
    NSArray *sortDescriptors = @[CustCount];
    NSArray *sortedArray = [arrTempRepHours sortedArrayUsingDescriptors:sortDescriptors];
    
    ymax = [sortedArray.lastObject[@"Count"] floatValue ];
    
//    descending array code over
    
    // descending array to get max coustomer count
    
//    NSSortDescriptor *hourSorting = [[NSSortDescriptor alloc] initWithKey:@"Hours" ascending:YES];
//    NSArray *sortHours = @[hourSorting];
    nsarrSortHours= [self.arrXRepHours copy];
    [self initPlot];
}

-(BOOL)checkisJSonDate:(NSString *)strDate{
    BOOL isJsonDate = NO;
    if ([strDate rangeOfString:@"/Date"].location != NSNotFound)
    {
        isJsonDate = YES;
    }
    
    return isJsonDate;
}

-(NSDate*)jsonStringToNSDate :(NSString* ) string
{
    // Extract the numeric part of the date.  Dates should be in the format
    // "/Date(x)/", where x is a number.  This format is supplied automatically
    // by JSON serialisers in .NET.
    NSRange range = NSMakeRange(6, string.length - 8);
    NSString* substring = [string substringWithRange:range];
    
    // Have to use a number formatter to extract the value from the string into
    // a long long as the longLongValue method of the string doesn't seem to
    // return anything useful - it is always grossly incorrect.
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    NSNumber* milliseconds = [formatter numberFromString:substring];
    // NSTimeInterval is specified in seconds.  The value we get back from the
    // web service is specified in milliseconds.  Both values are since 1st Jan
    // 1970 (epoch).
    NSTimeInterval seconds = milliseconds.longLongValue / 1000;
    
    return [NSDate dateWithTimeIntervalSince1970:seconds];
}

#pragma mark - Chart behavior
-(void)initPlot {
    [self configureHost];
    [self configureGraph];
    [self configurePlots];
    [self configureAxes];
    
    self.hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    // Padding
    self.hostView.hostedGraph.paddingLeft = 50;
    self.hostView.hostedGraph.paddingRight = 10;
    self.hostView.hostedGraph.paddingTop = 10;
    
    self.hostView.hostedGraph.paddingBottom = 10;
    self.hostView.hostedGraph.plotAreaFrame.paddingBottom = 80;

    // Colors
//    self.hostView.backgroundColor = [UIColor yellowColor];
//    self.hostView.hostedGraph.backgroundColor = [UIColor greenColor].CGColor;
//    self.hostView.hostedGraph.plotAreaFrame.backgroundColor = [UIColor blueColor].CGColor;
    self.hostView.clipsToBounds = YES;
}

-(void)configureHost {
	// 1 - Set up view frame
	CGRect parentRect = self.view.bounds;
    
	// 2 - Create host view
	self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
	self.hostView.allowPinchScaling = NO;
	[self.view addSubview:self.hostView];
}

-(void)configureGraph
{
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
	graph.plotAreaFrame.masksToBorder = NO;
	self.hostView.hostedGraph = graph;
    
	// 2 - Configure the graph
//	[graph applyTheme:[CPTTheme themeNamed:kCPTPlainWhiteTheme]];
//	graph.paddingBottom = 30.0f;
//	graph.paddingLeft  = 30.0f;
//	graph.paddingTop    = -1.0f;
//	graph.paddingRight  = -5.0f;

	// 3 - Set up styles
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor blackColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
    
	// 4 - Set up title
//	NSString *title = @"Portfolio Prices: April 23 - 27, 2012";
//	graph.title = title;
//	graph.titleTextStyle = titleStyle;
//	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
//	graph.titleDisplacement = CGPointMake(0.0f, -16.0f);

	// 5 - Set up plot space
    CGFloat xMin = 0.0f;
	CGFloat xMax = nsarrSortHours.count;
	CGFloat yMin = 0.0f;
	CGFloat yMax = ymax+1;  // should determine dynamically based on max price
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xMin) length:CPTDecimalFromFloat(xMax)];
	plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(yMin) length:CPTDecimalFromFloat(yMax)];
}

-(void)configurePlots {
	// 1 - Set up the three plots
	self.aaplPlot = [CPTBarPlot tubularBarPlotWithColor:[CPTColor redColor] horizontalBars:NO];
	self.aaplPlot.identifier = [nsarrSortHours valueForKey:@"Count"];

	// 2 - Set up line style
	CPTMutableLineStyle *barLineStyle = [[CPTMutableLineStyle alloc] init];
	barLineStyle.lineColor = [CPTColor lightGrayColor];
	barLineStyle.lineWidth = 0.5;
	// 3 - Add plots to graph
	CPTGraph *graph = self.hostView.hostedGraph;
	CGFloat barX = CPDBarInitialX;
    NSArray *plots = [NSArray arrayWithObjects:self.aaplPlot, self.googPlot, self.msftPlot, nil];

    for (CPTBarPlot *plot in plots)
    {
		plot.dataSource = self;
		plot.delegate = self;
		plot.barWidth = CPTDecimalFromDouble(CPDBarWidth);
		plot.barOffset = CPTDecimalFromDouble(barX);
		plot.lineStyle = barLineStyle;
		[graph addPlot:plot toPlotSpace:graph.defaultPlotSpace];
		barX += CPDBarWidth;
	}
}

-(void)configureAxes {
	// 1 - Configure styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor blueColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [[CPTColor blackColor] colorWithAlphaComponent:1];
    
	// 2 - Get the graph's axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) self.hostView.hostedGraph.axisSet;
//	// 3 - Configure the x-axis
//	axisSet.xAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//	axisSet.xAxis.title = @"Days of Week (Mon - Fri)";
//	axisSet.xAxis.titleTextStyle = axisTitleStyle;
//	axisSet.xAxis.titleOffset = 10.0f;
//	axisSet.xAxis.axisLineStyle = axisLineStyle;
	// 4 - Configure the y-axis
//	axisSet.yAxis.labelingPolicy = CPTAxisLabelingPolicyNone;
//	axisSet.yAxis.title = @"Price";
//	axisSet.yAxis.titleTextStyle = axisTitleStyle;
//	axisSet.yAxis.titleOffset = 5.0f;
//	axisSet.yAxis.axisLineStyle = axisLineStyle;
    
    CPTXYAxis *x          = axisSet.xAxis;
    x.majorIntervalLength         = CPTDecimalFromString(@"1");
    x.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    x.titleLocation               = CPTDecimalFromFloat(7.5f);
    x.titleOffset                 = 25.0f;
    axisSet.xAxis.axisLineStyle = axisLineStyle;
    
    
    // Define some custom labels for the data elements
    
//    CPTXYAxis *x          = axisSet.xAxis;
    x.labelRotation  = M_PI / 3;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;

    
    NSMutableArray *customTickLocations = [[NSMutableArray alloc] init ];
    float j=0.2;
    for(float i=0;i< nsarrSortHours.count;i++)
    {
        [customTickLocations addObject:[NSString stringWithFormat:@"%.2f",j]];
        j = j + 1.0;
    }
    
    NSUInteger labelLocation     = 0;
    NSMutableArray *customLabels = [NSMutableArray arrayWithCapacity:nsarrSortHours.count];
    for ( NSNumber *tickLocation in customTickLocations )
    {
        CPTAxisLabel *newLabel = [[CPTAxisLabel alloc] initWithText: [nsarrSortHours[labelLocation++] valueForKey:@"Hours" ] textStyle:axisSet.xAxis.labelTextStyle];
        newLabel.tickLocation = tickLocation.decimalValue;
        newLabel.offset = axisSet.xAxis.labelOffset + axisSet.xAxis.majorTickLength;
        newLabel.rotation     = M_PI / 3;
        [customLabels addObject:newLabel];
    }
    
    x.axisLabels = [NSSet setWithArray:customLabels];
    CPTXYAxis *y = axisSet.yAxis;
    
    
//    y.axisLineStyle               = nil;
//    y.majorTickLineStyle          = nil;
//    y.minorTickLineStyle          = nil;
    y.majorIntervalLength         = CPTDecimalFromString(@"5");
    y.orthogonalCoordinateDecimal = CPTDecimalFromString(@"0");
    y.title                       = @"Y Axis";
    y.titleOffset                 = 45.0f;
    y.titleLocation               = CPTDecimalFromFloat(150.0f);
    
    axisSet.yAxis.axisLineStyle = axisLineStyle;
    NSNumberFormatter *yAxisFormatter = (NSNumberFormatter*)y.labelFormatter;
    yAxisFormatter.maximumFractionDigits = 0;
}
-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
{
    
    CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@", nsarrSortHours[index][@"Count"]]];
    
    CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
     plot.labelOffset=0;
    textStyle.color = [CPTColor blueColor];
    label.textStyle = textStyle;
    
    return label;
}
#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return nsarrSortHours.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
	if ((fieldEnum == CPTBarPlotFieldBarTip) && (index < nsarrSortHours.count))
    {
        return nsarrSortHours[index][@"Count"];
//        return [[sortedTimes objectAtIndex:index] valueForKey:@"Count"];
//		if ([plot.identifier isEqual:CPDTickerSymbolAAPL]) {
//			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolAAPL] objectAtIndex:index];
//		} else if ([plot.identifier isEqual:CPDTickerSymbolGOOG]) {
//			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolGOOG] objectAtIndex:index];
//		} else if ([plot.identifier isEqual:CPDTickerSymbolMSFT]) {
//			return [[[CPDStockPriceStore sharedInstance] weeklyPrices:CPDTickerSymbolMSFT] objectAtIndex:index];
//		}
	}
	return [NSDecimalNumber numberWithUnsignedInteger:index];
}

#pragma mark - CPTBarPlotDelegate methods
-(void)barPlot:(CPTBarPlot *)plot barWasSelectedAtRecordIndex:(NSUInteger)index {
	// 1 - Is the plot hidden?
	if (plot.isHidden == YES) {
		return;
	}
	// 2 - Create style, if necessary
	static CPTMutableTextStyle *style = nil;
	if (!style) {
		style = [CPTMutableTextStyle textStyle];
		style.color= [CPTColor blackColor];
		style.fontSize = 16.0f;
		style.fontName = @"Helvetica-Bold";
	}
	// 3 - Create annotation, if necessary
	NSNumber *price = [self numberForPlot:plot field:CPTBarPlotFieldBarTip recordIndex:index];
	if (!self.priceAnnotation) {
		NSNumber *x = @0;
		NSNumber *y = @0;
		NSArray *anchorPoint = @[x, y];
		self.priceAnnotation = [[CPTPlotSpaceAnnotation alloc] initWithPlotSpace:plot.plotSpace anchorPlotPoint:anchorPoint];
	}
	// 4 - Create number formatter, if needed
	static NSNumberFormatter *formatter = nil;
	if (!formatter) {
		formatter = [[NSNumberFormatter alloc] init];
		formatter.maximumFractionDigits = 2;
	}
	// 5 - Create text layer for annotation
	NSString *priceValue = [formatter stringFromNumber:price];
	CPTTextLayer *textLayer = [[CPTTextLayer alloc] initWithText:priceValue style:style];
	self.priceAnnotation.contentLayer = textLayer;
	// 6 - Get plot index based on identifier
	NSInteger plotIndex = 0;
	if ([plot.identifier isEqual:nsarrSortHours] == YES)
    {
		plotIndex = 0;
	}
	// 7 - Get the anchor point for annotation
	CGFloat x = index + CPDBarInitialX + (plotIndex * CPDBarWidth);
	NSNumber *anchorX = @(x);
	CGFloat y = price.floatValue + 40.0f;
	NSNumber *anchorY = @(y);
	self.priceAnnotation.anchorPlotPoint = @[anchorX, anchorY];
	// 8 - Add the annotation
	[plot.graph.plotAreaFrame.plotArea addAnnotation:self.priceAnnotation];
}

@end
