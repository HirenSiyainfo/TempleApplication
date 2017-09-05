//
//  DiscountBillDetailVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 3/9/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "DiscountBillDetailVC.h"
#import "DiscountGraphView.h"


@interface DiscountBillDetailVC ()<UIScrollViewDelegate>
{
    IBOutlet UIScrollView *scrollView;
}

@property (nonatomic, weak) IBOutlet DiscountGraphView *discountGraphView;
@property (nonatomic, weak) NSArray *graphPath;


@end

@implementation DiscountBillDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    scrollView.contentSize = CGSizeMake(self.discountGraphView.frame.size.width, self.discountGraphView.frame.size.height);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


- (void)plotGraph:(DiscountGraphNode*)graphNode withPath:(NSArray *)path{
    self.discountGraphView.pathForView = path;
    
    for (GKGraphNode *graphNodes in graphNode.connectedNodes) {
        NSArray *connectedGraphNode = [graphNodes connectedNodes];
        NSLog(@"connectedGraphNode %@",connectedGraphNode);

        for (GKGraphNode *subGraphNodes in connectedGraphNode) {
            NSArray *connectedsubGraphNodesGraphNode = [subGraphNodes connectedNodes];
            NSLog(@"connectedsubGraphNodesGraphNode %@",connectedsubGraphNodesGraphNode);
            
        }
        
    }
    
    [self.discountGraphView configureWith:graphNode];
}

-(IBAction)btnCancelClick:(id)sender
{
    [self.discountBillDetailDelegate didCancelDiscountView];
}



@end
