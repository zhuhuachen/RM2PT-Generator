package net.mydreamy.requirementmodel.springboot

import org.eclipse.core.commands.AbstractHandler;
import org.eclipse.core.commands.ExecutionEvent;
import org.eclipse.core.commands.ExecutionException;
import org.eclipse.core.commands.IHandler;
import org.eclipse.core.resources.IFile;
//import org.eclipse.core.resources.IFolder;
//import org.eclipse.core.resources.IProject;
import org.eclipse.core.runtime.CoreException;
import org.eclipse.core.runtime.NullProgressMonitor;
import org.eclipse.emf.common.util.URI;
import org.eclipse.jface.viewers.IStructuredSelection;
import org.eclipse.ui.handlers.HandlerUtil;
//import org.eclipse.xtext.resource.IResourceDescriptions;
import org.eclipse.xtext.ui.resource.IResourceSetProvider;
import com.google.inject.Inject;
import com.google.inject.Provider;
//import org.eclipse.xtext.generator.IGenerator2
import org.eclipse.xtext.builder.EclipseResourceFileSystemAccess2
import org.eclipse.xtext.generator.GeneratorContext
import org.eclipse.jface.text.TextSelection
//import org.eclipse.ui.IEditorPart

class SpringBootHandler extends AbstractHandler implements IHandler {
	
	@Inject
    SpringBootGenerator generator;
 
    @Inject
    Provider<EclipseResourceFileSystemAccess2> fileAccessProvider;
     
//    @Inject
//    IResourceDescriptions resourceDescriptions;
     
    @Inject
    IResourceSetProvider resourceSetProvider;
	
	override execute(ExecutionEvent event) throws ExecutionException {
		
		var selection = HandlerUtil.getCurrentSelection(event);
		
		//select requirement model file			 
		if (selection instanceof IStructuredSelection) {
			      	 	
			var structuredSelection = selection as IStructuredSelection;
			          			            
			var firstElement = structuredSelection.getFirstElement();
			            
			if (firstElement instanceof IFile) 
				firstElement.generateCode         	
		
		 //select requirement model file editor					                
		 } else if (selection instanceof TextSelection) {
		 		var activeEditor = HandlerUtil.getActiveEditor(event);
		 		val file = activeEditor.editorInput.getAdapter(IFile)
		 		
		 		file.generateCode
		 }
        
         return null;
      }
      
      def generateCode(IFile file) {

				//file belonged project
				var project = file.getProject();
				//check whether have src-gen folder, if not, create this folder
				var srcGenFolder = project.getFolder("src-gen");
				if (!srcGenFolder.exists()) {
					try {
				    	srcGenFolder.create(true, true, new NullProgressMonitor());
				    } catch (CoreException e) {
				    	return null;
				    }
				}
			 
			 	//generate file steam 
			    val EclipseResourceFileSystemAccess2 fsa = fileAccessProvider.get();
			    fsa.project = project
			    fsa.outputPath = "src-gen"
			    fsa.monitor = new NullProgressMonitor()
			                 
			    //get source file resource 
			    val uri = URI.createPlatformResourceURI(file.getFullPath().toString(), true);
			    var rs = resourceSetProvider.get(project);
			    var r = rs.getResource(uri, true);
			                
			    //generate codes
			    generator.doGenerate(r, fsa, new GeneratorContext());     
      }
	
	  override isEnabled() {
        return true;
   	  }
}
