//
//  WholeMapView.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 01/08/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import "WholeMapView.h"
#import "AnnotationCreator.h"
#import "CSMapRouteLayerView.h"

@interface WholeMapView (Internal)
- (void)showLoadingIndicators;
- (void)hideLoadingIndicators;

- (void)beginLoadingItemList;
- (void)synchronousItemList;
- (void)didFinishLoadingItemListWithResults;

-(void)parseMapListXMLFileData:(NSData *)XMLData;
@end

@implementation WholeMapView
@synthesize mapDataURL, viewTitle;

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    mapView = [[[MKMapView alloc] initWithFrame:self.view.bounds] autorelease];
    mapView.mapType = MKMapTypeStandard;
    mapView.showsUserLocation = YES;
    mapView.delegate = self;
    [self.view addSubview:mapView];
    self.title = viewTitle;
    
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
    
    UIBarButtonItem *followLocation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(zoomToLocation)];
    NSArray *buttons = [NSArray arrayWithObject:followLocation];
    [mapTools setItems:buttons];
    
    
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
    CGRect segContrRectArea = CGRectMake(70, (parentViewHeight - segmentedControllerHeight)/2, [swapMapTypeControl frame].size.width, segmentedControllerHeight);
    
    [swapMapTypeControl setFrame:segContrRectArea];
    [mapTools addSubview:swapMapTypeControl];
    [swapMapTypeControl release];
    [mapTools release];
    
    
    operationQueue = [[NSOperationQueue alloc] init];
    [operationQueue setMaxConcurrentOperationCount:1];
    [self showLoadingIndicators];
    [self beginLoadingItemList];    
}

-(void)swapMapType {
    if (mapView.mapType == MKMapTypeHybrid) {
        mapView.mapType = MKMapTypeStandard;
    } else {
        mapView.mapType = MKMapTypeHybrid;
    }
}

-(void)zoomToLocation {
    UIBarButtonItem *followLocation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"] style:UIBarButtonItemStyleDone target:self action:@selector(stopUpdating)];
    NSArray *buttons = [NSArray arrayWithObject:followLocation];
    [mapTools setItems:buttons];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    
    
}

-(void)stopUpdating {
    UIBarButtonItem *followLocation = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"] style:UIBarButtonItemStyleBordered target:self action:@selector(zoomToLocation)];
    NSArray *buttons = [NSArray arrayWithObject:followLocation];
    [mapTools setItems:buttons];
    
    [locationManager stopUpdatingLocation];
    
}

- (void)locationManager:(CLLocationManager*)manager didUpdateToLocation:(CLLocation*)newLocation fromLocation:(CLLocation*)oldLocation {    
    CLLocationDegrees lat = newLocation.coordinate.latitude;
    CLLocationDegrees lon = newLocation.coordinate.longitude;
    
    MKCoordinateRegion region;
    
    region.center.latitude     = lat;
    region.center.longitude    = lon;
    region.span.latitudeDelta  = 0.007;
    region.span.longitudeDelta = 0.007;

    [mapView setRegion:region animated:YES];
}

- (void)locationManager: (CLLocationManager *)manager didFailWithError: (NSError *)error {
    NSLog(@"%@",error);
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
    //mapTools = nil;
}

- (void)viewWillDisappear:(BOOL)animated {
    [mapTools removeFromSuperview];
    //mapTools.hidden = YES;
}



- (void)dealloc {
    [mapDataURL release];
    [title release];
    [operationQueue release];
    [spinner release];
    [loadingLabel release];
    [mapItems release];
    [currentItem release];
    [itemName release];
    [itemCoordinates release];
    [mapView release];
    [currentElement release];
    //[mapTools release];
    [routeView release];
    [super dealloc];
}


-(void)showLoadingIndicators{
    if (!spinner) {
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        
        loadingLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        loadingLabel.font = [UIFont systemFontOfSize:20];
        loadingLabel.textColor = [UIColor grayColor];
        loadingLabel.text = @"Loading Map...";
        [loadingLabel sizeToFit];
        
        static CGFloat bufferWidth = 8.0;
        
        CGFloat totalWidth = spinner.frame.size.width + bufferWidth + loadingLabel.frame.size.width;
        
        CGRect spinnerFrame = spinner.frame;
        spinnerFrame.origin.x = (self.view.bounds.size.width - totalWidth) / 2.0;
        spinnerFrame.origin.y = (self.view.bounds.size.height - spinnerFrame.size.height) / 2.0;
        spinner.frame = spinnerFrame;
        [self.view addSubview:spinner];
        
        CGRect labelFrame = loadingLabel.frame;
        labelFrame.origin.x = (self.view.bounds.size.width - totalWidth) / 2.0 + spinnerFrame.size.width + bufferWidth;
        labelFrame.origin.y = (self.view.bounds.size.height - labelFrame.size.height) / 2.0;
        loadingLabel.frame = labelFrame;
        [self.view addSubview:loadingLabel];
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void)hideLoadingIndicators
{
    if (spinner) {
        [spinner stopAnimating];
        [spinner removeFromSuperview];
        [spinner release];
        spinner = nil;
        
        [loadingLabel removeFromSuperview];
        [loadingLabel release];
        loadingLabel = nil;
        
        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    }
}

-(void)beginLoadingItemList {
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(synchronousMapItem) object:nil];
    [operationQueue addOperation:operation];
    [operation release];
}

