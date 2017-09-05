//
//  VariationOptionCustomCell.h
//  RapidRMS
//
//  Created by Siya on 01/12/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol VariationOptionCellDelegate <NSObject>

-(void)didChangeOption:(NSIndexPath *)indexpath name:(NSString *)name tableView:(UITableView *)tblView;

-(void)didRemoveOption:(NSIndexPath *)indexpath tableView:(UITableView *)tblView;
-(void)startEdtingItemVariationItem:(UITableView *)tblView inToInput:(UITextField *)textField;

@end

@interface VariationOptionCustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UITextField *txtVariationOption;
@property (nonatomic, weak) UITableView *tbloption;
@property (nonatomic, weak) id <VariationOptionCellDelegate>variationOptionCellDelegate;

@property (nonatomic, strong) NSIndexPath *indexPath;

@end
