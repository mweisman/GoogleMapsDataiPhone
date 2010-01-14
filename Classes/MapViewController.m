//
//  MapViewController.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 27/07/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import "MapViewController.h"
#import "AnnotationCreator.h"
#import "CSMapRouteLayerView.h"
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>


@implementation MapViewController
@synthesize viewTitle, itemInformation, mapView;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    
    mapView = [[[MKMapView alloc] initWithFrame:self.view.bounds] autorelease];
    mapView.mapType = MKMapTypeStandard;
    mapView.showsUserLocation = YES;
    
    mapTools = [[UIToolbar alloc] init];
    [mapTools sizeToFit];

    
    //Caclulate the height of the toolbar
    CGFloat toolbarHeight = [mapTools frame].size.height;
    
    //Get the bounds of the parent view
    CGRect rootViewBounds = self.navigationController.view.bounds;
    
    //Get the height of the parent view.
    CGFloat rootViewHeight = CGRectGetHeight(rootViewBounds);
    
    //Get the width of the parent view,
    CGFloat rootViewWidth = CGRectGetWidth(rootViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect rectArea = CGRectMake(0, rootViewHeight - toolbarHeight, rootViewWidth, toolbarHeight);
    
    [mapTools setFrame:rectArea];
    
    
    [self.navigationController.view addSubview:mapTools];

    UISegmentedControl *swapMapTypeControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Satellite View",@"Map View",nil]];
    swapMapTypeControl.segmentedControlStyle = UISegmentedControlStyleBar;
    [swapMapTypeControl addTarget:self action:@selector(swapMapType) forControlEvents:UIControlEventValueChanged];
    swapMapTypeControl.selectedSegmentIndex = 0;
    
    CGFloat segmentedControllerHeight = [swapMapTypeControl frame].size.height;
    
    //Get the bounds of the parent view
    CGRect parentViewBounds = mapTools.bounds;
    
    //Get the height of the parent view.
    CGFloat parentViewHeight = CGRectGetHeight(parentViewBounds);
    
    //Create a rectangle for the toolbar
    CGRect segContrRectArea = CGRectMake(10, (parentViewHeight - segmentedControllerHeight)/2, [swapMapTypeControl frame].size.width, segmentedControllerHeight);
    
    [swapMapTypeControl setFrame:segContrRectArea];
    [mapTools addSubview:swapMapTypeControl];
    [swapMapTypeControl release];
    [mapTools release];
    
    
    NSMutableArray *annotations = [[[NSMutableArray alloc] init] autorelease];
    NSArray *tempCoordArray = nil;
    
    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    NSMutableArray *locationArray = [[[NSMutableArray alloc] init] autorelease];
    
    for (NSArray *feature in [self.itemInformation objectForKey:@"itemCoordiantes"]){
        if ([feature count] == 1) {
            NSString *coords = [feature objectAtIndex:0];
            NSArray *coordArray = [coords componentsSeparatedByString:@","];
            CLLocationCoordinate2D featureLocation;
            featureLocation.latitude = [[coordArray objectAtIndex:1] doubleValue];
            featureLocation.longitude = [[coordArray objectAtIndex:0] doubleValue];
            if(featureLocation.latitude > maxLat)
                maxLat = featureLocation.latitude;
            if(featureLocation.latitude < minLat)
                minLat = featureLocation.latitude;
            if(featureLocation.longitude > maxLon)
                maxLon = featureLocation.longitude;
            if(featureLocation.longitude < minLon)
                minLon = featureLocation.longitude;
            
            NSString *featureTitle = [self.itemInformation objectForKey:@"itemName"];
            AnnotationCreator *itemAnnotation = [AnnotationCreator annotationWithCoordinate:featureLocation Title:featureTitle Subtitle:nil];
            //[mapView addAnnotation:itemAnnotation];
            [annotations addObject:itemAnnotation];
            
        } else {
            //NSLog(@"%@",featureCoords);
            for (NSString *point in feature) {
                NSAutoreleasePool *coordPool = [[NSAutoreleasePool alloc] init];
                NSArray *coordArray = [point componentsSeparatedByString:@","];
                if ([coordArray count] != 1) {
                    CLLocationDegrees lon = [[coordArray objectAtIndex:0] doubleValue];
                    CLLocationDegrees lat = [[coordArray objectAtIndex:1] doubleValue];
                    CLLocation *currentLocation = [[[CLLocation alloc] initWithLatitude:lat longitude:lon] autorelease];
                    if(currentLocation.coordinate.latitude > maxLat)
                        maxLat = currentLocation.coordinate.latitude;
                    if(currentLocation.coordinate.latitude < minLat)
                        minLat = currentLocation.coordinate.latitude;
                    if(currentLocation.coordinate.longitude > maxLon)
                        maxLon = currentLocation.coordinate.longitude;
                    if(currentLocation.coordinate.longitude < minLon)
                        minLon = currentLocation.coordinate.longitude;
                    [locationArray addObject:currentLocation];
                    
                }
                tempCoordArray = [[NSArray alloc] initWithObjects:locationArray,nil];
                [coordPool release];
            }
            //routeView = [[[CSMapRouteLayerView alloc] initWithRoute:tempCoordArray mapView:mapView] autorelease];
            }
        //routeView = [[[CSMapRouteLayerView alloc] initWithRoute:tempCoordArray mapView:mapView annotations:annotations] autorelease];
        routeView = [[CSMapRouteLayerView alloc] initWithRoute:tempCoordArray mapView:mapView];
        [tempCoordArray release];
        [self.mapView addSubview:routeView];
        [mapView addAnnotations:annotations];
        [mapView setDelegate:self];
        for (NSArray *feature in tempCoordArray) {
            if (feature.count > 0) {
                CLLocation *startLocation = [feature objectAtIndex:0];
                CLLocation *endLocation = [feature lastObject];
                AnnotationCreator *startAnnotation = [[AnnotationCreator alloc] initWithCoordinate:startLocation.coordinate Title:@"Start" Subtitle:nil];
                AnnotationCreator *endAnnotation = [[AnnotationCreator alloc] initWithCoordinate:endLocation.coordinate Title:@"End" Subtitle:nil];
                [mapView addAnnotation:startAnnotation];
                [mapView addAnnotation:endAnnotation];
                [startAnnotation release];
                [endAnnotation release];
            }
        }
        
    }
    


    MKCoordinateRegion viewRegion;
    viewRegion.center.latitude     = (maxLat + minLat) / 2;
    viewRegion.center.longitude    = (maxLon + minLon) / 2;
    viewRegion.span.latitudeDelta  = maxLat - minLat + 0.005;
    viewRegion.span.longitudeDelta = maxLon - minLon + 0.005;
    [mapView setRegion:viewRegion animated:YES];
    self.title = viewTitle;
    [self.view addSubview:self.mapView];
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
    [routeView release];
    [super dealloc];
}