-(void)synchronousMapItem {
    NSString *authToken = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"token"]];
    NSString *userName = [NSString stringWithString:[[NSUserDefaults standardUserDefaults] valueForKey:@"user_preference"]];
    if (authToken == nil) {
        mapItems = nil;
        UIAlertView *noLoginInfo = [[UIAlertView alloc] initWithTitle:@"No Login Information"message:@"You have not set up an account. Please go to the Settings App and enter your Google Account login"delegate:self cancelButtonTitle:@"OK"otherButtonTitles:nil];
        [noLoginInfo show];
        [noLoginInfo release];
        [self hideLoadingIndicators];
    } else if (userName == nil) {
        UIAlertView *noUser = [[UIAlertView alloc] initWithTitle:@"No Username" message:@"You have not entered a username" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [noUser show];
        [noUser release];
        [self hideLoadingIndicators];
    } else {
        NSMutableURLRequest *mapListRequest = [NSMutableURLRequest requestWithURL:mapDataURL];
        [mapListRequest setValue:[NSString stringWithFormat:@"GoogleLogin auth=%@",authToken] forHTTPHeaderField:@"Authorization"];
        NSData *responseData;
        NSURLResponse *response;
        NSError *error;
        responseData = [NSURLConnection sendSynchronousRequest:mapListRequest returningResponse:&response error:&error];
        //NSString *dataAsString = [[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding];
        //NSLog(dataAsString);
        mapItems = [[NSMutableArray alloc] init];
        //NSString *textResponse = [[[NSString alloc] initWithData:responseData encoding:NSASCIIStringEncoding] autorelease];
        //NSLog(textResponse);
        NSData *invalid = [@"Invalid id format" dataUsingEncoding:NSASCIIStringEncoding];
        if (responseData == invalid) {
            UIAlertView *invalidUserName = [[UIAlertView alloc] initWithTitle:@"Invalid User Name" message:@"You have entered an invalid User Name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [invalidUserName show];
            [invalidUserName release];
            [self hideLoadingIndicators];
        } else {
            [self parseMapListXMLFileData:responseData];
            [self hideLoadingIndicators];
            [self performSelectorOnMainThread:@selector(didFinishLoadingItemListWithResults) withObject:nil waitUntilDone:NO];
            //NSLog(@"%@",mapsList);
        }
    }
}

-(void)didFinishLoadingItemListWithResults {
    mapAnnotations = [[NSMutableArray alloc] init];
    mapPolyLines = [[NSMutableArray alloc] init];

    CLLocationDegrees maxLat = -90;
    CLLocationDegrees maxLon = -180;
    CLLocationDegrees minLat = 90;
    CLLocationDegrees minLon = 180;
    
    for (NSDictionary *feature in mapItems) {
        NSAutoreleasePool *tempPool = [[NSAutoreleasePool alloc] init];
        NSMutableArray *tempFeatureStore = [[[NSMutableArray alloc] init] autorelease];
        NSArray *featureCoords = [[feature objectForKey:@"itemCoordiantes"] objectAtIndex:0];
        if ([featureCoords count] == 1) {
            NSString *coords = [featureCoords objectAtIndex:0];
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
            
            NSString *featureTitle = [feature objectForKey:@"itemName"];
            AnnotationCreator *itemAnnotation = [AnnotationCreator annotationWithCoordinate:featureLocation Title:featureTitle Subtitle:nil];
            [mapAnnotations addObject:itemAnnotation];
        } else {
            //NSLog(@"%@",featureCoords);
            for (NSString *point in featureCoords) {
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
                    [tempFeatureStore addObject:currentLocation];
                }
                [coordPool release];
            }
        }
        //CSMapRouteLayerView *routeView = [[CSMapRouteLayerView alloc] initWithRoute:tempFeatureStore mapView:mapView];
        [mapPolyLines addObject:tempFeatureStore];
        //[routeView release];
        
        //[mapPolyLines addObject:tempFeatureStore];
        [tempPool release];
    }
    MKCoordinateRegion region;
    region.center.latitude     = (maxLat + minLat) / 2;
    region.center.longitude    = (maxLon + minLon) / 2;
    region.span.latitudeDelta  = maxLat - minLat + 0.005;
    region.span.longitudeDelta = maxLon - minLon + 0.005;
    
    [mapView setRegion:region animated:YES];
    
    
    routeView = [[CSMapRouteLayerView alloc] initWithRoute:mapPolyLines mapView:mapView];
    [self.view addSubview:routeView];
    [mapView addAnnotations:mapAnnotations];
    [mapAnnotations release];
    for (NSArray *feature in mapPolyLines) {
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


-(void) parseMapListXMLFileData:(NSData *)XMLData {
    NSXMLParser *parseMapList = [[[NSXMLParser alloc] initWithData:XMLData] autorelease]; 
    [parseMapList setDelegate:self];
    [parseMapList setShouldProcessNamespaces:NO];
    [parseMapList setShouldReportNamespacePrefixes:NO];
    [parseMapList setShouldResolveExternalEntities:NO];
    [parseMapList parse];
}


- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    currentElement = [elementName copy];
    //NSDictionary *currentElementAttributeDict = [[[NSDictionary alloc] initWithDictionary:attributeDict] autorelease];
    if ([elementName isEqualToString:@"Placemark"]) {
        currentItem = [[NSMutableDictionary alloc] init];        
        itemName = [[NSMutableString alloc] init];
        itemCoordinates = [[NSMutableArray alloc] init];
    }
    
}
- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string{
    if ([currentElement isEqualToString:@"name"]){
        [itemName appendString:string];
    } else if ([currentElement isEqualToString:@"coordinates"]) {
        //[itemCoordinates appendString:[string stringByReplacingOccurrencesOfString:@" " withString:@","]];
        [itemCoordinates addObject:[string componentsSeparatedByString:@" "]];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    
    if ([elementName isEqualToString:@"Placemark"]){
        [currentItem setObject:itemName forKey:@"itemName"];
        [currentItem setObject:itemCoordinates forKey:@"itemCoordiantes"];
        
        [mapItems addObject:currentItem];
    }
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

@end
