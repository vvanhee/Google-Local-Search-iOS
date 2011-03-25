//
//  GoogleLocalConnection.m
//
//  Created by Victor C Van Hee on 1/24/11.
//  Copyright 2011 Victor C. Van Hee.
//
//  Licensed under the Apache License, Version 2.0 (the "License"); you may not
//  use this file except in compliance with the License.  You may obtain a copy
//  of the License at
// 
//  http://www.apache.org/licenses/LICENSE-2.0
// 
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
//  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
//  License for the specific language governing permissions and limitations under
//  the License.
//
//  If you use this code, I ask that you attribute me (Victor C. Van Hee). 
//  Also, I'd appreciate it if you would provide a link / trackback to my 
//  blog post about this code (if you have a website or blog):
//  http://www.totagogo.com/2011/02/08/google-local-search-ios-code/

#import "GoogleLocalConnection.h"
#import "GTMNSString+URLArguments.h"

@implementation GoogleLocalConnection

@synthesize delegate, responseData, connection, connectionIsActive, minAccuracyValue;

- (id)initWithDelegate:(id <GoogleLocalConnectionDelegate>)del
{
	self = [super init];
	
	if (!self)
		return nil;
	[self setDelegate:del];	
	return self;
}

- (id) init
{
	NSLog(@"need a delegate!! use initWithDelegate!");
	return nil;
}


-(void)getGoogleObjectsWithQuery:(NSString *)query andMapRegion:(MKCoordinateRegion)region andNumberOfResults:(int)numResults addressesOnly:(BOOL)addressOnly andReferer:(NSString *)referer;
{
	if (addressOnly == YES) {
		minAccuracyValue = 8;
	}
	else {
		minAccuracyValue = 0;
	}
	if (numResults > 4) {
		numResults = 4;
	}
	double centerLat = region.center.latitude;
	double centerLng = region.center.longitude;
	query = [query gtm_stringByEscapingForURLArgument];
	NSString *numberOfResults = [NSString stringWithFormat:@"%d",numResults];
	double spanLat = region.span.latitudeDelta;
	double spanLng = region.span.longitudeDelta;
	NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/local?v=1.0&mrt=localonly&q=%@&rsz=%@&start=0&sll=%f,%f&sspn=%f,%f",query,numberOfResults,centerLat,centerLng,spanLat,spanLng]];
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
	[request setValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"];
	[request setValue:referer forHTTPHeaderField:@"Referer"];

	[self cancelGetGoogleObjects];
	
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self startImmediately:YES];
	if (connection) {
		responseData = [[NSMutableData data] retain];
		connectionIsActive = YES;
	}		
	else {
	  NSLog(@"connection failed");
	}
}


- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response {
	[responseData setLength:0];
}


- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data {
	[responseData appendData:data];
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error {
	connectionIsActive = NO;
	[delegate googleLocalConnection:self didFailWithError:error];
	[conn release];
	[responseData release];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn 
{
	NSLog(@"did finish loading GoogleLocalConnection");

	connectionIsActive = NO;
	NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];	
	NSError *jsonError = nil;
	SBJsonParser *json = [[SBJsonParser new] autorelease];

	NSDictionary *parsedJSON = [json objectWithString:responseString error:&jsonError];
	if ([jsonError code]==0) {
			NSString *responseStatus = [NSString stringWithFormat:@"%@",[parsedJSON objectForKey:@"responseStatus"]];
			if ([responseStatus isEqualToString:@"200"]) {
				NSDictionary *gResponseData = [NSDictionary dictionaryWithDictionary:[parsedJSON objectForKey:@"responseData"]];				
				
				NSMutableArray *googleLocalObjects = [NSMutableArray arrayWithCapacity:[[gResponseData objectForKey:@"results"] count]]; 
				for (int x=0; x<[[gResponseData objectForKey:@"results"] count]; x++) {
					if ([[[[gResponseData objectForKey:@"results"] objectAtIndex:x] objectForKey:@"accuracy"] intValue] >= minAccuracyValue)
					{
					[googleLocalObjects addObject:(NSDictionary *)[[gResponseData objectForKey:@"results"] objectAtIndex:x]];
					}
				}
				for (int x=0; x<[googleLocalObjects count]; x++) {
					
					GoogleLocalObject *object = [[[GoogleLocalObject alloc] initWithJsonResultDict:[googleLocalObjects objectAtIndex:x]] autorelease];
					[googleLocalObjects replaceObjectAtIndex:x withObject:object];
					[object description];
				}
				NSDictionary *viewPort = [NSDictionary dictionaryWithDictionary:[gResponseData objectForKey:@"viewport"]];
				[delegate googleLocalConnection:self didFinishLoadingWithGoogleLocalObjects:googleLocalObjects andViewPort:[self getViewPortForGoogleSearchResults:googleLocalObjects andGoogleViewport:viewPort]];
			}
			else {
				// no results
				NSString *responseDetails = [NSString stringWithFormat:@"%@",[parsedJSON objectForKey:@"responseDetails"]];
				NSError *responseError = [NSError errorWithDomain:@"GoogleLocalObjectDomain" code:[responseStatus intValue] userInfo:[NSDictionary dictionaryWithObjectsAndKeys:responseDetails,@"NSLocalizedDescriptionKey",nil]];
				[delegate googleLocalConnection:self didFailWithError:responseError];
			}
	}
	else {
		
		[delegate googleLocalConnection:self didFailWithError:jsonError];
	}
	
	[responseString release];	
	[responseData release];	
	[conn release];	
}

-(MKCoordinateRegion)getViewPortForGoogleSearchResults:(NSMutableArray *)googleLocalObjectArray andGoogleViewport:(NSDictionary *)viewPort
{
	if ([googleLocalObjectArray count] == 0) { // shouldn't actually need this because 0 results will give an error
		return MKCoordinateRegionMake(CLLocationCoordinate2DMake(0.0, 0.0), MKCoordinateSpanMake(0.1, 0.1));
	}	
	if ([googleLocalObjectArray count] == 1) {
		MKCoordinateRegion searchViewPortRegion;
		
		if (minAccuracyValue == 8) {  // single address search
			GoogleLocalObject *obj = (GoogleLocalObject *)[googleLocalObjectArray objectAtIndex:0];
			searchViewPortRegion = MKCoordinateRegionMakeWithDistance([obj coordinate], 750, 750);
		}
		else { //could be a region search
			CLLocationCoordinate2D center = CLLocationCoordinate2DMake([[[viewPort objectForKey:@"center"] objectForKey:@"lat"] doubleValue], [[[viewPort objectForKey:@"center"] objectForKey:@"lng"] doubleValue]);
			NSString *viewPortSWLat = [[viewPort objectForKey:@"sw"] objectForKey:@"lat"];
			NSString *viewPortSWLng = [[viewPort objectForKey:@"sw"] objectForKey:@"lng"];
			NSString *viewPortNELat = [[viewPort objectForKey:@"ne"] objectForKey:@"lat"];
			NSString *viewPortNELng = [[viewPort objectForKey:@"ne"] objectForKey:@"lng"];
			searchViewPortRegion = [self makeRegionFromViewportCornersAndCenter:center NELat:viewPortNELat NELng:viewPortNELng SWLat:viewPortSWLat SWLng:viewPortSWLng];	
		}
		return searchViewPortRegion;					
	}
	
    // count >1 -- make a viewport region that includes all locations found
    CLLocationCoordinate2D topLeftCoord;
    topLeftCoord.latitude = -90;
    topLeftCoord.longitude = 180;
    
    CLLocationCoordinate2D bottomRightCoord;
    bottomRightCoord.latitude = 90;
    bottomRightCoord.longitude = -180;
    
    for(GoogleLocalObject *obj in googleLocalObjectArray)
    {
        topLeftCoord.longitude = fmin(topLeftCoord.longitude, obj.coordinate.longitude);
        topLeftCoord.latitude = fmax(topLeftCoord.latitude, obj.coordinate.latitude);
        
        bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, obj.coordinate.longitude);
        bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, obj.coordinate.latitude);
    }
    
    MKCoordinateRegion region;
    region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
    region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
    region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.2; // Add a little extra space on the sides
    region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.2; // Add a little extra space on the sides
	return region;
	
}

-(MKCoordinateRegion)makeRegionFromViewportCornersAndCenter:(CLLocationCoordinate2D)center NELat:(NSString *)NELat NELng:(NSString *)NELng SWLat:(NSString *)SWLat SWLng:(NSString *)SWLng
{
	double latDelta = [NELat doubleValue] - [SWLat doubleValue];
	double lonDelta = [NELng doubleValue] - [SWLng doubleValue];
	MKCoordinateSpan span = MKCoordinateSpanMake(latDelta, lonDelta);
	return MKCoordinateRegionMake(center,span);
	
}



- (void)cancelGetGoogleObjects {
	if (connectionIsActive == YES) {
		connectionIsActive = NO;
		[connection cancel];
		[responseData release];
		[connection release];
	}
}


- (void)dealloc 
{
    [self cancelGetGoogleObjects];
    [super dealloc];
}





@end
