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
				result.add(currentInterface);
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

	// See 3.2.2. Attributes

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-regular-attribute}
	 */
	static def boolean regularAttribute(Attribute attribute) {
		!attribute.static
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-static-attribute}
	 */
	static def boolean staticAttribute(Attribute attribute) {
		attribute.static
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
		result.addAll(bs);
		newInterfaces.addAll(bs);
		// each interface that a consequential interface of A inherits from
		val inherit = bs.map[it.inherits].filter(typeof(Interface)).filter[!result.contains(it)];
		result.addAll(inherit);
		newInterfaces.addAll(inherit);
		// each interface D where the IDL states that C implements D, where C is a consequential interface of A
		newInterfaces.forEach[
			it.consequentialInterfaces(result)
		];
	}

	// See 3.10.27. Union types
	/**
	 * {@link http://heycam.github.io/webidl/#dfn-flattened-union-member-types}
	 */
	static def Set<Type> flattenedMemberTypes(UnionType unionType) {
		val Set<Type> s = #{};
		for (u : unionType.unionMemberTypes) {
			if (u instanceof UnionType) {
				s.addAll(flattenedMemberTypes(u));
			} else {
				s.add(u);
			}
		}
		return s;
	}



	// Java specific methods, see also http://heycam.github.io/webidl/java.html

	def static String toJavaType(ReturnType type) {
		switch (type) {
			VoidType: "void"
			Type: type.toJavaType
		}
	}

	def static String toJavaType(Type type) {
		switch type {
			ReferenceType : {
//				logger.debug("ReferenceType");
				var Definition resolved = type.typeRef;
				if (resolved != null) {
					switch (resolved) {
						Interface : {/*logger.debug("InterfaceType");*/ return resolved.name}
						Dictionary : {/*logger.debug("DictionaryType"); */return "java.util.HashMap<java.lang.String,java.lang.Object>"}
						Enum : return "java.lang.String"
						// TODO implement CallbackFunctionType!
						CallbackFunction : {/*logger.debug("CallbackFunctionType");*/ return resolved.name}
						Typedef : {/*logger.debug("Typedef");*/ return resolved.type.toJavaType}
					}
				} else {
					return null
				}
			} // type.name
			AnyType: return "java.lang.Object"
			VoidType : return "void"
			BooleanType : return "boolean"
			ByteType : return "byte"
			OctetType : return "byte"
			ShortType : return "short"
//			UnsignedShortType : return "short"
			LongType : return "int"
//			UnsignedLongType : return "int"
			LongLongType : return "long"
//			UnsignedLongLongType : return "long"
			FloatType : return "float"
//			UnrestrictedFloatType : return "float"
			DoubleType : return "double"
//			UnrestrictedDoubleType : return "double"
			DOMStringType : return "java.lang.String"
			ObjectType : return "java.lang.Object"
			// TODO implement InterfaceType!
			// TODO Corresponding Java escaped identifier
//			InterfaceSymbol : {/*logger.debug("InterfaceType");*/ return type.name}
//			DictionarySymbol : {/*logger.debug("DictionaryType"); */return "java.util.HashMap<java.lang.String,java.lang.Object>"}
//			EnumerationSymbol : return "java.lang.String"
//			// TODO implement CallbackFunctionType!
//			CallbackFunctionSymbol : {/*logger.debug("CallbackFunctionType");*/ return type.name}
//			NullableType : {
//				val Type subType = type.innerType;
//				switch(subType) {
//					BooleanType : return "java.lang.Boolean"
//					ByteType : return "java.lang.Byte"
//					OctetType : return "java.lang.Byte"
//					ShortType : return "java.lang.Short"
////					UnsignedShortType : return "java.lang.Short"
//					LongType : return "java.lang.Integer"
////					UnsignedLongType : return "java.lang.Integer"
//					LongLongType : return "java.lang.Long"
////					UnsignedLongLongType : return "java.lang.Long"
//					FloatType : return "java.lang.Float"
////					UnrestrictedFloatType : return "java.lang.Float"
//					DoubleType : return "java.lang.Double"
////					UnrestrictedDoubleType : return "java.lang.Double"
//					DOMStringType : return "java.lang.String"
//					ByteStringType : return "String" // FIXME This is not defined!
//					USVStringType : return "String" // FIXME This is not defined!
//					default : {
//						val String subTypeString = toJavaType(subType);
//						if (subTypeString != null) {
//							return subTypeString;
//						}
//						return null;
//					}
//				}
//			}
			SequenceType : {
//				logger.debug("SequenceType");
				val Type subType = type.type;
				val String subTypeString = toJavaType(subType);
				if (subTypeString != null) {
					return subTypeString + "[]";
				}
				return null;
			}
//			ArrayType : {
////				logger.debug("ArrayType");
//				val Type subType = toType(type.elementType);
////				val Type subType = type.elementType;
//				if (subType instanceof PrimitiveType) {
//					return "org.w3c.dom." + subType.getName() + "Array";
//				}
//				val String subTypeString = toJavaType(subType);
//				if (subTypeString != null) {
//					return "org.w3c.dom.ObjectArray<" + subTypeString + ">";
//				}
//				return null;
//			}
			PromiseType : {
//				logger.debug("PromiseType");
//				val Type subType = type.elementType;
//				val String subTypeString = toJavaType(subType, resolver);
				return "java.lang.Object"
			}
			UnionType : {/*logger.debug("UnionType");*/ return "java.lang.Object"}
			DOMExceptionType : {/*logger.debug("DOMExceptionType");*/ return "java.lang.Object"}
			DateType : return "java.util.Date"
			ByteStringType : return "String"
			USVStringType : return "String"
			ArrayBufferType : return "ArrayBuffer"
			DataViewType : return "DataView"
			Int8ArrayType : return "Int8Array"
			Int16ArrayType : return "Int16Array"
			Int32ArrayType : return "Int32Array"
			Uint8ArrayType : return "Uint8Array"
			Uint16ArrayType : return "Uint16Array"
			Uint32ArrayType : return "Uint32Array"
			Uint8ClampedArrayType : return "Uint8ClampedArray"
			Float32ArrayType : return "Float32Array"
			Float64ArrayType : return "Float64Array"
//			ArrayBufferType : return "java.lang.Object"
//			DataViewType : return "java.lang.Object"
//			Int8ArrayType : return "java.lang.Object"
//			Int16ArrayType : return "java.lang.Object"
//			Int32ArrayType : return "java.lang.Object"
//			Uint8ArrayType : return "java.lang.Object"
//			Uint16ArrayType : return "java.lang.Object"
//			Uint32ArrayType : return "java.lang.Object"
//			Uint8ClampedArrayType : return "java.lang.Object"
//			Float32ArrayType : return "java.lang.Object"
//			Float64ArrayType : return "java.lang.Object"
			default : {/*logger.warn("Unknown type {}!", type);*/ return null}
		}
	}

	// TODO Consider moving these to OperationUtil

	// See 3.2.3. Operations

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-variadic}
	 */
	static def boolean variadic(Operation operation) {
		operation.arguments.last.ellipsis
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-optional-argument}
	 */
	static def boolean optionalArgument(Argument argument) {
		argument.optional
	}

	// See 3.2.4. Special operations

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