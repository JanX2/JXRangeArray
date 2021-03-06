//
//  JXRangeArray.h
//
//  Created by Jan on 30.10.13.
//  Copyright (c) 2006-2007 Christopher J. W. Lloyd
//  Copyright (c) 2013 Jan Weiß. Some rights reserved.
//
//  Based on NSRangeArray from cocotron
//  http://www.cocotron.org
//

/*
 MIT License
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE. 
 */

#import "JXRangeArray.h"

const NSUInteger JXRangeArrayGrowthFactor = 2;

@implementation JXRangeArray

- (instancetype)init
{
	return [self initWithCapacity:16];
}

- (instancetype)initWithCapacity:(NSUInteger)capacity;
{
	self = [super init];
	
	if (self) {
		_count = 0;
		_capacity = capacity;
		_ranges = malloc(sizeof(NSRange) * _capacity);
	}
	
	return self;
}

- (id)initWithRanges:(const NSRange *)ranges count:(NSUInteger)count
{
	// Calculate _capacity by rounding _count to nearest equal or greater power of 2.
	double log2OfCount = log2(count);
	double bestCapacity = exp2(ceil(log2OfCount));
	NSUInteger capacity = (NSUInteger)bestCapacity;
	
	self = [self initWithCapacity:capacity];
	
	if (self) {
		_count = count;
		
		_ranges = malloc(sizeof(NSRange) * _capacity);
		memcpy(_ranges, ranges, sizeof(NSRange) * _count);
	}
	
	return self;
}


- (void)dealloc
{
	if (_ranges != NULL)  free(_ranges);
}

- (NSUInteger)count;
{
	return _count;
}

- (NSRange)rangeAtIndex:(NSUInteger)idx;
{
	NSAssert2(idx < _count, @"index %lu beyond count %lu", (unsigned long)idx, (unsigned long)_count);
    
	return _ranges[idx];
}

NS_INLINE void ensureCapacity(NSUInteger *capacity_p, NSRange **ranges_pp, NSUInteger count) {
	if (count >= *capacity_p) {
		*capacity_p *= JXRangeArrayGrowthFactor;
		*ranges_pp = realloc(*ranges_pp, sizeof(NSRange) * *capacity_p);
	}
}

- (void)addRange:(NSRange)range;
{
	ensureCapacity(&_capacity, &_ranges, _count);
    
	_ranges[_count++] = range;
}

- (void)insertRange:(NSRange)range atIndex:(NSUInteger)idx;
{
	NSAssert2(idx <= _count, @"index %lu beyond count %lu", (unsigned long)idx, (unsigned long)_count);
    
	if (idx == _count) {
		[self addRange:range];
	} else {
		ensureCapacity(&_capacity, &_ranges, _count);
		
		memmove(&(_ranges[idx + 1]), &(_ranges[idx]), sizeof(NSRange) * (_count - idx));
		
		_count++;

		_ranges[idx] = range;
	}
}

- (void)removeRangeAtIndex:(NSUInteger)idx;
{
	NSAssert2(idx < _count, @"index %lu beyond count %lu", (unsigned long)idx, (unsigned long)_count);
    
	_count--;
	
	// This is safe in any case, because we have decremented _count above
	// so we can’t access anything beyond our allocated memory.
	memmove(&(_ranges[idx]), &(_ranges[idx + 1]), sizeof(NSRange) * (_count - idx));
}

- (void)replaceRangeAtIndex:(NSUInteger)idx withRange:(NSRange)range;
{
	NSAssert2(idx < _count, @"index %lu beyond count %lu", (unsigned long)idx, (unsigned long)_count);
    
	_ranges[idx] = range;
}

- (void)removeLastRange;
{
	_count--;
}

- (void)removeAllRanges;
{
	_count = 0;
}


- (NSRange *)ranges;
{
	return _ranges;
}


- (BOOL)isEqual:(id)otherObject
{
	if (self == otherObject) {
		return YES;
	}
	
	if ([self class] != [otherObject class]) {
		return NO;
	}
	
	JXRangeArray *other = (JXRangeArray *)otherObject;
	
	if (_count != [other count]) {
		return NO;
	}
	else {
		// Counts are identical.
	}
	
	NSRange *otherRanges = other.ranges;
	
	for (NSUInteger i = 0; i < _count; i++) {
		NSRange thisRange = _ranges[i];
		NSRange otherRange = otherRanges[i];
	
		if (NSEqualRanges(thisRange, otherRange) == NO) {
			return NO;
		}
	}
	
	return YES;
}

