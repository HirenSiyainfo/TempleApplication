//
//  ItemVariationRIMCell.h
//  RapidRMS
//
//  Created by Siya9 on 11/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^AddVariationItem)(NSMutableArray * arrListVariationItems);

@interface ItemVariationRIMCell : UITableViewCell {
    AddVariationItem addVariationItemCell;
}

@property (nonatomic, strong) NSMutableDictionary * dictVariationInfo;
@property (nonatomic, strong) NSMutableArray * arrvariationsubArray;

@property (nonatomic, weak) IBOutlet UILabel * lblVariationName;
@property (nonatomic, weak) IBOutlet UIButton * btnVariationDelete;
@property (nonatomic, weak) IBOutlet UIButton * btnVariationAddNew;
@property (nonatomic, weak) IBOutlet UIButton * btnVariationValueAddNew;
@property (nonatomic, weak) IBOutlet UICollectionView * colVariationValueList;


-(void)confugareCell:(NSMutableDictionary *)dictVariationInfo withAddVariationItem:(AddVariationItem)addVariationItem;
@end
