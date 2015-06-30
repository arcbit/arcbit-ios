//
//  UINavigationBar+FixedHeightWhenStatusBarHidden.m
//
//  Created by Vitaliy Ivanov on 7/30/14.
//  Copyright (c) 2014 Factorial Complexity. All rights reserved.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "UINavigationBar+FixedHeightWhenStatusBarHidden.h"
#import <objc/runtime.h>

#define FYIsIOSVersionGreaterThanOrEqualTo(v) \
	([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

static char const* const FixedNavigationBarSize = "FixedNavigationBarSize";

@implementation UINavigationBar (FixedHeightWhenStatusBarHidden)

- (CGSize)sizeThatFits_FixedHeightWhenStatusBarHidden:(CGSize)size
{
	if ([UIApplication sharedApplication].statusBarHidden &&
		FYIsIOSVersionGreaterThanOrEqualTo(@"7.0") &&
		self.fixedHeightWhenStatusBarHidden)
	{
		CGSize newSize = CGSizeMake(self.frame.size.width, 64);
		return newSize;
	}
	else
	{
		return [self sizeThatFits_FixedHeightWhenStatusBarHidden:size];
	}
}

- (BOOL)fixedHeightWhenStatusBarHidden
{
	return [objc_getAssociatedObject(self, FixedNavigationBarSize) boolValue];
}

- (void)setFixedHeightWhenStatusBarHidden:(BOOL)fixedHeightWhenStatusBarHidden
{
	objc_setAssociatedObject(self, FixedNavigationBarSize,
		[NSNumber numberWithBool:fixedHeightWhenStatusBarHidden], OBJC_ASSOCIATION_RETAIN);
}

+ (void)load
{
    method_exchangeImplementations(class_getInstanceMethod(self, @selector(sizeThatFits:)),
		class_getInstanceMethod(self, @selector(sizeThatFits_FixedHeightWhenStatusBarHidden:)));
}

@end
