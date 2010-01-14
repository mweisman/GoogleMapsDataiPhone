//
//  AnnotationCreator.m
//  gMapsDataiPhone
//
//  Created by Michael Weisman on 01/08/09.
//  Copyright 2009 Michael Weisman. All rights reserved.
//

#import "AnnotationCreator.h"


@implementation AnnotationCreator
@synthesize coordinate;
@synthesize title;
@synthesize subtitle;

+(id)annotationWithCoordinate:(CLLocationCoordinate2D)annotationCoordinate Title:(NSString *)annotationTitle Subtitle:(NSString *)annotationSubtitle {
    return [[[[self class] alloc] initWithCoordinate:annotationCoordinate Title:annotationTitle Subtitle:annotationSubtitle] autorelease];
}

-(id)initWithCoordinate:(CLLocationCoordinate2D)annotationCoordinate Title:(NSString *)annotationTitle Subtitle:(NSString *)annotationSubtitle {
    self = [super init];
    if (nil != self) {
        self.coordinate = annotationCoordinate;
        self.title = annotationTitle;
        self.subtitle = annotationSubtitle;
    }
    return self;
}

-(void)dealloc{
    [title release];
    [subtitle release];
    [super dealloc];
}

@end
