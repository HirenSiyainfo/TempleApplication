//
//  SelectUserOptionVC.h
//  RapidRMS
//
//  Created by Siya9 on 05/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PopupSuperVC.h"
typedef void (^SelectionComplete)(NSArray * arrSelection);
typedef void (^SelectionColse)(UIViewController * popUpVC);

@interface SelectUserOptionVC : PopupSuperVC

@property (nonatomic, strong) NSNumber * currentID;
@property (nonatomic) BOOL isMultipleSelection;
@property (nonatomic) id selectedObject;
@property (nonatomic, strong) NSArray * arrDisableSelectionTitle;
@property (nonatomic, strong) NSArray * arrDisableSelectionObject;
@property (nonatomic, strong) NSString * strkey;
@property (nonatomic, strong) NSString * strImgKey;
@property (nonatomic) float fltRowHeight;
@property (nonatomic) int intMiximumRowDisplay;


+(instancetype)setSelectionViewitem:(NSArray *)arrItem SelectedObject:(id)selectedobject SelectionComplete:(SelectionComplete)selectionComplete SelectionColse:(SelectionColse)selectionColse;

+(instancetype)setSelectionViewitem:(NSArray *)arrItem OptionId:(NSNumber *)vid isMultipleSelectionAllow:(BOOL)isMultipale SelectionComplete:(SelectionComplete)selectionComplete SelectionColse:(SelectionColse)selectionColse;

//-(void)presentViewControllerForViewController:(UIViewController *)viewConteroler;
//-(void)presentViewControllerForViewController:(UIViewController *)viewConteroler forSourceView:(UIView *)view;
//-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView ArrowDirection:(UIPopoverArrowDirection)arrowDirection;
@end

#pragma mark - Cell -
@interface SelectUserOptionVCCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UILabel * lblTitle;
@property (nonatomic, weak) IBOutlet UIImageView * imgCell;
@property (nonatomic, weak) IBOutlet UIImageView * imgSelected;
@property (nonatomic, weak) IBOutlet UIView * viewSeparator;
@end