//
//  RASMasterViewController.m
//  AlertProject
//
//  Created by Ekaterina Kondareva on 11/27/12.
//  Copyright (c) 2012 Ekaterina Kondareva. All rights reserved.
//

#import "RASMasterViewController.h"

#import "RASDetailViewController.h"
#import "PTPusher.h"

@interface RASMasterViewController () {
    NSMutableArray *_objects;
}
@end

@implementation RASMasterViewController

@synthesize loginViewController=_loginViewController;
@synthesize detailViewController=_detailViewController;
@synthesize devicesList = _devicesList;
@synthesize isAuthenticated= _isAuthenticated;
@synthesize logoutButton = _logoutButton;
@synthesize myIndicator=_myIndicator;
@synthesize pusher = _pusher;



- (void) setupPusher {   
    // Create a Pusher client, using your Pusher app key as the credential
    // TODO: Move Pusher app key to configuration file
    self.pusher = [PTPusher pusherWithKey:@"dbef6f7aa3cd6f62b8c9" delegate:self encrypted:NO];
    self.pusher.reconnectAutomatically = YES;
    
    
    // Subscribe to the 'todo-updates' channel
    PTPusherChannel *alertChannel = [self.pusher subscribeToChannelNamed:@"sudeep"];
    

    // Bind to the 'todo-added' event
    [alertChannel bindToEventNamed:@"my-event" handleWithBlock:^(PTPusherEvent *channelEvent) {
        NSString *isAuthenticatedStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAuthenticated"];
        if ([isAuthenticatedStatus isEqualToString:(@"YES")])
        {
            UIAlertView *push_alert = [[UIAlertView alloc]
                                   initWithTitle: @"ALERT!"
                                   message: [(NSDictionary *)[channelEvent data] valueForKey:@"message"]
                                   delegate:self
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil
                                   ];        
            [push_alert show];
        }
        
    }];
}


- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    }    
    [super awakeFromNib];
}


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
    [self stopSpinner];
    [self fillDeviceList];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.detailViewController = (RASDetailViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveRefreshed)
                                                 name:@"DataReceived" object:nil];
    [self setupPusher];
}

