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
#import <AddressBook/ABPerson.h>
#import "StringUtil.h"

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
        NSDictionary *addressDict = @{
                                      (NSString *) kABPersonAddressStreetKey : ![StringUtil isStringEmpty:self.serviceLocationModel.street] ? self.serviceLocationModel.street : @"",
                                      (NSString *) kABPersonAddressCityKey : ![StringUtil isStringEmpty:self.serviceLocationModel.city] ? self.serviceLocationModel.city : @"",
                                      (NSString *) kABPersonAddressStateKey : ![StringUtil isStringEmpty:self.serviceLocationModel.state] ? self.serviceLocationModel.state : @"",
                                      (NSString *) kABPersonAddressZIPKey : ![StringUtil isStringEmpty:self.serviceLocationModel.zip] ? self.serviceLocationModel.zip : @"",
                                      (NSString *) kABPersonAddressCountryKey : ![StringUtil isStringEmpty:self.serviceLocationModel.country] ? self.serviceLocationModel.country : @"",
                                      };
        MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:self.serviceLocationModel.latLonCoordinates
                                                       addressDictionary:addressDict];
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
