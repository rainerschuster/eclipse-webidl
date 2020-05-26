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
package com.rainerschuster.webidl.formatting

import org.eclipse.xtext.formatting.impl.AbstractDeclarativeFormatter
import org.eclipse.xtext.formatting.impl.FormattingConfig
import com.google.inject.Inject;
import com.rainerschuster.webidl.services.WebIDLGrammarAccess
import org.eclipse.xtext.Keyword
import org.eclipse.xtext.util.Pair

/**
 * This class contains custom formatting description.
 * 
 * see : http://www.eclipse.org/Xtext/documentation.html#formatting
 * on how and when to use it 
 * 
 * Also see {@link org.eclipse.xtext.xtext.XtextFormattingTokenSerializer} as an example
 */
class WebIDLFormatter extends AbstractDeclarativeFormatter {

	@Inject extension WebIDLGrammarAccess

	override protected void configureFormatting(FormattingConfig c) {
		// Default linewrap is 80
		c.setAutoLinewrap(120);

		// Find common keywords an specify formatting for them
		for (Pair<Keyword, Keyword> pair : findKeywordPairs("(", ")")) {
			c.setNoSpace().after(pair.first);
			c.setNoSpace().before(pair.second);
		}
		for (Pair<Keyword, Keyword> pair : findKeywordPairs("<", ">")) {
			c.setNoSpace().after(pair.first);
			c.setNoSpace().before(pair.second);
		}
		for (Keyword comma : findKeywords(",")) {
			c.setNoSpace().before(comma);
//			c.setSpace().after(comma);
		}
		for (Keyword semicolon : findKeywords(";")) {
			c.setNoSpace().before(semicolon);
		}

		// (Extended) Definition
//		c.setLinewrap().after(extendedDefinitionAccess.ealExtendedAttributeListParserRuleCall_0_0);
//		c.setLinewrap().before(definitionRule);

		// Callback function
		c.setLinewrap().after(callbackAccess.semicolonKeyword_7);

		// Interface
		c.setLinewrap().before(interfaceAccess.interfaceKeyword_1);
		c.setIndentation(interfaceAccess.leftCurlyBracketKeyword_5, interfaceAccess.rightCurlyBracketKeyword_7);
		c.setLinewrap().after(interfaceAccess.leftCurlyBracketKeyword_5);
		c.setNoSpace.between(interfaceAccess.rightCurlyBracketKeyword_7, interfaceAccess.semicolonKeyword_8);
		c.setLinewrap().after(interfaceAccess.semicolonKeyword_8);

		// Dictionary
		c.setLinewrap().before(dictionaryAccess.dictionaryKeyword_0);
		c.setIndentation(dictionaryAccess.leftCurlyBracketKeyword_3, dictionaryAccess.rightCurlyBracketKeyword_5);
		c.setLinewrap().after(dictionaryAccess.leftCurlyBracketKeyword_3);
		c.setNoSpace.between(dictionaryAccess.rightCurlyBracketKeyword_5, dictionaryAccess.semicolonKeyword_6);
		c.setLinewrap().after(dictionaryAccess.semicolonKeyword_6);

		c.setLinewrap().after(dictionaryMemberRule);

		// Partial
		c.setLinewrap().before(partialAccess.partialKeyword_0);

		// Partial Interface
		c.setIndentation(partialInterfaceAccess.leftCurlyBracketKeyword_3, partialInterfaceAccess.rightCurlyBracketKeyword_5);
		c.setLinewrap().after(partialInterfaceAccess.leftCurlyBracketKeyword_3);
		c.setNoSpace.between(partialInterfaceAccess.rightCurlyBracketKeyword_5, partialInterfaceAccess.semicolonKeyword_6);
		c.setLinewrap().after(partialInterfaceAccess.semicolonKeyword_6);

		// Partial Dictionary
		c.setIndentation(partialDictionaryAccess.leftCurlyBracketKeyword_2, partialDictionaryAccess.rightCurlyBracketKeyword_4);
		c.setLinewrap().after(partialDictionaryAccess.leftCurlyBracketKeyword_2);
		c.setNoSpace.between(partialDictionaryAccess.rightCurlyBracketKeyword_4, partialDictionaryAccess.semicolonKeyword_5);
		c.setLinewrap().after(partialDictionaryAccess.semicolonKeyword_5);

		// Enum
		c.setIndentation(enumAccess.leftCurlyBracketKeyword_2, enumAccess.rightCurlyBracketKeyword_6);
		c.setLinewrap().after(enumAccess.leftCurlyBracketKeyword_2);
		c.setNoSpace.between(enumAccess.rightCurlyBracketKeyword_6, enumAccess.semicolonKeyword_7);
		c.setLinewrap().before(enumAccess.rightCurlyBracketKeyword_6);
		c.setLinewrap().after(enumAccess.semicolonKeyword_7);

		// Typedef
		c.setLinewrap(2).after(typedefAccess.semicolonKeyword_3);
		c.setNoSpace().before(typedefAccess.semicolonKeyword_3);

		// IncludesStatement
		c.setLinewrap(2).after(includesStatementAccess.semicolonKeyword_3);
		c.setNoSpace().before(includesStatementAccess.semicolonKeyword_3);

		// Interface member
		c.setLinewrap().after(interfaceMemberRule);

		// Operation
		c.setNoSpace().before(operationAccess.leftParenthesisKeyword_4);

		// Argument
		c.setNoSpace().before(argumentAccess.ellipsisFullStopFullStopFullStopKeyword_1_1_1_0);

		// Type
		c.setNoSpace().before(nullableAccess.questionMarkKeyword_1);

		// Comments 
		c.setLinewrap(0, 1, 2).before(SL_COMMENTRule);
		c.setLinewrap(0, 1, 2).before(ML_COMMENTRule);
		c.setLinewrap(0, 1, 1).after(ML_COMMENTRule);
	}
}