#pragma mark mapView delegate functions
- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
{
	// turn off the view of the route as the map is chaning regions. This prevents
	// the line from being displayed at an incorrect positoin on the map during the
	// transition. 
	routeView.hidden = YES;
}
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
	// re-enable and re-poosition the route display. 
	routeView.hidden = NO;
	[routeView setNeedsDisplay];
}

- (MKAnnotationView *)mapView:(MKMapView *)theMapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKAnnotationView *view = nil;
    if (annotation != theMapView.userLocation){
        if(view == nil) {
            view = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"point"] autorelease];
        }
        if (annotation.title == @"Start") {
            [(MKPinAnnotationView *)view setPinColor:MKPinAnnotationColorGreen];
            [view setCanShowCallout:YES];
        } else if (annotation.title == @"End") {
            [(MKPinAnnotationView *)view setAnimatesDrop:NO];
            [(MKPinAnnotationView *)view setPinColor:MKPinAnnotationColorRed];
            [view setCanShowCallout:YES];
        } else {
            [(MKPinAnnotationView *)view setAnimatesDrop:YES];
            [(MKPinAnnotationView *)view setPinColor:MKPinAnnotationColorPurple];
            [view setCanShowCallout:YES];
            [view setRightCalloutAccessoryView:[UIButton buttonWithType:UIButtonTypeInfoLight]];
        }
    }
    return view;
}
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    //    CLLocationCoordinate2D locationOfPin = [self.mapView convertPoint:view.annotation.coordinate toCoordinateFromView:mapView];
    //    NSString *locationString = [NSString stringWithFormat:@"%d, %d",locationOfPin.latitude, locationOfPin.longitude];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:view.annotation.title message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}

-(void)swapMapType {
    if (mapView.mapType == MKMapTypeHybrid) {
        mapView.mapType = MKMapTypeStandard;
    } else {
        mapView.mapType = MKMapTypeHybrid;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [mapTools removeFromSuperview];
    //mapTools.hidden = YES;
}

@end
