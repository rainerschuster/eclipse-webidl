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
package com.rainerschuster.webidl.util

import com.rainerschuster.webidl.webIDL.AnyType
import com.rainerschuster.webidl.webIDL.ArrayBufferType
import com.rainerschuster.webidl.webIDL.BooleanType
import com.rainerschuster.webidl.webIDL.ByteStringType
import com.rainerschuster.webidl.webIDL.ByteType
import com.rainerschuster.webidl.webIDL.CallbackFunction
import com.rainerschuster.webidl.webIDL.DOMExceptionType
import com.rainerschuster.webidl.webIDL.DOMStringType
import com.rainerschuster.webidl.webIDL.DataViewType
import com.rainerschuster.webidl.webIDL.DateType
import com.rainerschuster.webidl.webIDL.Definition
import com.rainerschuster.webidl.webIDL.Dictionary
import com.rainerschuster.webidl.webIDL.DoubleType
import com.rainerschuster.webidl.webIDL.Enum
import com.rainerschuster.webidl.webIDL.Float32ArrayType
import com.rainerschuster.webidl.webIDL.Float64ArrayType
import com.rainerschuster.webidl.webIDL.FloatType
import com.rainerschuster.webidl.webIDL.ImplementsStatement
import com.rainerschuster.webidl.webIDL.Int16ArrayType
import com.rainerschuster.webidl.webIDL.Int32ArrayType
import com.rainerschuster.webidl.webIDL.Int8ArrayType
import com.rainerschuster.webidl.webIDL.Interface
import com.rainerschuster.webidl.webIDL.LongLongType
import com.rainerschuster.webidl.webIDL.LongType
import com.rainerschuster.webidl.webIDL.ObjectType
import com.rainerschuster.webidl.webIDL.OctetType
import com.rainerschuster.webidl.webIDL.PromiseType
import com.rainerschuster.webidl.webIDL.ReferenceType
import com.rainerschuster.webidl.webIDL.ReturnType
import com.rainerschuster.webidl.webIDL.SequenceType
import com.rainerschuster.webidl.webIDL.ShortType
import com.rainerschuster.webidl.webIDL.Type
import com.rainerschuster.webidl.webIDL.Typedef
import com.rainerschuster.webidl.webIDL.USVStringType
import com.rainerschuster.webidl.webIDL.Uint16ArrayType
import com.rainerschuster.webidl.webIDL.Uint32ArrayType
import com.rainerschuster.webidl.webIDL.Uint8ArrayType
import com.rainerschuster.webidl.webIDL.Uint8ClampedArrayType
import com.rainerschuster.webidl.webIDL.UnionType
import com.rainerschuster.webidl.webIDL.VoidType
import java.util.List
import java.util.Set
import com.rainerschuster.webidl.webIDL.Special
import com.rainerschuster.webidl.webIDL.Operation
import com.rainerschuster.webidl.webIDL.Argument
import com.rainerschuster.webidl.webIDL.Attribute
import com.rainerschuster.webidl.webIDL.ExtendedInterfaceMember
import com.rainerschuster.webidl.webIDL.PartialInterface
import com.rainerschuster.webidl.webIDL.ExtendedAttributeArgList
import com.rainerschuster.webidl.webIDL.ExtendedAttributeNamedArgList
import com.rainerschuster.webidl.webIDL.NullableTypeSuffix
import com.rainerschuster.webidl.webIDL.InterfaceOrTypedef
import com.rainerschuster.webidl.webIDL.DictionaryOrTypedef
import com.rainerschuster.webidl.webIDL.ArrayTypeSuffix

class TypeUtil {

	// See 3.2. Interfaces
	/**
	 * {@link http://heycam.github.io/webidl/#dfn-inherited-interfaces}
	 */
	static def List<Interface> inheritedInterfaces(Interface iface) {
		val result = newArrayList();
		var currentInterface = iface;
		var currentInherit = currentInterface.inherits;
		while (currentInherit != null) {
			if (currentInherit instanceof Typedef) {
				currentInterface = resolveDefinition(currentInherit) as Interface;
			} else if (currentInherit instanceof Interface) {
				currentInterface = currentInherit as Interface;
			} else {
				println('Interface inherit of "' + iface.name + '" is neither interface nor typedef!');
				currentInterface = null;
				// TODO throw exception!
//				return null;
			}
			if (result.contains(currentInterface)) {
				println('Interface hierarchy of "' + iface.name + '" has a cycle!');
				// TODO throw exception!
				return null;
			} else {
				result += currentInterface;
			}
			currentInherit = currentInterface.inherits;
		}
		return result;
	}

