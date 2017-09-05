#import "EMVViewController.h"


@implementation EMVViewController

-(void)displayAlert:(NSString *)title message:(NSString *)message
{
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
	[alert show];
}

#define RF_COMMAND(operation,c) {if(!c){[self displayAlert:@"Operatin failed!" message:[NSString stringWithFormat:@"%@ failed, error %@, code: %d",operation,error.localizedDescription,error.code]]; return;} }

/*static BOOL stringToHex(NSString *str, uint8_t *data, int length)
{
    NSString *t=[[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] lowercaseString];
    if([t length]<(length*3-1))
        return FALSE;
    for(int i=0;i<[t length];i++)
    {
        char c=[t characterAtIndex:i];
        if((c<'0' || c>'9') && (c<'a' || c>'f') && c!=' ')
            return FALSE;
    }
    
    for(int i=0;i<length;i++)
    {
        char c=[t characterAtIndex:i*3];
        if(c>='a')
            data[i]=c-'a'+10;
        else
            data[i]=c-'0';
        data[i]<<=4;
        
        c=[t characterAtIndex:i*3+1];
        if(c>='a')
            data[i]|=c-'a'+10;
        else
            data[i]|=c-'0';
    }
    return true;
}*/

static NSString *hexToString(NSString * label, void *data, int length)
{
	const char HEX[]="0123456789ABCDEF";
	char s[2000];
	for(int i=0;i<length;i++)
	{
		s[i*3]=HEX[((uint8_t *)data)[i]>>4];
		s[i*3+1]=HEX[((uint8_t *)data)[i]&0x0f];
		s[i*3+2]=' ';
	}
	s[length*3]=0;
	
    if(label)
        return [NSString stringWithFormat:@"%@(%d): %s",label,length,s];
    else
        return [NSString stringWithCString:s encoding:NSASCIIStringEncoding];
}

-(void)log:(NSString *)text
{
    NSLog(@"%@",text);
    logView.text=[logView.text stringByAppendingFormat:@"\n%@",text];
}

#define TEST_EMV(title,function) \
    if(!function){[self log:[NSString stringWithFormat:@"%@ failed: %@",title,error.localizedDescription]]; return;}; \
    [self log:[NSString stringWithFormat:@"%@ succeeded\nEMV Status: %d",title,dtdev.emvLastStatus]];

#define TEST(title,function) \
    if(!function){[self log:[NSString stringWithFormat:@"%@ failed: %@",title,error.localizedDescription]]; return;}; \
    [self log:[NSString stringWithFormat:@"%@ succeeded",title]];

