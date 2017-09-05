//
//  GusestSelectionVC.m
//  RapidRMS
//
//  Created by siya-IOS5 on 4/17/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "GusestSelectionVC.h"
#import "RmsDbController.h"
#import "GuestSelectionCell.h"


@interface GusestSelectionVC ()
{
}
@property (nonatomic, weak) IBOutlet UICollectionView *guestSelectionCollectionView;

@property (nonatomic, strong) RmsDbController *rmsDbController;

@end

@implementation GusestSelectionVC
- (void)viewDidLoad
{
    [super viewDidLoad];

    self.rmsDbController = [RmsDbController sharedRmsDbController];
    self.managedObjectContext = self.rmsDbController.managedObjectContext;
    _guestSelectionCollectionView.allowsMultipleSelection = NO;
    [_guestSelectionCollectionView reloadData];
    [_guestSelectionCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:TRUE scrollPosition:UICollectionViewScrollPositionNone];
    // Do any additional setup after loading the view.
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
   
}
-(void)reloadGuestView{
    
    NSArray *selectedGuest = [_guestSelectionCollectionView indexPathsForSelectedItems];
    NSIndexPath *selectedGuestIndexpath = selectedGuest.firstObject;
    [_guestSelectionCollectionView reloadData];
    
    if(self.guestCount <= selectedGuestIndexpath.row){
       [_guestSelectionCollectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:0] animated:TRUE scrollPosition:UICollectionViewScrollPositionNone];
    }
    else{
        [_guestSelectionCollectionView selectItemAtIndexPath:selectedGuestIndexpath animated:TRUE scrollPosition:UICollectionViewScrollPositionNone];
        
    }
    
}

/*- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.guestCount;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GuestSelectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuestSelectionCell"];
    NSInteger indexpath = indexPath.row + 1;
    cell.guestId.text = [NSString stringWithFormat:@"%ld",(long)indexpath];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
 
}*/

-(NSInteger )selectedGuestId
{
    NSArray *selectedGuest = [_guestSelectionCollectionView indexPathsForSelectedItems];
    NSIndexPath *selectedGuestIndexpath = selectedGuest.firstObject;
    return selectedGuestIndexpath.row +1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.guestCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    GuestSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GuestSelectionCell" forIndexPath:indexPath];
    cell.guestId.text = [NSString stringWithFormat:@"%ld",(long)indexPath.row+1];

    return cell;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
- (NSIndexPath *)selectedIndexPath {
    NSArray *indices = [_guestSelectionCollectionView indexPathsForSelectedItems];
    return indices.firstObject;
}

- (NSString*)labelTextForGuestAtPoint:(CGPoint)point {
    NSString *textValue;
    NSIndexPath *indexPath = [_guestSelectionCollectionView indexPathForItemAtPoint:point];
    if (indexPath) {
        textValue = [NSString stringWithFormat:@"%ld", (long)indexPath.row + 1];
    }
    
    return textValue;
}

- (CGPoint)centerForGuestAtPoint:(CGPoint)point {
    CGPoint centerPoint = CGPointZero;
    NSIndexPath *indexPath = [_guestSelectionCollectionView indexPathForItemAtPoint:point];
    if (indexPath) {
        UICollectionViewCell *cell = [_guestSelectionCollectionView cellForItemAtIndexPath:indexPath];
        centerPoint = cell.center;
        centerPoint = [_guestSelectionCollectionView convertPoint:centerPoint toView:self.parentViewController.view];
    }
    
    return centerPoint;
}




@end
