//
//  ItemImageSelectionVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 16/12/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "ItemImageSelectionVC.h"
#import "ImagesCell.h"
#import "RmsDbController.h"

@interface ItemImageSelectionVC ()<UIPopoverPresentationControllerDelegate>

@property (nonatomic, weak) RmsActivityIndicator *activityIndicator;
@property (nonatomic, strong) RmsDbController *rmsDbController;

@property (nonatomic, weak) IBOutlet UICollectionView *imageCollectionView;
@property (nonatomic, weak) IBOutlet UITextField *imageName;

@property (nonatomic, strong) NSMutableArray *searchImageResult;
@property (nonatomic, strong) RapidWebServiceConnection * getItemImageListByNameWC;

@end

@implementation ItemImageSelectionVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    self.getItemImageListByNameWC = [[RapidWebServiceConnection alloc] init];
    //[self.imageCollectionView registerNib:[UINib nibWithNibName:@"ImagesCell" bundle:nil] forCellWithReuseIdentifier:@"CELL"];
    if (IsPhone()) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self viewWillAppear:YES];
        });
    }
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.imageName.text = self.strSearchText;
    [self searchImage];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - UITextFieldDelegate -
- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return self.searchImageResult.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (ImagesCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ImagesCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    if(self.searchImageResult.count > 0) {
        NSString *imgString = [NSString stringWithFormat:@"%@",[(self.searchImageResult)[indexPath.row] valueForKey:@"Image"]];
        [cell.itemImages loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imgString]]];
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    ImagesCell *cell = (ImagesCell*)[collectionView cellForItemAtIndexPath:indexPath];
    if(cell.itemImages.image == nil){
        
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Image not available." buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
        return;
    }
    
    NSMutableDictionary *itemData = [NSMutableDictionary dictionary];
    [itemData setValue:[(self.searchImageResult)[indexPath.row] valueForKey:@"Image"] forKey:@"ItemImage"];
    
    [self.itemSelctionImageChangedVCDelegate itemImageChangeNewImage:cell.itemImages.image withImageUrl:[(self.searchImageResult)[indexPath.row] valueForKey:@"Image"]];
}

-(IBAction)btnBack:(id)sender{
    [self.navigationController popViewControllerAnimated:TRUE];
}
-(IBAction)btnImageSearchClicked:(id)sender{
    if(self.imageName.text.length > 0) {
        [self searchImage];
    }
    else{
        UIAlertActionHandler rightHandler = ^ (UIAlertAction *action) {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"Inventory Management" message:@"Please enter item name" buttonTitles:@[@"OK"] buttonHandlers:@[rightHandler]];
    }
}
-(void)searchImage{
    self.searchImageResult = [[NSMutableArray alloc] init];
    [self.imageCollectionView reloadData];
    NSString * itemName=[NSString stringWithFormat:@"%@",self.imageName.text];
     if(itemName.length > 0) {
        _activityIndicator = [RmsActivityIndicator showActivityIndicator:self.view];
        
        NSMutableDictionary *searchImageName = [[NSMutableDictionary alloc] init];
        searchImageName[@"Item_Name"] = itemName;
        NSDictionary *imageDict = @{kRIMItemImageSearchWebServiceCallKey : itemName};
        [Appsee addEvent:kRIMItemImageSearchWebServiceCall withProperties:imageDict];
        
         CompletionHandler completionHandler = ^(id response, NSError *error) {
	            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.001 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self responseSearchResponse:response error:error];
                });
         };
         
         self.getItemImageListByNameWC = [self.getItemImageListByNameWC initWithRequest:KURL actionName:WSM_GET_ITEM_IMAGE_LIST_BY_NAME params:searchImageName completionHandler:completionHandler];
    }
}
- (void) responseSearchResponse:(id)response error:(NSError *)error {

    [_activityIndicator hideActivityIndicator];
    
    if (response != nil) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if ([[response valueForKey:@"IsError"] intValue] == 0) {
                
                self.searchImageResult = [self.rmsDbController objectFromJsonString:[response valueForKey:@"Data"]];
                NSDictionary *imageResponseDict = @{kRIMItemImageSearchWebServiceResponseKey : @(self.searchImageResult.count)};
                [Appsee addEvent:kRIMItemImageSearchWebServiceResponse withProperties:imageResponseDict];
                [self.imageCollectionView reloadData];
            }
        }
    }
}
-(void)reloadImageListWith:(NSString *)strSearchText {
    self.strSearchText = strSearchText;
    self.imageName.text = self.strSearchText;
    [self searchImage];
}
-(void)presentViewControllerForviewConteroller:(UIViewController *) objView sourceView:(UIView *)sourceView ArrowDirection:(UIPopoverArrowDirection)arrowDirection {
    
    self.modalPresentationStyle = UIModalPresentationPopover;

    self.preferredContentSize = self.view.frame.size;
    [objView presentViewController:self animated:YES completion:nil];
    
    UIPopoverPresentationController * popup =self.popoverPresentationController;
    popup.delegate = self;
    popup.backgroundColor = [UIColor colorWithRed:0.086 green:0.075 blue:0.141 alpha:1.000];
    popup.permittedArrowDirections = arrowDirection;
    popup.sourceView = sourceView;
    popup.sourceRect = sourceView.bounds;
}
@end