-(IBAction)onEMVTest:(id)sender
{
    NSError *error;
    
    [logView setText:@""];
    
    TEST(@"*** Init SmartCard module",[dtdev scInit:SLOT_MAIN error:&error]);
    
    TEST(@"*** Check SmartCard present",[dtdev scIsCardPresent:SLOT_MAIN error:&error]);
    
    NSData *atr=[dtdev scCardPowerOn:SLOT_MAIN error:&error];
    TEST(@"*** Power on SmartCard",atr);
    [self log:hexToString(@"ATR",(uint8_t *)atr.bytes,atr.length)];
    
    TEST_EMV(@"*** Check if card is EMV",[dtdev emvATRValidation:atr warmReset:TRUE error:&error]);
    
    TEST_EMV(@"*** Set aquirer ident",[dtdev emvSetDataAsString:TAG_ACQUIRER_IDENTIFIER data:@"112233445566" error:&error]);
    
    TEST_EMV(@"*** Add terminal capabilities",[dtdev emvSetDataAsString:TAG_ADD_TERM_CAPABILITIES data:@"0000000000" error:&error]);
    
    TEST_EMV(@"*** Set serial number",[dtdev emvSetDataAsString:TAG_SERIAL_NUMBER data:@"12345678" error:&error]);
    
    TEST_EMV(@"*** Set merchant category",[dtdev emvSetDataAsString:TAG_MERCHANT_CATEGORY_CODE data:@"0000" error:&error]);
    
    TEST_EMV(@"*** Set merchant ident",[dtdev emvSetDataAsString:TAG_MERCHANT_IDENTIFIER data:@"BAI SPIROIDON" error:&error]);
    
    TEST_EMV(@"*** Set POS entry mode",[dtdev emvSetDataAsString:TAG_POS_ENTRY_MODE data:@"05" error:&error]);
    
    TEST_EMV(@"*** Set terminal capabilities",[dtdev emvSetDataAsString:TAG_TERMINAL_CAPABILITIES data:@"000000" error:&error]);
    
    TEST_EMV(@"*** Set terminal country code",[dtdev emvSetDataAsString:TAG_TERMINAL_COUNTRY_CODE data:@"0724" error:&error]);
    
    TEST_EMV(@"*** Set terminal ID",[dtdev emvSetDataAsString:TAG_TERMINAL_ID data:@"PPADXXXX" error:&error]);
    
    TEST_EMV(@"*** Set terminal type",[dtdev emvSetDataAsString:TAG_TERMINAL_TYPE data:@"22" error:&error]);
    
    
    uint8_t AIDs[8][7]=
    {
        {0xA0,0x00,0x00,0x00,0x03,0x10,0x10},
        {0xA0,0x00,0x00,0x00,0x03,0x20,0x10},
        {0xA0,0x00,0x00,0x00,0x04,0x10,0x10},
        {0xA0,0x00,0x00,0x00,0x03,0x30,0x10},
        {0xA0,0x00,0x00,0x00,0x04,0x60,0x60},
        {0xA0,0x00,0x00,0x00,0x04,0x30,0x60},
        {0xA0,0x00,0x00,0x00,0x01,0x30,0x30},
        {0xA0,0x00,0x00,0x00,0x65,0x10,0x10},
    };
    NSMutableArray *apps=[[NSMutableArray alloc] init];
    
    for(int i=0;i<8;i++)
    {
        DTEMVApplication *emv=[[DTEMVApplication alloc] init];
        emv.aid=[NSData dataWithBytes:AIDs[i] length:sizeof(AIDs[i])];
        emv.label=@"VISA/MASTER";
        emv.matchCriteria=MATCH_PARTIAL_VISA;
        [apps addObject:emv];
    }
    
    TEST_EMV(@"*** Load EMV application list",[dtdev emvLoadAppList:apps selectionMethod:SELECTION_PSE includeBlockedAIDs:FALSE error:&error]);
    
    BOOL confirmationRequired;
    NSArray *commonApps=[dtdev emvGetCommonAppList:&confirmationRequired error:&error];
    TEST_EMV(@"*** Get common application list",commonApps);
    for(int i=0;i<commonApps.count;i++)
    {
        DTEMVApplication *emv=[commonApps objectAtIndex:i];
        [self log:[NSString stringWithFormat:@"\n%d. %@\n%@",i+1,emv.label,hexToString(@"ATR",(uint8_t *)emv.aid.bytes,emv.aid.length)]];
    }
    
    
    TEST_EMV(@"*** Set transaction time",[dtdev emvSetDataAsString:TAG_TRANSACTION_TIME data:@"000000" error:&error]);
    
    TEST_EMV(@"*** Set transaction date",[dtdev emvSetDataAsString:TAG_TRANSACTION_DATE data:@"010111" error:&error]);
    
    TEST_EMV(@"*** Set transaction counter",[dtdev emvSetDataAsString:TAG_TRANSACTION_SEQ_COUNTER data:@"000001" error:&error]);
    
    if(commonApps.count>0)
    {
        DTEMVApplication *app=[commonApps objectAtIndex:0];
        TEST_EMV(@"*** Initial application processing",[dtdev emvInitialAppProcessing:app.aid error:&error]);
    
        TEST_EMV(@"*** Read application data",[dtdev emvReadAppData:nil error:&error]);
        
        NSString *appNumber=[dtdev emvGetDataAsString:TAG_APP_VERSION_NUMBER error:&error];
        TEST_EMV(@"*** Read application number",appNumber);
        if(appNumber)
            [self log:[NSString stringWithFormat:@"Application number: %@",appNumber]];
    }
    
    NSString *track2=[dtdev emvGetDataAsString:TAG_TRACK2_EQUIVALENT_DATA error:&error];
    TEST_EMV(@"*** Read track 2",track2);
    if(track2)
        [self log:[NSString stringWithFormat:@"Track2: %@",track2]];
    
    TEST_EMV(@"*** Set transaction type",[dtdev emvSetDataAsString:TAG_TRANSACTION_TYPE data:@"00" error:&error]);
    
    TEST_EMV(@"*** Set application version",[dtdev emvSetDataAsString:TAG_APP_VERSION_NUMBER data:@"008C" error:&error]);
    
    TEST_EMV(@"*** Set action default",[dtdev emvSetDataAsString:TAG_TERM_ACTION_DEFAULT data:@"D84000A800C" error:&error]);
    
    TEST_EMV(@"*** Set action deny",[dtdev emvSetDataAsString:TAG_TERM_ACTION_DENIAL data:@"D84000F800" error:&error]);
    
    TEST_EMV(@"*** Set action online",[dtdev emvSetDataAsString:TAG_TERM_ACTION_ONLINE data:@"0010000000" error:&error]);
    
    TEST_EMV(@"*** Set DDOL",[dtdev emvSetDataAsString:TAG_DEFAULT_DDOL data:@"9F3704" error:&error]);
    
    TEST_EMV(@"*** Set TDOL",[dtdev emvSetDataAsString:TAG_DEFAULT_TDOL data:@"9F02065F2A029A039C0195059F3704" error:&error]);
    
    TEST_EMV(@"*** Set authorized ammount",[dtdev emvSetDataAsString:TAG_AMOUNT_AUTHORISED_NUM data:@"000000001234" error:&error]);
    
    TEST_EMV(@"*** Set transaction currency code",[dtdev emvSetDataAsString:TAG_TRANSACTION_CURR_CODE data:@"0978" error:&error]);
    
    
    TEST_EMV(@"*** EMV authentication",[dtdev emvAuthentication:FALSE error:&error]);
    
    TEST_EMV(@"*** EMV process restrictions",[dtdev emvProcessRestrictions:&error]);
    
    
    TEST_EMV(@"*** Set floor limit currency",[dtdev emvSetDataAsString:TAG_FLOOR_LIMIT_CURRENCY data:@"0978" error:&error]);
    
    TEST_EMV(@"*** Set terminal floor limit",[dtdev emvSetDataAsString:TAG_TERMINAL_FLOOR_LIMIT data:@"10000000" error:&error]);
    
    
    TEST_EMV(@"*** Terminal risk",[dtdev emvTerminalRisk:TRUE error:&error]);
    
    TEST_EMV(@"*** Get authentication method",[dtdev emvGetAuthenticationMethod:&error]);
}

-(void)viewWillAppear:(BOOL)animated
{
}

-(void)viewWillDisappear:(BOOL)animated
{
    [dtdev rfClose:nil];
}

-(void)viewDidLoad
{
	dtdev=[DTDevices sharedDevice];
    [dtdev addDelegate:self];
    [super viewDidLoad];
}


@end
