//
//  ItemVariationRIMCell.m
//  RapidRMS
//
//  Created by Siya9 on 11/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ItemVariationRIMCell.h"
#import "ItemVariationRIMCollectionCell.h"

@implementation ItemVariationRIMCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}
-(void)confugareCell:(NSMutableDictionary *)dictVariationInfo withAddVariationItem:(AddVariationItem)addVariationItem {
    self.dictVariationInfo = dictVariationInfo;
    self.lblVariationName.text = dictVariationInfo[@"variationName"];
    self.arrvariationsubArray = dictVariationInfo[@"variationsubArray"];
    [self.colVariationValueList reloadData];
    addVariationItemCell = addVariationItem;
}
-(IBAction)addNewVariationItem:(UIButton *)sender {
    addVariationItemCell(self.arrvariationsubArray);
}

-(IBAction)deleteVariationItem:(UIButton *)sender {
    if (self.arrvariationsubArray.count > sender.tag) {
        [self.arrvariationsubArray removeObjectAtIndex:sender.tag];
        [self.colVariationValueList reloadData];
    }
}
#pragma mark - UICollectionViewDataSource -

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.arrvariationsubArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    ItemVariationRIMCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    
    cell.lblVariationValueName.text = self.arrvariationsubArray[indexPath.row][@"Value"];
    cell.btnVariationValueDelete.tag = indexPath.row;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    return cell;
}

@end
