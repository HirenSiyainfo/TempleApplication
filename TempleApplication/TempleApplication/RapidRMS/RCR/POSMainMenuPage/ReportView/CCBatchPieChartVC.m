//
//  CCBatchPieChartVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 7/7/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "CCBatchPieChartVC.h"
#import "RmsDbController.h"
#import "RapidPlot.h"

@interface CCBatchPieChartVC ()
@property (nonatomic, strong) CPTGraphHostingView *hostView;
@property (strong, nonatomic) RmsDbController *rmsDbController;

-(void)initPlot;
-(void)configureHost;
-(void)configureGraph;
-(void)configureChart;
-(void)configureLegend;

@end

@implementation CCBatchPieChartVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.view.layer.borderWidth = 0.5;

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
    
    CGRect graphFrame = self.view.bounds;
//    graphFrame.size.width =  graphFrame.size.width/2;
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:graphFrame];
    self.hostView.hostedGraph = graph;
    graph.plotAreaFrame.paddingRight = 215.0;
    graph.paddingLeft = 0.0f;
    graph.paddingTop = 0.0f;
    graph.paddingRight = 0.0f;
    graph.paddingBottom = 0.0f;
    graph.axisSet = nil;
    
    // 2 - Set up text style
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor blackColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 5.0f;
    
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
    CPTPieChart *pieChart = [[RapidPlot alloc] init];
    pieChart.dataSource = self;
    pieChart.delegate = self;
    pieChart.pieRadius = (self.hostView.bounds.size.height * 0.6) / 2;
    pieChart.identifier = graph.title;
    pieChart.startAngle = M_PI_4;
    pieChart.sliceDirection = CPTPieDirectionClockwise;
    pieChart.centerAnchor = CGPointMake(0.5, 0.5);
    pieChart.pieInnerRadius = 50.0;

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
 //  theLegend.numberOfRows = 14;

    theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
    theLegend.borderLineStyle = [CPTLineStyle lineStyle];
    theLegend.cornerRadius = 5.0;
    
    CPTMutableTextStyle *mySmallerTextStyle = [[CPTMutableTextStyle alloc] init];
    mySmallerTextStyle.fontName = @"Helvetica-Bold";
    mySmallerTextStyle.fontSize = 5.0f;
    
    //This is the important property for your needs
    mySmallerTextStyle.fontSize = 5;

    graph.legend.textStyle = (CPTTextStyle *)mySmallerTextStyle;
    
    // 4 - Add legend to graph
    graph.legend = theLegend;
    graph.legendAnchor = CPTRectAnchorRight;
    CGFloat legendPadding = -(self.view.bounds.size.width / 10);
   // CGFloat legendPadding = 0;

    graph.legendDisplacement = CGPointMake(legendPadding, 0.0);
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot
{
    
    return self.cardDetails.count;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index
{
    if (CPTPieChartFieldSliceWidth == fieldEnum)
    {
        NSNumber *LegendTitle = [(self.cardDetails)[index] valueForKey:@"Amount"];
        return LegendTitle;
    }
    return [NSDecimalNumber zero];
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    if (index < self.cardDetails.count)
    {
        NSString *LegendTitle = [NSString stringWithFormat:@"%@ (%@) ",[(self.cardDetails)[index] valueForKey:@"Card" ],[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",[[(self.cardDetails)[index] valueForKey:@"Amount"] floatValue]]]];
        return LegendTitle;
    }
    return @"N/A";
}

-(void)legend:(CPTLegend *)legend legendEntryForPlot:(CPTPlot *)plot wasSelectedAtIndex:(NSUInteger)idx
{
    NSString *LegendTitle = [NSString stringWithFormat:@"%@ (%@) ",[(self.cardDetails)[idx] valueForKey:@"Card" ],[self.rmsDbController applyCurrencyFomatter:[NSString stringWithFormat:@"%f",[[(self.cardDetails)[idx] valueForKey:@"Amount"] floatValue]]]];
    NSLog(@"LegendTitle = %@",LegendTitle);

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
