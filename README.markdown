# Google-Local-Search-iOS

Some iOS (Objective-C) classes for implementing Google's Local Search API JSON interface ([http://code.google.com/apis/maps/documentation/localsearch/jsondevguide.html][GoogleLocalSearchAPI]), particularly for use in iPhone / iPad apps.

## Usage

#### Dependencies

This code depends on stig's JSON Framework for Objective C:
[https://github.com/stig/json-framework][JSONFramework]

#### GoogleClientLogin class

Here's some sample code showing how to use the classes:

setup:

    GoogleLocalConnection *googleLocalConnection = [[GoogleLocalConnection alloc] initWithDelegate:self]; 

< get user input, perhaps from a text field (textField.text) which you'll need to set up.  Also will need to set up an MKMapView (here called mapView) to get the region for region biasing of the search ... >

    [googleLocalConnection getGoogleObjectsWithQuery:textField.text andMapRegion:[mapView region] andNumberOfResults:8 addressesOnly:YES];

< time passes and one of the delegate methods will be called ... >

delegate methods:

    - (void) googleLocalConnection:(GoogleLocalConnection *)conn didFinishLoadingWithGoogleLocalObjects:(NSMutableArray *)objects andViewPort:(MKCoordinateRegion)region
    {
        if ([objects count] == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No matches found near this location" message:@"Try another place name or address (or move the map and try again)" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [alert release];
        }
        else {
            [mapView removeAllAnnotations];
            [mapView addAnnotations:objects];
            [mapView setRegion:region];
        }
    }

    - (void) googleLocalConnection:(GoogleLocalConnection *)conn didFailWithError:(NSError *)error
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error finding place - Try again" message:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [alert release];
    }


 [GoogleLocalSearchAPI]: http://code.google.com/apis/maps/documentation/localsearch/jsondevguide.html
 [JSONFramework]: https://github.com/stig/json-framework
