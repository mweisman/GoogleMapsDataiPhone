//
//  RootViewController.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 09/07/09.
//  Copyright Michael Weisman 2009. All rights reserved.
//

#import "RootViewController.h"
#import "gMapsDataiPhoneAppDelegate.h"
#import "SettingsController.h"
#import "UserMapsController.h"
#import "AlertPrompt.h"


@implementation RootViewController
@synthesize appSections;


- (void)viewDidLoad {
    [self setTitle:@"GMaps Data"];
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    //[buildAppSections addObject:@"View My Maps"];
    //[buildAppSections addObject:@"Public Maps for User"];
    //[buildAppSections addObject:@"Create New Map"];
    //[buildAppSections addObject:@"Settings"];
    
    //UserMapsController *userMaps = [[UserMapsController alloc] initWithNibName:@"UserMapsView" bundle:nil];
    self.appSections = [[NSMutableArray alloc] init];
    
    UserMapsController *userMaps = [[UserMapsController alloc] init];
    userMaps.title = @"My Maps";
    [self.appSections addObject:userMaps];
    userMaps.userName = [[NSUserDefaults standardUserDefaults] objectForKey:@"user_preference"];
    [userMaps release];
	
	//SettingsController *settingsController = [[SettingsController alloc] initWithNibName:@"settingsView" bundle:nil];
    SettingsController *settingsController = [[SettingsController alloc] initWithStyle:UITableViewStyleGrouped];
	settingsController.title = @"Settings";
    [self.appSections addObject:settingsController];
	[settingsController release];

    [super viewWillAppear:animated];
}

/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
 // Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations.
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
 */

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release anything that can be recreated in viewDidLoad or on demand.
	// e.g. self.myOutlet = nil;
}


#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.appSections count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
	// Configure the cell.
    NSInteger row = [indexPath row];
	UITableViewController *tableViewController = [appSections objectAtIndex:row];
    cell.textLabel.text = tableViewController.title;
    return cell;
}


- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != [alertView cancelButtonIndex]) {
        UserMapsController *mapsForUser = [[UserMapsController alloc] init];
        mapsForUser.title = @"Maps for User";
        mapsForUser.userName = [(AlertPrompt *)alertView enteredText];
        gMapsDataiPhoneAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navigationController pushViewController:mapsForUser animated:YES];
    } else {
        [self.tableView reloadData];
    }
}



// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    // Navigation logic may go here -- for example, create and push another view controller.
	// AnotherViewController *anotherViewController = [[AnotherViewController alloc] initWithNibName:@"AnotherView" bundle:nil];
	// [self.navigationController pushViewController:anotherViewController animated:YES];
	// [anotherViewController release];
	NSUInteger row = [indexPath row];
	UITableViewController *nextController = [self.appSections objectAtIndex:row];
	
        gMapsDataiPhoneAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
        [delegate.navigationController pushViewController:nextController animated:YES];
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


- (void)dealloc {
    [appSections release];
    [super dealloc];
}


@end

