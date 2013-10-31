//
//  main.m
//  JXRangeArray
//
//  Created by Jan on 31.10.13.
//  Copyright (c) 2013 Jan Weiß. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "JXRangeArray.h"

int main(int argc, const char * argv[])
{

	@autoreleasepool {
	    
		JXRangeArray *rangeArray = [JXRangeArray new];
	    
		NSRange range = NSMakeRange(0, 1);
		[rangeArray addRange:range];
		
		NSRange range2 = [rangeArray rangeAtIndex:0];
		NSLog(@"%@", NSStringFromRange(range2));

	}
    return 0;
}

