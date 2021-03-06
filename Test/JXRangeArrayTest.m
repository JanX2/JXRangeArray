//
//  JXRangeArrayTest.m
//  JXRangeArray
//
//  Created by Jan on 30.10.13.
//  Copyright (c) 2013 Jan Weiß. All rights reserved.
//

#import <XCTest/XCTest.h>

#import "JXRangeArray.h"

#import "JXRangeArray+Privat.h"

const NSRange testRangeArrayOf4[] = {
	{.location = 0, .length = 1},
	{.location = 1, .length = 2},
	{.location = 3, .length = 4},
	{.location = 7, .length = 8}
};

const NSUInteger testRangeArrayOf4Count = sizeof(testRangeArrayOf4)/sizeof(testRangeArrayOf4[0]);


@interface JXRangeArrayTest : XCTestCase

@end

@implementation JXRangeArrayTest

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBasics
{
	JXRangeArray *rangeArray = [[JXRangeArray alloc] initWithCapacity:2];
	
	XCTAssertEqual(rangeArray.count, (NSUInteger)0, @"rangeArray.count should be 0.");
	
	[rangeArray addRange:testRangeArrayOf4[0]];
	
	XCTAssertEqual(rangeArray.count, (NSUInteger)1, @"rangeArray.count should be 1.");
	XCTAssertTrue(NSEqualRanges([rangeArray rangeAtIndex:0], testRangeArrayOf4[0]), @"rangeArray[0] should be the same as initialRange.");
	XCTAssertEqual(rangeArray.capacity, (NSUInteger)2, @"rangeArray.capacity should be 2.");
	
	// Trigger reallocation.
	[rangeArray addRange:testRangeArrayOf4[1]];
	[rangeArray addRange:testRangeArrayOf4[2]];
	
	XCTAssertEqual(rangeArray.count, (NSUInteger)3, @"rangeArray.count should be 3.");
	XCTAssertEqual(rangeArray.capacity, (NSUInteger)4, @"rangeArray.capacity should be 4.");
	
	XCTAssertTrue(NSEqualRanges([rangeArray rangeAtIndex:0], testRangeArrayOf4[0]), @"rangeArray[0] should be the same as testRangeArrayOf4[0].");
	XCTAssertTrue(NSEqualRanges([rangeArray rangeAtIndex:1], testRangeArrayOf4[1]), @"rangeArray[1] should be the same as testRangeArrayOf4[1].");
	XCTAssertTrue(NSEqualRanges([rangeArray rangeAtIndex:2], testRangeArrayOf4[2]), @"rangeArray[2] should be the same as testRangeArrayOf4[2].");

	[rangeArray addRange:testRangeArrayOf4[3]];
	
	XCTAssertEqual(rangeArray.count, (NSUInteger)4, @"rangeArray.count should be 4.");
	XCTAssertTrue(NSEqualRanges([rangeArray rangeAtIndex:3], testRangeArrayOf4[3]), @"rangeArray[3] should be the same as testRangeArrayOf4[3].");
	XCTAssertEqual(rangeArray.capacity, (NSUInteger)4, @"rangeArray.capacity should be 4.");
}

- (void)testEqualityBasics
{
	JXRangeArray *rangeArray = [JXRangeArray new];
	NSObject *anObject = [NSObject new];

	XCTAssertEqualObjects(rangeArray, rangeArray, @"Two identically range arrays should be equal.");
	
	XCTAssertTrue([rangeArray isEqual:rangeArray], @"Two identically range arrays should be equal."); // The above test appears to filter out the rangeArray == rangeArray case.

	XCTAssertFalse([rangeArray isEqual:anObject], @"A range array should not be equal to an object with a different class.");
}

- (void)testEquality1
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two identically initialized range arrays should be equal.");
	
	// Test reciprocity.
	XCTAssertEqualObjects(rangeArray2, rangeArray1, @"Two identically initialized range arrays should be equal.");
}

- (void)testEquality2
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [JXRangeArray new];
	
	[rangeArray2 addRange:testRangeArrayOf4[0]];
	[rangeArray2 addRange:testRangeArrayOf4[1]];
	[rangeArray2 addRange:testRangeArrayOf4[2]];
	[rangeArray2 addRange:testRangeArrayOf4[3]];
	
	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two range arrays with the same data should be equal.");
	
	// Test reciprocity.
	XCTAssertEqualObjects(rangeArray2, rangeArray1, @"Two range arrays with the same data should be equal.");
}

- (void)testEquality3
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [rangeArray1 copy];
	[rangeArray2 removeLastRange];
	
	XCTAssertFalse([rangeArray1 isEqual:rangeArray2], @"A range array should not be equal to another with a different clas.");
}

