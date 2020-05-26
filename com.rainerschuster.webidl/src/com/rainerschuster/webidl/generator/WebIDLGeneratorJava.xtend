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
/*
 * generated by Xtext
 */
package com.rainerschuster.webidl.generator

import com.google.common.collect.ArrayListMultimap
import com.google.common.collect.ListMultimap
import com.google.inject.Inject
import com.rainerschuster.webidl.webIDL.Argument
import com.rainerschuster.webidl.webIDL.Attribute
import com.rainerschuster.webidl.webIDL.Callback
import com.rainerschuster.webidl.webIDL.Const
import com.rainerschuster.webidl.webIDL.Dictionary
import com.rainerschuster.webidl.webIDL.ExtendedAttributeList
import com.rainerschuster.webidl.webIDL.ExtendedInterfaceMember
import com.rainerschuster.webidl.webIDL.IncludesStatement
import com.rainerschuster.webidl.webIDL.Interface
import com.rainerschuster.webidl.webIDL.InterfaceMember
import com.rainerschuster.webidl.webIDL.Operation
import com.rainerschuster.webidl.webIDL.PartialDictionary
import com.rainerschuster.webidl.webIDL.PartialInterface
import com.rainerschuster.webidl.webIDL.Special
import com.rainerschuster.webidl.webIDL.impl.InterfaceImpl
import java.util.List
import org.eclipse.emf.ecore.resource.Resource
import org.eclipse.emf.ecore.util.EcoreUtil
import org.eclipse.xtext.generator.IFileSystemAccess
import org.eclipse.xtext.generator.IGenerator
import org.eclipse.xtext.naming.IQualifiedNameProvider

import static extension com.rainerschuster.webidl.util.EffectiveOverloadingSetUtil.*
import static extension com.rainerschuster.webidl.util.NameUtil.*
import static extension com.rainerschuster.webidl.util.TypeUtil.*
import com.rainerschuster.webidl.util.EffectiveOverloadingSetEntry
import com.rainerschuster.webidl.util.OptionalityValue
import com.rainerschuster.webidl.webIDL.Type
import com.rainerschuster.webidl.webIDL.Callable
import com.rainerschuster.webidl.webIDL.impl.OperationImpl
import org.eclipse.xtext.xbase.jvmmodel.JvmTypesBuilder
import org.eclipse.xtext.EcoreUtil2
import java.util.Set
import com.rainerschuster.webidl.util.TypeUtil

/**
 * Generates code from your model files on save.
 * 
 * see http://www.eclipse.org/Xtext/documentation.html#TutorialCodeGeneration
 */
class WebIDLGeneratorJava implements IGenerator {

	@Inject extension JvmTypesBuilder

	@Inject extension IQualifiedNameProvider

