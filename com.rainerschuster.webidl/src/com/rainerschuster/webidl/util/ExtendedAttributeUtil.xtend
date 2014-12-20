package com.rainerschuster.webidl.util

import java.util.ArrayList
import java.util.List
import com.rainerschuster.webidl.webIDL.ExtendedAttribute
import com.rainerschuster.webidl.webIDL.Argument
import com.rainerschuster.webidl.webIDL.ExtendedAttributeNoArgs
import com.rainerschuster.webidl.webIDL.ExtendedAttributeArgList
import com.rainerschuster.webidl.webIDL.ExtendedAttributeIdent
import com.rainerschuster.webidl.webIDL.ExtendedAttributeNamedArgList

// TODO ExtendedAttributeDottedName (from Java binding spec)
class XtendExtendedAttributeUtil {
//	val static Logger logger = LoggerFactory.getLogger(typeof(XtendExtendedAttributeUtil));

	def static boolean contains(Iterable<ExtendedAttribute> input, String name) {
		for (ExtendedAttribute eAttr : input) {
			if (eAttr.nameRef.equals(name)) {
				return true;
			}
		}
		return false;
	}

	def static ExtendedAttribute getSingle(Iterable<ExtendedAttribute> input, String name) {
		val List<ExtendedAttribute> attributes = getAll(input, name);
		if (attributes == null) {
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

	def static List<ExtendedAttribute> getAll(Iterable<ExtendedAttribute> input, String name) {
		input.filter[it.nameRef.equals(name)].toList;
	}

	def static boolean containsArrayClass(Iterable<ExtendedAttribute> input) {
		contains(input, "ArrayClass");
	}

	def static boolean containsClamp(Iterable<ExtendedAttribute> input) {
		contains(input, "Clamp");
	}

	def static boolean containsConstructor(Iterable<ExtendedAttribute> input) {
		contains(input, "Constructor");
	}

	def static boolean containsEnforceRange(Iterable<ExtendedAttribute> input) {
		contains(input, "EnforceRange");
	}

	def static boolean containsImplicitThis(Iterable<ExtendedAttribute> input) {
		contains(input, "ImplicitThis");
	}

	def static boolean containsGlobal(Iterable<ExtendedAttribute> input) {
		contains(input, "Global");
	}

	def static boolean containsPrimaryGlobal(Iterable<ExtendedAttribute> input) {
		contains(input, "PrimaryGlobal");
	}

	def static boolean containsLenientThis(Iterable<ExtendedAttribute> input) {
		contains(input, "LenientThis");
	}

	def static boolean containsNamedConstructor(Iterable<ExtendedAttribute> input) {
		contains(input, "NamedConstructor");
	}

	def static boolean containsNewObject(Iterable<ExtendedAttribute> input) {
		contains(input, "NewObject");
	}

	def static boolean containsNoInterfaceObject(Iterable<ExtendedAttribute> input) {
		contains(input, "NoInterfaceObject");
	}

	def static boolean containsOverrideBuiltins(Iterable<ExtendedAttribute> input) {
		contains(input, "OverrideBuiltins");
	}

	def static boolean containsPutForwards(Iterable<ExtendedAttribute> input) {
		contains(input, "PutForwards");
	}

	def static boolean containsReplaceableNamedProperties(Iterable<ExtendedAttribute> input) {
		contains(input, "ReplaceableNamedProperties");
	}

	def static boolean containsReplaceable(Iterable<ExtendedAttribute> input) {
		contains(input, "Replaceable");
	}

	def static boolean containsSameObject(Iterable<ExtendedAttribute> input) {
		contains(input, "SameObject");
	}

	def static boolean containsTreatNonCallableAsNull(Iterable<ExtendedAttribute> input) {
		contains(input, "TreatNonCallableAsNull");
	}

	def static boolean containsTreatNonObjectAsNull(Iterable<ExtendedAttribute> input) {
		contains(input, "TreatNonObjectAsNull");
	}

	def static boolean containsTreatNullAs(Iterable<ExtendedAttribute> input) {
		contains(input, "TreatNullAs");
	}

	def static boolean containsUnforgeable(Iterable<ExtendedAttribute> input) {
		contains(input, "Unforgeable");
	}

	def static boolean containsUnscopeable(Iterable<ExtendedAttribute> input) {
		contains(input, "Unscopeable");
	}

	def static List<Constructor> getConstructorValues(Iterable<ExtendedAttribute> input) {
		if (!containsNamedConstructor(input)) {
//			logger.warn("Input does not contain extended attribute 'Constructor'!");
			return null;
		}
		return getConstructorValuesUnchecked(input);
	}

	def static List<Constructor> getConstructorValuesUnchecked(Iterable<ExtendedAttribute> input) {
		return getAll(input, "Constructor").map[getConstructorValue(it)].toList;
	}

	def static Constructor getConstructorValue(ExtendedAttribute eAttr) {
		var Constructor constructor = null;

		switch (eAttr) {
			ExtendedAttributeNoArgs: {constructor = new Constructor(); constructor.argumentList = new ArrayList<Argument>();}
			ExtendedAttributeArgList: {constructor = new Constructor(); constructor.argumentList = eAttr.arguments;}
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
		return getAll(input, "NamedConstructor").map[getNamedConstructorValue(it)].toList;
	}

	def static Constructor getNamedConstructorValue(ExtendedAttribute eAttr) {
		var Constructor constructor = null;

		switch (eAttr) {
			ExtendedAttributeIdent: {constructor = new Constructor(); constructor.argumentList = new ArrayList<Argument>(); constructor.name = eAttr.nameRef;}
			ExtendedAttributeNamedArgList: {constructor = new Constructor(); constructor.argumentList = eAttr.arguments; constructor.name = eAttr.nameRef;}
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

}