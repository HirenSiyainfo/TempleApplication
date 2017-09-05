//
//  XReportpaymentPieChart.m
//  POSRetail
//
//  Created by Siya Infotech on 24/12/13.
//  Copyright (c) 2013 Nirav Patel. All rights reserved.
//

#import "XReportpaymentPieChart.h"
#import "RmsDbController.h"

@interface XReportpaymentPieChart ()

@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (strong, nonatomic) RmsDbController *rmsDbController;

-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;
@end

@implementation XReportpaymentPieChart

@synthesize hostView = hostView_;
@synthesize arrXRepDepartment,StrLableName;
@synthesize objPayReportView;

#pragma mark - UIViewController lifecycle methods
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // The plot is initialized here, since the view bounds have not transformed for landscape till now
    [self initPlot];
}

#pragma mark - Chart behavior
-(void)initPlot
{
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    [self configureHost];
    [self configureGraph];
    [self configureChart];
    [self configureLegend];

    self.hostView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

-(void)configureHost {
	// 1 - Set up view frame
	CGRect parentRect = self.view.bounds;
    
	// 2 - Create host view
	self.hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
	self.hostView.allowPinchScaling = NO;
	[self.view addSubview:self.hostView];
}

-(void)configureGraph {
	// 1 - Create and initialise graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.view.bounds];
	self.hostView.hostedGraph = graph;
    graph.plotAreaFrame.paddingLeft = -150.0;
	graph.paddingLeft = 0.0f;
	graph.paddingTop = 0.0f;
	graph.paddingRight = 0.0f;
	graph.paddingBottom = 0.0f;
	graph.axisSet = nil;
    
	// 2 - Set up text style
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color = [CPTColor blackColor];
	textStyle.fontName = @"Helvetica-Bold";
	textStyle.fontSize = 16.0f;
    
	// 3 - Configure title
    /*	NSString *title = StrLableName;
     graph.title = title;
     graph.titleTextStyle = textStyle;
     graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
     graph.titleDisplacement = CGPointMake(0.0f, -40.0f);*/
}

-(void)configureChart
{
	// 1 - Get reference to graph
	CPTGraph *graph = self.hostView.hostedGraph;
    
	// 2 - Create chart
	CPTPieChart *pieChart = [[CPTPieChart alloc] init];
	pieChart.dataSource = self;
	pieChart.delegate = self;
	pieChart.pieRadius = (self.hostView.bounds.size.height * 0.6) / 2;
	pieChart.identifier = graph.title;
	pieChart.startAngle = M_PI_4;
	pieChart.sliceDirection = CPTPieDirectionClockwise;
    
	// 3 - Create gradient
	CPTGradient *overlayGradient = [[CPTGradient alloc] init];
	overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
	pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
    
	// 4 - Add chart to graph
	[graph addPlot:pieChart];
}

-(void)configureLegend
{
    // 1 - Get graph instance
    CPTGraph *graph = self.hostView.hostedGraph;
    
    // 2 - Create legend
    CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
    
    // 3 - Configure legen
    theLegend.numberOfColumns = 1;
    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 10);
    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
	return self.arrXRepDepartment.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
	if (CPTPieChartFieldSliceWidth == fieldEnum)
    {
		if([objPayReportView.strTypeofChart isEqualToString:@"Dollorwise"])
        {
            return [(self.arrXRepDepartment)[index] valueForKey:@"Amount" ];
        }
        else
        {
            NSNumber *sum=[self.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
            float pcnt = ([[(self.arrXRepDepartment)[index] valueForKey:@"Amount" ] floatValue ] * 100) / sum.floatValue ;
            return @(pcnt);
        }
	}
	return [NSDecimalNumber zero];
}

//-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index
//{
//	// 1 - Define label text style
//	static CPTMutableTextStyle *labelText = nil;
//	if (!labelText) {
//		labelText= [[CPTMutableTextStyle alloc] init];
//		labelText.color = [CPTColor grayColor];
//	}
//
//	// 3 - Calculate percentage value
//    //	NSString *strDept = [[self.arrXRepDepartment objectAtIndex:index] valueForKey:@"Descriptions" ];
//	float percent = [[[self.arrXRepDepartment objectAtIndex:index] valueForKey:@"Per" ] floatValue ];
//
//	// 4 - Set up display label
//    //       NSString * labelValue = [NSString stringWithFormat:@"$%@ - (%0.1f %%)", strDept, percent];
//    NSString *labelValue = [NSString stringWithFormat:@"%0.2f %%",percent];
//
//	// 5 - Create and return layer with label text
//    CPTTextLayer *label = [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
//
//    //    label.paddingLeft = 10.0f; //
//
//	return label;
//}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
	if (index < self.arrXRepDepartment.count)
    {
        if([objPayReportView.strTypeofChart isEqualToString:@"Dollorwise"])
        {
            NSString *LegendTitle = [NSString stringWithFormat:@"%@ (%@) ",[(self.arrXRepDepartment)[index] valueForKey:@"Descriptions" ],[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",[[(self.arrXRepDepartment)[index] valueForKey:@"Amount"] floatValue]]]];
            return LegendTitle;
        }
        else
        {
            NSNumber *sum=[self.arrXRepDepartment valueForKeyPath:@"@sum.Amount"];
            float pcnt = ([[(self.arrXRepDepartment)[index] valueForKey:@"Amount" ] floatValue ] * 100) / sum.floatValue ;
            
            NSString *LegendTitle = [NSString stringWithFormat:@"%@ (%.2f%%) ",[(self.arrXRepDepartment)[index] valueForKey:@"Descriptions" ],pcnt];
            return LegendTitle;
            
        }
        //        return [[self.arrXRepDepartment objectAtIndex:index] valueForKey:@"Descriptions" ];
	}
	return @"N/A";
}
//-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
//    
//    if([plot isKindOfClass:[CPTPieChart class]]) {
//        static CPTMutableTextStyle *labelText = nil;
//        if (!labelText) {
//            labelText= [[CPTMutableTextStyle alloc] init];
//            labelText.color = [CPTColor blackColor];
//            
//        }
//        
//        NSDecimalNumber *portfolioSum = [NSDecimalNumber zero];
//        for (NSDecimalNumber *price in [self.arrXRepDepartment objectAtIndex:index] ) {
//            portfolioSum = [portfolioSum decimalNumberByAdding:price];
//        }
//        NSDecimalNumber *countValue = [[self.arrXRepDepartment objectAtIndex:index] valueForKey:@"Descriptions" ];
//        NSString *labelValue = [NSString stringWithFormat:@"%@",countValue];
//        CPTTextLayer *textLayer = [[CPTTextLayer alloc]initWithText:labelValue];
//        plot.labelOffset=0;
//        plot.labelRotation=45.0;
//        return textLayer;
//    }
//    else {
//        
//        return nil;
//    }
//}

@end