	static def Definition resolveDefinition(Typedef typedef) {
		val Type type = typedef.type;
		if (type instanceof ReferenceType) {
			resolveDefinition(type)
		} else {
			println('Typedef resolves to a non-reference type!');
			return null;
		}
	}

	static def Definition resolveDefinition(ReferenceType type) {
		val typeRef = type.typeRef;
		if (typeRef instanceof Typedef) {
			resolveDefinition(typeRef)
		} else {
			return typeRef;
		}
	}

	static def Type resolveType(Typedef typedef) {
		val Type type = typedef.type;
		if (type instanceof ReferenceType) {
			resolveType(type)
		} else {
			type
		}
	}

	static def Type resolveType(ReferenceType type) {
		val typeRef = type.typeRef;
		if (typeRef instanceof Typedef) {
			resolveType(typeRef)
		} else {
			println('Typedef resolves to a reference type that does not reference a typedef!');
			return null;
		}
	}

	static def Definition resolveDefinition(InterfaceOrTypedef iot) {
		switch iot {
			Interface: iot
			Typedef: iot.resolveDefinition
		}
	}

	static def Definition resolveDefinition(DictionaryOrTypedef dot) {
		switch dot {
			Dictionary: dot
			Typedef: dot.resolveDefinition
		}
	}

	// See 3.2.2. Attributes

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-regular-attribute}
	 */
	static def boolean regularAttribute(Attribute attribute) {
		!attribute.static
	}