	override void doGenerate(Resource resource, IFileSystemAccess fsa) {
		println("Starting Generator for Java!");
//		// Prepare helper structures
//		var ListMultimap<Interface, Interface> implementsMap = ArrayListMultimap.create();
//		var ListMultimap<Interface, PartialInterface> partialInterfaceMap = ArrayListMultimap.create();
//		var ListMultimap<Dictionary, PartialDictionary> partialDictionaryMap = ArrayListMultimap.create();
//		for (e : resource.allContents.toIterable.filter(typeof(ImplementsStatement))) {
//			val ifaceB = e.ifaceB.resolveDefinition as Interface;
//			implementsMap.put(e.ifaceA, ifaceB);
//		}
//		for (e : resource.allContents.toIterable.filter(typeof(PartialInterface))) {
//			partialInterfaceMap.put(e.interfaceName, e);
//		}
//		for (e : resource.allContents.toIterable.filter(typeof(PartialDictionary))) {
//			partialDictionaryMap.put(e.dictionaryName, e);
//		}
//		// Process Interfaces
//		for (e : resource.allContents.toIterable.filter(typeof(Interface))) {
//			val Set<String> processedOperations = newLinkedHashSet();
//			val allImplements = newArrayList();
//			if (e.inherits != null) {
//				val inherits = e.inherits.resolveDefinition as Interface;
//				allImplements += EcoreUtil2.cloneWithProxies(inherits);
//			}
//			if (implementsMap.containsKey(e)) {
//				allImplements += implementsMap.get(e).map[EcoreUtil2.cloneWithProxies(it)];
//			}
////			val myInterface = EcoreUtil.copy(e);
//			val myInterface = EcoreUtil.create(e.eClass()) as InterfaceImpl;
//			myInterface.callback = e.callback;
//			myInterface.name = e.name;
//			myInterface.inherits = EcoreUtil2.cloneWithProxies(e.inherits);
////			myInterface.getInterfaceMembers().clear();
//			// TODO Overloaded operations / constructors
////			myInterface.interfaceMembers += e.interfaceMembers;
//					for (extendedMember : e.interfaceMembers) {
//						val member = extendedMember.interfaceMember;
//						if (member instanceof Operation) {
//							if (!processedOperations.contains(member.name)) {
//								val effectiveOverloadingSet = if (member.staticOperation) {
//									computeForStaticOperation(EcoreUtil2.cloneWithProxies(e), member.name, 0)
//								} else {
//									computeForRegularOperation(EcoreUtil2.cloneWithProxies(e), member.name, 0)
//								}
//								for (entry : effectiveOverloadingSet) {
//									val mappedMember = entry.callable.mapOperation(entry);
//									val myExtendedMember = EcoreUtil2.cloneWithProxies(extendedMember);
//									myExtendedMember.interfaceMember = mappedMember;
//									myInterface.interfaceMembers += myExtendedMember;
//								}
//								processedOperations += member.name;
//							}
//						} else {
//							val mappedMember = member;
//							val myExtendedMember = EcoreUtil2.cloneWithProxies(extendedMember);
//							myExtendedMember.interfaceMember = mappedMember;
//							myInterface.interfaceMembers += myExtendedMember;
//						}
//					}
//
//
//			if (partialInterfaceMap.containsKey(e)) {
//				for (pi : partialInterfaceMap.get(e)) {
//					for (member : pi.interfaceMembers) {
////						if (member instanceof Operation) {
////							val effectiveOverloadingSet = if (member.staticOperation) {
////								computeForStaticOperation(pi, member.name, 0)
////							} else {
////								computeForRegularOperation(pi, member.name, 0)
////							}
////							val mappedMember = member.mapOperation(effectiveOverloadingSet);
////							myInterface.interfaceMembers += mappedMember;
////						} else {
//							myInterface.interfaceMembers += EcoreUtil2.cloneWithProxies(member);
////						}
//					}
////					myInterface.interfaceMembers += pi.interfaceMembers;
//				}
//			}
//			// TODO Interfaces with [NoInterfaceObject]?
//			fsa.generateFile(e.fullyQualifiedName.toString("/") + ".java", myInterface.binding(e, allImplements));
//		}
//		// Process Callback Functions
//		for (e : resource.allContents.toIterable.filter(typeof(CallbackFunction))) {
//			val effectiveOverloadingSet = e.computeForCallbackFunction(0);
//			fsa.generateFile(e.fullyQualifiedName.toString("/") + ".java", e.binding(effectiveOverloadingSet));
//		}
	}

	private def Operation mapOperation(Operation original, EffectiveOverloadingSetEntry<Operation> entry) {
//		val myOperation = EcoreUtil.copy(original);
		val myOperation = EcoreUtil.create(original.eClass()) as OperationImpl;
		myOperation.static = original.static;
		myOperation.specials += original.specials; // FIXME Clone specials?
		myOperation.name = original.name;
		myOperation.type = EcoreUtil2.cloneWithProxies(original.type);
		val argumentsCopy = original.arguments.map[EcoreUtil2.cloneWithProxies(it)];
		for (Pair<Argument, Pair<Type, OptionalityValue>> i : entry.mapArguments(argumentsCopy)) {
			val originalArgument = i.key;
			val type = i.value.key;
			val optionalityValue = i.value.value;
			val myArgument = EcoreUtil2.cloneWithProxies(originalArgument);
////			val myArgument = EcoreUtil.copy(originalArgument);
//			val myArgument = EcoreUtil.create(originalArgument.eClass()) as ArgumentImpl;
//			myArgument.eal = originalArgument.eal;
//			myArgument.defaultValue = originalArgument.defaultValue;
//			myArgument.optional = originalArgument.optional;
//			myArgument.type = type;
//			myArgument.name = originalArgument.name;
			myArgument.optional = optionalityValue == OptionalityValue.OPTIONAL;
			myArgument.ellipsis = optionalityValue == OptionalityValue.VARIADIC;
			myOperation.arguments += myArgument;
		}
		return myOperation;
	}

