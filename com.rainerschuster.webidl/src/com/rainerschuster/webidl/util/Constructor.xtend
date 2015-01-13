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

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import com.rainerschuster.webidl.webIDL.Argument
import com.rainerschuster.webidl.webIDL.Callable
import org.eclipse.emf.ecore.impl.MinimalEObjectImpl

// TODO reconsider this  extends MinimalEObjectImpl.Container implements Callable!
class Constructor extends MinimalEObjectImpl.Container implements Callable {

	@Accessors String name;
	@Accessors List<Argument> arguments;

}
