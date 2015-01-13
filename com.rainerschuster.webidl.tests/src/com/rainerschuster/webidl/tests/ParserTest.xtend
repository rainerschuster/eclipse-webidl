/*
 * Copyright 2015 Rainer Schuster
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package com.rainerschuster.webidl.tests

import com.google.inject.Inject
import com.rainerschuster.webidl.WebIDLInjectorProvider
import com.rainerschuster.webidl.util.EffectiveOverloadingSetUtil
import com.rainerschuster.webidl.util.NameUtil
import com.rainerschuster.webidl.webIDL.Definitions
import com.rainerschuster.webidl.webIDL.Interface
import org.eclipse.xtext.junit4.InjectWith
import org.eclipse.xtext.junit4.XtextRunner
import org.eclipse.xtext.junit4.util.ParseHelper
import org.eclipse.xtext.junit4.validation.ValidationTestHelper
import org.junit.Test
import org.junit.runner.RunWith

@InjectWith(WebIDLInjectorProvider)
@RunWith(XtextRunner)
class ParserTest {

	@Inject extension ParseHelper<Definitions> parser
	@Inject extension ValidationTestHelper



	@Test
	def void overloadSample_3_2_6__02() {
		// Replaced Node and Event since they are not available
		val definitions = '''
			interface A {
			  /* f1 */ void f(DOMString a);
			  /* f2 */ void f(RegExp a, DOMString b, float... c);
			  /* f3 */ void f();
			  /* f4 */ void f(Date a, DOMString b, optional DOMString c, float... d);
			};
		'''.parse;

		for (Interface iface : definitions.definitions.map[it.def].filter(typeof(Interface))) {
			val effectiveOverloadingSet = EffectiveOverloadingSetUtil.computeForRegularOperation(iface, "f", 4)
			val String output = "{" + effectiveOverloadingSet.map[
				val StringBuilder sb = new StringBuilder();
				sb.append("<");
				sb.append(it.callable.name);
				sb.append(", ");
				sb.append("(");
				sb.append(it.typeList.map[NameUtil.typeName(it)].join(', '));
				sb.append(")");
				sb.append(", ");
				sb.append("(");
				sb.append(it.optionalityList.map[it.name.toLowerCase].join(', '));
				sb.append(")");
				sb.append(">");
				sb.toString
			].join(",\n ") + "}";
//			println(output);
		}
	}

//	private def effectiveOverloadingSetToString(List<EffectiveOverloadingSetEntry> effectiveOverloadingSet)
//	'''
//	
//	'''




	// See 3. Interface definition language

	@Test
	def void parseSample_3__01() {
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

	// See 3.1. Names

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

	// See 3.2. Interfaces

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
	def void parseSample_3_2__04() {
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
//	def void parseSample_3_2__05() {
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

	// See 3.2.1. Constants

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

	// See 3.2.2. Attributes

	@Test
	def void parseSample_3_2_2__01() {
		'''
			interface Animal {
			
			  // A simple attribute that can be set to any string value.
			  readonly attribute DOMString name;
			
			  // An attribute whose value can be assigned to.
			  attribute unsigned short age;
			};
			
			interface Person : Animal {
			
			  // An attribute whose getter behavior is inherited from Animal, and need not be
			  // specified in the description of Person.
			  inherit attribute DOMString name;
			};
		'''.parse.assertNoErrors
	}

	// See 3.2.3. Operations

	@Test
	def void parseSample_3_2_3__01() {
		'''
			interface Dimensions {
			  attribute unsigned long width;
			  attribute unsigned long height;
			};
			
			interface Button {
			
			  // An operation that takes no arguments and returns a boolean.
			  boolean isMouseOver();
			
			  // Overloaded operations.
			  void setDimensions(Dimensions size);
			  void setDimensions(unsigned long width, unsigned long height);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_3__02() {
		'''
			interface IntegerSet {
			  readonly attribute unsigned long cardinality;
			
			  void union(long... ints);
			  void intersection(long... ints);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_3__03() {
		'''
			interface ColorCreator {
			  object createColor(float v1, float v2, float v3, optional float alpha);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_3__04() {
		'''
			interface ColorCreator {
			  object createColor(float v1, float v2, float v3);
			  object createColor(float v1, float v2, float v3, float alpha);
			};
		'''.parse.assertNoErrors
	}

	// See 3.2.4. Special operations

	@Test
	def void parseSample_3_2_4__01() {
		'''
			interface Dictionary {
			  readonly attribute unsigned long propertyCount;
			
			  getter float (DOMString propertyName);
			  setter void (DOMString propertyName, float propertyValue);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_4__02() {
		'''
			interface Dictionary {
			  readonly attribute unsigned long propertyCount;
			
			  getter float getProperty(DOMString propertyName);
			  setter void setProperty(DOMString propertyName, float propertyValue);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_4__03() {
		'''
			interface Dictionary {
			  readonly attribute unsigned long propertyCount;
			
			  float getProperty(DOMString propertyName);
			  void setProperty(DOMString propertyName, float propertyValue);
			
			  getter float (DOMString propertyName);
			  setter void (DOMString propertyName, float propertyValue);
			};
		'''.parse.assertNoErrors
	}

	// See 3.2.4.1. Legacy callers

	@Test
	def void parseSample_3_2_4_1__01() {
		'''
			interface NumberQuadrupler {
			  // This operation simply returns four times the given number x.
			  legacycaller float compute(float x);
			};
		'''.parse.assertNoErrors
	}

	// See 3.2.4.2. Stringifiers

	@Test
	def void parseSample_3_2_4_2__01() {
		'''
			interface A {
			  stringifier DOMString ();
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_4_2__02() {
		'''
			interface A {
			  stringifier;
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_4_2__03() {
		'''
			[Constructor]
			interface Student {
			  attribute unsigned long id;
			  stringifier attribute DOMString name;
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_4_2__04() {
		'''
			[Constructor]
			interface Student {
			  attribute unsigned long id;
			  attribute DOMString? familyName;
			  attribute DOMString givenName;
			
			  stringifier DOMString ();
			};
		'''.parse.assertNoErrors
	}

	// See 3.2.4.3. Serializers

// TODO Check if "serializer;" is valid WebIDL
//	@Test
//	def void parseSample_3_2_4_3__01() {
//		'''
//			interface Transaction {
//			  readonly attribute Account from;
//			  readonly attribute Account to;
//			  readonly attribute float amount;
//			  readonly attribute DOMString description;
//			  readonly attribute unsigned long number;
//			
//			  serializer;
//			};
//			
//			interface Account {
//			  DOMString name;
//			  unsigned long number;
//			};
//		'''.parse.assertNoErrors
//	}

// TODO Bug in example "DOMString name;" is neither attribute nor operation!
//	@Test
//	def void parseSample_3_2_4_3__02() {
//		'''
//			interface Transaction {
//			  readonly attribute Account from;
//			  readonly attribute Account to;
//			  readonly attribute float amount;
//			  readonly attribute DOMString description;
//			  readonly attribute unsigned long number;
//			
//			  serializer = { from, to, amount, description };
//			};
//			
//			interface Account {
//			  DOMString name;
//			  unsigned long number;
//			
//			  serializer = number;
//			};
//		'''.parse.assertNoErrors
//	}

	// See 3.2.4.4. Indexed properties

	@Test
	def void parseSample_3_2_4_4__01() {
		'''
			interface A {
			  getter DOMString toWord(unsigned long index);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_2_4_4__02() {
		'''
			interface OrderedMap {
			  readonly attribute unsigned long size;
			
			  getter any getByIndex(unsigned long index);
			  setter void setByIndex(unsigned long index, any value);
			  deleter void removeByIndex(unsigned long index);
			
			  getter any get(DOMString name);
			  setter creator void set(DOMString name, any value);
			  deleter void remove(DOMString name);
			};
		'''.parse.assertNoErrors
	}

	// See 3.2.5. Static attributes and operations

	@Test
	def void parseSample_3_2_5__01() {
		'''
			interface Point { /* ... */ };
			
			interface Circle {
			  attribute float cx;
			  attribute float cy;
			  attribute float radius;
			
			  static readonly attribute long triangulationCount;
			  static Point triangulate(Circle c1, Circle c2, Circle c3);
			};
		'''.parse.assertNoErrors
	}

	// See 3.2.6. Overloading

	@Test
	def void parseSample_3_2_6__01() {
		'''
			interface A {
			  void f();
			};
			
			partial interface A {
			  void f(float x);
			  void g();
			};
			
			partial interface A {
			  void g(DOMString x);
			};
		'''.parse.assertNoErrors
	}

	// Disabled because Node is not available
//	@Test
//	def void parseSample_3_2_6__02() {
//		'''
//			interface A {
//			  /* f1 */ void f(DOMString a);
//			  /* f2 */ void f(Node a, DOMString b, float... c);
//			  /* f3 */ void f();
//			  /* f4 */ void f(Event a, DOMString b, optional DOMString c, float... d);
//			};
//		'''.parse.assertNoErrors
//	}

	// TODO must be invalid!
//	@Test
//	def void parseSample_3_2_6__03() {
//		'''
//			interface B {
//			  void f(DOMString x);
//			  void f(float x);
//			};
//		'''.parse.assertNoErrors
//	}

	// TODO must be invalid!
//	@Test
//	def void parseSample_3_2_6__04() {
//		'''
//			interface B {
//			  /* f1 */ void f(DOMString w);
//			  /* f2 */ void f(long w, float x, Node y, Node z);
//			  /* f3 */ void f(float w, float x, DOMString y, Node z);
//			};
//		'''.parse.assertNoErrors
//	}

	// See 3.2.7. Iterable declarations

	@Test
	def void parseSample_3_2_7__01() {
		'''
			interface SessionManager {
			  Session getSessionForUser(DOMString username);
			  readonly attribute unsigned long sessionCount;
			
			  iterable<Session>;
			};
			
			interface Session {
			  readonly attribute DOMString username;
			  // ...
			};
		'''.parse.assertNoErrors
	}

	// See 3.2.8. Maplike declarations

	// See 3.2.9. Setlike declarations

	// See 3.3. Dictionaries

	@Test
	def void parseSample_3_3__01() {
		'''
			dictionary B : A {
			  long b;
			  long a;
			};
			
			dictionary A {
			  long c;
			  long g;
			};
			
			dictionary C : B {
			  long e;
			  long f;
			};
			
			partial dictionary A {
			  long h;
			  long d;
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_3__02() {
		'''
			dictionary B : A {
			  long b;
			  long a;
			};
			
			dictionary A {
			  long c;
			  long g;
			};
			
			dictionary C : B {
			  long e;
			  long f;
			};
			
			partial dictionary A {
			  long h;
			  long d;
			};
			
			interface Something {
			  void f(A a);
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_3__03() {
		'''
			[Constructor]
			interface Point {
			  attribute float x;
			  attribute float y;
			};
			
			dictionary PaintOptions {
			  DOMString? fillPattern = "black";
			  DOMString? strokePattern = null;
			  Point position;
			};
			
			interface GraphicsContext {
			  void drawRectangle(float width, float height, optional PaintOptions options);
			};
		'''.parse.assertNoErrors
	}

	// See 3.5. Enumerations

	@Test
	def void parseSample_3_5__01() {
		'''
			enum MealType { "rice", "noodles", "other" };
			
			interface Meal {
			  attribute MealType type;
			  attribute float size;     // in grams
			
			  void initialize(MealType type, float size);
			};
		'''.parse.assertNoErrors
	}

	// See 3.6. Callback functions

	@Test
	def void parseSample_3_6__01() {
		'''
			callback AsyncOperationCallback = void (DOMString status);
			
			interface AsyncOperations {
			  void performOperation(AsyncOperationCallback whenFinished);
			};
		'''.parse.assertNoErrors
	}

	// See 3.7. Typedefs

	@Test
	def void parseSample_3_7__01() {
		'''
			interface Point {
			  attribute float x;
			  attribute float y;
			};
			
			typedef sequence<Point> Points;
			
			interface Widget {
			  boolean pointWithinBounds(Point p);
			  boolean allPointsWithinBounds(Points ps);
			};
		'''.parse.assertNoErrors
	}

	// See 3.8. Implements statements

	@Test
	def void parseSample_3_8__01() {
		'''
			interface Window { /*...*/ };
			interface SomeFunctionality { /*...*/ };
			Window implements SomeFunctionality;
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_8__02() {
		'''
			interface Window { /*...*/ };
			interface SomeFunctionality { /*...*/ };
			Window implements SomeFunctionality;
			
			interface Gizmo { /*...*/ };
			interface MoreFunctionality { /*...*/ };
			SomeFunctionality implements MoreFunctionality;
			Gizmo implements SomeFunctionality;
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_8__03() {
		'''
			interface Window { /*...*/ };
			interface SomeFunctionality { /*...*/ };
			Window implements SomeFunctionality;
			
			interface Gizmo { /*...*/ };
			interface MoreFunctionality { /*...*/ };
			Gizmo implements SomeFunctionality;
			Gizmo implements MoreFunctionality;
		'''.parse.assertNoErrors
	}

	// TODO Split?
	// TODO must be invalid!
//	@Test
//	def void parseSample_3_8__04() {
//		'''
//			interface A { attribute long x; };
//			interface B { attribute long x; };
//			A implements B;  // B::x would clash with A::x
//			
//			interface C { attribute long y; };
//			interface D { attribute long y; };
//			interface E : D { };
//			C implements E;  // D::y would clash with C::y
//			
//			interface F { };
//			interface H { attribute long z; };
//			interface I { attribute long z; };
//			F implements H;
//			F implements I;  // H::z and I::z would clash when mixed in to F
//		'''.parse.assertNoErrors
//	}

	// Disabled because EventListener is not available
//	@Test
//	def void parseSample_3_8__05() {
//		'''
//			interface Entry {
//			  readonly attribute unsigned short entryType;
//			  // ...
//			};
//			
//			interface Observable {
//			  void addEventListener(DOMString type,
//			                        EventListener listener,
//			                        boolean useCapture);
//			  // ...
//			};
//			
//			Entry implements Observable;
//		'''.parse.assertNoErrors
//	}

	// See 3.10.23. Nullable types — T?

	@Test
	def void parseSample_3_10_23__01() {
		'''
			interface MyConstants {
			  const boolean? ARE_WE_THERE_YET = false;
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_3_10_23__02() {
		'''
			interface Node {
			  readonly attribute DOMString? namespaceURI;
			  readonly attribute Node? parentNode;
			  // ...
			};
		'''.parse.assertNoErrors
	}

	// See 4.2.25. Sequences — sequence<T>

	@Test
	def void parseSample_4_2_25__01() {
		'''
			interface Canvas {
			
			  sequence<DOMString> getSupportedImageCodecs();
			
			  void drawPolygon(sequence<float> coordinates);
			  sequence<float> getLastDrawnPolygon();
			
			  // ...
			};
		'''.parse.assertNoErrors
	}

	// See 4.2.26. Arrays — T[]

	@Test
	def void parseSample_4_2_26__01() {
		'''
			[Constructor]
			interface LotteryResults {
			  readonly attribute unsigned short[] numbers;
			};
		'''.parse.assertNoErrors
	}

	@Test
	def void parseSample_4_2_26__02() {
		'''
			[Constructor]
			interface LotteryResults {
			  attribute unsigned short[] numbers;
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.1. [ArrayClass]

	@Test
	def void parseSample_4_3_1__01() {
		'''
			[ArrayClass]
			interface ItemList {
			  attribute unsigned long length;
			  getter object getItem(unsigned long index);
			  creator setter object setItem(unsigned long index, object item);
			  deleter void removeItem(unsigned long index);
			};
			
			[ArrayClass]
			interface ImmutableItemList {
			  readonly attribute unsigned long length;
			  getter object getItem(unsigned long index);
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.2. [Clamp]

	@Test
	def void parseSample_4_3_2__01() {
		'''
			interface GraphicsContext {
			  void setColor(octet red, octet green, octet blue);
			  void setColorClamped([Clamp] octet red, [Clamp] octet green, [Clamp] octet blue);
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.3. [Constructor]

	// Disabled because Node is not available
//	@Test
//	def void parseSample_4_3_3__01() {
//		'''
//			interface NodeList {
//			  Node item(unsigned long index);
//			  readonly attribute unsigned long length;
//			};
//			
//			[Constructor,
//			 Constructor(float radius)]
//			interface Circle {
//			  attribute float r;
//			  attribute float cx;
//			  attribute float cy;
//			  readonly attribute float circumference;
//			};
//		'''.parse.assertNoErrors
//	}

	@Test
	def void parseSample_4_3_3__02() {
		'''
			[Constructor(unsigned long patties, unsigned long cheeseSlices)]
			dictionary BurgerOrder {
			  unsigned long pattyCount;
			  unsigned long cheeseSliceCount;
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.4. [EnforceRange]

	@Test
	def void parseSample_4_3_4__01() {
		'''
			interface GraphicsContext {
			  void setColor(octet red, octet green, octet blue);
			  void setColorEnforcedRange([EnforceRange] octet red, [EnforceRange] octet green, [EnforceRange] octet blue);
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.5. [Exposed]

	// Disabled because WorkerGlobalScope is not available
//	@Test
//	def void parseSample_4_3_5__01() {
//		'''
//			[PrimaryGlobal]
//			interface Window {
//			  /*...*/
//			};
//			
//			// By using the same identifier Worker for both SharedWorkerGlobalScope
//			// and DedicatedWorkerGlobalScope, both can be addressed in an [Exposed]
//			// extended attribute at once.
//			[Global=Worker]
//			interface SharedWorkerGlobalScope : WorkerGlobalScope {
//			  /*...*/
//			};
//			
//			[Global=Worker]
//			interface DedicatedWorkerGlobalScope : WorkerGlobalScope {
//			  /*...*/
//			};
//			
//			// MathUtils is available for use in workers and on the main thread.
//			[Exposed=(Window,Worker)]
//			interface MathUtils {
//			  static double someComplicatedFunction(double x, double y);
//			};
//			
//			// WorkerUtils is only available in workers.  Evaluating WorkerUtils
//			// in the global scope of a worker would give you its interface object, while
//			// doing so on the main thread will give you a ReferenceError.
//			[Exposed=Worker]
//			interface WorkerUtils {
//			  static void setPriority(double x);
//			};
//			
//			// Node is only available on the main thread.  Evaluating Node
//			// in the global scope of a worker would give you a ReferenceError.
//			interface Node {
//			  /*...*/
//			};
//		'''.parse.assertNoErrors
//	}

	// See 4.3.6. [ImplicitThis]

	@Test
	def void parseSample_4_3_6__01() {
		'''
			[ImplicitThis]
			interface Window {
			  /*...*/
			  attribute DOMString name;
			  void alert(DOMString message);
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.7. [Global] and [PrimaryGlobal]

	@Test
	def void parseSample_4_3_7__01() {
		'''
			[PrimaryGlobal]
			interface Window {
			  getter any (DOMString name);
			  attribute DOMString name;
			  // ...
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.8. [LenientThis]

	@Test
	def void parseSample_4_3_8__01() {
		'''
			interface Example {
			  [LenientThis] attribute DOMString x;
			  attribute DOMString y;
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.9. [NamedConstructor]

	// Disabled because HTMLMediaElement is not available
//	@Test
//	def void parseSample_4_3_9__01() {
//		'''
//			[NamedConstructor=Audio,
//			 NamedConstructor=Audio(DOMString src)]
//			interface HTMLAudioElement : HTMLMediaElement {
//			  // ...
//			};
//		'''.parse.assertNoErrors
//	}

	// See 4.3.10. [NewObject]

	// Disabled because Node and Element are not available
//	@Test
//	def void parseSample_4_3_10__01() {
//		'''
//			interface Document : Node {
//			  [NewObject] Element createElement(DOMString localName);
//			  // ...
//			};
//		'''.parse.assertNoErrors
//	}

	// See 4.3.11. [NoInterfaceObject]

	@Test
	def void parseSample_4_3_11__01() {
		'''
			interface Storage {
			  void addEntry(unsigned long key, any value);
			};
			
			[NoInterfaceObject]
			interface Query {
			  any lookupEntry(unsigned long key);
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.12. [OverrideBuiltins]

	@Test
	def void parseSample_4_3_12__01() {
		'''
			interface StringMap {
			  readonly attribute unsigned long length;
			  getter DOMString lookup(DOMString key);
			};
			
			[OverrideBuiltins]
			interface StringMap2 {
			  readonly attribute unsigned long length;
			  getter DOMString lookup(DOMString key);
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.13. [PutForwards]

	@Test
	def void parseSample_4_3_13__01() {
		'''
			interface Name {
			  attribute DOMString full;
			  attribute DOMString family;
			  attribute DOMString given;
			};
			
			interface Person {
			  [PutForwards=full] readonly attribute Name name;
			  attribute unsigned short age;
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.14. [Replaceable]

	@Test
	def void parseSample_4_3_14__01() {
		'''
			interface Counter {
			  [Replaceable] readonly attribute unsigned long value;
			  void increment();
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.15. [SameObject]

	// Disabled because Node and DOMImplementation is not available
//	@Test
//	def void parseSample_4_3_15__01() {
//		'''
//			interface Document : Node {
//			  [SameObject] readonly attribute DOMImplementation implementation;
//			  // ...
//			};
//		'''.parse.assertNoErrors
//	}

	// See 4.3.16. [TreatNonObjectAsNull]

	@Test
	def void parseSample_4_3_16__01() {
		'''
			callback OccurrenceHandler = void (DOMString details);
			
			[TreatNonObjectAsNull]
			callback ErrorHandler = void (DOMString details);
			
			interface Manager {
			  attribute OccurrenceHandler? handler1;
			  attribute ErrorHandler? handler2;
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.17. [TreatNullAs]

	@Test
	def void parseSample_4_3_17__01() {
		'''
			interface Dog {
			  attribute DOMString name;
			  [TreatNullAs=EmptyString] attribute DOMString owner;
			
			  boolean isMemberOfBreed([TreatNullAs=EmptyString] DOMString breedName);
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.18. [Unforgeable]

	// TODO must be invalid!
//	@Test
//	def void parseSample_4_3_18__01() {
//		'''
//			interface A1 {
//			  [Unforgeable] readonly attribute DOMString x;
//			};
//			interface B1 : A1 {
//			  void x();  // Invalid; would be shadowed by A1's x.
//			};
//			
//			interface B2 : A1 { };
//			B2 implements Mixin;
//			interface Mixin {
//			  void x();  // Invalid; B2's copy of x would be shadowed by A1's x.
//			};
//			
//			[Unforgeable]
//			interface A2 {
//			  readonly attribute DOMString x;
//			};
//			interface B3 : A2 {
//			  void x();  // Invalid; would be shadowed by A2's x.
//			};
//			
//			interface B4 : A2 { };
//			B4 implements Mixin;
//			interface Mixin {
//			  void x();  // Invalid; B4's copy of x would be shadowed by A2's x.
//			};
//			
//			interface A3 { };
//			A3 implements A2;
//			interface B5 : A3 {
//			  void x();  // Invalid; would be shadowed by A3's mixed-in copy of A2's x.
//			};
//		'''.parse.assertNoErrors
//	}

	@Test
	def void parseSample_4_3_18__02() {
		'''
			interface System {
			  [Unforgeable] readonly attribute DOMString username;
			  readonly attribute Date loginTime;
			};
		'''.parse.assertNoErrors
	}

	// See 4.3.19. [Unscopeable]
// TODO enable (check if there is a bug in the spec since g neither has a return type nor is a special operation)!
//	@Test
//	def void parseSample_4_3_19__01() {
//		'''
//			interface Thing {
//			  void f();
//			  [Unscopeable] g();
//			};
//		'''.parse.assertNoErrors
//	}

	// See 4.5.4. Interface prototype object

	// Disabled because Window is not available
//	@Test
//	def void parseSample_4_5_4__01() {
//		'''
//			[NoInterfaceObject]
//			interface Foo {
//			};
//			
//			partial interface Window {
//			  attribute Foo foo;
//			};
//		'''.parse.assertNoErrors
//	}

	// See 4.5.9.2. forEach

	// Disabled because this is only an operation and no full definition
//	@Test
//	def void parseSample_4_5_9_2__01() {
//		'''
//			void forEach(Function callback, optional any thisArg = undefined);
//		'''.parse.assertNoErrors
//	}

	// See 4.6. Implements statements

	@Test
	def void parseSample_4_6__01() {
		'''
			interface A {
			  void f();
			};
			
			interface B { };
			B implements A;
			
			interface C { };
			C implements A;
		'''.parse.assertNoErrors
	}

	// See 4.12. Creating and throwing exceptions

	@Test
	def void parseSample_4_12__01() {
		'''
			interface A {
			
			  /**
			   * Calls computeSquareRoot on m, passing x as its argument.
			   */
			  float doComputation(MathUtils m, float x);
			};
			
			interface MathUtils {
			  /**
			   * If x is negative, throws a NotSupportedError.  Otherwise, returns
			   * the square root of x.
			   */
			  float computeSquareRoot(float x);
			};
		'''.parse.assertNoErrors
	}

	// See 4.13. Handling exceptions

	@Test
	def void parseSample_4_13__01() {
		'''
			interface Dahut {
			  attribute DOMString type;
			};
			
			interface ExceptionThrower {
			  // This attribute always throws a NotSupportedError and never returns a value.
			  attribute long valueOf;
			};
		'''.parse.assertNoErrors
	}

}
