//
//  RASHistoryViewController.h
//  AlertProject
//
//  Created by Ekaterina Kondareva on 11/27/12.
//  Copyright (c) 2012 Ekaterina Kondareva. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "LoginViewController.h"
#import "LogEvent.h"
#import "SBJson.h"

@interface RASHistoryViewController : UITableViewController // <UISplitViewControllerDelegate>

@property (strong, nonatomic) LoginViewController *loginViewController;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *logoutButton;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *devicesButton;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) NSString *nameText;

@property (nonatomic, retain) NSString *deviceIdText;

@property(nonatomic, retain) NSMutableData *histData;
@property (nonatomic, retain) NSMutableArray *historyLog;
@property (assign, nonatomic) BOOL isStatusOK;

@property (nonatomic, retain) UIActivityIndicatorView *myIndicator;


- (IBAction)devicesPressed:(id)sender;

- (void) getHistory;

- (IBAction)logoutPressed:(id)sender;

-(void)startSpinner;
-(void)stopSpinner;
-(void)haveRefreshed;
-(void)fillHistoryLog;

@end
