/*
* generated by Xtext
*/
package com.rainerschuster.webidl.ui.outline

import com.rainerschuster.webidl.webIDL.Attribute
import com.rainerschuster.webidl.webIDL.CallbackFunction
import com.rainerschuster.webidl.webIDL.Const
import com.rainerschuster.webidl.webIDL.Definitions
import com.rainerschuster.webidl.webIDL.Dictionary
import com.rainerschuster.webidl.webIDL.DictionaryMember
import com.rainerschuster.webidl.webIDL.ImplementsStatement
import com.rainerschuster.webidl.webIDL.Interface
import com.rainerschuster.webidl.webIDL.Iterable_
import com.rainerschuster.webidl.webIDL.Maplike
import com.rainerschuster.webidl.webIDL.Operation
import com.rainerschuster.webidl.webIDL.PartialDictionary
import com.rainerschuster.webidl.webIDL.PartialInterface
import com.rainerschuster.webidl.webIDL.Setlike
import com.rainerschuster.webidl.webIDL.Typedef
import org.eclipse.xtext.ui.editor.outline.IOutlineNode
import org.eclipse.xtext.ui.editor.outline.impl.DefaultOutlineTreeProvider
import org.eclipse.xtext.ui.editor.outline.impl.DocumentRootNode

import static extension com.rainerschuster.webidl.util.NameUtil.*

/**
 * Customization of the default outline structure.
 *
 * see http://www.eclipse.org/Xtext/documentation.html#outline
 */
class WebIDLOutlineTreeProvider extends DefaultOutlineTreeProvider {
	
	// ExtendedDefinition

	def _createChildren(DocumentRootNode parentNode, Definitions definitions) {
		definitions.definitions.forEach[
			createNode(parentNode, it.def);
		];
	}

	// ExtendedInterfaceMember

	def _createChildren(IOutlineNode parentNode, Interface iface) {
		// name
		// inherits
		iface.interfaceMembers.forEach[
			createNode(parentNode, it.interfaceMember);
		];
	}

	def _createChildren(IOutlineNode parentNode, PartialInterface iface) {
		// interfaceName (reference)
		iface.interfaceMembers.forEach[
			createNode(parentNode, it.interfaceMember);
		];
	}

	// ExtendedDictionaryMember

	def _createChildren(IOutlineNode parentNode, Dictionary dictionary) {
		// name
		// inherits
		dictionary.dictionaryMembers.forEach[
			createNode(parentNode, it.dictionaryMember);
		];
	}

	def _createChildren(IOutlineNode parentNode, PartialDictionary dictionary) {
		// dictionaryName (reference)
		dictionary.dictionaryMembers.forEach[
			createNode(parentNode, it.dictionaryMember);
		];
	}


	def _isLeaf(Const const) {
		true
	}

	def _isLeaf(Attribute attribute) {
		true
	}

	def _isLeaf(Operation operation) {
		true
	}

	def _isLeaf(Iterable_ maplike) {
		true
	}

	def _isLeaf(Maplike maplike) {
		true
	}

	def _isLeaf(Setlike setlike) {
		true
	}

	def _isLeaf(CallbackFunction callbackFunction) {
		true
	}

	def _isLeaf(DictionaryMember dictionaryMember) {
		true
	}

	def _isLeaf(Typedef typedef) {
		true
	}

	// TODO Argument ?

	def _text(Typedef typedef) {
		typedef.name + ' : ' + typeName(typedef.type)
	}

	def _text(ImplementsStatement implementsStatement) {
		implementsStatement.ifaceA?.name + ' implements ' + /*implementsStatement.ifaceB?.name*/ {
			val ifaceB = implementsStatement.ifaceB;
			switch (ifaceB) {
				Interface: ifaceB.name
				Typedef: ifaceB.name
			}
		}
	}

	def _text(CallbackFunction callbackFunction) {
		callbackFunction.name + ' : ' + (typeName(callbackFunction.type)?:callbackFunction.type)
	}

	def _text(Const const) {
		const.name + ' : ' + (typeName(const.type)?:const.type)
	}

	// TODO Attributes etc.
	def _text(Operation operation) {
		operation.name + ' : ' + (typeName(operation.type)?:operation.type)
	}

	// TODO required, default etc.
	def _text(DictionaryMember dictionaryMember) {
		dictionaryMember.name + ' : ' + (typeName(dictionaryMember.type)?:dictionaryMember.type)
	}

	// TODO inherit, readonly etc.
	def _text(Attribute attribute) {
		attribute.name + ' : ' + (typeName(attribute.type)?:attribute.type)
	}
}
