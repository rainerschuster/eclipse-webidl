package com.rainerschuster.webidl.util

import java.util.List
import com.rainerschuster.webidl.webIDL.Interface
import com.rainerschuster.webidl.webIDL.ImplementsStatement
import java.util.Set

class TypeUtil {

	// See 3.5. Enumerations
	/**
	 * {@link http://heycam.github.io/webidl/#dfn-enumeration-value}
	 */
	static def List<String> enumerationValues(com.rainerschuster.webidl.webIDL.Enum enumeration) {
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

}