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
import com.rainerschuster.webidl.webIDL.CallbackFunction
import com.rainerschuster.webidl.webIDL.Interface
import com.rainerschuster.webidl.webIDL.Operation
import com.rainerschuster.webidl.webIDL.Callable
import com.rainerschuster.webidl.webIDL.Type
import com.rainerschuster.webidl.webIDL.ExtendedDefinition
import static extension com.rainerschuster.webidl.util.NameUtil.*

class EffectiveOverloadingSetUtil {
	// TODO OperationUtil: regularOperation, staticOperation, variadicOperation

	def static List<EffectiveOverloadingSetEntry<Operation>> computeForRegularOperation(Interface iface, String identifier, long argumentCount) {
		val f = iface.interfaceMembers.map[it.interfaceMember].
			filter(typeof(Operation)).
			filter[TypeUtil.regularOperation(it)].
			filter[(it == null && identifier == null) || (identifier != null && identifier == it.name)];

		return compute(f, argumentCount);
	}

	def static List<EffectiveOverloadingSetEntry<Operation>> computeForStaticOperation(Interface iface, String identifier, long argumentCount) {
		val f = iface.interfaceMembers.map[it.interfaceMember].
			filter(typeof(Operation)).
			filter[TypeUtil.staticOperation(it)].
			filter[(it == null && identifier == null) || (identifier != null && identifier == it.name)];

		return compute(f, argumentCount);
	}

	def static List<EffectiveOverloadingSetEntry<Constructor>> computeForConstructor(Interface iface, long argumentCount) {
		val definition = iface.eContainer as ExtendedDefinition;
		val f = ExtendedAttributeUtil.getConstructorValuesUnchecked(definition.eal.extendedAttributes).filterNull.toList;

		return compute(f, argumentCount);
	}

	def static List<EffectiveOverloadingSetEntry<Constructor>> computeForNamedConstructor(Interface iface, String identifier, long argumentCount) {
		val definition = iface.eContainer as ExtendedDefinition;
		val f = ExtendedAttributeUtil.getNamedConstructorValuesUnchecked(definition.eal.extendedAttributes).filterNull.filter[identifier == it.name].toList;

		return compute(f, argumentCount);
	}

	def static List<EffectiveOverloadingSetEntry<CallbackFunction>> computeForCallbackFunction(CallbackFunction callbackFunction, long argumentCount) {
		val List<CallbackFunction> f = #[callbackFunction];
		return compute(f, argumentCount);
	}

	private def static <T extends Callable> boolean containsEntry(Iterable<EffectiveOverloadingSetEntry<T>> iterable, EffectiveOverloadingSetEntry<T> entry) {
		for (e : iterable) {
			if (equalsEntries(e, entry)) {
				return true;
			}
		}
		return false;
	}
	private def static <T extends Callable> boolean equalsEntries(EffectiveOverloadingSetEntry<T> entryA, EffectiveOverloadingSetEntry<T> entryB) {
		// FIXME what about callable?
		if (entryA.typeList.size != entryB.typeList.size || entryA.optionalityList.size != entryB.optionalityList.size) {
			return false;
		}
		val checkTypeLists = (0..<entryA.typeList.size).forall[entryA.typeList.get(it).typeName == entryB.typeList.get(it).typeName];
		val checkOptionalityLists = (0..<entryA.optionalityList.size).forall[entryA.optionalityList.get(it) == entryB.optionalityList.get(it)];
		return checkTypeLists && checkOptionalityLists;
	}

