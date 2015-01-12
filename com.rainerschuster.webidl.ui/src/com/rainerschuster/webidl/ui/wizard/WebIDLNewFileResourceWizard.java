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
package com.rainerschuster.webidl.ui.wizard;

import java.net.MalformedURLException;
import java.net.URL;

import org.eclipse.core.resources.IFile;
import org.eclipse.jface.resource.ImageDescriptor;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.IWorkbench;
import org.eclipse.ui.IWorkbenchPage;
import org.eclipse.ui.IWorkbenchWindow;
import org.eclipse.ui.PartInitException;
import org.eclipse.ui.ide.IDE;
import org.eclipse.ui.internal.ide.DialogUtil;
import org.eclipse.ui.internal.wizards.newresource.ResourceMessages;
import org.eclipse.ui.wizards.newresource.BasicNewResourceWizard;

// See org.eclipse.ui.wizards.newresource.BasicNewFileResourceWizard
public class WebIDLNewFileResourceWizard extends BasicNewResourceWizard/*BasicNewFileResourceWizard*/ {

	/**
	 * The wizard id for creating new files in the workspace.
	 */
	public static final String WIZARD_ID = "com.rainerschuster.webidl.ui.wizard.new.file"; //$NON-NLS-1$
	
    private WebIDLNewFileCreationPage mainPage;

    /**
     * Creates a wizard for creating a new file resource in the workspace.
     */
    public WebIDLNewFileResourceWizard() {
        super();
    }

    /* (non-Javadoc)
     * Method declared on IWizard.
     */
    public void addPages() {
        super.addPages();
        mainPage = new WebIDLNewFileCreationPage("newFilePage1", getSelection());//$NON-NLS-1$
        mainPage.setTitle("WebIDL File");
        mainPage.setDescription("Creates a new WebIDL file."); 
        addPage(mainPage);
    }

    /* (non-Javadoc)
     * Method declared on IWorkbenchWizard.
     */
    public void init(IWorkbench workbench, IStructuredSelection currentSelection) {
        super.init(workbench, currentSelection);
        setWindowTitle("New WebIDL File");
        setNeedsProgressMonitor(true);
    }

    /* (non-Javadoc)
     * Method declared on BasicNewResourceWizard.
     */
    protected void initializeDefaultPageImageDescriptor() {
		try {
			final ImageDescriptor desc = ImageDescriptor.createFromURL(new URL("platform:/plugin/com.rainerschuster.webidl.ui/icons/logo.png")); //$NON-NLS-1$
//			ImageDescriptor desc = IDEWorkbenchPlugin.getIDEImageDescriptor("icons/logo.png");//$NON-NLS-1$
			setDefaultPageImageDescriptor(desc);
		} catch (MalformedURLException e) {
			e.printStackTrace();
		}
    }

    /* (non-Javadoc)
     * Method declared on IWizard.
     */
    public boolean performFinish() {
        IFile file = mainPage.createNewFile();
        if (file == null) {
			return false;
		}

        selectAndReveal(file);

        // Open editor on new file.
        IWorkbenchWindow dw = getWorkbench().getActiveWorkbenchWindow();
        try {
            if (dw != null) {
                IWorkbenchPage page = dw.getActivePage();
                if (page != null) {
                    IDE.openEditor(page, file, true);
                }
            }
        } catch (PartInitException e) {
            DialogUtil.openError(dw.getShell(), ResourceMessages.FileResource_errorMessage, 
                    e.getMessage(), e);
        }

        return true;
    }
    

}
