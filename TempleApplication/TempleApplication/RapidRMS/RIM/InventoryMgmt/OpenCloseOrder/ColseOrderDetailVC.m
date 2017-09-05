//
//  ColseOrderDetailVC.m
//  RapidRMS
//
//  Created by Siya9 on 18/05/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "ColseOrderDetailVC.h"
#import "RmsDbController.h"
#import "ItemInfoPopupVC.h"

#import "InvnetoryInCustomCell.h"


@interface ColseOrderDetailVC ()<ExportPopupVCDelegate> {
    
}
@property (nonatomic, weak) IBOutlet UITableView * tblOrderItemDetails;
@property (nonatomic, weak) IBOutlet UILabel *lblDate;
@property (nonatomic, weak) IBOutlet UILabel *lblTime;
@property (nonatomic, weak) IBOutlet UILabel *lblCloseOrderTitle;

@property (nonatomic, strong) RmsDbController *rmsDbController;
@end

@implementation ColseOrderDetailVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.rmsDbController = [RmsDbController sharedRmsDbController];
    
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSString  *Datetime = [NSString stringWithFormat:@"%@",[self.dictInventoryMain valueForKey:@"CreatedDate"]];
    _lblDate.text = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"MMMM dd, yyyy"];
    _lblTime.text = [self getStringFormate:Datetime fromFormate:@"MM/dd/yyyy HH:mm:ss" toFormate:@"hh:mm a"];
    NSString * strTitle = [NSString stringWithFormat:@"%@",[self.dictInventoryMain valueForKey:@"Description"]];
    if (strTitle.length > 0) {
        _lblCloseOrderTitle.text = strTitle;
    }
    else{
        _lblCloseOrderTitle.text = @"- - -";
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - IBAction -
-(IBAction)btnBackTapped:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)btnExportlist:(UIButton *)sender {
    
    ExportPopupVC * exportPopupVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"ExportPopupVC_sid"];
    exportPopupVC.delegate = self;
    exportPopupVC.tag = self.tag;
    
    [exportPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionDown];
}

-(void)didSelectExportType:(ExportType)exportType withTag:(NSInteger)tag {
    [self.popupVCdelegate didSelectExportType:exportType withTag:tag];
}

-(IBAction)btnIteminfoTapped:(id)sender {
    float totalQTYeach = 0.0;
    float totalCostPrice = 0.0;
    for( int iArr = 0 ; iArr < self.arrItemOrderList.count; iArr++)
    {
        // Calculate Total CostPrice
        int iQty = [self.arrItemOrderList[iArr][@"AddedQty"] intValue ];
        totalQTYeach = totalQTYeach + iQty;
        
        float iCost = [self.arrItemOrderList[iArr][@"CostPrice"] floatValue ];
        totalCostPrice = totalCostPrice + (iQty * iCost);
    }
    ItemInfoPopupVC * objItemInfoPopupVC =
    [[UIStoryboard storyboardWithName:@"RimStoryboard" bundle:NULL] instantiateViewControllerWithIdentifier:@"ItemInfoPopupVC_sid"];
    
    NSMutableDictionary * dictItemInfo = [NSMutableDictionary dictionary];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%lu",(unsigned long)self.arrItemOrderList.count] forKey:ItemInfoPopupVCNumOfProduct];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%.0f",totalQTYeach] forKey:ItemInfoPopupVCAddedQTY];
    [dictItemInfo setObject:[NSString stringWithFormat:@"%.2f",totalCostPrice] forKey:ItemInfoPopupVCTotalCost];
    objItemInfoPopupVC.dictItemInfo = dictItemInfo;
    
    [objItemInfoPopupVC presentViewControllerForviewConteroller:self sourceView:sender ArrowDirection:UIPopoverArrowDirectionDown];
}


-(NSString *)getStringFormate:(NSString *)pstrDate fromFormate:(NSString *)pstrFformate toFormate:(NSString *)pstrToformate{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = pstrFformate;
    NSDate *dateFromString;// = [[NSDate alloc] init];
    dateFromString = [dateFormatter dateFromString:pstrDate];
    
    NSDateFormatter* df = [[NSDateFormatter alloc]init];
    df.dateFormat = pstrToformate;
    NSString *result = [df stringFromDate:dateFromString];
    
    return result;
}

#pragma mark - Table view data source -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return self.arrItemOrderList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"AddItemCustomCell";
    InvnetoryInCustomCell *cell = (InvnetoryInCustomCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    NSMutableDictionary *dict =self. arrItemOrderList[indexPath.row];
    
    // show Image for each item in cell
    NSString * imageImage = @"";
    imageImage = dict[@"ItemImage"];
    
    if(([imageImage isKindOfClass:[NSNull class]]) || ([imageImage isEqualToString:@"<null>"])  )
    {
        imageImage = @"";
    }
    
    if ([[imageImage stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""])
    {
        cell.imgItem.image = [UIImage imageNamed:@"noimage.png"];
    }
    else
    {
        [cell.imgItem loadImageFromURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@",imageImage]]];
    }

    cell.lblInventoryName.text = dict[@"ItemName"];
    cell.lblBarcode.text = dict[@"Barcode"];
    
    cell.txtCostPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:[dict[@"CostPrice"] floatValue]]];
    [cell.txtCostPrice setEnabled:NO];
    
    cell.txtSellingPrice.text = [NSString stringWithFormat:@"%@",[self.rmsDbController getStringPriceFromFloat:[dict[@"SalesPrice"] floatValue]]];
    [cell.txtSellingPrice setEnabled:NO];
    
    cell.txtAvaQTY.text = [NSString stringWithFormat:@"%@",dict[@"avaibleQty"] ];

    [cell.txtAvaQTY setEnabled:NO];
    
    cell.txtAddQTY.text = [NSString stringWithFormat:@"%@",dict[@"AddedQty"] ];
    [cell.txtAddQTY setEnabled:NO];
    
    cell.contentView.backgroundColor = [UIColor clearColor];
    cell.backgroundColor = [UIColor clearColor];
    return cell;
}
// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}
@end
