package com.rainerschuster.webidl.util

class NameUtil {

	static val reservedIdentifiers = #[
//		"prototype", // TODO prototype is no reserved identifier
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

}