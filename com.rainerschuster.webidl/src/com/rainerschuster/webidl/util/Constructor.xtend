package com.rainerschuster.webidl.util

import java.util.List
import org.eclipse.xtend.lib.annotations.Accessors
import com.rainerschuster.webidl.webIDL.Argument

class Constructor {

	@Accessors String name;
	@Accessors List<Argument> argumentList;

}
