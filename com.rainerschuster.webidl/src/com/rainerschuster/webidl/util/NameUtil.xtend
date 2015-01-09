package com.rainerschuster.webidl.util

import com.rainerschuster.webidl.webIDL.InterfaceMember
import com.rainerschuster.webidl.webIDL.Definition
import com.rainerschuster.webidl.webIDL.Interface
import com.rainerschuster.webidl.webIDL.Dictionary
import com.rainerschuster.webidl.webIDL.CallbackFunction
import com.rainerschuster.webidl.webIDL.Typedef
import com.rainerschuster.webidl.webIDL.Const
import com.rainerschuster.webidl.webIDL.Operation
import com.rainerschuster.webidl.webIDL.Attribute

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
		switch(definition) {
			Interface: definition.name
			Dictionary: definition.name
			com.rainerschuster.webidl.webIDL.Enum: definition.name
			CallbackFunction: definition.name
			Typedef: definition.name
		}
	}

	def static interfaceMemberToName(InterfaceMember interfaceMember) {
		switch(interfaceMember) {
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

}