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
import com.rainerschuster.webidl.webIDL.ArrayTypeSuffix
import com.rainerschuster.webidl.webIDL.Attribute
import com.rainerschuster.webidl.webIDL.BooleanType
import com.rainerschuster.webidl.webIDL.ByteStringType
import com.rainerschuster.webidl.webIDL.ByteType
import com.rainerschuster.webidl.webIDL.CallbackFunction
import com.rainerschuster.webidl.webIDL.Const
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
import com.rainerschuster.webidl.webIDL.Int16ArrayType
import com.rainerschuster.webidl.webIDL.Int32ArrayType
import com.rainerschuster.webidl.webIDL.Int8ArrayType
import com.rainerschuster.webidl.webIDL.Interface
import com.rainerschuster.webidl.webIDL.LongLongType
import com.rainerschuster.webidl.webIDL.LongType
import com.rainerschuster.webidl.webIDL.NullableTypeSuffix
import com.rainerschuster.webidl.webIDL.ObjectType
import com.rainerschuster.webidl.webIDL.OctetType
import com.rainerschuster.webidl.webIDL.Operation
import com.rainerschuster.webidl.webIDL.PromiseType
import com.rainerschuster.webidl.webIDL.RegExpType
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
import com.rainerschuster.webidl.webIDL.InterfaceMember
import com.rainerschuster.webidl.webIDL.ReturnType
import com.rainerschuster.webidl.webIDL.ReferenceType

class NameUtil {

	static val reservedIdentifiers = #[
		"constructor",
		"toString",
		"toJSON"
	];

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-reserved-identifier}
	 */
	def static boolean isReservedIdentifier(String identifier) {
		reservedIdentifiers.contains(identifier) || identifier.startsWith("_")
	}

	/**
	 * {@link http://heycam.github.io/webidl/java.html#dfn-java-escaped}
	 */
	def static String getEscapedJavaName(String name) {
		if (isJavaReservedWord(name)) {
			"_" + name
		} else {
			name
		}
	}

	static val javaReservedWords = #[
		"abstract",
		"assert",
		"boolean",
		"break",
		"byte",
		"case",
		"catch",
		"char",
		"class",
		"const",
		"continue",
		"default",
//		"delete", // TODO delete is no reserved word in Java but in JavaScript!
		"do",
		"double",
		"else",
		"enum",
		"extends",
		"final",
		"finally",
		"float",
		"for",
		"goto",
		"if",
		"implements",
		"import",
		"instanceof",
		"int",
		"interface",
		"long",
		"native",
		"new",
		"package",
		"private",
		"protected",
		"public",
		"return",
		"short",
		"static",
		"strictfp",
		"super",
		"switch",
		"synchronized",
		"this",
		"throw",
		"throws",
		"transient",
		"try",
		"void",
		"volatile",
		"while"
	];

	def static boolean isJavaReservedWord(String word) {
		javaReservedWords.contains(word)
	}



	def static definitionToName(Definition definition) {
		switch definition {
			Interface: definition.name
			Dictionary: definition.name
			com.rainerschuster.webidl.webIDL.Enum: definition.name
			CallbackFunction: definition.name
			Typedef: definition.name
		}
	}

	def static interfaceMemberToName(InterfaceMember interfaceMember) {
		switch interfaceMember {
			Const: interfaceMember.name
			Operation: interfaceMember.name
//			Serializer: interfaceMember.name
//			Stringifier: interfaceMember.name
//			StaticMember: interfaceMember.name
//			Iterable_: interfaceMember.name
			Attribute: interfaceMember.name
//			Maplike: interfaceMember.name
//			Setlike: interfaceMember.name
		}
	}


	def static String typeName(ReturnType type) {
		switch type {
			VoidType: 'Void' // TODO void does not have a typeName!
			Type: typeName(type)
			default: null
		}
	}

	def static String typeName(Definition type) {
		switch type {
			 Interface: type.name
			 Dictionary: type.name
			 Enum: type.name
			 CallbackFunction: type.name
			 Typedef: type.name // TODO This may not be specified!
			 default: null
		}
	}

	def static String typeName(Type type) {
		typeNameWithoutSuffix(type) + type.typeSuffix.map[
			switch it {
				NullableTypeSuffix: 'OrNull'
				ArrayTypeSuffix: 'Array'
			}
		].join
	}

//	def static String typeName(ConstType type) {
//		typeNameWithoutSuffix(type) + type.typeSuffix.map[
//			switch it {
//				NullableTypeSuffix: 'OrNull'
//				ArrayTypeSuffix: 'Array'
//			}
//		].join
//	}

//	def static String typeNameWithoutSuffix(ConstType type) {
//		switch type {
////			PrimitiveType: typeNameWithoutSuffix(type as PrimitiveType)
//			// Reference type
////			NonAnyType: typeName(type.typeRef)
//			ReferenceType: typeName(type.typeRef)
//
//			default: null
//		}
//	}

	private def static String typeNameWithoutSuffix(Type type) {
		switch type {
			AnyType: 'Any'
			BooleanType: 'Boolean'
			ByteType: 'Byte'
			OctetType: 'Octet'
			ShortType: {if (type.unsigned) 'UnsignedShort' else 'Short'}
			LongType: {if (type.unsigned) 'UnsignedLong' else 'Long'}
			LongLongType: {if (type.unsigned) 'UnsignedLongLong' else 'LongLong'}
			FloatType: {if (type.unrestricted) 'UnrestrictedFloat' else 'Float'}
			DoubleType: {if (type.unrestricted) 'UnrestrictedDouble' else 'Double'}
			DOMStringType: 'String'
			ByteStringType: 'ByteString'
			USVStringType: 'USVString'
			ObjectType: 'Object'
			SequenceType: typeName(type.type as Type) + 'Sequence'
			PromiseType: typeName(type.type as /*Return*/Type) + 'Promise'
			UnionType: type.unionMemberTypes.map[typeName(it)].join('Or')
			DateType: 'Date'
			RegExpType: 'RegExp'
			DOMExceptionType: 'DOMException'
			ArrayBufferType : 'ArrayBuffer'
			DataViewType : 'DataView'
			Int8ArrayType : 'Int8Array'
			Int16ArrayType : 'Int16Array'
			Int32ArrayType : 'Int32Array'
			Uint8ArrayType : 'Uint8Array'
			Uint16ArrayType : 'Uint16Array'
			Uint32ArrayType : 'Uint32Array'
			Uint8ClampedArrayType : 'Uint8ClampedArray'
			Float32ArrayType : 'Float32Array'
			Float64ArrayType : 'Float64Array'

			// Reference type
//			NonAnyType: typeName(type.typeRef)
			ReferenceType: typeName(type.typeRef)

			default: null
		}
	}
}