//
//  ManualFilterOptionViewController.m
//  RapidRMS
//
//  Created by Siya on 21/08/14.
//  Copyright (c) 2014 Siya Infotech. All rights reserved.
//

#import "ManualFilterOptionViewController.h"
#import "ManualOptionCell_iPad.h"
#import "PurchaseOrderFilterListDetail.h"
#import "GenerateOrderView.h"

@interface ManualFilterOptionViewController ()
{
    IntercomHandler *intercomHandler;
}

@property (nonatomic, weak) IBOutlet UIButton *btnIntercom;
@property (nonatomic, weak) IBOutlet UITableView *tblPurchaseOrderList;
@property (nonatomic, weak) IBOutlet UILabel *currenctDate;

@end

@implementation ManualFilterOptionViewController
@synthesize arrayMainPurchaseOrderList,manualOption;
@synthesize currenctDate,objPur,objGOrder;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    NSString  *generateorderCell;
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        generateorderCell = @"ManualOptionCell_iPhone";
    }
    else{
        
        if(manualOption)
        {
             generateorderCell = @"ManualOptionCell_iPad";
        }
        else{
             generateorderCell = @"ManualOptionCell2_iPad";
        }
    }
    
    UINib *mixGenerateirderNib = [UINib nibWithNibName:generateorderCell bundle:nil];
    [_tblPurchaseOrderList registerNib:mixGenerateirderNib forCellReuseIdentifier:@"ManualOption"];
    
    for(int i=0;i<self.arrayMainPurchaseOrderList.count;i++){
        
        NSMutableDictionary *dict = [(self.arrayMainPurchaseOrderList)[i]mutableCopy];
        dict[@"selection"] = @"0";
        (self.arrayMainPurchaseOrderList)[i] = dict;
        
    }
    [self updateDateLabels];
    intercomHandler = [[IntercomHandler alloc] initWithButtton:_btnIntercom withViewController:self];
    // Do any additional setup after loading the view from its nib.
}

- (void)updateDateLabels
{
    NSDate* date = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    formatter.dateFormat = @"MMMM dd, yyyy";
    self.currenctDate.text = [formatter stringFromDate:date];
}


#pragma mark - UITableView delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        return 134;
    }
    else{
        return 73;
    }

}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return self.arrayMainPurchaseOrderList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCellStyle style =  UITableViewCellStyleDefault;
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:@"BaseCell"];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor=[UIColor clearColor];
    
   if(tableView == _tblPurchaseOrderList)
    {
        if(self.arrayMainPurchaseOrderList.count > 0)
        {
            NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"ItemName" ascending:YES];
            [self.arrayMainPurchaseOrderList sortUsingDescriptors:@[sort]];
            
            //            if ([[UIDevice currentDevice]  userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
            //            {
            //
            NSString *cellIdentifier = @"ManualOption";
            
            ManualOptionCell_iPad *manualOrderCell = (ManualOptionCell_iPad *)[_tblPurchaseOrderList dequeueReusableCellWithIdentifier:cellIdentifier];
            
            manualOrderCell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            manualOrderCell.lblTitle.text=[NSString stringWithFormat:@"%@",[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"ItemName"]];
            
            if([[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"Barcode"] isKindOfClass:[NSString class]])
            {
                if([[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@""] || [[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"Barcode"] isEqualToString:@"<null>"])
                {
                    
                    manualOrderCell.lblBarcode.text=@"";
                }
                else
                {
                    manualOrderCell.lblBarcode.text=[NSString stringWithFormat:@"%@",[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"Barcode"]];
                    
                }
            }
            else
            {
                
                manualOrderCell.lblBarcode.text=@"";
            }
            
            if([[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"selection"] isEqualToString:@"1"])
            {
                manualOrderCell.imgCheck.image = [UIImage imageNamed:@"img_add.png"];
        
            }
            else
            {
                [manualOrderCell.imgCheck setImage:nil];

            }

        
            manualOrderCell.lblsoldqty.text=[NSString stringWithFormat:@"%@",[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"Sold"]];
            
            if(objGOrder){
                
                manualOrderCell.lblavailableqty.text=[NSString stringWithFormat:@"%@",[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"AvailableQty"]];
            }
            else{
              manualOrderCell.lblavailableqty.text=[NSString stringWithFormat:@"%@",[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"avaibleQty"]];
            }
            
            
            manualOrderCell.lblreorder.text=[NSString stringWithFormat:@"%@",[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"ReOrder"]];
        
            manualOrderCell.lblmax.text=[NSString stringWithFormat:@"%@",[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"MaxStockLevel"]];
            
            
            manualOrderCell.lblmin.text=[NSString stringWithFormat:@"%@",[(self.arrayMainPurchaseOrderList)[indexPath.row] valueForKey:@"MinStockLevel"]];
            
        
            cell=manualOrderCell;
            
            return cell;
            
            
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(tableView == _tblPurchaseOrderList)
    {
        NSMutableArray *dict = [(self.arrayMainPurchaseOrderList)[indexPath.row]mutableCopy];
        
        if([[dict valueForKey:@"selection"] isEqualToString:@"0"])
        {
            [dict setValue:@"1" forKey:@"selection"];
            
        }
        else{
            [dict setValue:@"0" forKey:@"selection"];
        }
        (self.arrayMainPurchaseOrderList)[indexPath.row] = dict;
        [_tblPurchaseOrderList reloadData];
    }
}

-(IBAction)cancelClick:(id)sender{
    [Appsee addEvent:kPOGenerateOrderBackListDataCancel];
    //[self.view removeFromSuperview];
    
    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
    
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else{
        
        [objGOrder hideBackOrderListWithAnimation];
    }

    
}
-(IBAction)doneClick:(id)sender{
    
    //[self.view removeFromSuperview];
    
    
    if(objGOrder){
        
        NSPredicate *isselection = [NSPredicate predicateWithFormat:@"selection == \"1\""];
        NSMutableArray *arraySelected = [[self.arrayMainPurchaseOrderList filteredArrayUsingPredicate:isselection]mutableCopy];
        NSDictionary *selectedDict = @{kPOGenerateOrderBackListDataDoneKey : @(arraySelected.count)};
        [Appsee addEvent:kPOGenerateOrderBackListDataDone withProperties:selectedDict];
        if(arraySelected.count>0)
        {
            for(NSMutableDictionary *dict  in arraySelected){
                [dict removeObjectForKey:@"selection"];
            }
        }
        
        objGOrder.arrBackorderSelected = [arraySelected mutableCopy];
        
    }
    else{
        
        NSPredicate *isselection = [NSPredicate predicateWithFormat:@"selection == \"1\""];
        NSMutableArray *arraySelected = [[self.arrayMainPurchaseOrderList filteredArrayUsingPredicate:isselection]mutableCopy];
        
        objPur.arrSelectedManualList=[arraySelected mutableCopy];
        
        if(objPur.arrSelectedManualList.count>0)
        {
            for(NSMutableDictionary *dict  in objPur.arrSelectedManualList){
                [dict removeObjectForKey:@"selection"];
            }
        }
        [objPur filterDepartmentamdSupplierforFilterList];
        
        
       
    }

    if ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone)
    {
        
        [self dismissViewControllerAnimated:YES completion:nil];
        
    }
    else{
        
        [objGOrder hideBackOrderListWithAnimation];
    }
   
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