- (void)testHash
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [rangeArray1 copy];
	
	XCTAssertTrue([rangeArray1 hash] == [rangeArray2 hash], @"Two range arrays with the same data should have the same hash.");
	
	[rangeArray2 removeLastRange];
	
	XCTAssertFalse([rangeArray1 hash] == [rangeArray2 hash], @"Two range arrays with different data should have different hashes.");
}

- (void)testInsertRange
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [JXRangeArray new];
	
	[rangeArray2 addRange:testRangeArrayOf4[0]];
	[rangeArray2 addRange:testRangeArrayOf4[2]];
	[rangeArray2 addRange:testRangeArrayOf4[3]];
	
	[rangeArray2 insertRange:testRangeArrayOf4[1] atIndex:1];
	
	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two range arrays should be equal after parity is achieved.");
	
	// Test reciprocity.
	XCTAssertEqualObjects(rangeArray2, rangeArray1, @"Two range arrays should be equal after parity is achieved.");
	
	// Trigger reallocation.
	[rangeArray1 insertRange:testRangeArrayOf4[1] atIndex:1];
	[rangeArray2 insertRange:testRangeArrayOf4[1] atIndex:1];

	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two range arrays should be equal after parity is achieved.");

	// Test falling back to “-addRange:”.
	[rangeArray1 insertRange:testRangeArrayOf4[3] atIndex:testRangeArrayOf4Count];
	[rangeArray2 insertRange:testRangeArrayOf4[3] atIndex:testRangeArrayOf4Count];

	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two range arrays should be equal after parity is achieved.");
}

- (void)testRemoveLastRange
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [JXRangeArray new];
	
	[rangeArray2 addRange:testRangeArrayOf4[0]];
	[rangeArray2 addRange:testRangeArrayOf4[1]];
	[rangeArray2 addRange:testRangeArrayOf4[2]];
	
	[rangeArray1 removeLastRange];
	
	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two range arrays should be equal after parity is achieved via removeLastRange.");
}

- (void)testRemoveRangeAtIndex
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [JXRangeArray new];
	
	[rangeArray2 addRange:testRangeArrayOf4[0]];
	[rangeArray2 addRange:testRangeArrayOf4[2]];
	[rangeArray2 addRange:testRangeArrayOf4[3]];
	
	[rangeArray1 removeRangeAtIndex:1];

	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two range arrays should be equal after parity is achieved via removeRangeAtIndex.");
}

- (void)testRemoveLastRangeViaIndex
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [JXRangeArray new];
	
	[rangeArray2 addRange:testRangeArrayOf4[0]];
	[rangeArray2 addRange:testRangeArrayOf4[1]];
	[rangeArray2 addRange:testRangeArrayOf4[2]];
	
	[rangeArray1 removeRangeAtIndex:3];
	
	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two range arrays should be equal after parity is achieved via removeRangeAtIndex.");
}

- (void)testReplaceRangeAtIndex
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [JXRangeArray new];
	
	[rangeArray2 addRange:testRangeArrayOf4[0]];
	[rangeArray2 addRange:testRangeArrayOf4[2]];
	[rangeArray2 addRange:testRangeArrayOf4[2]];
	[rangeArray2 addRange:testRangeArrayOf4[3]];
	
	XCTAssertFalse([rangeArray1 isEqual:rangeArray2], @"A range array should not be equal to an object with differing entries.");
	
	[rangeArray2 replaceRangeAtIndex:1 withRange:testRangeArrayOf4[1]];

	XCTAssertEqualObjects(rangeArray1, rangeArray2, @"Two range arrays should be equal after parity is achieved via replaceRangeAtIndex:withRange:.");
}

- (void)testRemoveAllRanges
{
	JXRangeArray *rangeArray = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															  count:testRangeArrayOf4Count];
	
	[rangeArray removeAllRanges];
	XCTAssertEqual(rangeArray.count, (NSUInteger)0, @"rangeArray.count should be 0.");
}

- (void)testRangesInternalPointer
{
	JXRangeArray *rangeArray1 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	JXRangeArray *rangeArray2 = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	

	XCTAssertEqual(rangeArray1.count, rangeArray2.count, @"Counts should be identical.");

	NSRange *rangeArray1Ranges = rangeArray1.ranges;
	NSRange *rangeArray2Ranges = rangeArray2.ranges;
	
	for (NSUInteger i = 0; i < rangeArray1.count; i++) {
		NSRange thisRange = rangeArray1Ranges[i];
		NSRange otherRange = rangeArray2Ranges[i];
		
		XCTAssertTrue(NSEqualRanges(thisRange, otherRange), @"Internal ranges should be identical.");
	}
}

