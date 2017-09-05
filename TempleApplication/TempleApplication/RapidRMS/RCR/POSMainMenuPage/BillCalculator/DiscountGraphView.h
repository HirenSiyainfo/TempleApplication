//
//  DiscountGraphView.h
//  RapidDiscountDemo
//
//  Created by siya info on 06/02/16.
//  Copyright © 2016 siya info. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DiscountGraphNode;

@interface DiscountGraphView : UIView
{
}
@property (nonatomic , strong) NSArray *pathForView;

- (void)configureWith:(DiscountGraphNode*)rootNode;

@end