	def static <T extends Callable> List<EffectiveOverloadingSetEntry<T>> compute(Iterable<T> f, long argumentCount) {
		// TODO Add a check that argumentCount is not greater than the number of available arguments!
		// Note that S is a set in the specification!
		// 1. Initialize S to empty set
		val List<EffectiveOverloadingSetEntry<T>> s = new ArrayList<EffectiveOverloadingSetEntry<T>>();

		// 2. Let F be a set with elements as follows, according to the kind of effective overload set:
		// Note that F is a set in the specification!

		// 3. Let maxarg be the maximum number of arguments the operations, constructor extended attributes or callback functions in F are declared to take. For variadic operations and constructor extended attributes, the argument on which the ellipsis appears counts as a single argument.
		var long maxarg = 0;
		for (ff : f) {
			// TODO Implement Interface HasArguments?
			val int maxargCandidate = switch (ff) {
				Operation: ff.arguments.size
				CallbackFunction: ff.arguments.size
				Constructor: ff.arguments.size
				default: 0
			};
			maxarg = Math.max(maxarg, maxargCandidate);
		}

		// 4. Let m be the maximum of maxarg and N.
		val m = Math.max(maxarg, argumentCount);

		// 5. For each operation, extended attribute or callback function X in F:
		for (x : f) {
			val argumentsOfX = switch (x) {
				Operation: x.arguments
				CallbackFunction: x.arguments
				Constructor: x.arguments
			};

			// 5.1. Let n be the number of arguments X is declared to take.
			val n = argumentsOfX.size();

			// 5.2. Let t0..n−1 be a list of types, where ti is the type of X's argument at index i.
			// FIXME Check if EcoreUtil2.cloneWithProxies(it.type) is necessary here!
			val t = argumentsOfX.map[it.type].toList();

			// 5.3. Let o0..n−1 be a list of optionality values, where oi is "variadic" if X's argument at index i is a final, variadic argument, "optional" if the argument is optional, and "required" otherwise.
			val o = argumentsOfX.map[
				if (TypeUtil.variadic(it)) {
					OptionalityValue.VARIADIC
				} else if (it.optional) {
					OptionalityValue.OPTIONAL
				} else {
					OptionalityValue.REQUIRED
				}
			].toList();

			// 5.4. Add to S the tuple <X, t0..n−1, o0..n−1>.
			val entry54 = new EffectiveOverloadingSetEntry(x, t, o);
			if (!s.containsEntry(entry54)) {
				s += entry54;
			}

			// 5.5. If X is declared to be variadic, then:
			// TODO TypeUtil.variadic should support polymorphic dispatch or Callable
			val variadic = switch (x) {
				Operation: TypeUtil.variadic(x)
				CallbackFunction: TypeUtil.variadic(x)
				Constructor: TypeUtil.variadic(x)
			};
			if (/*n > 0 && */variadic) {
				// 5.5.1. Add to S the tuple <X, t0..n−2, o0..n−2>.
				val t_1 = t.subList(0, n - 1);
				val o_1 = o.subList(0, n - 1);
				val entry551 = new EffectiveOverloadingSetEntry(x, t_1, o_1);
				if (!s.containsEntry(entry551)) {
					s += entry551;
				}

				// 5.5.2. For every integer i, such that n ≤ i ≤ m−1:
				for (var i = n; i <= m - 1; i++) {
					// 5.5.2.1. Let u0..i be a list of types, where uj = tj (for j < n) and uj = tn−1 (for j ≥ n).
					// 5.5.2.2. Let p0..i be a list of optionality values, where pj = oj (for j < n) and pj = "variadic" (for j ≥ n).
					val u = new ArrayList<Type>(i + 1);
					val p = new ArrayList<OptionalityValue>(i + 1);
					for (var j = 0; j <= i; j++) {
						if (j < n) {
							u += t.get(j);
							p += o.get(j);
						} else {
							u +=t.get(n - 1);
							p +=OptionalityValue.VARIADIC;
						}
					}
					// 5.5.2.3. Add to S the tuple <X, u0..i, p0..i>.
					val entry5523 = new EffectiveOverloadingSetEntry(x, u, p);
					if (!s.containsEntry(entry5523)) {
						s += entry5523;
					}
				}
			}

			// 5.6. Initialize i to n−1.
			var i = n - 1;
			// The variable break is a workaround since Xtend does not support break in while loops
			var break = false;

			// 5.7. While i ≥ 0:
			while (!break && i >= 0) {
				// 5.7.1. If argument i of X is not optional, then break this loop.
				if (!TypeUtil.optionalArgument(argumentsOfX.get(i))) {
					break = true;
				} else {
					// 5.7.2. Otherwise, add to S the tuple <X, t0..i−1, o0..i−1>.
					val t_i = t.subList(0, i);
					val o_i = o.subList(0, i);
					val entry571 = new EffectiveOverloadingSetEntry(x, t_i, o_i);
					if (!s.containsEntry(entry571)) {
						s += entry571;
					}
					// 5.7.3. Set i to i−1.
					i = i - 1;
				}
			}

			// 5.8 If n > 0 and all arguments of X are optional, then add to S the tuple <X, (), ()> (where "()" represents the empty list).
			if (n > 0 && argumentsOfX.forall[it.optional]) {
				val entry58 = new EffectiveOverloadingSetEntry(x, #[], #[]);
				if (!s.containsEntry(entry58)) {
					s += entry58;
				}
			}
		}

		// 6. The effective overload set is S.
		return s;
	}

}
