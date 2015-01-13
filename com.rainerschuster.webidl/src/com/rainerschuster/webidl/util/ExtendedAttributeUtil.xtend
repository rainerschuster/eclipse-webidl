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

	public static val String EA_ARRAY_CLASS = "ArrayClass";
	public static val String EA_CLAMP = "Clamp";
	public static val String EA_CONSTRUCTOR = "Constructor";
	public static val String EA_ENFORCE_RANGE = "EnforceRange";
	public static val String EA_EXPOSED = "Exposed";
	public static val String EA_IMPLICIT_THIS = "ImplicitThis";
	public static val String EA_GLOBAL = "Global";
	public static val String EA_PRIMARY_GLOBAL = "PrimaryGlobal";
	public static val String EA_LENIENT_THIS = "LenientThis";
	public static val String EA_NAMED_CONSTRUCTOR = "NamedConstructor";
	public static val String EA_NEW_OBJECT = "NewObject";
	public static val String EA_NO_INTERFACE_OBJECT = "NoInterfaceObject";
	public static val String EA_OVERRIDE_BUILTINS = "OverrideBuiltins";
	public static val String EA_PUT_FORWARDS = "PutForwards";
//	public static val String EA_REPLACEABLE_NAMED_PROPERTIES = "ReplaceableNamedProperties";
	public static val String EA_REPLACEABLE = "Replaceable";
	public static val String EA_SAME_OBJECT = "SameObject";
	public static val String EA_TREAT_NON_CALLABLE_AS_NULL = "TreatNonCallableAsNull";
	public static val String EA_TREAT_NON_OBJECT_AS_NULL = "TreatNonObjectAsNull";
	public static val String EA_TREAT_NULL_AS = "TreatNullAs";
	public static val String EA_UNFORGEABLE = "Unforgeable";
	public static val String EA_UNSCOPEABLE = "Unscopeable";

	public static val KNOWN_EXTENDED_ATTRIBUTES = #[
		EA_ARRAY_CLASS,
		EA_CLAMP,
		EA_CONSTRUCTOR,
		EA_ENFORCE_RANGE,
		EA_EXPOSED,
		EA_IMPLICIT_THIS,
		EA_GLOBAL,
		EA_PRIMARY_GLOBAL,
		EA_LENIENT_THIS,
		EA_NAMED_CONSTRUCTOR,
		EA_NEW_OBJECT,
		EA_NO_INTERFACE_OBJECT,
		EA_OVERRIDE_BUILTINS,
		EA_PUT_FORWARDS,
//		EA_REPLACEABLE_NAMED_PROPERTIES,
		EA_REPLACEABLE,
		EA_SAME_OBJECT,
		EA_TREAT_NON_CALLABLE_AS_NULL,
		EA_TREAT_NON_OBJECT_AS_NULL,
		EA_TREAT_NULL_AS,
		EA_UNFORGEABLE,
		EA_UNSCOPEABLE
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
		input.filter[it.nameRef.equals(name)]
	}

	def static boolean containsArrayClass(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_ARRAY_CLASS)
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

	def static boolean containsPrimaryGlobal(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_PRIMARY_GLOBAL)
	}

	def static boolean containsLenientThis(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_LENIENT_THIS)
	}

	def static boolean containsNamedConstructor(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_NAMED_CONSTRUCTOR)
	}

	def static boolean containsNewObject(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_NEW_OBJECT)
	}

	def static boolean containsNoInterfaceObject(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_NO_INTERFACE_OBJECT)
	}

	def static boolean containsOverrideBuiltins(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_OVERRIDE_BUILTINS)
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

	def static boolean containsTreatNonObjectAsNull(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_TREAT_NON_OBJECT_AS_NULL)
	}

	def static boolean containsTreatNullAs(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_TREAT_NULL_AS)
	}

	def static boolean containsUnforgeable(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_UNFORGEABLE)
	}

	def static boolean containsUnscopeable(Iterable<ExtendedAttribute> input) {
		com.rainerschuster.webidl.util.ExtendedAttributeUtil.containsExtendedAttribute(input, EA_UNSCOPEABLE)
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

		switch (eAttr) {
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

		switch (eAttr) {
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
			result.addAll(namedConstructors);
		}

		if (containsConstructor(list)) {
			// FIXME .filterNull.toList is a bad workaround to omit NPEs after failed parsing
			val constructors = getConstructorValuesUnchecked(list).filterNull;
			result.addAll(constructors);
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