- (NSUInteger)hash
{
	// Pretty inefficient, but you should rarely need this.
	// In case this becomes a performance issue,
	// you can subclass and return _count (like Foundation)
	// or design a scheme appropriate
	// for your required performance characteristics.
	const NSUInteger prime = 31;
	NSUInteger result = _count;

	for (NSUInteger i = 0; i < _count; i++) {
		NSRange thisRange = _ranges[i];
		
		result = prime * result + thisRange.location;
		result = prime * result + thisRange.length;
	}

	return result;
}



- (void)enumerateRangesUsingBlock:(void (^)(NSRange range, NSUInteger idx, BOOL *stop))block;
{
	[self enumerateRangesWithOptions:0
						  usingBlock:block];
}

- (void)enumerateRangesWithOptions:(NSEnumerationOptions)opts
						usingBlock:(void (^)(NSRange range, NSUInteger idx, BOOL *stop))block;
{
	__block BOOL stop = NO;
	
	if (_count == 0) {
		return;
		// The code below is safe in this case, but terminating early makes it explicit.
	}
	
	if (opts & NSEnumerationReverse) {
		// Iterate from n-1 down to 0.
		for (NSUInteger i = _count; i-- > 0; ) {
			NSRange range = _ranges[i];
			
			block(range, i, &stop);
			
			if (stop) {
				break;
			}
		}
	} else {
		// Iterate from 0 to n-1.
		for (NSUInteger i = 0; i < _count; i++) {
			NSRange range = _ranges[i];
			
			block(range, i, &stop);
			
			if (stop) {
				break;
			}
		}
	}
}


- (NSRange)rangeContainingIndex:(NSUInteger)idx;
{
	return [self rangeContainingIndex:idx foundArrayIndex:NULL];
}

- (NSRange)rangeContainingIndex:(NSUInteger)idx foundArrayIndex:(NSUInteger *)foundRangeIndex;
{
	// Assumes that contents of the array is in ascending sorted order.
	
	int (^comparator)(const void *, const void *);
	
	comparator = ^(const void *key, const void *entry) {
		NSUInteger keyIndex = *(NSUInteger *)key;
		NSRange range = *(NSRange *)entry;
		
		if (keyIndex < range.location) {
			return -1;
		}
		else if (keyIndex >= NSMaxRange(range)) {
			return 1;
		}
		else {
			return 0;
		}
	};
	
	void *found = bsearch_b(&idx,				// the searched value
	                        _ranges,			// the searched array
	                        _count,				// the length of array
	                        sizeof(NSRange),	// the size of the values
	                        comparator);		// the comparator

	if (found == NULL) {
		if (foundRangeIndex != NULL) {
			*foundRangeIndex = NSNotFound;
		}
		
		return NSMakeRange(NSNotFound, 0);
	} else {
		NSUInteger matchIndex = ((found - (void *)_ranges) / sizeof(NSRange));
		
		if (foundRangeIndex != NULL) {
			*foundRangeIndex = matchIndex;
		}
		
		NSRange foundRange = *(NSRange *)found;
		
		return foundRange;
	}
}

- (NSUInteger)arrayIndexForRangeContainingIndex:(NSUInteger)idx;
{
	NSUInteger matchIndex;
	
	[self rangeContainingIndex:idx foundArrayIndex:&matchIndex];
	
	return matchIndex;
}


- (id)copyWithZone:(NSZone *)zone
{
	id newRangeArray = [[[self class] allocWithZone:zone] initWithRanges:_ranges
																   count:_count];
	
	return newRangeArray;
}

#ifndef COVERAGE
// not visible to coverage

- (NSString *)description
{
	return [self descriptionWithLocale:nil indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale;
{
	return [self descriptionWithLocale:locale indent:0];
}

- (NSString *)descriptionWithLocale:(id)locale indent:(NSUInteger)level;
{
	NSMutableString *description = [NSMutableString string];
	
	NSString *indentationString = @"    ";
	NSUInteger indentationStringLength = indentationString.length;
	
	NSUInteger indentationDepth = level * indentationStringLength;
	
	NSString *indentation = [@"" stringByPaddingToLength:indentationDepth withString:indentationString startingAtIndex:0];
	
	[description appendString:indentation];
	[description appendFormat:@"<%@ %p>(\n", NSStringFromClass([self class]), self];
	
	NSUInteger lastIndex = _count - 1;
	
	for (NSUInteger i = 0; i < _count; i++) {
		NSRange range = _ranges[i];
		NSString *rangeDescription = NSStringFromRange(range);
		
		[description appendString:indentation];
		[description appendString:rangeDescription];
		if (i != lastIndex) {
			[description appendString:@","];
		}
		[description appendString:@"\n"];
	}

	[description appendString:@")"];

	return description;
}

#endif

@end
