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

import java.util.ArrayList
import java.util.List
import com.rainerschuster.webidl.webIDL.ExtendedAttribute
import com.rainerschuster.webidl.webIDL.Argument
import com.rainerschuster.webidl.webIDL.ExtendedAttributeNoArgs
import com.rainerschuster.webidl.webIDL.ExtendedAttributeArgList
import com.rainerschuster.webidl.webIDL.ExtendedAttributeIdent
import com.rainerschuster.webidl.webIDL.ExtendedAttributeNamedArgList
import com.rainerschuster.webidl.webIDL.ExtendedAttributeIdentList

// TODO ExtendedAttributeDottedName (from Java binding spec)
class ExtendedAttributeUtil {
//	static val Logger logger = LoggerFactory.getLogger(typeof(XtendExtendedAttributeUtil));

//	public static val String EA_ARRAY_CLASS = "ArrayClass";
	// TODO https://html.spec.whatwg.org/#cereactions
	// TODO https://html.spec.whatwg.org/#concept-custom-element-reaction
	public static val String EA_ALLOW_SHARED = "AllowShared";
	public static val String EA_CE_REACTIONS = "CEReactions";
	public static val String EA_CLAMP = "Clamp";
	public static val String EA_CONSTRUCTOR = "Constructor";
	public static val String EA_DEFAULT = "Default";
	public static val String EA_ENFORCE_RANGE = "EnforceRange";
	public static val String EA_EXPOSED = "Exposed";
	public static val String EA_IMPLICIT_THIS = "ImplicitThis";
	public static val String EA_GLOBAL = "Global";
//	public static val String EA_PRIMARY_GLOBAL = "PrimaryGlobal";
//	public static val String EA_LEGACY_ARRAY_CLASS = "LegacyArrayClass";
	public static val String EA_LEGACY_FACTORY_FUNCTION = "LegacyFactoryFunction";
	public static val String EA_LEGACY_LENIENT_SETTER = "LegacyLenientSetter";
	public static val String EA_LEGACY_LENIENT_THIS = "LegacyLenientThis";
	public static val String EA_LEGACY_NAMESPACE = "LegacyNamespace";
	public static val String EA_LEGACY_NO_INTERFACE_OBJECT = "LegacyNoInterfaceObject";
	public static val String EA_LEGACY_NULL_TO_EMPTY_STRING = "LegacyNullToEmptyString";
	public static val String EA_LEGACY_OVERRIDE_BUILT_INS = "LegacyOverrideBuiltIns";
	public static val String EA_LEGACY_TREAT_NON_OBJECT_AS_NULL = "LegacyTreatNonObjectAsNull";
	public static val String EA_LEGACY_UNENUMERABLE_NAMED_PROPERTIES = "LegacyUnenumerableNamedProperties";
	public static val String EA_LEGACY_UNFORGEABLE = "LegacyUnforgeable";
	public static val String EA_LEGACY_WINDOW_ALIAS = "LegacyWindowAlias";
	public static val String EA_NAMED_CONSTRUCTOR = "NamedConstructor";
	public static val String EA_NEW_OBJECT = "NewObject";
	public static val String EA_PUT_FORWARDS = "PutForwards";
//	public static val String EA_REPLACEABLE_NAMED_PROPERTIES = "ReplaceableNamedProperties";
	public static val String EA_REPLACEABLE = "Replaceable";
	public static val String EA_SAME_OBJECT = "SameObject";
	public static val String EA_SECURE_CONTEXT = "SecureContext";
	public static val String EA_TREAT_NON_CALLABLE_AS_NULL = "TreatNonCallableAsNull";
//	public static val String EA_TREAT_NON_OBJECT_AS_NULL = "TreatNonObjectAsNull";
	public static val String EA_TREAT_NULL_AS = "TreatNullAs";
	public static val String EA_UNSCOPABLE = "Unscopable";
	public static val String EA_WEB_GL_HANDLES_CONTEXT_LOSS= "WebGLHandlesContextLoss";
	
	// HTML Specification
	public static val String EA_HTML_CONSTRUCTOR = "HTMLConstructor";

