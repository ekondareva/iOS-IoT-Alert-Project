//
//  RASHistoryViewController.m
//  AlertProject
//
//  Created by Ekaterina Kondareva on 11/27/12.
//  Copyright (c) 2012 Ekaterina Kondareva. All rights reserved.
//

#import "RASHistoryViewController.h"

@interface RASHistoryViewController ()


@end

@implementation RASHistoryViewController

@synthesize loginViewController=_loginViewController;

@synthesize logoutButton = _logoutButton;
@synthesize devicesButton = _devicesButton;
@synthesize nameLabel = _nameLabel;
@synthesize nameText = _nameText;
@synthesize deviceIdText = _deviceIdText;

@synthesize histData = _histData;
@synthesize historyLog =_historyLog;
@synthesize isStatusOK =_isStatusOK;
@synthesize myIndicator=_myIndicator;

-(void)startSpinner{
    self.myIndicator = [[UIActivityIndicatorView alloc]
                        initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.myIndicator.center = CGPointMake(160, 240);
    self.myIndicator.hidesWhenStopped = YES;
    [self.view addSubview:self.myIndicator];
    [self.myIndicator startAnimating];
}

-(void)stopSpinner{
    [self.myIndicator stopAnimating];
}

-(void)haveRefreshed{
    [self fillHistoryLog];
    [self stopSpinner];
}



- (void)viewDidLoad
{    
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveRefreshed)
                                                 name:@"DataReceived" object:nil];
  
    self.nameLabel.text=self.nameText;
    self.deviceIdText = self.deviceIdText;
    
    // start indicator spinner        
    [self getHistory];
    
    [self.tableView reloadData];    
 }   


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

// we will fill in the table with device history log
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.historyLog count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // we show the alert message as title and date and battery level as subtitle
    static NSString *CellIdentifier = @"histCell";
    
    UITableViewCell *histCell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if( histCell == nil )
    {        
        histCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if ([self.historyLog count]>0)
    {       
               
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
        histCell.textLabel.text = [[self.historyLog objectAtIndex:indexPath.row] notification];
        histCell.detailTextLabel.text = [NSString stringWithFormat:@"%@       Battery: %@%%",
                                         [[self.historyLog objectAtIndex:indexPath.row] alarmTime],
                                         [[self.historyLog objectAtIndex:indexPath.row] battery]];
    }
    
    return histCell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}


-(void) getHistory {
    [self startSpinner];
    
    NSString *webAddress = [NSString stringWithFormat:@"http://xprog44/api/v1/device/log/%@", self.deviceIdText];
    connectionRoutine *cR = [[connectionRoutine alloc] init];
    [cR connectionWithoutCredentials:webAddress requestMethod:@"GET"
                           userLogin:[[NSUserDefaults standardUserDefaults] objectForKey:@"login"]
                                      connetionGoal:1];
}

-(void)fillHistoryLog{
    self.histData = [[NSUserDefaults standardUserDefaults] objectForKey:@"histData"];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    
    NSString *json_string = [[NSString alloc] initWithBytes: [self.histData mutableBytes] length:[self.histData length] encoding :NSUTF8StringEncoding];
        
    self.historyLog = [[NSMutableArray alloc] init];
    NSArray *jsonHistoryObjects = [parser objectWithString:json_string error:nil];
    for (NSDictionary *historyDict in jsonHistoryObjects)
    {
        LogEvent *newEvent = [[LogEvent alloc] init];        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
        
        NSDictionary *fields = [[NSDictionary alloc] init];
        fields = [historyDict objectForKey:@"fields"];
        
        newEvent.deviceID = [fields objectForKey:@"device_ref"];
        newEvent.notification = [fields objectForKey:@"message"];
        
        if ([[fields objectForKey:@"battery"] isKindOfClass:[NSString class]])
        {
            newEvent.battery = [fields objectForKey:@"battery"];
        }
        else
        {
            newEvent.battery = @"100";
        }
        
        NSDate *date = [dateFormatter dateFromString:[fields objectForKey:@"timestamp"]];
        // we edit the time once more to be more readable  [format setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
        [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
        
        newEvent.alarmTime = [dateFormatter stringFromDate:date];        
        
        [self.historyLog addObject:newEvent];
    }       
    parser = nil;    
    //  should update the tableview
    [self.tableView reloadData];
}

- (IBAction)devicesPressed:(id)sender {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {    
        // go back to detailview controller or splitview?        
    }    
    else {        
    // extra navigation to get to the main page (RASMasterViewController)
    [self.navigationController popToRootViewControllerAnimated:YES];
    }
}
- (IBAction)logoutPressed:(id)sender {    
        
    NSMutableData *data=[[NSMutableData alloc] init];
    [data setLength: 0];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"webData"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"login"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isAuthenticated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {             
    }
    else {        
         //  go to RASMasterViewController for login window
        [self.navigationController popToRootViewControllerAnimated:YES];
    }        
}


@end
