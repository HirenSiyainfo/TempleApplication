//
//  DiscountGraphView.m
//  RapidDiscountDemo
//
//  Created by siya info on 06/02/16.
//  Copyright © 2016 siya info. All rights reserved.
//

#import "DiscountGraphView.h"
#import "DiscountGraphNode.h"


@interface DiscountGraphView ()
{
    NSMutableArray *alreadyDrawedNodes;
}
@end

@implementation DiscountGraphView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView*)viewForNode:(DiscountGraphNode*)graphNode parentView:(UIView*)parentView {
    UIView *nodeContainer = [[UIView alloc] initWithFrame:CGRectZero];
    nodeContainer.backgroundColor = [UIColor whiteColor];
    nodeContainer.translatesAutoresizingMaskIntoConstraints = NO;

    [parentView addSubview:nodeContainer];

//    NSLayoutConstraint *a = [nodeContainer.heightAnchor constraintEqualToConstant:5];
    [nodeContainer.heightAnchor constraintGreaterThanOrEqualToConstant:50].active = YES;
    [nodeContainer.widthAnchor constraintGreaterThanOrEqualToConstant:50].active = YES;

    UILabel *nodeLabel = [self addLabelToNode:nodeContainer];

    UIView *childContainer = [self addChildContainertoNode:nodeContainer];

    [nodeLabel.bottomAnchor constraintEqualToAnchor:childContainer.topAnchor constant:-5].active = YES;
    [childContainer.widthAnchor constraintEqualToAnchor:nodeContainer.widthAnchor];

    [self addChildNodesToContainer:childContainer graphNode:graphNode];

    if (graphNode.discount.discountName.length > 0) {
        if ([self isNodeAvailableInPath:graphNode]) {
            nodeLabel.backgroundColor = [UIColor purpleColor];
        }
        nodeLabel.text = [NSString stringWithFormat:@"%@\n(%.2f)", graphNode.discount.discountName, [graphNode totalDiscount]];
    } else {
        nodeLabel.text = @"-";
    }
    
    return nodeContainer;
}
-(BOOL)isNodeAvailableInPath:(DiscountGraphNode *)graphNode
{
    BOOL isNodeAvailableInPath = FALSE;
    for (DiscountGraphNode *node in  self.pathForView) {
        if ([node isEqual:graphNode]) {
            isNodeAvailableInPath = TRUE;
        }
        
    }
    return   isNodeAvailableInPath;
}

- (void)configureWith:(DiscountGraphNode*)rootNode {
    alreadyDrawedNodes = [[NSMutableArray alloc]init];
    self.backgroundColor = [UIColor purpleColor];
    self.translatesAutoresizingMaskIntoConstraints = NO;

    UIView *nodeContainer = [self viewForNode:rootNode parentView:self];

    [nodeContainer.topAnchor constraintEqualToAnchor:self.topAnchor constant:5].active = YES;
    [nodeContainer.leftAnchor constraintGreaterThanOrEqualToAnchor:self.leftAnchor constant:5].active = YES;
    [self.rightAnchor constraintEqualToAnchor:nodeContainer.rightAnchor constant:5].active = YES;
    [self.bottomAnchor constraintEqualToAnchor:nodeContainer.bottomAnchor constant:5].active = YES;
}

- (UILabel*)addLabelToNode:(UIView *)nodeContainer {
    UILabel *nodeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    nodeLabel.backgroundColor = [UIColor greenColor];
    nodeLabel.numberOfLines = 0;

    nodeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [nodeContainer addSubview:nodeLabel];

    [nodeLabel.topAnchor constraintEqualToAnchor:nodeContainer.topAnchor constant:5].active = YES;
    [nodeLabel.centerXAnchor constraintEqualToAnchor:nodeContainer.centerXAnchor].active = YES;
    [nodeLabel.leftAnchor constraintGreaterThanOrEqualToAnchor:nodeContainer.leftAnchor constant:5].active = YES;
    [nodeContainer.rightAnchor constraintGreaterThanOrEqualToAnchor:nodeLabel.rightAnchor constant:5].active = YES;
    [nodeContainer.bottomAnchor constraintGreaterThanOrEqualToAnchor:nodeLabel.bottomAnchor constant:5].active = YES;

    return nodeLabel;
}

- (UIView*)addChildContainertoNode:(UIView *)nodeContainer {
    UIView *childContainer = [[UIView alloc] initWithFrame:CGRectZero];
    childContainer.backgroundColor = [UIColor blackColor];
    
    childContainer.translatesAutoresizingMaskIntoConstraints = NO;
    [nodeContainer addSubview:childContainer];
    
    [childContainer.leftAnchor constraintGreaterThanOrEqualToAnchor:nodeContainer.leftAnchor constant:10].active = YES;
    [nodeContainer.rightAnchor constraintGreaterThanOrEqualToAnchor:childContainer.rightAnchor constant:10].active = YES;
    [childContainer.bottomAnchor constraintEqualToAnchor:nodeContainer.bottomAnchor constant:-5].active = YES;
    
    [childContainer.heightAnchor constraintGreaterThanOrEqualToConstant:10].active = YES;

    return childContainer;
}

- (void)addChildNodesToContainer:(UIView*)childContainer graphNode:(DiscountGraphNode *)graphNode {
    UIView *neighbourView = nil;
    for (DiscountGraphNode *node in [graphNode connectedNodes]) {
        
        if ([alreadyDrawedNodes containsObject:node]) {
            continue;
        }
        else
        {
            [alreadyDrawedNodes addObject:node];
        }
        
        UIView *currentView = [self viewForNode:node parentView:childContainer];
        
        [currentView.topAnchor constraintEqualToAnchor:childContainer.topAnchor constant:5].active = YES;
        [currentView.leftAnchor constraintGreaterThanOrEqualToAnchor:childContainer.leftAnchor constant:5].active = YES;
        [childContainer.bottomAnchor constraintGreaterThanOrEqualToAnchor:currentView.bottomAnchor constant:5].active = YES;
        [childContainer.rightAnchor constraintGreaterThanOrEqualToAnchor:currentView.rightAnchor constant:5].active = YES;

        if (neighbourView) {
            [neighbourView.rightAnchor constraintEqualToAnchor:currentView.leftAnchor constant:5].active = YES;
        }
        neighbourView = currentView;
    }
}



@end
