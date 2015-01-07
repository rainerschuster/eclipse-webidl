package com.rainerschuster.webidl.tests

import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.InjectWith
import org.junit.runner.RunWith
import com.google.inject.Inject
import org.eclipse.xtext.junit4.util.ParseHelper
import com.rainerschuster.webidl.WebIDLInjectorProvider
import org.junit.Test
import com.rainerschuster.webidl.webIDL.Definitions

import org.eclipse.xtext.junit4.validation.ValidationTestHelper

@InjectWith(WebIDLInjectorProvider)
@RunWith(XtextRunner)
class ParserTest {

	@Inject extension ParseHelper<Definitions> parser
	@Inject extension ValidationTestHelper

	@Test
	def void parsePaintSample() {
		'''
			interface Paint { };
			
			interface SolidColor : Paint {
			  attribute float red;
			  attribute float green;
			  attribute float blue;
			};
			
			interface Pattern : Paint {
			  attribute DOMString imageURL;
			};
			
			[Constructor]
			interface GraphicalWindow {
			  readonly attribute unsigned long width;
			  readonly attribute unsigned long height;
			
			  attribute Paint currentPaint;
			
			  void drawRectangle(float x, float y, float width, float height);
			
			  void drawText(float x, float y, DOMString text);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_1__01() {
		'''
			interface B : A {
			  void f(ArrayOfLongs x);
			};
			
			interface A {
			};
			
			typedef long[] ArrayOfLongs;
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_1__02() {
		'''
			// Typedef identifier: "number"
			typedef float number;
			
			// Interface identifier: "System"
			interface System {
			
			  // Operation identifier:          "createObject"
			  // Operation argument identifier: "interface"
			  object createObject(DOMString _interface);
			
			  // Operation argument identifier: "interface"
			  object[] createObjectArray(DOMString interface);
			
			  // Operation has no identifier; it declares a getter.
			  getter DOMString (DOMString keyName);
			};
			
			// Interface identifier: "TextField"
			interface TextField {
			
			  // Attribute identifier: "const"
			  attribute boolean _const;
			
			  // Attribute identifier: "value"
			  attribute DOMString? _value;
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2__01() {
		'''
			interface A {
			  void f();
			  void g();
			};
			
			interface B : A {
			  void f();
			  void g(DOMString x);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2__02() {
		'''
			callback interface Options {
			  attribute DOMString? option1;
			  attribute DOMString? option2;
			  attribute long? option3;
			};
			
			interface A {
			  void doTask(DOMString type, Options options);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2__03() {
		'''
			dictionary Options {
			  DOMString? option1;
			  DOMString? option2;
			  long? option3;
			};
			
			interface A {
			  void doTask(DOMString type, Options options);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_04__Animal() {
		'''
			interface Animal {
			  attribute DOMString name;
			};
			
			interface Human : Animal {
			  attribute Dog? pet;
			};
			
			interface Dog : Animal {
			  attribute Human? owner;
			};
		'''.parse.assertNoErrors
	}

//	@Test
//	def void parseSample_3_2_05__Node() {
//		'''
//			interface Node {
//			  readonly attribute DOMString nodeName;
//			  readonly attribute Node? parentNode;
//			  Node appendChild(Node newChild);
//			  void addEventListener(DOMString type, EventListener listener);
//			};
//			
//			callback interface EventListener {
//			  void handleEvent(Event event);
//			};
//		'''.parse.assertNoErrors
//	}

	@Test
	def void parseSample_3_2_1__01() {
		'''
			interface A {
			  const short rambaldi = 47;
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_1__02() {
		'''
			interface Util {
			  const boolean DEBUG = false;
			  const octet LF = 10;
			  const unsigned long BIT_MASK = 0x0000fc00;
			  const float AVOGADRO = 6.022e23;
			};
		'''.parse.assertNoErrors
	}

}
