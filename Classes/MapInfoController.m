//
//  MapInfoController.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 26/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import "MapInfoController.h"
#import "MapItemsController.h"
#import"MapViewController.h"

@implementation MapInfoController
@synthesize mapInformation;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        // Custom initialization
    }
    return self;
}
*/

- (void)viewWillAppear:(BOOL)animated {
    self.title = [NSString stringWithString:[self.mapInformation objectForKey:@"mapTitle"]];
    [self.tableView reloadData];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }    
    // Set up the cell...
    if (indexPath.row == 0) {
        cell.detailTextLabel.text = [NSString stringWithString:[self.mapInformation objectForKey:@"mapTitle"]];
        cell.textLabel.text = @"Map Name";
    } else if (indexPath.row == 1) {
        cell.detailTextLabel.text = [NSString stringWithString:[self.mapInformation objectForKey:@"mapAuthorName"]];
        cell.textLabel.text = @"Author";
    } else if (indexPath.row == 2) {
        NSString *labelString = [self formatDateFromString:[NSString stringWithString:[self.mapInformation objectForKey:@"published"]]];
        cell.detailTextLabel.text = labelString;
        cell.textLabel.text = @"Created";
    } else if (indexPath.row == 3) {
        NSString *labelString = [self formatDateFromString:[NSString stringWithString:[self.mapInformation objectForKey:@"updated"]]];
        cell.detailTextLabel.text = labelString;
        cell.textLabel.text = @"Updated";
    } else {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"viewMap"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        cell.textLabel.text = @"Map Items";
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.userInteractionEnabled = YES;
    }

    
    return cell;
}

-(NSString *)formatDateFromString:(NSString *)dateAsString {
    NSDateFormatter *inputDateFormatter = [[NSDateFormatter alloc] init];
    [inputDateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:SSSSS"];
    NSDate *date = [inputDateFormatter dateFromString:[self.mapInformation objectForKey:@"published"]];
    NSDateFormatter *outputDateFormatter = [[NSDateFormatter alloc] init];
    [outputDateFormatter setDateFormat:@"MMMM dd',' yyyy"];
    NSString *newDate = [outputDateFormatter stringFromDate:date];
    [inputDateFormatter release];
    [outputDateFormatter release];
    return newDate;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 4) {
        MapItemsController *thisMapsItems = [[MapItemsController alloc] init];
        thisMapsItems.title = @"Map Items";
        thisMapsItems.mapIDURL = [NSURL URLWithString:[self.mapInformation objectForKey:@"contentLink"]];
        [self.navigationController pushViewController:thisMapsItems animated:YES];
        [thisMapsItems release];
    }
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [mapInformation release];
    [super dealloc];
}


@end
