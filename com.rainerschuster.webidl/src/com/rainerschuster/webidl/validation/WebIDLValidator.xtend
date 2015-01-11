/*
 * generated by Xtext
 */
package com.rainerschuster.webidl.validation

import com.rainerschuster.webidl.webIDL.Argument
import com.rainerschuster.webidl.webIDL.Attribute
import com.rainerschuster.webidl.webIDL.CallbackFunction
import com.rainerschuster.webidl.webIDL.Const
import com.rainerschuster.webidl.webIDL.Definition
import com.rainerschuster.webidl.webIDL.Definitions
import com.rainerschuster.webidl.webIDL.Dictionary
import com.rainerschuster.webidl.webIDL.Enum
import com.rainerschuster.webidl.webIDL.ExtendedAttribute
import com.rainerschuster.webidl.webIDL.ExtendedDefinition
import com.rainerschuster.webidl.webIDL.ExtendedInterfaceMember
import com.rainerschuster.webidl.webIDL.ImplementsStatement
import com.rainerschuster.webidl.webIDL.Interface
import com.rainerschuster.webidl.webIDL.Iterable_
import com.rainerschuster.webidl.webIDL.Operation
import com.rainerschuster.webidl.webIDL.PartialInterface
import com.rainerschuster.webidl.webIDL.PrimitiveType
import com.rainerschuster.webidl.webIDL.PromiseType
import com.rainerschuster.webidl.webIDL.ReferenceType
import com.rainerschuster.webidl.webIDL.SequenceType
import com.rainerschuster.webidl.webIDL.Special
import com.rainerschuster.webidl.webIDL.Typedef
import com.rainerschuster.webidl.webIDL.UnionType
import com.rainerschuster.webidl.webIDL.WebIDLPackage
import java.util.List
import java.util.Set
import org.eclipse.emf.ecore.EObject
import org.eclipse.emf.ecore.EStructuralFeature
import org.eclipse.xtext.validation.Check

import static extension com.rainerschuster.webidl.util.NameUtil.*
import static extension com.rainerschuster.webidl.util.ExtendedAttributeUtil.*
import static extension com.rainerschuster.webidl.util.TypeUtil.*
import com.rainerschuster.webidl.webIDL.NullableTypeSuffix
import com.rainerschuster.webidl.webIDL.Type
import com.rainerschuster.webidl.webIDL.DictionaryMember
import com.rainerschuster.webidl.webIDL.Maplike
import com.rainerschuster.webidl.webIDL.Setlike

/**
 * Custom validation rules. 
 *
 * see http://www.eclipse.org/Xtext/documentation.html#validation
 */
class WebIDLValidator extends AbstractWebIDLValidator {

//  public static val INVALID_NAME = 'invalidName'
//
//	@Check
//	def checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.name.charAt(0))) {
//			warning('Name should start with a capital', 
//					MyDslPackage.Literals.GREETING__NAME,
//					INVALID_NAME)
//		}
//	}

	// See 3.1. Names

	// TODO See org.eclipse.xtext.validation.NamesAreUniqueValidationHelper
	@Check
	def checkUniqueNames(Definitions definitions) {
		for (definition : definitions.definitions.map[it.def]) {
			// TODO Only interface, dictionary, enumeration, callback function and typedef should be checked!
			val definitionName = definition.definitionToName();
			if (definitionName != null) {
				checkUniqueNames(definitions, definition);
			}
		}
	}

	private def checkUniqueNames(Definitions definitions, Definition definition) {
		val String definitionName = definition.definitionToName();
		val duplicateList = definitions.definitions.map[it.def].filter[it != definition && definitionName == it.definitionToName()];
		duplicateList.forEach[
			val feature = it.definitionToFeature();
			error('Duplicate definition "' + it.definitionToName() + '"', 
					it,
					feature)
		];
	}

	// See 3.2. Interfaces

