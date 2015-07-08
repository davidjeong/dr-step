//
//  HistoryGraphViewController.m
//  BioWear
//
//  Created by David Jeong on 2015. 6. 7..
//
//

#import "BWHistoryGraphViewController.h"

@interface BWHistoryGraphViewController ()

@end

@implementation BWHistoryGraphViewController

@synthesize hostView = _hostView;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set value to 12 for demo.
    self.numberOfPoints = 12;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self initializeChart];
}

#pragma mark - Chart Setup

- (void)initializeChart {
    // Initialize the chart.
    [self configureHost];
    [self configureChart];
    [self configurePlots];
    [self configureAxes];
}

- (void)configureHost {
    self.hostView = [[CPTGraphHostingView alloc] initWithFrame:self.view.bounds];
    self.hostView.allowPinchScaling = NO;
    [self.view addSubview:self.hostView];
}

- (void)configureChart {
    // Create the graph and set it as hosted graph.
    CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:self.hostView.bounds];
    [graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
    self.hostView.hostedGraph = graph;
    
    graph.title = @"Occurrence of Pressures Over Last N Minutes";
    
    // Create the style used by title.
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor whiteColor];
    textStyle.fontName = @"Helvetica-Bold";
    textStyle.fontSize = 14.0f;
    
    graph.titleTextStyle = textStyle;
    graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
    graph.titleDisplacement = CGPointMake(0.0f, -10.0f);
    
    // Set padding
    [graph.plotAreaFrame setPaddingTop:60.0f];
    [graph.plotAreaFrame setPaddingLeft:30.0f];
    [graph.plotAreaFrame setPaddingBottom:30.0f];
    [graph.plotAreaFrame setPaddingRight:20.0f];
    
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)graph.defaultPlotSpace;
    plotSpace.allowsUserInteraction = NO;
    
}

- (void)configurePlots {
    CPTGraph *graph = self.hostView.hostedGraph;
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace*)graph.defaultPlotSpace;
    
    // Create plot.
    CPTScatterPlot *greenPlot = [[CPTScatterPlot alloc] init];
    greenPlot.dataSource = self;
    CPTColor *greenColor = [CPTColor greenColor];
    [graph addPlot:greenPlot toPlotSpace:plotSpace];
    
    [plotSpace scaleToFitPlots:[NSArray arrayWithObjects:greenPlot, nil]];
    
    // Expand xRange and yRange.
    CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
    [xRange expandRangeByFactor:CPTDecimalFromFloat(1.1f)];
    plotSpace.xRange = xRange;
    
    CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
    [yRange expandRangeByFactor:CPTDecimalFromFloat(1.2f)];
    plotSpace.yRange = yRange;
    
    // Configure line styles for the plot.
    CPTMutableLineStyle *greenLineStyle = [greenPlot.dataLineStyle mutableCopy];
    greenLineStyle.lineWidth = 2.5;
    greenLineStyle.lineColor = greenColor;
    greenPlot.dataLineStyle = greenLineStyle;
}

- (void)configureAxes {
    CPTMutableTextStyle *titleTextStyle = [CPTMutableTextStyle textStyle];
    titleTextStyle.color = [CPTColor whiteColor];
    titleTextStyle.fontName = @"Helvetica-Bold";
    titleTextStyle.fontSize = 12.0f;
    
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineWidth = 2.0f;
    lineStyle.lineColor = [CPTColor whiteColor];
    
    CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
    axisTextStyle.color = [CPTColor whiteColor];
    axisTextStyle.fontName = @"Helvetica-Bold";
    axisTextStyle.fontSize = 11.0f;
    
    CPTMutableLineStyle *tickStyle = [CPTMutableLineStyle lineStyle];
    tickStyle.lineColor = [CPTColor whiteColor];
    tickStyle.lineWidth = 2.0f;
    
    CPTMutableLineStyle *gridStyle = [CPTMutableLineStyle lineStyle];
    gridStyle.lineColor = [CPTColor blackColor];
    tickStyle.lineWidth = 1.0f;
    
    CPTXYAxisSet *axisSet = (CPTXYAxisSet*)self.hostView.hostedGraph.axisSet;
    
    // Set x axis.
    CPTAxis *x = axisSet.xAxis;
    x.title = @"Time";
    x.titleTextStyle = axisTextStyle;
    x.titleOffset = 15.0f;
    x.axisLineStyle = lineStyle;
    x.labelingPolicy = CPTAxisLabelingPolicyNone;
    x.labelTextStyle = axisTextStyle;
    x.majorTickLength = 4.0f;
    x.tickLabelDirection = CPTSignNegative;
    NSMutableSet *xLabels = [NSMutableSet setWithCapacity:self.numberOfPoints];
    NSMutableSet *xLocations = [NSMutableSet setWithCapacity:self.numberOfPoints];
    
    for (NSUInteger i = 0; i < self.numberOfPoints; i++) {
        CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%d", (int)i] textStyle:x.labelTextStyle];
        CGFloat location = i;
        label.tickLocation = CPTDecimalFromCGFloat(location);
        label.offset = x.majorTickLength;
        if (label) {
            [xLabels addObject:label];
            [xLocations addObject:[NSNumber numberWithFloat:location]];
        }
    }
    x.axisLabels = xLabels;
    x.majorTickLocations = xLocations;
    
    CPTAxis *y = axisSet.yAxis;
    y.title = @"Frequency";
    y.titleTextStyle = axisTextStyle;
    y.titleOffset = -40.0f;
    y.axisLineStyle = lineStyle;
    y.majorGridLineStyle = gridStyle;
    y.labelingPolicy = CPTAxisLabelingPolicyNone;
    y.labelTextStyle = axisTextStyle;
    y.labelOffset = 16.0f;
    y.majorTickLineStyle = lineStyle;
    y.majorTickLength = 4.0f;
    y.minorTickLength = 2.0f;
    y.tickDirection = CPTSignPositive;
    
    NSInteger majorIncrement = 10;
    NSInteger minorIncrement = 5;
    
    NSMutableSet *yLabels = [NSMutableSet set];
    NSMutableSet *yMajorLocations = [NSMutableSet set];
    NSMutableSet *yMinorLocations = [NSMutableSet set];
    for (NSInteger i = minorIncrement; i <= 250; i += minorIncrement) {
        NSUInteger mod = i % majorIncrement;
        if (mod == 0) {
            CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", (int)i] textStyle:y.labelTextStyle];
            NSDecimal location = CPTDecimalFromInteger(i);
            label.tickLocation = location;
            label.offset = -y.majorTickLength - y.labelOffset;
            if (label) {
                [yLabels addObject:label];
            }
            [yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
        } else {
            [yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(i)]];
        }
    }
    y.axisLabels = yLabels;
    y.majorTickLocations = yMajorLocations;
    y.minorTickLocations = yMinorLocations;
    
}

#pragma mark - CPTPlotDataSource

- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return self.numberOfPoints;
}

- (NSNumber*)numberForPlot:(CPTPlot*)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)idx{
    switch (fieldEnum) {
        case CPTScatterPlotFieldX:
            return [NSNumber numberWithInt:(int)idx];
            break;
        case CPTScatterPlotFieldY:
            return [NSNumber numberWithInt:(int)(idx*idx) - 5];
        default:
            break;
    }
    return [NSDecimalNumber zero];
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
