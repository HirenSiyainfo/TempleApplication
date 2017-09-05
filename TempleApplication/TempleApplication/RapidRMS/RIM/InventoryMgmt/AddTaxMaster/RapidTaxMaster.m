//
//  RapidTaxMaster.m
//  RapidRMS
//
//  Created by Siya Infotech on 25/09/15.
//  Copyright (c) 2015 Siya Infotech. All rights reserved.
//

#import "RapidTaxMaster.h"
#import "RmsDbController.h"

@interface RapidTaxMaster ()

@property (nonatomic, strong) RmsDbController *rmsDbController;
@property (assign) BOOL IsDeleted;

@end

@implementation RapidTaxMaster


-(instancetype)init
{
    self = [super init];
    
    if (self) {
        self.rmsDbController = [RmsDbController sharedRmsDbController];
        [self resetRapidTaxMaster];
    }
    return self;
}

-(void)resetRapidTaxMaster
{
    self.TaxId = @(0);
    self.TAXNAME = @"";
    self.SrNo = @(0);
    self.PERCENTAGE = @(0);
    self.Type = @"";
    self.IsDeleted = FALSE;
    self.Amount = @(0);
    self.BranchId = @(0);
    self.CreatedBy = @(0);
    self.CreatedDate = @"";
    
}
-(void)configureRapidTaxMasterFromDictionary :(NSDictionary *)taxMasterDictionary
{
    self.TaxId =  @([[taxMasterDictionary valueForKey:@"TaxId"] integerValue]);
    self.TAXNAME =[taxMasterDictionary valueForKey:@"TAXNAME"] ;
    self.PERCENTAGE =[taxMasterDictionary valueForKey:@"PERCENTAGE"];
    self.Type = [taxMasterDictionary valueForKey:@"Type"];
    self.Amount = [taxMasterDictionary valueForKey:@"Amount"];
    self.BranchId = [taxMasterDictionary valueForKey:@"BranchId"];
}

-(NSDictionary *)rapidTaxMasterDictionary
{
 
    NSMutableDictionary *rapidTaxMasterDictionary = [[NSMutableDictionary alloc] init];
    
    rapidTaxMasterDictionary[@"TaxId"] = [NSString stringWithFormat:@"%@",self.TaxId];
    rapidTaxMasterDictionary[@"TAXNAME"] = [NSString stringWithFormat:@"%@",self.TAXNAME];
    rapidTaxMasterDictionary[@"PERCENTAGE"] = [NSString stringWithFormat:@"%@",self.PERCENTAGE];
    
    /// Update process parameter. Do not pass it in insert process......
    if (self.TaxId.integerValue  > 0) {
        rapidTaxMasterDictionary[@"TaxId"] = [NSString stringWithFormat:@"%@",self.TaxId];
    }
    else
    {
        NSDate* date = [NSDate date];
        NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
        formatter.dateFormat = @"MM/dd/yyyy hh:mm a";
        NSString *currentDateTime = [formatter stringFromDate:date];
        rapidTaxMasterDictionary[@"localdatatime"] = currentDateTime;
    }
    rapidTaxMasterDictionary[@"SrNo"] = [NSString stringWithFormat:@"%@",self.SrNo];

    rapidTaxMasterDictionary[@"Type"] = [NSString stringWithFormat:@"%@",self.Type];
    rapidTaxMasterDictionary[@"Amount"] = [NSString stringWithFormat:@"%@",self.Amount.stringValue];
    
    rapidTaxMasterDictionary[@"BranchId"] = (self.rmsDbController.globalDict)[@"BranchID"];
    rapidTaxMasterDictionary[@"CreatedBy"] = (self.rmsDbController.globalDict)[@"UserInfo"][@"UserId"];
    return rapidTaxMasterDictionary;

}



@end
