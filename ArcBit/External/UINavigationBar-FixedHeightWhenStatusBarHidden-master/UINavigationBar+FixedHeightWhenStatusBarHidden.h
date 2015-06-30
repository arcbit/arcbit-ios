//
//  UINavigationBar+FixedHeightWhenStatusBarHidden.h
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

#import <UIKit/UIKit.h>

@interface UINavigationBar (FixedHeightWhenStatusBarHidden)

/**
 * If set to YES, UINavigationBar height will not change after status bar was hidden.
 * Normally on iOS 7+ navigation bar height equals to 64 px, when status bar is shown.
 * After it is hidden, its height is changed to 44 px by default.
 */
@property (readwrite, nonatomic) BOOL fixedHeightWhenStatusBarHidden;

@end