	def binding(Interface iface, Interface original, List<Interface> allImplements) '''
		«IF original.eContainer.fullyQualifiedName != null»
			package «original.eContainer.fullyQualifiedName»;

		«ENDIF»

		public interface «iface.name»«IF !allImplements.nullOrEmpty» extends «FOR i : allImplements SEPARATOR ', '»«i.fullyQualifiedName»«ENDFOR»«ENDIF» {
		«FOR i : iface.interfaceMembers SEPARATOR '\n'»
			«binding(i)»
		«ENDFOR»
		}
	'''

	def binding(Callback callback, List<EffectiveOverloadingSetEntry<Callback>> effectiveOverloadingSet) '''
		«IF callback.eContainer.fullyQualifiedName != null»
			package «callback.eContainer.fullyQualifiedName»;

		«ENDIF»

		public interface «callback.name» {
		«FOR entry : effectiveOverloadingSet SEPARATOR '\n'»
			«entry.callable.type.toJavaType» call(«FOR i : entry.mapArguments(callback.arguments) SEPARATOR ', '»«binding(i.key, i.value)»«ENDFOR»);
		«ENDFOR»
«««			«callback.type.toJavaType» call(«FOR i : callback.arguments SEPARATOR ', '»«binding(i)»«ENDFOR»);
		}
	'''

	private def <T extends Callable> mapArguments(EffectiveOverloadingSetEntry<T> entry, List<Argument> arguments) {
		// FIXME is this Math.min really necessary?
		(0 ..< Math.min(arguments.size, entry.typeList.size())).map[
			EcoreUtil2.cloneWithProxies(arguments.get(it)) -> 
				(EcoreUtil2.cloneWithProxies(entry.typeList.get(it)) 
					-> entry.optionalityList.get(it))
		]
	}

	def binding(ExtendedInterfaceMember member) {
		bindingInterfaceMember(member.eal, member.interfaceMember)
	}

	def dispatch bindingInterfaceMember(ExtendedAttributeList eal, InterfaceMember interfaceMember) {
		System.out.println("Fallback method - Unsupported type " + interfaceMember.class.name + "!");
	}

	/* TODO NON-SPEC: Added "public static final " */
	def dispatch bindingInterfaceMember(ExtendedAttributeList eal, Const constant) '''
		«constant.type.toJavaType» «constant.name.getEscapedJavaName» = «constant.constValue»;

	'''

	// TODO is... for boolean! (non-nullable?!)
	def dispatch bindingInterfaceMember(ExtendedAttributeList eal, Attribute attribute) '''
		«IF !attribute.inherit»
			«attribute.type.type.toJavaType» get«attribute.name.toFirstUpper»();
		«ENDIF»
		«IF !attribute.readOnly»
			void set«attribute.name.toFirstUpper»(«attribute.type.type.toJavaType» «attribute.name.getEscapedJavaName»);
		«ENDIF»

	'''

	// FIXME What if more than one specials occur, e.g.: setter creator void (unsigned long index, HTMLOptionElement? option);
	def dispatch bindingInterfaceMember(ExtendedAttributeList eal, Operation operation) '''
		«operation.type.toJavaType» «IF operation.name.nullOrEmpty»«IF operation.specials.contains(Special.GETTER)»_get«ELSEIF operation.specials.contains(Special.SETTER)»_set«ELSEIF operation.specials.contains(Special.DELETER)»_delete«ENDIF»«ELSE»«operation.name.getEscapedJavaName»«ENDIF»(«FOR i : operation.arguments SEPARATOR ', '»«binding(i)»«ENDFOR»);
	'''

	def binding(Argument parameter) '''
		«TypeUtil.type(parameter).toJavaType»«IF parameter.ellipsis»...«ENDIF» «parameter.name.getEscapedJavaName»'''
	def binding(Argument parameter, Pair<Type, OptionalityValue> o) '''
		«TypeUtil.type(parameter).toJavaType»«IF o.value == OptionalityValue.VARIADIC»...«ENDIF» «parameter.name.getEscapedJavaName»'''

}