	@Check
	def checkInheritedInterfaceCycle(Interface iface) {
		val inheritedInterfaces = iface.inheritedInterfaces();
		if (inheritedInterfaces == null) {
			error('An interface must not be declared such that its inheritance hierarchy has a cycle', 
					iface,
					WebIDLPackage.Literals.INTERFACE__INHERITS)
		} else if (inheritedInterfaces.contains(iface)) {
			error('An interface must not inherit from itself', 
					iface,
					WebIDLPackage.Literals.INTERFACE__INHERITS)
		}
	}

	@Check
	def checkInheritedInterfacesCallback(Interface iface) {
		val inheritedInterfaces = iface.inheritedInterfaces();
		if (!inheritedInterfaces.nullOrEmpty) {
			val checkInvalid = inheritedInterfaces.exists[it.callback != iface.callback];
			if (checkInvalid) {
				if (iface.callback) {
					error('Callback interfaces must not inherit from any non-callback interfaces', 
							iface,
							WebIDLPackage.Literals.INTERFACE__INHERITS)
				} else {
					error('Non-callback interfaces must not inherit from any callback interfaces', 
							iface,
							WebIDLPackage.Literals.INTERFACE__INHERITS)
				}
			}
		}
	}

	@Check
	def checkExtendedAttributeOnInterface(Interface iface) {
		val allowedExtendedAttributes = #[EA_ARRAY_CLASS, EA_CONSTRUCTOR, EA_EXPOSED, EA_GLOBAL, EA_IMPLICIT_THIS, EA_NAMED_CONSTRUCTOR, EA_NO_INTERFACE_OBJECT, EA_OVERRIDE_BUILTINS, EA_PRIMARY_GLOBAL, EA_UNFORGEABLE];
		val containerDefinition = iface.eContainer as ExtendedDefinition;
		val extendedAttributes = containerDefinition.eal.extendedAttributes;
		for (ExtendedAttribute extendedAttribute : extendedAttributes) {
			if (KNOWN_EXTENDED_ATTRIBUTES.contains(extendedAttribute.nameRef) && !allowedExtendedAttributes.contains(extendedAttribute.nameRef)) {
				error('The extended attribute "' + extendedAttribute.nameRef + '" must not be specified on interface definitions', 
						extendedAttribute,
						WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
			}
		}
	}

	@Check
	def checkExtendedAttributeOnPartialInterface(PartialInterface partialInterface) {
		val forbiddenExtendedAttributes = #[EA_ARRAY_CLASS, EA_CONSTRUCTOR, EA_IMPLICIT_THIS, EA_NAMED_CONSTRUCTOR, EA_NO_INTERFACE_OBJECT];
		val containerDefinition = partialInterface.eContainer as ExtendedDefinition;
		val extendedAttributes = containerDefinition.eal.extendedAttributes;
		for (String extendedAttribute : forbiddenExtendedAttributes) {
			if (extendedAttributes.containsExtendedAttribute(extendedAttribute)) {
				extendedAttributes.getAllExtendedAttributes(extendedAttribute).forEach[
					error('The extended attribute "' + it.nameRef + '" must not be specified on partial interface definitions', 
							it,
							WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
				];
			}
		}
	}

	// See 3.2.1. Constants

	@Check
	def checkConstantName(Const constant) {
		if (constant.name == "prototype") {
			error('The identifier of a constant must not be “prototype”', 
					constant,
					WebIDLPackage.Literals.CONST__NAME)
		}
	}

	@Check
	def checkConstantType(Const constant) {
		// TODO What about arrays?
		val constantType = constant.type;
		if (!(constantType instanceof PrimitiveType || (constantType instanceof ReferenceType && resolveType(constantType as ReferenceType) instanceof PrimitiveType))) {
			error('The type of a constant must not be any type other than a primitive type or typedef with primitive type',
					constant,
					WebIDLPackage.Literals.CONST__NAME)
		}
	}

	// See 3.2.2. Attributes

	@Check
	def checkAttributeName(Attribute attribute) {
		if (attribute.static && attribute.name == "prototype") {
			error('The identifier of a static attribute must not be “prototype”', 
					attribute,
					WebIDLPackage.Literals.ATTRIBUTE__NAME)
		}
	}

	@Check
	def checkAttributeType(Attribute attribute) {
		// TODO this check is not exact enough (see specification, esp. resolved typedefs)!
		val attributeType = attribute.type;
		if (attributeType instanceof ReferenceType) {
			val Definition ref = attributeType.typeRef;
			if (ref instanceof SequenceType) {
				error('The type of an attribute must not be a sequence type', 
						attribute,
						WebIDLPackage.Literals.ATTRIBUTE__NAME)
			}
			if (ref instanceof Dictionary) {
				error('The type of an attribute must not be a dictionary', 
						attribute,
						WebIDLPackage.Literals.ATTRIBUTE__NAME)
			}
			if (ref instanceof UnionType) {
				if (ref.flattenedMemberTypes.exists[it instanceof SequenceType || it instanceof Dictionary]) {
					error('The type of an attribute must not be a union type that has a nullable or non-nullable sequence type or dictionary as one of its flattened member types', 
							attribute,
							WebIDLPackage.Literals.ATTRIBUTE__NAME)
				}
			}
		}
	}

	@Check
	def checkAttributeInheritGetter(Attribute attribute) {
		if (attribute.inheritsGetter) {
			if (attribute.readOnly || attribute.staticAttribute)
				error('inherit must not appear on a read only attribute or a static attribute', 
						attribute,
						WebIDLPackage.Literals.ATTRIBUTE__INHERIT)
		}
	}

	@Check
	def checkAttributeInheritedGetterTyped(Attribute attribute) {
		if (attribute.inheritsGetter) {
			val inheritedGetter = attribute.inheritedGetter;
			// TODO resolve? implement equals?
			if (attribute.type.typeName != inheritedGetter.type.typeName)
				error('The attribute whose getter is being inherited must be of the same type as the inheriting attribute', 
						attribute,
						WebIDLPackage.Literals.ATTRIBUTE__INHERIT)
		}
	}

	// TODO Refactor this once Attribute is refactored (static inlined etc.)
	@Check
	def checkExtendedAttributeOnAttribute(Attribute attribute) {
//		val allowedExtendedAttributesStatic = #[EA_CLAMP, EA_ENFORCE_RANGE, EA_EXPOSED, EA_SAME_OBJECT, EA_TREAT_NULL_AS];
		val allowedExtendedAttributesRegular = #[EA_CLAMP, EA_ENFORCE_RANGE, EA_EXPOSED, EA_SAME_OBJECT, EA_TREAT_NULL_AS, EA_LENIENT_THIS, EA_PUT_FORWARDS, EA_REPLACEABLE, EA_UNFORGEABLE, EA_UNSCOPEABLE];
		val containerDefinition = attribute.eContainer;
		if (containerDefinition instanceof ExtendedInterfaceMember) {
			val extendedAttributes = containerDefinition.eal.extendedAttributes;
			for (ExtendedAttribute extendedAttribute : extendedAttributes) {
				if (KNOWN_EXTENDED_ATTRIBUTES.contains(extendedAttribute.nameRef) && !allowedExtendedAttributesRegular.contains(extendedAttribute.nameRef)) {
					error('The extended attribute "' + extendedAttribute.nameRef + '" must not be specified on attributes', 
							extendedAttribute,
							WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
				}
			}
		}
	}

	// See 3.2.3. Operations

	@Check
	def checkSpecialOperationNameNotEmpty(Operation operation) {
		if (operation.name.nullOrEmpty && operation.specials.empty) {
			error('If an operation has no identifier, then it must be declared to be a special operation using one of the special keywords', 
					operation,
					WebIDLPackage.Literals.OPERATION__NAME)
		}
	}

	@Check
	def checkOperationName(Operation operation) {
		if (operation.static && operation.name == "prototype") {
			error('The identifier of a static operation must not be “prototype”', 
					operation,
					WebIDLPackage.Literals.OPERATION__NAME)
		}
	}

	def checkArgumentEllipsisFinal(List<Argument> arguments, EObject source, EStructuralFeature feature) {
		arguments.filter[it.ellipsis].forEach[
			if (it != arguments.last) {
				error('An argument must not be declared with the ... token unless it is the final argument in the operation’s argument list', 
						source,
						feature)
			}
		]
	}

//	@Check
//	def checkArgumentEllipsisFinal(CallbackRest callback) {
//		checkArgumentEllipsisFinal(callback.arguments, callback, WebIDLPackage.Literals.CALLBACK__ARGUMENTS)
//	}

	@Check
	def checkArgumentEllipsisFinal(Operation operation) {
		// TODO This marks the first argument (although this one is not the problem)!
		checkArgumentEllipsisFinal(operation.arguments, operation, WebIDLPackage.Literals.OPERATION__ARGUMENTS)
	}

	@Check
	def checkExtendedAttributeOnOperation(Operation operation) {
		val allowedExtendedAttributes = #[EA_EXPOSED, EA_NEW_OBJECT, EA_TREAT_NULL_AS, EA_UNFORGEABLE, EA_UNSCOPEABLE];
		val containerDefinition = operation.eContainer;
		if (containerDefinition instanceof ExtendedInterfaceMember) {
			val extendedAttributes = containerDefinition.eal.extendedAttributes;
			for (ExtendedAttribute extendedAttribute : extendedAttributes) {
				if (KNOWN_EXTENDED_ATTRIBUTES.contains(extendedAttribute.nameRef) && !allowedExtendedAttributes.contains(extendedAttribute.nameRef)) {
					error('The extended attribute "' + extendedAttribute.nameRef + '" must not be specified on operations', 
							extendedAttribute,
							WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
				}
			}
		}
	}

	// TODO Is this also true for other arguments (like callback, constructor etc.)?
	@Check
	def checkExtendedAttributeOnOperationArguments(Operation operation) {
		val allowedExtendedAttributes = #[EA_CLAMP, EA_ENFORCE_RANGE, EA_TREAT_NULL_AS];
		val containerDefinition = operation.eContainer;
		if (containerDefinition instanceof ExtendedInterfaceMember) {
			for (argument : operation.arguments) {
				val extendedAttributes = argument.eal.extendedAttributes;
				for (ExtendedAttribute extendedAttribute : extendedAttributes) {
					if (KNOWN_EXTENDED_ATTRIBUTES.contains(extendedAttribute.nameRef) && !allowedExtendedAttributes.contains(extendedAttribute.nameRef)) {
						error('The extended attribute "' + extendedAttribute.nameRef + '" must not be specified on operation arguments', 
								extendedAttribute,
								WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
					}
				}
			}
		}
	}

	// See 3.2.4. Special operations

	@Check
	def checkSpecialKeywordOnce(Operation operation) {
		for (Special special : operation.specials) {
			if (operation.specials.filter[it == special].length >= 2) {
				// TODO This marks the first special (although this one is not the problem)!
				error('A given special keyword must not appear twice on an operation', 
						operation,
						WebIDLPackage.Literals.OPERATION__SPECIALS)
			}
		}
	}

	@Check
	def checkSpecialOperationsNotVariadicNorOptionalArguments(Operation operation) {
		// FIXME is this also true for legacy callers?
		// => Added this exception since HTML specification uses "legacycaller any (any... arguments);"
		if (!operation.specials.isNullOrEmpty && operation.specials.exists[it != Special.LEGACYCALLER]) {
			if (operation.variadic) {
				error('Special operations declared using operations must not be variadic nor have any optional arguments', 
						operation,
						WebIDLPackage.Literals.OPERATION__SPECIALS)
			}
			if (operation.arguments.exists[optionalArgument]) {
				error('Special operations declared using operations must not be variadic nor have any optional arguments', 
						operation,
						WebIDLPackage.Literals.OPERATION__SPECIALS)
			}
		}
	}

	// See 3.2.4.1. Legacy callers

	@Check
	def checkLegacyCallersDoNotReturnPromiseType(Operation operation) {
		val operationType = operation.type;
		if (operation.specials.contains(Special.LEGACYCALLER) && operationType instanceof PromiseType) {
			error('Legacy callers must not be defined to return a promise type', 
					operation,
					WebIDLPackage.Literals.OPERATION__TYPE)
		}
	}

	// See 3.2.4.2. Stringifiers

//	@Check
//	def checkStringifierAttributeNotString(Attribute attribute) {
//		val attributeType = attribute.type;
//		if (attribute.specials.contains(Special.STRINGIFIER) && attributeType instanceof DOMStringType) {
//			error('The stringifier keyword must not be placed on an attribute unless it is declared to be of type DOMString', 
//					attribute,
//					WebIDLPackage.Literals.ATTRIBUTE__TYPE)
//		}
//	}
//
//	@Check
//	def checkStringifierAttributeNotStatic(Attribute attribute) {
//		if (attribute.specials.contains(Special.STRINGIFIER) && attribute.static) {
//			error('The stringifier keyword must not be placed on a static attribute', 
//					attribute,
//					WebIDLPackage.Literals.ATTRIBUTE__STATIC)
//		}
//	}

	// See 3.2.7. Iterable declarations

//	@Check
//	def checkIterableInterfaceMembers(Interface iface) {
//		if (iface.interfaceMembers.exists[it.interfaceMember instanceof Iterable_]) {
//			iface.interfaceMembers.filter[it.name == "entries") || it.name = "keys" || it.name = "values"].forEach[
//				error('Interfaces with iterable declarations must not have any interface members named “entries”, “keys” or “values”', 
//						iface,
//						WebIDLPackage.Literals.INTERFACE__INTERFACE_MEMBERS)
//			]
//		}
//	}

	@Check
	def checkIterableNotMoreThanOnce(Interface iface) {
		// TODO This marks the first interface member (although this one is not the problem)!
		if (iface.interfaceMembers.filter[it.interfaceMember instanceof Iterable_].length >= 2) {
			error('An interface must not have more than one iterable declaration', 
					iface,
					WebIDLPackage.Literals.INTERFACE__INTERFACE_MEMBERS)
		}
	}

	// See 3.5. Enumerations
	/**
	 * The list of enumeration values must not include duplicates.
	 */
	@Check
	def checkEnumerationValuesNoDuplicates(Enum enumeration) {
		val List<String> enumerationValues = enumeration.enumerationValues();
		val Set<String> enumerationValuesSet = newHashSet(enumerationValues);
		if (enumerationValues.size() != enumerationValuesSet.size()) {
			error('The list of enumeration values must not include duplicates', 
					enumeration,
					WebIDLPackage.Literals.ENUM__VALUES)
		}
	}

	// See 3.6. Callback functions
	/**
	 * Callback functions must not be used as the type of a constant.
	 */
	@Check
	def checkConstTypeNotCallbackFunction(Const constant) {
		val constantType = constant.type;
		if (constantType instanceof ReferenceType) {
			if (constantType.typeRef instanceof CallbackFunction) {
				error('Callback functions must not be used as the type of a constant', 
						constant,
						WebIDLPackage.Literals.CONST__TYPE)
			}
		}
	}

	// See 3.8. Implements statements
	/**
	 * The two identifiers must identify two different interfaces.
	 */
	@Check
	def checkImplementsStatementIdentifiers(ImplementsStatement implementsStatement) {
		if (implementsStatement.ifaceA == implementsStatement.ifaceB) {
			error('The two identifiers in an implements statement must identify two different interfaces.', 
					implementsStatement,
					WebIDLPackage.Literals.CONST__TYPE)
		}
	}

//	/**
//	 * For a given interface, there must not be any member defined on any of its consequential interfaces whose identifier is the same as any other member defined on any of those consequential interfaces or on the original interface itself
//	 */
//	@Check
//	def checkConsequentialInterfaceMembers(Interface iface) {
//		// TODO This check is not complete since the consequentialInterface's members are not checked against the other's members
//		val ownMembers = iface.interfaceMembers.map[it.interfaceMember];
//		val ownMembersNames = ownMembers.map[interfaceMemberToName(it)];
//		val consequentialInterfaces = iface.consequentialInterfaces();
//		for (consequentialInterface : consequentialInterfaces) {
//			val otherMembers = consequentialInterface.interfaceMembers.map[it.interfaceMember];
////			val otherMembersNames = otherMembers.map[interfaceMemberToName(it)];
//			for (otherMember : otherMembers) {
//				val same = ownMembers.filter[ownMembersNames.contains(interfaceMemberToName(it))];
//				if (!same.empty) {
//					error('For a given interface, there must not be any member defined on any of its consequential interfaces whose identifier is the same as any other member defined on any of those consequential interfaces or on the original interface itself', 
//							otherMember,
//							WebIDLPackage.Literals.INTERFACE__INTERFACE_MEMBERS)
//				}
//			}
//		}
//	}

	/**
	 * The interface identified on the left-hand side of an implements statement must not inherit from the interface identifier on the right-hand side, and vice versa.
	 */
	@Check
	def checkImplementsStatementInherits(ImplementsStatement implementsStatement) {
		// FIXME use inherited interfaces instead?!
		// TODO Check typedefs!
		val ifaceA = implementsStatement.ifaceA;
		val ifaceB = implementsStatement.ifaceB;
		if (ifaceA != null && ifaceB != null) {
			if (ifaceA.inherits == ifaceB) {
				error('The interface identified on the left-hand side of an implements statement must not inherit from the interface identifier on the right-hand side', 
							implementsStatement,
							WebIDLPackage.Literals.IMPLEMENTS_STATEMENT__IFACE_A)
			}
			if (ifaceB instanceof Interface) {
				if (ifaceB.inherits == ifaceA) {
					error('The interface identified on the right-hand side of an implements statement must not inherit from the interface identifier on the left-hand side', 
						implementsStatement,
						WebIDLPackage.Literals.IMPLEMENTS_STATEMENT__IFACE_B)
				}
			}
		}
	}

	// See 3.11. Extended attributes

	@Check
	def checkDeprecatedExtendedAttribute(ExtendedAttribute extendedAttribute) {
		if (extendedAttribute.nameRef == EA_TREAT_NON_CALLABLE_AS_NULL) {
			warning('The extended attribute TreatNonCallableAsNull was renamed to TreatNonObjectAsNull', 
				extendedAttribute,
				WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
		}
	}

	@Check
	def checkUnknownExtendedAttribute(ExtendedAttribute extendedAttribute) {
		if (!KNOWN_EXTENDED_ATTRIBUTES.contains(extendedAttribute.nameRef)) {
			warning('The extended attribute "' + extendedAttribute.nameRef + '" is no known extended attribute', 
				extendedAttribute,
				WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
		}
	}



	// See 4.3.1. [ArrayClass]
	@Check
	def checkExtendedAttributeArrayClassInherits(Interface iface) {
		// FIXME use inherited interfaces instead!
		if (iface.inherits != null) {
			val containerDefinition = iface.eContainer as ExtendedDefinition;
			val extendedAttributes = containerDefinition.eal.extendedAttributes;
			if (extendedAttributes.containsExtendedAttribute(EA_ARRAY_CLASS)) {
				// TODO can there be more than one?
				val extendedAttribute = extendedAttributes.getSingleExtendedAttribute(EA_ARRAY_CLASS);
				error('The extended attribute "' + extendedAttribute.nameRef + '" must not be specified on an interface that inherits from another', 
					extendedAttribute,
					WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
			}
		}
	}

	@Check
	def checkExtendedAttributeArrayClassTakesNoArguments(Interface iface) {
		val containerDefinition = iface.eContainer as ExtendedDefinition;
		val extendedAttributes = containerDefinition.eal.extendedAttributes;
		if (extendedAttributes.containsExtendedAttribute(EA_ARRAY_CLASS)) {
			// TODO can there be more than one?
			val extendedAttribute = extendedAttributes.getSingleExtendedAttribute(EA_ARRAY_CLASS);
			if (!extendedAttribute.takesNoArguments()) {
				error('The extended attribute "' + extendedAttribute.nameRef + '" must take no arguments', 
					extendedAttribute,
					WebIDLPackage.Literals.EXTENDED_ATTRIBUTE__NAME_REF)
			}
		}
	}

	@Check
	def checkPromiseTypeTypeSuffix(PromiseType type) {
		if (!type.typeSuffix.nullOrEmpty) {
			val firstTypeSuffix = type.typeSuffix.get(0);
			if (!(firstTypeSuffix instanceof NullableTypeSuffix) || type.typeSuffix.size > 1) {
				error('Promise types only support the type suffix "?"',
					type,
					WebIDLPackage.Literals.TYPE__TYPE_SUFFIX)
			}
		}
	}

	@Check
	def checkSequenceTypeTypeSuffix(SequenceType type) {
		if (!type.typeSuffix.nullOrEmpty) {
			val firstTypeSuffix = type.typeSuffix.get(0);
			if (!(firstTypeSuffix instanceof NullableTypeSuffix) || type.typeSuffix.size > 1) {
				error('Sequence types only support the type suffix "?"',
					type,
					WebIDLPackage.Literals.TYPE__TYPE_SUFFIX)
			}
		}
	}


	private def EStructuralFeature typeToFeature(Type type) {
		val containerDefinition = type.eContainer;
		switch (containerDefinition) {
			Argument: WebIDLPackage.Literals.ARGUMENT__TYPE
			Attribute: WebIDLPackage.Literals.ATTRIBUTE__TYPE
			CallbackFunction: WebIDLPackage.Literals.CALLBACK_FUNCTION__TYPE
			DictionaryMember: WebIDLPackage.Literals.DICTIONARY_MEMBER__TYPE
			Iterable_: WebIDLPackage.Literals.ITERABLE___TYPES
			Maplike: if(containerDefinition.keyType == type) {
				WebIDLPackage.Literals.MAPLIKE__KEY_TYPE
			} else {
				WebIDLPackage.Literals.MAPLIKE__VALUE_TYPE
			}
			Operation: WebIDLPackage.Literals.OPERATION__TYPE
			Setlike: WebIDLPackage.Literals.SETLIKE__TYPE
			Typedef: WebIDLPackage.Literals.TYPEDEF__TYPE
			UnionType: type.typeToFeature()
		}
	}

	private def EStructuralFeature definitionToFeature(Definition definition) {
		switch (definition) {
//			CallbackRestOrInterface: WebIDLPackage.Literals.CALLBACK_REST_OR_INTERFACE__NAME
			Interface: WebIDLPackage.Literals.INTERFACE__NAME
			Dictionary: WebIDLPackage.Literals.DICTIONARY__NAME
			Enum: WebIDLPackage.Literals.ENUM__NAME
			CallbackFunction: WebIDLPackage.Literals.CALLBACK_FUNCTION__NAME
			Typedef: WebIDLPackage.Literals.TYPEDEF__NAME
		}
	}
}
