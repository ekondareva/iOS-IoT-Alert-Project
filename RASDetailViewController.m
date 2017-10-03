//
//  RASDetailViewController.m
//  AlertProject
//
//  Created by Ekaterina Kondareva on 11/27/12.
//  Copyright (c) 2012 Ekaterina Kondareva. All rights reserved.
//

#import "RASDetailViewController.h"

@interface RASDetailViewController ()

@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation RASDetailViewController

@synthesize detailDescriptionLabel;
@synthesize historyViewController=_historyViewController;
@synthesize loginViewController=_loginViewController;
@synthesize detailViewController=_detailViewController;

@synthesize sensorText=_sensorText;
@synthesize sensor=_sensor;

@synthesize deviceIdText=_deviceIdText;
@synthesize deviceID=_deviceID;

@synthesize statusText=_statusText;
@synthesize status=_status;

@synthesize timeText=_timeText;
@synthesize time=_time;

@synthesize switchLabel=_switchLabel;
@synthesize high_low=_high_low;

@synthesize textLabel=_textLabel;
@synthesize nickNameTextField=_nickNameTextField;

@synthesize logoutButton=_logoutButton;
@synthesize changesButton=_changesButton;
@synthesize EmailButton=_EmailButton;

@synthesize myIndicator=_myIndicator;
@synthesize isPriorityOn=_isPriorityOn;

@synthesize view1 = _view1;
@synthesize view2 = _view2;

@synthesize nickNameText=_nickNameText;


// @synthesize SeeHistoryButton;

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}

- (void)configureView
{
    // Update the user interface for the detail item.

    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

-(void)startSpinner{
    self.myIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
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
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view1.layer.cornerRadius = 10;
    self.view2.layer.cornerRadius = 10;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(haveRefreshed)
                                                 name:@"DataReceived" object:nil];
        
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {       
        
        NSString *isAuthenticatedStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAuthenticated"];
        if (([isAuthenticatedStatus isEqualToString:(@"NO")]) || (isAuthenticatedStatus == NULL))
        {   
            self.loginViewController=[[LoginViewController alloc] init];            
            [self presentViewController:self.loginViewController animated:YES completion:nil];
        }
    }    
    
    self.deviceIdText.text=self.deviceID;
    self.nickNameTextField.text=self.nickNameText;
    self.sensorText.text=self.sensor;
    self.statusText.text=self.status;
    self.timeText.text=self.time;
    
    [self.high_low setOn:self.isPriorityOn];
    [self.emailNotification setOn:self.isEmailOn];
    
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

-(void) viewWillAppear:(BOOL)animated {   
}

-(void) viewDidAppear {     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    
    // handles the tap outside keyboard in login view controller
    // dismisses the keyboard    
    [[self view] endEditing:TRUE];
    
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
//    barButtonItem.title = NSLocalizedString(@"Master", @"Master");
    barButtonItem.title = NSLocalizedString(@"Devices", @"Devices");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}


- (IBAction)saveChangesPressed:(id)sender {      
    [self startSpinner];
    
    NSString *emailNotificationStr=@"";
    if (self.emailNotification.on) emailNotificationStr= @"EML";
    NSString *alertNotificationStr=@"";
    if (self.high_low.on) alertNotificationStr= @"MAC";
    
    NSString *notificationString=[NSString stringWithFormat:@"%@b%@b%@", @"MPA", alertNotificationStr, emailNotificationStr];
    
    NSString *nicknameStr=self.nickNameTextField.text;
    if ([self.nickNameTextField.text isEqualToString:@""]) nicknameStr=self.deviceID;
    else {
        nicknameStr = [self.nickNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@"_"];
    }
    
    // we conncet to the server to get the list of events
    NSString *webAddress = [NSString stringWithFormat:@"http://xprog44/api/v1/%@/%@/%@/%@",
                            [[NSUserDefaults standardUserDefaults] objectForKey:@"login"],
                            self.deviceID, nicknameStr, notificationString];
       
    connectionRoutine *cR = [[connectionRoutine alloc] init];
    [cR connectionWithCredentials:webAddress requestMethod:@"PUT" userLogin:[[NSUserDefaults standardUserDefaults] objectForKey:@"login"] userPassword:[[NSUserDefaults standardUserDefaults] objectForKey:@"password"] connetionGoal:2 callingView:self.view];        
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"historyPressed"]) {
        
        UIViewController *viewController = [segue destinationViewController];
        
        if([viewController isKindOfClass:[RASHistoryViewController class]]) {           
                        
            RASHistoryViewController *historyVC = (RASHistoryViewController *) viewController;            
            // takes device name and id to history view controller
            [historyVC setNameText:self.title];
            [historyVC setDeviceIdText:self.deviceIdText.text];
            
        }
    }
}
- (IBAction)SeeHistoryButtonPressed {
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        // takes device name and id to history view controller
        self.historyViewController.nameLabel.text = self.title;
        self.historyViewController.deviceIdText = self.deviceIdText.text;          
    }
}
- (IBAction)emailButtonPressed:(id)sender {        
    // this sends the alert information as as an email
    // makes the subject out of devicename
    NSString *subject = [NSString stringWithFormat:@"Alert from %@", self.title];
    
    
    // we could give here more details about alert
    NSString *body = [NSString stringWithFormat:@"Alert received from %@, at %@, status: %@, sensor type: %@", self.title, self.timeText.text,
                      self.statusText.text, self.sensorText.text];
    
    // pre-fills the email
    MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
    controller.mailComposeDelegate = self;
    
    [controller setSubject:subject];
    
    [controller setMessageBody:body isHTML:NO];
    
    [self presentViewController:controller animated:YES completion:nil]; 
    
}

// handles closing or sending the email
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	[self becomeFirstResponder];
	[self dismissViewControllerAnimated:YES completion:nil];
    
}
- (IBAction)logoutPressed:(id)sender {
    
    // empty username, pwd and all data of devices
    // re-direct to login page / master page
    NSMutableData *data=[[NSMutableData alloc] init];
    [data setLength: 0];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"webData"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"login"];
    [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
    [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"isAuthenticated"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {        
        
       NSString *isAuthenticatedStatus = [[NSUserDefaults standardUserDefaults] objectForKey:@"isAuthenticated"];
        if (([isAuthenticatedStatus isEqualToString:(@"NO")]) || (isAuthenticatedStatus == NULL))
        {
            self.loginViewController=[[LoginViewController alloc] init];
            [self presentViewController:self.loginViewController animated:YES completion:nil];            
        }
    }
    else {    
        //  go to RASMasterViewController for login window
     [self.navigationController popToRootViewControllerAnimated:YES];
     }
}


@end
