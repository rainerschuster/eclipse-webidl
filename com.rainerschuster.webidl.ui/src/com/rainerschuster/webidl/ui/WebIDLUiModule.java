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
package com.rainerschuster.webidl.ui;

import org.eclipse.ui.plugin.AbstractUIPlugin;

import com.rainerschuster.webidl.ui.wizard.WebIDLProjectCreator;

/**
 * Use this class to register components to be used within the IDE.
 */
public class WebIDLUiModule extends com.rainerschuster.webidl.ui.AbstractWebIDLUiModule {
	public WebIDLUiModule(AbstractUIPlugin plugin) {
		super(plugin);
	}

	// contributed by org.eclipse.xtext.ui.generator.projectWizard.SimpleProjectWizardFragment
	public Class<? extends org.eclipse.xtext.ui.wizard.IProjectCreator> bindIProjectCreator() {
		return WebIDLProjectCreator.class;
	}
}
