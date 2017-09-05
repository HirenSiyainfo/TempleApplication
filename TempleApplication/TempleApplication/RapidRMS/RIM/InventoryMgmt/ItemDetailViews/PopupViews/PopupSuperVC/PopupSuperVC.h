//
//  PopupSuperVC.h
//  RapidRMS
//
//  Created by Siya9 on 08/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopupSuperVC : UIViewController
/**
 *  @brief when arror with any view need to set different colors
 */
@property (nonatomic, strong) UIColor * colorArrowDirection;
/**
 *  @brief Preseted View Border color default color white
 */
@property (nonatomic, strong) UIColor * colorBorder;
/**
 *  @brief Hide popover with coustom class of background view
 */
@property (nonatomic) BOOL isHideArrow;
/**
 *  @brief used for iPhone then show keyboard then view managment
 */
@property (nonatomic) BOOL isKeybordShow;
/**
 *  @brief The arrow directions that you prefer for the popover.
 */
@property (nonatomic) CGSize sizePreferredContentSize;
/**
 *  @brief Present View Controller in center and it support iPhone.
 *
 *  @param viewConteroler view controller which have to center position
 */
-(void)presentViewControllerForViewController:(UIViewController *)viewConteroler;
/**
 *  @brief please avoid this method
 *
 *  @param viewConteroler view controller which have to center position
 *  @param view           Action or arrow view
 *  @warning:
 *  this method have a static frame please use this method
 *  @code -(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView ArrowDirection:(UIPopoverArrowDirection)arrowDirection
 */
-(void)presentViewControllerForViewController:(UIViewController *)viewConteroler forSourceView:(UIView *)view __attribute__((deprecated("used presentViewControllerForviewConteroller:sourceView:ArrowDirection: instead of.")));
/**
 *  @brief Present View Controler with arrow and it support iPhone.
 *
 *  @param objView        presented view controller
 *  @param sourceView     Action or which have to arrow view
 *  @param arrowDirection arrow Direction
 */
-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *) sourceView ArrowDirection:(UIPopoverArrowDirection) arrowDirection;
/**
 *  @brief Present View Controler with arrow and it support iPhone.
 *
 *  @param objView        presented view controller
 *  @param sourceView     Action or which have to arrow view
 *  @param arrowDirection arrow Direction
 *  @param passthroughViews whitch view allow to touch
 */
-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView ArrowDirection:(UIPopoverArrowDirection)arrowDirection InputViews:(NSArray<UIView *> *)passthroughViews;

/**
 *  @brief Present View Controler with specific postion and it support iPhone.
 *
 *  @param objView        presented view controller
 *  @param sourceView     Action or which have to arrow view
 *  @param passthroughViews whitch view allow to touch
 *  @param sourceRect where to present

 */
-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView InputViews:(NSArray<UIView *> *)passthroughViews atPostion:(CGRect)sourceRect;

-(void)presentVCForRightSide:(UIViewController *) objView WithInputView:(UIView *)sourceView;

/**
 *  @brief called when the popover is dimissed programatically.
 */
- (void)popoverPresentationControllerShouldDismissPopover;
@end

@interface CustomPopoverBackgroundView : UIPopoverBackgroundView {
    UIImageView *_borderImageView;
    UIImageView *_arrowView;
    CGFloat _arrowOffset;
    UIPopoverArrowDirection _arrowDirection;
}

@end
