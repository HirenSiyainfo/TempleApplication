//
//  CL_CustomerProfileVC.m
//  RapidRMS
//
//  Created by Siya Infotech on 27/11/15.
//  Copyright © 2015 Siya Infotech. All rights reserved.
//

#import "CL_CustomerProfileVC.h"
#import "CL_CustomerInfoCell.h"
#import "AddCustomerVC.h"
#import "RmsDbController.h"

typedef NS_ENUM(NSInteger, CustomerProfileInformationSection)
{
    CustomerprofileEmail,
    CustomerprofileContact,
    CustomerprofileDOB,
    CustomerprofileCustomerNo,
    CustomerprofileShippingAddress,
    CustomerprofileBillingAddress
};

@interface CL_CustomerProfileVC ()<UICollectionViewDataSource , UICollectionViewDelegate,AddCustomerVCdelegate>
{
    NSMutableArray *arrImages;
    NSMutableArray *arrInfo;
    NSArray *customerProfileInformationSectionArray;

}

@property (nonatomic, weak) IBOutlet UICollectionView *customerInfo;
@property (nonatomic, weak) IBOutlet UILabel *lblCustomerName;
@property (nonatomic, strong) AddCustomerVC *addCustomerVC;;
@property (nonatomic, strong) RmsDbController *rmsDbController;;

@end

@implementation CL_CustomerProfileVC

- (void)viewDidLoad {
    [super viewDidLoad];
   
   }


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)setCustomerInfoDetail
{
    _lblCustomerName.text = [NSString stringWithFormat:@"%@ %@", self.rapidCustomerLoyaltyProfileObject.firstName ,self.rapidCustomerLoyaltyProfileObject.lastName] ;
    
    if (self.rapidCustomerLoyaltyProfileObject.address1.length > 0 || self.rapidCustomerLoyaltyProfileObject.city.length > 0 || self.rapidCustomerLoyaltyProfileObject.state.length > 0) {
        customerProfileInformationSectionArray = @[@(CustomerprofileEmail),@(CustomerprofileContact),@(CustomerprofileDOB),@(CustomerprofileCustomerNo) , @(CustomerprofileShippingAddress) , @(CustomerprofileBillingAddress)];
    }
    else
    {
        customerProfileInformationSectionArray = @[@(CustomerprofileEmail),@(CustomerprofileContact),@(CustomerprofileDOB),@(CustomerprofileCustomerNo) , @(CustomerprofileShippingAddress)];
    }
    [self.customerInfo reloadData];
}



- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
       return customerProfileInformationSectionArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
        CL_CustomerInfoCell *customerInfoCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CL_CustomerInfoCell" forIndexPath:indexPath];
        
        customerInfoCell.backgroundColor = [UIColor clearColor];
        
        CustomerProfileInformationSection customerProfileInformationSection = [customerProfileInformationSectionArray[indexPath.row] integerValue];
        customerInfoCell.lblDetail.frame = CGRectMake(95, 35, 170, 50);
        switch (customerProfileInformationSection) {
                
            case CustomerprofileEmail:
                customerInfoCell.lblDetail.text =[NSString stringWithFormat:@"%@",self.rapidCustomerLoyaltyProfileObject.email];
                customerInfoCell.imgBg.image = [UIImage imageNamed:@"cl_emailicon.png"];
                customerInfoCell.lblName.text = @"EMAIL";


                break;
                
            case CustomerprofileContact:
                customerInfoCell.lblDetail.text = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyaltyProfileObject.contactNo];
                customerInfoCell.imgBg.image = [UIImage imageNamed:@"cl_contacticon.png"];
                customerInfoCell.lblName.text = @"CONTACT #";

                break;
                
            case CustomerprofileDOB:
                customerInfoCell.lblDetail.text = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyaltyProfileObject.dateOfBirth];
                customerInfoCell.imgBg.image = [UIImage imageNamed:@"cl_dobicon.png"];
                customerInfoCell.lblName.text = @"DOB";

                break;
                
            case CustomerprofileCustomerNo:
                customerInfoCell.lblDetail.text = [NSString stringWithFormat:@"%@",self.rapidCustomerLoyaltyProfileObject.customerNo];
                customerInfoCell.imgBg.image = [UIImage imageNamed:@"cl_numbericon.png"];
                customerInfoCell.lblName.text = @"CUSTOMER #";

                break;
                
            case CustomerprofileShippingAddress:
                customerInfoCell.lblDetail.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",self.rapidCustomerLoyaltyProfileObject.shipAddress1 , self.rapidCustomerLoyaltyProfileObject.shipAddress2, self.rapidCustomerLoyaltyProfileObject.shipCity , self.rapidCustomerLoyaltyProfileObject.shipCountry , self.rapidCustomerLoyaltyProfileObject.shipZipCode];
                customerInfoCell.imgBg.image = [UIImage imageNamed:@"cl_deliveryicon.png"];
                customerInfoCell.lblName.text = @"SHIPPING ADDRESS";

                break;
                
            case CustomerprofileBillingAddress:
                customerInfoCell.lblDetail.text = [NSString stringWithFormat:@"%@ %@ %@ %@ %@",self.rapidCustomerLoyaltyProfileObject.address1 , self.rapidCustomerLoyaltyProfileObject.address2 , self.rapidCustomerLoyaltyProfileObject.city , self.rapidCustomerLoyaltyProfileObject.state , self.rapidCustomerLoyaltyProfileObject.zipCode];
                customerInfoCell.imgBg.image = [UIImage imageNamed:@"cl_invoiceicon.png"];
                customerInfoCell.lblName.text = @"BILLING ADDRESS";

                break;
                
            default:
                break;
        }
    [customerInfoCell.lblDetail sizeToFit];
        
        return customerInfoCell;
        
    
}

- (void)didUpdateCustomerList
{
    [self setCustomerInfoDetail];

}

-(IBAction)editCustomerInformation:(id)sender
{
    BOOL hasRights = [UserRights hasRights:UserRightCustomerLoyalty];
    if (!hasRights) {
        UIAlertActionHandler leftHandler = ^ (UIAlertAction *action)
        {
        };
        [self.rmsDbController popupAlertFromVC:self title:@"User Rights" message:@"You don't have rights to edit customer information. Please contact to Admin." buttonTitles:@[@"OK"] buttonHandlers:@[leftHandler]];
        return;
    }

    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    self.addCustomerVC = [storyBoard instantiateViewControllerWithIdentifier:@"AddCustomerVC"];
    self.addCustomerVC.modalPresentationStyle = UIModalPresentationFullScreen;
    self.addCustomerVC.addCustomerVCdelegate = self;
    self.addCustomerVC.rapidCustomerLoyalty = self.rapidCustomerLoyaltyProfileObject;
    [self.view addSubview:self.addCustomerVC.view];

}


@end
