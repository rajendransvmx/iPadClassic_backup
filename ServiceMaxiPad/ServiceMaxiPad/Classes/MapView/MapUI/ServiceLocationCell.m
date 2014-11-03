//
//  ServiceLocationCell.m
//  MapPopUp
//
//  Created by Anoop on 9/8/14.
//  Copyright (c) 2014 ServiceMax. All rights reserved.
//

#import "ServiceLocationCell.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "ServiceLocationModel.h"

@implementation ServiceLocationCell

- (id)debugQuickLookObject
{
    NSAttributedString *cr = [[NSAttributedString alloc] initWithString:@"\n"];
    NSMutableAttributedString *result = [[NSMutableAttributedString alloc] initWithAttributedString:self.titleLabel.attributedText];
    [result appendAttributedString:cr];
    [result appendAttributedString:self.descriptionLabel.attributedText];
    return result;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    [self.contentView layoutIfNeeded];
    self.descriptionLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.descriptionLabel.frame);
}

- (IBAction)getDirectionsButtonTapped:(UIButton *)sender
{
    Class mapItemClass = [MKMapItem class];
    if (mapItemClass && [mapItemClass respondsToSelector:@selector(openMapsWithItems:launchOptions:)])
    {
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.serviceLocationModel.latLonCoordinates
                                                       addressDictionary:nil];
        MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
        [mapItem setName:self.serviceLocationModel.serviceLocation];

        NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
        MKMapItem *currentLocationMapItem = [MKMapItem mapItemForCurrentLocation];
        [MKMapItem openMapsWithItems:@[currentLocationMapItem, mapItem]
                       launchOptions:launchOptions];
    }

}


- (void)configureCellWithTitle:(NSString*)titleString
            andServiceLocation:(ServiceLocationModel*)serviceLocationObj {
    
    [self cleanUp];
    _serviceLocationModel = serviceLocationObj;
    self.titleLabel.text = titleString;
    self.descriptionLabel.text = serviceLocationObj.serviceLocation;

}

- (void)cleanUp {
    
    self.serviceLocationModel = nil;
    self.descriptionLabel.text = nil;
    self.titleLabel.text = nil;
    
}

@end
