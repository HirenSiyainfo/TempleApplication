//
//  MMDItemSectionVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 22/01/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "MMDItemSectionVC.h"
#import "MMDItemSectionTitleCell.h"

@interface MMDItemSectionVC () {
    NSIndexPath * selectedIndePath;
}
@property (nonatomic, weak) IBOutlet UICollectionView * collItemTitleList;
@end
@implementation MMDItemSectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setArrSectionTitle:(NSArray *)arrSectionTitle {
    NSMutableArray * arrTitleArray = [[NSMutableArray alloc]initWithArray:arrSectionTitle];

    if (arrTitleArray.count >0) {
        NSArray * removedObject = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"0",@"#"];
        BOOL isAddHash = FALSE;
        for (NSString * str in removedObject) {
            if ([arrTitleArray containsObject:str]) {
                [arrTitleArray removeObject:str];
                isAddHash = TRUE;
            }
        }
        if (isAddHash) {
            [arrTitleArray insertObject:@"#" atIndex:0];
        }
//        [arrTitleArray addObject:@"ALL"];
    }
    _arrSectionTitle = [[NSArray alloc]initWithArray:arrTitleArray];
    [_collItemTitleList reloadData];
}
-(void)setDefaultSelectedTitle:(NSString *)defaultSelectedTitle {
    if (defaultSelectedTitle) {
        _defaultSelectedTitle = defaultSelectedTitle;
        selectedIndePath = nil;
        [_collItemTitleList reloadData];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (selectedIndePath && selectedIndePath.row <= [self collectionView:_collItemTitleList numberOfItemsInSection:0]) {
                [_collItemTitleList selectItemAtIndexPath:selectedIndePath animated:YES scrollPosition:UICollectionViewScrollPositionNone];
            }
        });
    }
}
#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _arrSectionTitle.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMDItemSectionTitleCell *cell = (MMDItemSectionTitleCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"Cell" forIndexPath:indexPath];
    cell.lblTitle.text = _arrSectionTitle[indexPath.row];
    cell.imgSelected.clipsToBounds = YES;
    cell.imgSelected.layer.cornerRadius = 11.0;
    cell.imgSelected.layer.borderWidth = 1.0;
    cell.imgSelected.layer.borderColor = [UIColor colorWithWhite:0.933 alpha:1.000].CGColor;
    if ([_defaultSelectedTitle isEqualToString:_arrSectionTitle[indexPath.row]]) {
        selectedIndePath = indexPath;
//        [collectionView selectItemAtIndexPath:indexPath animated:NO scrollPosition:UICollectionViewScrollPositionNone];
//        [[collectionView cellForItemAtIndexPath:indexPath] setSelected:YES];
    }
    return cell;
}

// Called after the user changes the selection.
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    [self.Delegate didItemSectionTitleSelect:_arrSectionTitle[indexPath.row]];
}
@end
