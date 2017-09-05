//
//  UITableView+AddBorder.h
//  TableView
//
//  Created by Siya9 on 01/09/16.
//  Copyright © 2016 Siya9. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableView (AddBorder)

/**
 *  @brief Defalut HeaderView
 *
 *  @param strHeader title for header
 *
 *  @return header view
 */
-(UIView *)defaultTableHeaderView:(NSString *)strHeader;

/**
 *  @brief Add Rectangel with default color, border and border color.
 *
 *  @param cell      Created cell that will be display.
 *  @param indexPath IndexPath of current cell.
 */
- (void)addCellBorderForWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  @brief Add Rectangel and it color with border.
 *
 *  @param cell       Created cell that will be display.
 *  @param indexPath  IndexPath of current cell.
 *  @param fillColor  Rectangel backGround color.
 *  @param stockColor Rectangel border (stock) color.
 *  @param borderWidth Rectangel border width.
 */
- (void)addCellBorderForWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath FillColor:(UIColor *)fillColor WithStockColor:(UIColor *)stockColor borderWidth:(float)border;

/**
 *  @brief Add Rectangel and it color with border and bottom border space.
 *
 *  @param cell       Created cell that will be display.
 *  @param indexPath  IndexPath of current cell.
 *  @param fillColor  Rectangel backGround color.
 *  @param stockColor Rectangel border (stock) color.
 *  @param borderWidth Rectangel border width.
 *  @param bottomBorderSpace Rectangel border space.
 */
- (void)addCellBorderForWillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath FillColor:(UIColor *)fillColor WithStockColor:(UIColor *)stockColor borderWidth:(float)border bottomBorderSpace:(float)borderSpace;


-(void)arrangeHeightOfViews:(NSArray *)cellSubViews WillDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath;
@end