	public static val KNOWN_EXTENDED_ATTRIBUTES = #[
//		EA_ARRAY_CLASS,
		EA_ALLOW_SHARED,
		EA_CE_REACTIONS,
		EA_CLAMP,
		EA_CONSTRUCTOR,
		EA_DEFAULT,
		EA_ENFORCE_RANGE,
		EA_EXPOSED,
		EA_IMPLICIT_THIS,
		EA_GLOBAL,
//		EA_PRIMARY_GLOBAL,
//		EA_LEGACY_ARRAY_CLASS,
		EA_LEGACY_FACTORY_FUNCTION,
		EA_LEGACY_LENIENT_SETTER,
		EA_LEGACY_LENIENT_THIS,
		EA_LEGACY_NAMESPACE,
		EA_LEGACY_NO_INTERFACE_OBJECT,
		EA_LEGACY_NULL_TO_EMPTY_STRING,
		EA_LEGACY_OVERRIDE_BUILT_INS,
		EA_LEGACY_TREAT_NON_OBJECT_AS_NULL,
		EA_LEGACY_UNENUMERABLE_NAMED_PROPERTIES,
		EA_LEGACY_UNFORGEABLE,
		EA_LEGACY_WINDOW_ALIAS,
		EA_NAMED_CONSTRUCTOR,
		EA_NEW_OBJECT,
		EA_PUT_FORWARDS,
//		EA_REPLACEABLE_NAMED_PROPERTIES,
		EA_REPLACEABLE,
		EA_SAME_OBJECT,
		EA_SECURE_CONTEXT,
		EA_TREAT_NON_CALLABLE_AS_NULL,
		EA_TREAT_NULL_AS,
		EA_LEGACY_UNFORGEABLE,
		EA_UNSCOPABLE,
		EA_WEB_GL_HANDLES_CONTEXT_LOSS,

		EA_HTML_CONSTRUCTOR
	];

	def static boolean containsExtendedAttribute(Iterable<ExtendedAttribute> input, String name) {
		for (ExtendedAttribute eAttr : input) {
			if (eAttr.nameRef.equals(name)) {
				return true;
			}
		}
		return false;
	}

	def static ExtendedAttribute getSingleExtendedAttribute(Iterable<ExtendedAttribute> input, String name) {
		val List<ExtendedAttribute> attributes = com.rainerschuster.webidl.util.ExtendedAttributeUtil.getAllExtendedAttributes(input, name).toList;
		if (attributes.nullOrEmpty) {
			// TODO throw NoResultException (see Query class)!
			return null;
		}
		if (attributes.size() == 1) {
			return attributes.get(0);
		} else {
			// TODO throw NonUniqueResultException (see Query class)!
			return null;
		}
	}

	def static getAllExtendedAttributes(Iterable<ExtendedAttribute> input, String name) {
		input.filter[it.nameRef == name]
	}

	def static boolean containsAllowShared(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_ALLOW_SHARED)
	}

	def static boolean containsClamp(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_CLAMP)
	}

	def static boolean containsConstructor(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_CONSTRUCTOR)
	}

	def static boolean containsEnforceRange(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_ENFORCE_RANGE)
	}

	def static boolean containsExposed(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_EXPOSED)
	}

	def static boolean containsImplicitThis(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_IMPLICIT_THIS)
	}

	def static boolean containsGlobal(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_GLOBAL)
	}

//	def static boolean containsPrimaryGlobal(Iterable<ExtendedAttribute> input) {
//		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_PRIMARY_GLOBAL)
//	}

