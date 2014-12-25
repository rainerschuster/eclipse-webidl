package com.rainerschuster.webidl.ui.wizard;

import java.io.ByteArrayInputStream;
import java.io.InputStream;

import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.dialogs.WizardNewFileCreationPage;
import org.eclipse.xtext.xbase.lib.StringExtensions;

public class WebIDLNewFileCreationPage extends WizardNewFileCreationPage {

	public WebIDLNewFileCreationPage(String pageName, IStructuredSelection selection) {
		super(pageName, selection);
		setFileExtension("idl");
	}

	@Override
	protected InputStream getInitialContents() {
		final String fileName = getFileName();
		String ifaceName = fileName;
		int dotLoc = fileName.lastIndexOf('.');
		if (dotLoc != -1) {
			ifaceName = ifaceName.substring(0, dotLoc);
		}
		ifaceName = StringExtensions.toFirstUpper(ifaceName);
		final String contents = WebIDLSampleContent.sampleFileContent(ifaceName).toString();
		return new ByteArrayInputStream(contents.getBytes());
	}

}