//	/**
//	 * {@link http://heycam.github.io/webidl/#dfn-read-only}
//	 */
//	static def boolean readOnly(Attribute attribute) {
//		attribute.readOnly
//	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-inherit-getter}
	 */
	static def boolean inheritsGetter(Attribute attribute) {
		attribute.inherit
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-inherit-getter}
	 */
	static def Attribute inheritedGetter(Attribute attribute) {
		val containerDefinition = attribute.eContainer;
		if (containerDefinition instanceof ExtendedInterfaceMember) {
			val outerContainerDefinition = containerDefinition.eContainer;
			val containerInterface = if (outerContainerDefinition instanceof Interface) {
				outerContainerDefinition
			} else if (outerContainerDefinition instanceof PartialInterface) {
				outerContainerDefinition.interfaceName
			};
			for (ancestor : containerInterface.inheritedInterfaces) {
				// TODO can there exist multiple attributes with the same name?
				// TODO Are non matching types "ignored" (i.e., are the other available ancestors checked?
				return ancestor.interfaceMembers.map[it.interfaceMember].filter(Attribute).findFirst[it.name == attribute.name];
			}
		}
	}

	// See 3.2.3. Operations

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-regular-operation}
	 */
	static def boolean regularOperation(Operation operation) {
		!operation.name.nullOrEmpty && !operation.static
	}

	// FIXME Check if nullOrEmpty is ok for these variadic methods!
	/**
	 * {@link http://heycam.github.io/webidl/#dfn-variadic}
	 */
	static def boolean variadic(Operation operation) {
		if (operation.arguments.nullOrEmpty) {
			return false;
		}
		operation.arguments.last.ellipsis
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-variadic}
	 */
	static def boolean variadic(ExtendedAttributeArgList eal) {
		if (eal.arguments.nullOrEmpty) {
			return false;
		}
		eal.arguments.last.ellipsis
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-variadic}
	 */
	static def boolean variadic(ExtendedAttributeNamedArgList eal) {
		if (eal.arguments.nullOrEmpty) {
			return false;
		}
		eal.arguments.last.ellipsis
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-variadic}
	 */
	static def boolean variadic(Constructor constructor) {
		if (constructor.arguments.nullOrEmpty) {
			return false;
		}
		constructor.arguments.last.ellipsis
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-variadic}
	 */
	 // Note variadic arguments are implicitly specified
	 // Precondition: The argument must be the last argument in an argument list
	static def boolean variadic(Argument argument) {
		argument.ellipsis
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-variadic}
	 */
	static def boolean variadic(CallbackFunction callback) {
		if (callback.arguments.nullOrEmpty) {
			return false;
		}
		callback.arguments.last.ellipsis
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-optional-argument}
	 */
	static def boolean optionalArgument(Argument argument) {
		argument.optional || argument.variadic
	}

	// See 3.2.4. Special operations

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-special-operation}
	 */
	static def boolean specialOperation(Operation operation) {
		// TODO Is serializer really excluded or just forgotten in the specification?
//		!operation.specials.filter[it != Special.SERIALIZER].empty
		!operation.specials.nullOrEmpty
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-named-property-getter}
	 */
	static def boolean namedPropertyGetter(Operation operation) {
		namedProperty(operation, Special.GETTER)
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-named-property-setter}
	 */
	static def boolean namedPropertySetter(Operation operation) {
		namedProperty(operation, Special.SETTER)
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-named-property-creator}
	 */
	static def boolean namedPropertyCreator(Operation operation) {
		namedProperty(operation, Special.CREATOR)
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-named-property-deleter}
	 */
	static def boolean namedPropertyDeleter(Operation operation) {
		namedProperty(operation, Special.DELETER)
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-indexed-property-getter}
	 */
	static def boolean indexedPropertyGetter(Operation operation) {
		indexedProperty(operation, Special.GETTER)
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-indexed-property-setter}
	 */
	static def boolean indexedPropertySetter(Operation operation) {
		indexedProperty(operation, Special.SETTER)
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-indexed-property-creator}
	 */
	static def boolean indexedPropertyCreator(Operation operation) {
		indexedProperty(operation, Special.CREATOR)
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-indexed-property-deleter}
	 */
	static def boolean indexedPropertyDeleter(Operation operation) {
		indexedProperty(operation, Special.DELETER)
	}

	// See 3.2.5. Static attributes and operations

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-static-attribute}
	 */
	static def boolean staticAttribute(Attribute attribute) {
		attribute.static
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-static-operation}
	 */
	static def boolean staticOperation(Operation operation) {
		operation.static
	}

	// See 3.5. Enumerations

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-enumeration-value}
	 */
	static def List<String> enumerationValues(Enum enumeration) {
		enumeration.values
	}

	// See 3.8. Implements statements

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-consequential-interfaces}
	 */
	static def consequentialInterfaces(Interface iface) {
		val result = newHashSet();
		consequentialInterfaces(iface, result);
		return result;
	}

	private static def void consequentialInterfaces(Interface iface, Set<Interface> result) {
		// FIXME Remove all occurrences of .filter(typeof(Interface)) and resolve typedefs correctly!
		val newInterfaces = newArrayList();
		// each interface B where the IDL states A implements B
		// FIXME eCrossReferences does not work!
		val references = iface.eCrossReferences;
		val bs = references.filter(typeof(ImplementsStatement)).filter[it.ifaceA == iface].map[it.ifaceB].filter(typeof(Interface)).filter[!result.contains(it)];
		result += bs;
		newInterfaces += bs;
		// each interface that a consequential interface of A inherits from
		val inherit = bs.map[it.inherits].filter(typeof(Interface)).filter[!result.contains(it)];
		result += inherit;
		newInterfaces += inherit;
		// each interface D where the IDL states that C implements D, where C is a consequential interface of A
		newInterfaces.forEach[
			it.consequentialInterfaces(result)
		];
	}

	// See 3.10.23. Nullable types — T?

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-nullable-type}
	 */
	static def nullableType(Type type) {
		// FIXME check if this really conforms to the specification (e.g., maybe only first typesuffix is relevant!)
		!(type.typeSuffix.nullOrEmpty || type.typeSuffix.filter(typeof(NullableTypeSuffix)).empty)
	}

	// See 3.10.27. Union types

