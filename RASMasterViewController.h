//
//  RASMasterViewController.h
//  AlertProject
//
//  Created by Ekaterina Kondareva on 11/27/12.
//  Copyright (c) 2012 Ekaterina Kondareva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "SBJson.h"
#import "Device.h"
#import "RASDetailViewController.h"
#import "LoginViewController.h"
#import "connectionRoutine.h"
#import "PTPusher.h"
#import "PTPusherDelegate.h"
#import "PTPusher.h"
#import "PTPusherEvent.h"
#import "PTPusherChannel.h"

@interface RASMasterViewController : UITableViewController <PTPusherDelegate>

@property (strong, nonatomic) RASDetailViewController *detailViewController;
@property (strong, nonatomic) LoginViewController *loginViewController;

@property (assign, nonatomic) BOOL isAuthenticated;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *logoutButton;
@property (nonatomic, retain) NSMutableArray *devicesList;

@property (nonatomic, retain) UIActivityIndicatorView *myIndicator;

- (IBAction)logoutPressed:(id)sender;

@property(nonatomic, retain) NSMutableData *infoData;
@property (assign, nonatomic) BOOL isStatusOK;

@property (nonatomic, strong) PTPusher *pusher;

// Sets up the Pusher client
- (void) setupPusher;

-(void)fillDeviceList;
-(void)startSpinner;
-(void)stopSpinner;

@end