- (void)testEnumerateRangesUsingBlock
{
	JXRangeArray *rangeArray = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															   count:testRangeArrayOf4Count];
	
	__block NSUInteger iterationCounter = 0;
	
	[rangeArray enumerateRangesUsingBlock:^(NSRange range, NSUInteger idx, BOOL *stop) {
		if (idx == 2) {
			*stop = YES;
		}
		XCTAssertTrue(NSEqualRanges([rangeArray rangeAtIndex:idx], testRangeArrayOf4[idx]), @"rangeArray[%1$lu] should be the same as testRangeArrayOf4[%1$lu].", (unsigned long)idx);
		
		iterationCounter++;
	}];
	
	XCTAssertEqual(iterationCounter, (NSUInteger)3, @"iterationCounter should be 3.");
}

- (void)testEnumerateEmptyRangesUsingBlock
{
	JXRangeArray *rangeArray = [[JXRangeArray alloc] init];
	
	__block NSUInteger iterationCounter = 0;
	
	[rangeArray enumerateRangesUsingBlock:^(NSRange range, NSUInteger idx, BOOL *stop) {
		iterationCounter++;
	}];
	
	XCTAssertEqual(iterationCounter, (NSUInteger)0, @"iterationCounter should be 0.");
}

- (void)testReverseEnumerateRangesUsingBlock
{
	JXRangeArray *rangeArray = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															  count:testRangeArrayOf4Count];
	
	__block NSUInteger iterationCounter = 0;
	
	[rangeArray enumerateRangesWithOptions:NSEnumerationReverse
								usingBlock:^(NSRange range, NSUInteger idx, BOOL *stop) {
		if (idx == 2) {
			*stop = YES;
		}
		XCTAssertTrue(NSEqualRanges([rangeArray rangeAtIndex:idx], testRangeArrayOf4[idx]), @"rangeArray[%1$lu] should be the same as testRangeArrayOf4[%1$lu].", (unsigned long)idx);
		
		iterationCounter++;
	}];
	
	XCTAssertEqual(iterationCounter, (NSUInteger)2, @"iterationCounter should be 2.");
}

- (void)testReverseEnumerateEmptyRangesUsingBlock
{
	JXRangeArray *rangeArray = [[JXRangeArray alloc] init];
	
	__block NSUInteger iterationCounter = 0;
	
	[rangeArray enumerateRangesWithOptions:NSEnumerationReverse
								usingBlock:^(NSRange range, NSUInteger idx, BOOL *stop) {
									iterationCounter++;
								}];
	
	XCTAssertEqual(iterationCounter, (NSUInteger)0, @"iterationCounter should be 0.");
}

- (void)testRangeContainingIndex
{
	JXRangeArray *rangeArray = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															  count:testRangeArrayOf4Count];
	
	NSUInteger lastTestRangeIndex = testRangeArrayOf4Count - 1;
	
	for (NSUInteger rangeIdx = 0; rangeIdx < testRangeArrayOf4Count; rangeIdx++) {
		NSRange expectedRange = testRangeArrayOf4[rangeIdx];
		
		for (NSUInteger idx = expectedRange.location; idx < NSMaxRange(expectedRange); idx++) {
			NSUInteger matchIndex;

			NSRange rangeContaining = [rangeArray rangeContainingIndex:idx foundArrayIndex:&matchIndex];
			
			BOOL rangesAreEqual = NSEqualRanges(rangeContaining, expectedRange);
			XCTAssertTrue(rangesAreEqual, @"Range containing %lu should be %@.", (unsigned long)idx, NSStringFromRange(expectedRange));
			
			XCTAssertEqual(matchIndex, rangeIdx, @"The index of the containing range and the matching range need to be identical.");
		}
		
		if (rangeIdx == lastTestRangeIndex) {
			NSRange notFoundRange = NSMakeRange(NSNotFound, 0);
			
			NSUInteger idx = NSMaxRange(expectedRange);
			NSRange rangeContaining = [rangeArray rangeContainingIndex:idx];
			
			BOOL rangesAreEqual = NSEqualRanges(rangeContaining, notFoundRange);
			XCTAssertTrue(rangesAreEqual, @"There should be no range containing %lu.", (unsigned long)idx);
			
			NSUInteger matchIndex = [rangeArray arrayIndexForRangeContainingIndex:idx];
			XCTAssertEqual(matchIndex, NSNotFound, @"There should be no range for an index (%lu) not covered by the ranges in the array.", (unsigned long)idx);
		}
	}
}

- (void)testNSCopyingSupport
{
	JXRangeArray *original = [[JXRangeArray alloc] initWithRanges:(NSRange *)&testRangeArrayOf4
															count:testRangeArrayOf4Count];
	
	JXRangeArray *copy = [original copy];
	
	XCTAssertEqualObjects(original, copy, @"A copy of a range array should be identically to the original.");
}

@end