//	/**
//	 * {@link http://heycam.github.io/webidl/#dfn-union-member-type}
//	 */
//	static def unionMemberTypes(UnionType unionType) {
//		unionType.unionMemberTypes
//	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-flattened-union-member-types}
	 */
	static def Set<Type> flattenedMemberTypes(UnionType unionType) {
		val Set<Type> s = newLinkedHashSet();
		for (u : unionType.unionMemberTypes) {
			if (u instanceof UnionType) {
				s += flattenedMemberTypes(u);
			} else {
				s += u;
			}
		}
		return s;
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-number-of-nullable-member-types}
	 */
	static def int numberOfNullableMemberTypes(UnionType unionType) {
		var n = 0;
		for (u : unionType.unionMemberTypes) {
			if (nullableType(u)) {
				n = n + 1;
			}
			// TODO http://heycam.github.io/webidl/#dfn-union-type
			if (u instanceof UnionType) {
				// Let m be the number of nullable member types of U.
				val m = numberOfNullableMemberTypes(u);
				n = n + m;
			}
		}
		return n;
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-includes-a-nullable-type}
	 */
	static def boolean includesANullableType(Type type) {
		nullableType(type) || (type instanceof UnionType && numberOfNullableMemberTypes(type as UnionType) == 1)
	}



	// Java specific methods, see also http://heycam.github.io/webidl/java.html

	def static String toJavaType(ReturnType type) {
		switch type {
			VoidType: "void"
			Type: type.toJavaType
		}
	}

	def static String toJavaType(Type type) {
		val intermediate = switch type {
			ReferenceType : {
				var Definition resolved = type.typeRef;
				if (resolved != null) {
					switch resolved {
						Interface : resolved.name
						Dictionary : "java.util.HashMap<java.lang.String,java.lang.Object>"
						Enum : "java.lang.String"
						// TODO implement CallbackFunctionType!
						CallbackFunction : resolved.name
						Typedef : resolved.type.toJavaType
					}
				} else {
					null
				}
			} // type.name
			AnyType: "java.lang.Object"
			VoidType : "void"
			BooleanType : "boolean"
			ByteType : "byte"
			OctetType : "byte"
			ShortType : "short"
//			UnsignedShortType : "short"
			LongType : "int"
//			UnsignedLongType : "int"
			LongLongType : "long"
//			UnsignedLongLongType : "long"
			FloatType : "float"
//			UnrestrictedFloatType : "float"
			DoubleType : "double"
//			UnrestrictedDoubleType : "double"
			DOMStringType : "java.lang.String"
			ObjectType : "java.lang.Object"
			// TODO implement InterfaceType!
			// TODO Corresponding Java escaped identifier
//			InterfaceSymbol : type.name
//			DictionarySymbol : "java.util.HashMap<java.lang.String,java.lang.Object>"
//			EnumerationSymbol : "java.lang.String"
//			// TODO implement CallbackFunctionType!
//			CallbackFunctionSymbol : type.name
			SequenceType : {
				val Type subType = type.type;
				val String subTypeString = subType.toJavaType;
				if (subTypeString != null) {
					subTypeString + "[]";
				}
			}
			PromiseType : {
//				val Type subType = type.elementType;
//				val String subTypeString = toJavaType(subType, resolver);
				"java.lang.Object"
			}
			UnionType : "java.lang.Object"
			DOMExceptionType : "java.lang.Object"
			DateType : "java.util.Date"
			ByteStringType : "String"
			USVStringType : "String"
			ArrayBufferType : "ArrayBuffer"
			DataViewType : "DataView"
			Int8ArrayType : "Int8Array"
			Int16ArrayType : "Int16Array"
			Int32ArrayType : "Int32Array"
			Uint8ArrayType : "Uint8Array"
			Uint16ArrayType : "Uint16Array"
			Uint32ArrayType : "Uint32Array"
			Uint8ClampedArrayType : "Uint8ClampedArray"
			Float32ArrayType : "Float32Array"
			Float64ArrayType : "Float64Array"
//			ArrayBufferType : "java.lang.Object"
//			DataViewType : "java.lang.Object"
//			Int8ArrayType : "java.lang.Object"
//			Int16ArrayType : "java.lang.Object"
//			Int32ArrayType : "java.lang.Object"
//			Uint8ArrayType : "java.lang.Object"
//			Uint16ArrayType : "java.lang.Object"
//			Uint32ArrayType : "java.lang.Object"
//			Uint8ClampedArrayType : "java.lang.Object"
//			Float32ArrayType : "java.lang.Object"
//			Float64ArrayType : "java.lang.Object"
			default : {/*logger.warn("Unknown type {}!", type);*/ null}
		};
		if (intermediate != null) {
			intermediate + type.typeSuffix.filter(ArrayTypeSuffix).map["[]"].join("")
		}
	}

	protected static def boolean namedProperty(Operation operation, Special special) {
		val operationType = operation.type;
		// TODO What about typedefs?
		operationType instanceof DOMStringType && operation.specials.contains(special);
	}

	protected static def boolean indexedProperty(Operation operation, Special special) {
		val operationType = operation.type;
		// TODO What about typedefs?
		if (operationType instanceof LongType) {
			return operationType.unsigned && operation.specials.contains(special);
		}
		return false;
	}

}