-(void)fillDeviceList{
    self.devicesList = [[NSMutableArray alloc] init];
    
    // we parse the data from the server and store it to the list in userdefaults
    NSString *isAuthenticatedStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAuthenticated"];
   
   
    if ([isAuthenticatedStatus isEqualToString:(@"YES")])
    {
        // we show activity indicator spinner during data parsing
        [self startSpinner];
        
        NSMutableData *webData = [[NSUserDefaults standardUserDefaults] objectForKey:@"deviceListData"];
        SBJsonParser *parser = [[SBJsonParser alloc] init];
        
        NSString *json_string = [[NSString alloc] initWithBytes: [webData mutableBytes] length:[webData length] encoding :NSUTF8StringEncoding];
               
        NSArray *jsonObjects = [parser objectWithString:json_string error:nil];       
        Device *newDevice;
        for (NSDictionary *dict in jsonObjects)
        {
            NSString *model=[dict objectForKey:@"model"];
            if ([model isEqualToString:@"RAS.device"])
            {
                newDevice = [[Device alloc] init];
                
                NSDictionary *fields = [[NSDictionary alloc] init];
                fields = [dict objectForKey:@"fields"];
                
                newDevice.deviceID = [fields objectForKey:@"device_ref"];
                
                if ([[fields objectForKey:@"name"] isKindOfClass:[NSString class]])
                {
                    newDevice.nickName = [fields objectForKey:@"name"];
                }
                else
                {
                    newDevice.nickName =@"";
                }                
                
                [self.devicesList addObject:newDevice];
            }
            else if ([model isEqualToString:@"RAS.devicenotificationslog"])
            {
                NSDictionary *fields = [[NSDictionary alloc] init];
                fields = [dict objectForKey:@"fields"];
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                
                [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
                dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
                [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
                [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS"];
                
                NSDate *date = [dateFormatter dateFromString:[fields objectForKey:@"timestamp"]];
                
                // we edit the time once more to be more readable  [format setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
                [dateFormatter setDateFormat:@"MMM dd, yyyy HH:mm:ss"];
                
                newDevice.lastAlarmTime = [dateFormatter stringFromDate:date];
                                
                newDevice.currentState = [fields objectForKey:@"message"];
            }
            else if ([model isEqualToString:@"RAS.sensortype"])
            {
                NSDictionary *fields = [[NSDictionary alloc] init];
                fields = [dict objectForKey:@"fields"];
                
                newDevice.sensorType = [fields objectForKey:@"type"];
            }
            else if ([model isEqualToString:@"RAS.devicenotificationtypes"])
            {
                NSDictionary *fields = [[NSDictionary alloc] init];
                fields = [dict objectForKey:@"fields"];
                
                NSString *notification_type=[fields objectForKey:@"notification"];
                
                if ([notification_type isEqualToString:@"MAC"])
                    newDevice.activeNotification = @"YES";
                else if ([notification_type isEqualToString:@"MPA"])
                    newDevice.passiveNotification = @"YES";
                else if ([notification_type isEqualToString:@"EML"])
                    newDevice.emailNotification = @"YES";                
            }       
            
        }        
        [self stopSpinner];
        parser = nil;             
        
        // we reload the table view to show the parsed data
        [self.tableView reloadData];
        
    } else {
        // calls for login view if not logged in
        if (self.loginViewController == nil) {
            self.loginViewController=[[LoginViewController alloc] init];
            [self presentViewController:self.loginViewController animated:YES completion:nil];          
        }
    }
}

-(void)viewWillAppear:(BOOL)animated{
    [self fillDeviceList];
}


-(void)viewDidAppear:(BOOL)animated{        
  // if we press "log out" in other views, we return here and call for the login view
  // calls for login view if not logged in
    
    NSString *isAuthenticatedStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAuthenticated"];   
   
    if (([isAuthenticatedStatus isEqualToString:(@"NO")]) || (isAuthenticatedStatus == NULL))
    {               
        self.loginViewController=[[LoginViewController alloc] init];        
        [self presentViewController:self.loginViewController animated:YES completion:nil];        
        
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

// here we fill in the table view with the list of devices
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.devicesList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if( cell == nil )
    {        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if ([self.devicesList count]>0)
    {
        if ([[[self.devicesList objectAtIndex:indexPath.row] nickName] isEqualToString:@""])
            cell.textLabel.text = [[self.devicesList objectAtIndex:indexPath.row] deviceID];
        else cell.textLabel.text = [[self.devicesList objectAtIndex:indexPath.row] nickName];
        
        cell.detailTextLabel.text = [[self.devicesList objectAtIndex:indexPath.row] deviceID];
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return NO;
}



- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
       // sets the device name to be the detail view controller
        self.detailViewController.title = [[self.devicesList objectAtIndex:indexPath.row] nickName];
        self.detailViewController.deviceIdText.text = [[self.devicesList objectAtIndex:indexPath.row] deviceID];
        self.detailViewController.sensorText.text = [NSString stringWithFormat:@"sensor "];
        self.detailViewController.statusText.text = [NSString stringWithFormat:@"status "];
        self.detailViewController.timeText.text = [NSString stringWithFormat:@"time"];
        
        // If priority/big alert is on
        // self.detailViewController.high_low.on;

      }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        
        UIViewController *viewController = [segue destinationViewController];
        
        if([viewController isKindOfClass:[RASDetailViewController class]]) {
            
            NSLog(@"View controller was identified as detailViewController!");
            RASDetailViewController *detailVC = (RASDetailViewController *) viewController;
            
            NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
            
            if ([[[self.devicesList objectAtIndex:indexPath.row] nickName] isEqualToString:@""])
            {
                [detailVC setTitle:[[self.devicesList objectAtIndex:indexPath.row] deviceID]];
                detailVC.nickNameText =[[self.devicesList objectAtIndex:indexPath.row] deviceID];
            }
            else {
                [detailVC setTitle:[[self.devicesList objectAtIndex:indexPath.row] nickName]];
                 detailVC.nickNameText =[[self.devicesList objectAtIndex:indexPath.row] nickName];
            }
            
            detailVC.deviceID=[[self.devicesList objectAtIndex:indexPath.row] deviceID];
            detailVC.status=[[self.devicesList objectAtIndex:indexPath.row] currentState];
            detailVC.sensor=[[self.devicesList objectAtIndex:indexPath.row] sensorType];
            detailVC.time=[[self.devicesList objectAtIndex:indexPath.row] lastAlarmTime];

            detailVC.isPriorityOn = ([[[self.devicesList objectAtIndex:indexPath.row] activeNotification] isEqualToString:@"YES"]);
            detailVC.isEmailOn = ([[[self.devicesList objectAtIndex:indexPath.row] emailNotification] isEqualToString:@"YES"]);
        }
    }
}

- (IBAction)logoutPressed:(id)sender {
    
    // empty username, passwd and all data of devices
    // and show login page again 
    NSMutableData *data=[[NSMutableData alloc] init];
    [data setLength: 0];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"webData"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"login"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isAuthenticated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
   
    if (self.loginViewController == nil) {
        self.loginViewController=[[LoginViewController alloc] init];
    }
    [self presentViewController:self.loginViewController animated:YES completion:nil];
    
}

- (IBAction)refreshPressed:(id)sender {
    [self startSpinner];
    
    NSString *webAddress = [NSString stringWithFormat:@"http://xprog44/api/v1/devices/%@",
                            [[NSUserDefaults standardUserDefaults] objectForKey:@"login"]];    
    connectionRoutine *cR = [[connectionRoutine alloc] init];
    [cR connectionWithCredentials:webAddress requestMethod:@"GET" userLogin:[[NSUserDefaults standardUserDefaults] objectForKey:@"login"] userPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] connetionGoal:0 callingView:self.view];
}

@end
