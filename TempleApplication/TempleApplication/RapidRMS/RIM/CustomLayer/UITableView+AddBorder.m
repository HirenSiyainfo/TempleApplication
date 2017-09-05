//
//  UITableView+AddBorder.m
//  TableView
//
//  Created by Siya9 on 01/09/16.
//  Copyright © 2016 Siya9. All rights reserved.
//

#import "UITableView+AddBorder.h"


@implementation UITableView (AddBorder)

-(UIView *)defaultTableHeaderView:(NSString *)strHeader {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, RIMHeaderHeight())];
    
    
    /* Create custom view to display section header... */
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(RIMLeftMargin(), 0, view.frame.size.width-20, view.frame.size.height)];
    [label setFont:[UIFont fontWithName:@"Lato-Bold" size:14.0]];
    [label setText:strHeader.uppercaseString];
    [view addSubview:label];
    [view setBackgroundColor:[UIColor colorWithWhite:0.882 alpha:1.000]]; //your background color...
    return view;
}

#pragma mark - Border for cell -

- (void)addCellBorderForWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    [self addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:[UIColor whiteColor] WithStockColor:[UIColor colorWithWhite:0.667 alpha:1.000] borderWidth:1.0f];
}
- (void)addCellBorderForWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath FillColor:(UIColor *)fillColor WithStockColor:(UIColor *)stockColor borderWidth:(float)border{
    [self addCellBorderForWillDisplayCell:cell forRowAtIndexPath:indexPath FillColor:fillColor WithStockColor:stockColor borderWidth:border bottomBorderSpace:RIMLeftMargin()];
}

- (void)addCellBorderForWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath FillColor:(UIColor *)fillColor WithStockColor:(UIColor *)stockColor borderWidth:(float)border bottomBorderSpace:(float)borderSpace {
    if ([cell respondsToSelector:@selector(tintColor)]) {
        if (!fillColor) {
            fillColor = [UIColor whiteColor];
        }
        if (!stockColor) {
            stockColor = [UIColor colorWithWhite:0.667 alpha:1.000];
        }
        CGFloat cornerRadius = 0.f;
        cell.backgroundColor = UIColor.clearColor;
        CAShapeLayer *layer = [[CAShapeLayer alloc] init];
        
        
        CGMutablePathRef pathRef = CGPathCreateMutable();
        
        CGRect bounds = CGRectInset(cell.bounds, RIMLeftMargin(), 0);
        UIView *testView = [[UIView alloc] initWithFrame:bounds];
        //1
        if (indexPath.row == 0 && indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
            bounds.origin.y += 0.5;
            bounds.size.height -= 1;
            CGPathAddRoundedRect(pathRef, nil, bounds, cornerRadius, cornerRadius);
            UIImageView * imgBG = [cell.contentView viewWithTag:15963];
            if (imgBG) {
                [self numberOfCellIsOnlyOne:@[imgBG] CellRect:bounds];
            }
        }
        else if (indexPath.row == 0) {//2
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds)+0.5f);
            
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds)+0.5f, CGRectGetMidX(bounds), CGRectGetMinY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds)+0.5f, CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds)-0.5f);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMinX(bounds)+borderSpace, CGRectGetMaxY(bounds)-0.5f);
            
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds)+borderSpace, CGRectGetMaxY(bounds));
            UIImageView * imgBG = [cell.contentView viewWithTag:15963];
            if (imgBG) {
                [self numberOfCellIsFirst:@[imgBG] CellRect:bounds];
            }
        }
        else if (indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {//3
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds) -0.5f, CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds)-0.5, CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            
            UIImageView * imgBG = [cell.contentView viewWithTag:15963];
            if (imgBG) {
                [self numberOfCellIsLast:@[imgBG] CellRect:bounds];
            }
        }
        else {//4
            CGPathMoveToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMinX(bounds), CGRectGetMaxY(bounds), CGRectGetMidX(bounds), CGRectGetMaxY(bounds), cornerRadius);
            CGPathMoveToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds));
            
            CGPathAddArcToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds), CGRectGetMaxX(bounds), CGRectGetMidY(bounds), cornerRadius);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMinY(bounds));
            
            CGPathMoveToPoint(pathRef, nil, CGRectGetMaxX(bounds), CGRectGetMaxY(bounds) -0.5f);
            CGPathAddLineToPoint(pathRef, nil, CGRectGetMinX(bounds)+borderSpace, CGRectGetMaxY(bounds) -0.5f);
            
            UIImageView * imgBG = [cell.contentView viewWithTag:15963];
            if (imgBG) {
                [self numberOfCellIsLast:@[imgBG] CellRect:bounds];
            }
        }
        layer.path = pathRef;
        CFRelease(pathRef);
        layer.strokeColor = stockColor.CGColor;
        layer.lineWidth = border;
        layer.fillColor = [UIColor clearColor].CGColor;
        [testView.layer insertSublayer:layer atIndex:0];
        
        //set the backgrount color
        CAShapeLayer *layercolor = [[CAShapeLayer alloc] init];
        CGMutablePathRef pathRefmid = CGPathCreateMutable();
        CGRect fillbounds = CGRectInset(cell.bounds, RIMLeftMargin(), 0);
        CGPathAddRoundedRect(pathRefmid, nil, fillbounds, cornerRadius, cornerRadius);
        layercolor.path = pathRefmid;
        CFRelease(pathRefmid);
        layercolor.strokeColor = [UIColor clearColor].CGColor;
        layercolor.lineWidth = 0;
        layercolor.fillColor = fillColor.CGColor;
        [testView.layer insertSublayer:layercolor atIndex:0];
        testView.backgroundColor = UIColor.clearColor;
        
        cell.backgroundView = testView;
    }
}

-(void)numberOfCellIsOnlyOne:(NSArray <UIView *> *)cellSubViews CellRect:(CGRect)bounds{
    for (UIView * subView in cellSubViews) {
        CGRect frame = subView.frame;
        frame.origin.y = 1;
        frame.size.height = bounds.size.height - 1;
        subView.frame = frame;
    }
}
-(void)numberOfCellIsFirst:(NSArray <UIView *> *)cellSubViews CellRect:(CGRect)bounds{
    for (UIView * subView in cellSubViews) {
        CGRect frame = subView.frame;
        frame.origin.y = 1;
        frame.size.height = bounds.size.height - 2;
        subView.frame = frame;
    }
}
-(void)numberOfCellIsLast:(NSArray <UIView *> *)cellSubViews CellRect:(CGRect)bounds{
    for (UIView * subView in cellSubViews) {
        CGRect frame = subView.frame;
        frame.origin.y = 0;
        frame.size.height = bounds.size.height - 1;
        subView.frame = frame;
    }
}

-(void)arrangeHeightOfViews:(NSArray *)cellSubViews WillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    CGRect bounds = CGRectInset(cell.bounds, RIMLeftMargin(), 0);
    
    if (indexPath.row == 0 && indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
        bounds.origin.y += 0.5;
        bounds.size.height -= 1;
        [self numberOfCellIsOnlyOne:cellSubViews CellRect:bounds];
    }
    else if (indexPath.row == 0) {
        [self numberOfCellIsFirst:cellSubViews CellRect:bounds];
    }
    else if (indexPath.row == [self numberOfRowsInSection:indexPath.section]-1) {
        [self numberOfCellIsLast:cellSubViews CellRect:bounds];
    }
    else {
        [self numberOfCellIsLast:cellSubViews CellRect:bounds];
    }
}
@end