//	def static boolean containsLegacyArrayClass(Iterable<ExtendedAttribute> input) {
//		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_LEGACY_ARRAY_CLASS)
//	}

	def static boolean containsLegacyLenientThis(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_LEGACY_LENIENT_THIS)
	}

	def static boolean containsNamedConstructor(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_NAMED_CONSTRUCTOR)
	}

	def static boolean containsNewObject(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_NEW_OBJECT)
	}

	def static boolean containsLegacyNoInterfaceObject(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_LEGACY_NO_INTERFACE_OBJECT)
	}

	def static boolean containsOverrideBuiltIns(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_LEGACY_OVERRIDE_BUILT_INS)
	}

	def static boolean containsPutForwards(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_PUT_FORWARDS)
	}

	def static boolean containsReplaceable(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_REPLACEABLE)
	}

	def static boolean containsSameObject(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_SAME_OBJECT)
	}

	def static boolean containsTreatNonCallableAsNull(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_TREAT_NON_CALLABLE_AS_NULL)
	}

	def static boolean containsLegacyTreatNonObjectAsNull(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_LEGACY_TREAT_NON_OBJECT_AS_NULL)
	}

	def static boolean containsTreatNullAs(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_TREAT_NULL_AS)
	}

	def static boolean containsLegacyUnforgeable(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_LEGACY_UNFORGEABLE)
	}

	def static boolean containsUnscopable(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_UNSCOPABLE)
	}

	def static List<Constructor> getConstructorValues(Iterable<ExtendedAttribute> input) {
		if (!containsNamedConstructor(input)) {
//			logger.warn("Input does not contain extended attribute 'Constructor'!");
			return null;
		}
		return getConstructorValuesUnchecked(input);
	}

	def static List<Constructor> getConstructorValuesUnchecked(Iterable<ExtendedAttribute> input) {
		return com.rainerschuster.webidl.util.ExtendedAttributeUtil.getAllExtendedAttributes(input, EA_CONSTRUCTOR).map[getConstructorValue(it)].toList;
	}

	def static Constructor getConstructorValue(ExtendedAttribute eAttr) {
		var Constructor constructor = null;

		switch eAttr {
			ExtendedAttributeNoArgs: {constructor = new Constructor(); constructor.arguments = new ArrayList<Argument>();}
			ExtendedAttributeArgList: {constructor = new Constructor(); constructor.arguments = eAttr.arguments;}
		}

		return constructor;
	}

	def static List<Constructor> getNamedConstructorValues(Iterable<ExtendedAttribute> input) {
		if (!containsNamedConstructor(input)) {
//			logger.warn("Input does not contain extended attribute 'NamedConstructor'!");
			return null;
		}
		return getNamedConstructorValuesUnchecked(input);
	}

	def static List<Constructor> getNamedConstructorValuesUnchecked(Iterable<ExtendedAttribute> input) {
		return com.rainerschuster.webidl.util.ExtendedAttributeUtil.getAllExtendedAttributes(input, EA_NAMED_CONSTRUCTOR).map[getNamedConstructorValue(it)].toList;
	}

	def static Constructor getNamedConstructorValue(ExtendedAttribute eAttr) {
		var Constructor constructor = null;

		switch eAttr {
			ExtendedAttributeIdent: {constructor = new Constructor(); constructor.arguments = new ArrayList<Argument>(); constructor.name = eAttr.nameRef;}
			ExtendedAttributeNamedArgList: {constructor = new Constructor(); constructor.arguments = eAttr.arguments; constructor.name = eAttr.nameRef;}
		}

		return constructor;
	}

	def static List<Constructor> getConstructors(Iterable<ExtendedAttribute> list) {
		val List<Constructor> result = new ArrayList<Constructor>();

		if (containsNamedConstructor(list)) {
			// FIXME .filterNull.toList is a bad workaround to omit NPEs after failed parsing
			val namedConstructors = getNamedConstructorValuesUnchecked(list).filterNull;
			result += namedConstructors;
		}

		if (containsConstructor(list)) {
			// FIXME .filterNull.toList is a bad workaround to omit NPEs after failed parsing
			val constructors = getConstructorValuesUnchecked(list).filterNull;
			result += constructors;
		}

		return result;
	}

	// 3.11. Extended attributes

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-xattr-no-arguments}
	 */
	def static takesNoArguments(ExtendedAttribute extendedAttribute) {
		extendedAttribute instanceof ExtendedAttributeNoArgs
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-xattr-argument-list}
	 */
	def static takesAnArgumentList(ExtendedAttribute extendedAttribute) {
		extendedAttribute instanceof ExtendedAttributeArgList
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-xattr-named-argument-list}
	 */
	def static takesANamedArgumentList(ExtendedAttribute extendedAttribute) {
		extendedAttribute instanceof ExtendedAttributeNamedArgList
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-xattr-identifier}
	 */
	def static takesAnIdentifier(ExtendedAttribute extendedAttribute) {
		extendedAttribute instanceof ExtendedAttributeIdent
	}

	/**
	 * {@link http://heycam.github.io/webidl/#dfn-xattr-identifier-list}
	 */
	def static takesAnIdentifierList(ExtendedAttribute extendedAttribute) {
		extendedAttribute instanceof ExtendedAttributeIdentList
	}

}