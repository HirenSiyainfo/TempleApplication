//
//  GasInvoiceReceiptPrint.h
//  RapidRMS
//
//  Created by Siya10 on 29/06/16.
//  Copyright © 2016 Siya Infotech. All rights reserved.
//

#import "InvoiceReceiptPrint.h"

@interface GasInvoiceReceiptPrint : InvoiceReceiptPrint


@property (nonatomic, strong)NSMutableArray *arrPumpCartArray;
- (NSArray*)fetchFuelDetails:(NSString *)entityName withPumpIndex:(int)fuelIndex withMoc:(NsmoContext *)moc;
@end
