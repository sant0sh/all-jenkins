import com.cloudbees.groovy.cps.NonCPS
import hudson.tasks.test.AbstractTestResultAction
import hudson.model.*
//import groovy.io.FileType
//import hudson.FilePath
//import static groovy.io.FileType.FILES

Object msvc_variables = [
	// Properties for the service job only.
	'service_job_properties': [
		'env_vars': "BUILD_TYPE=${env.BUILD_TYPE}",		// **REQUIRED** This sets up the env variables as part of the job configuration.
		'enable_concurrent_builds': false,				// **OPTIONAL** Doesn't let concurrent builds of the same pipeline happen. Defaults to false
		'input_params': getCustomInputParams(),		           // **OPTIONAL** This lets your team define custom params or override default params
		'test_job_start_params':
                [
                        
                        string(name: 'TEST_TAGS',           value: "${TEST_TAGS}")
                        
                ]
	],
]

Object getCustomInputParams()
{
def defaultParams = []
    
    defaultParams.add(string(defaultValue:'', description:'New tests. Default value is @BasicTest', name:'TEST_TAGS', trim:false))
    defaultParams.add(string(defaultValue: '', description: 'Specify jar version', name: 'JAR_VERSION', trim:true))

return defaultParams
}



def call (Object msvc_variables) {
    echo msvc_variables.toString()
    echo msvc_variables['service_job_properties']['env_vars']
    //echo msvc_variables['service_job_properties']['input_params']
    
    if (msvc_variables['service_job_properties']['input_params'] != null && msvc_variables['service_job_properties']['input_params'] != "") {
        msvc_variables['service_job_properties']['input_params'].each { param ->
            //defaultParams = utils.addInputParameter (defaultParams, param)
	    print 'Adding parameter:' + param
        }
    }
	node
	{
          generateWickedCLIReport()

	}
}

/*
 * Method to publish HTML test results in HTML Publisher.
 * @param reportsDir The relative or absolute path to where the HTML test reports are stored.
 * @param reportName The name of the test report.
 */
void publishHTMLResults (String reportName, String reportsDir = ".", String filePattern = "**/*.html") {
	publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: reportsDir, reportFiles: filePattern, reportName: reportName])
}

/**
 * Generates Wicked CLI scan reports for a given service
 * @param dirName The name of the directory to scan
 * @return nothing
 */
def generateWickedCLIReport(String dirName = ".") {
	
	String jobName = "Dev_${BUILD_ID}"
	String overrideTag = "Rel_98"
	String imageName= "sec-cloud-identity-builds-docker-local.artifactory.swg-devops.com/actions:Rel_98"
	String gitWorkspace= "${WORKSPACE}@script"
	dirName = dirName.trim()
	jobName = jobName.trim().replaceAll(" ", "_")
	String resultsWorkspace= "/tmp/fedramp-compliance-scans/fedramp_compliance_scans"
	
	try {
		sh "env"
		sh "pwd"
		def jobPath="/tmp/${jobName}"
		sh "rm -rf /tmp/Dev_*; mkdir -p ${resultsWorkspace}"
		sh "rm -rf ${resultsWorkspace}; mkdir -p ${resultsWorkspace}"
		sh "ls ${gitWorkspace}/*/"
		
		sh "rm -rf ${resultsWorkspace}; mkdir -p ${resultsWorkspace}/${jobName}"
		sh "cp -r ${gitWorkspace}/*/* ${resultsWorkspace}/${jobName}/" 
		
		sh "cp -r ${WORKSPACE}/output_files/* /tmp/${jobName}/"
		sh "ls /tmp/${jobName}/"
		// Add logic to change files names
		// twistlock-20220517-<microservice>-<RELbuildversion>
	        def microServiceName = '', version = ''
	        (microServiceName, version) = getMicroServiceNameAndVersion(imageName)
	        renameTwistlockResults(jobPath, microServiceName, version)
	        
		//
		publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, escapeUnderscores: false, reportDir: jobPath, reportFiles: "**/*", reportName: "TwistlockReport-${microServiceName}-${version}"])
		
	} catch (e) {
		//sh "cat wicked_cli.log"
		echo "Error: There were issues while generating the wicked cli scan report."
		throw e
	}

}

/**
 * Searches the file with extension.
 * @param path The path where the file is expected
 * @param ext File extension to be searched. It should help to find a single file.
 * @return string File name
 */
def findFileWithExtension(def path, def nameStartsWith, def ext)
{
  def fileName = ''
  try {
	  String fileNamePart1 = sh(script:"ls ${path}/${nameStartsWith}*${ext}", returnStdout:true).trim()
	  String fileNamePart2 = fileNamePart1.substring(0, fileNamePart1.indexOf(ext))
          int lastSlashIndex = fileNamePart2.lastIndexOf('/') + 1
          fileName = fileNamePart2.substring(lastSlashIndex)
     } catch (Exception e) {
	echo "Failed to search file with extension *${ext} on ${path} " + e.toString()
     }
   return fileName
 }

/**
 * Get date stamp from the twistlock file name.
 * @param fileName Twistlock file name
 * @return string date stamp
 */
def getDateStampFromTwistlockFile(def fileName)
{
   def dateStamp = ''
   try {
        def splitValues = fileName.split('-')
        dateStamp = splitValues[3]
     } catch (Exception e) {
	echo "Failed to extract data stamp from the file ${fileName} " + e.toString()
     }
   return dateStamp
}

def getMicroServiceNameAndVersion(def imageName)
{
	def microServiceNameAndVersion=imageName.substring(imageName.lastIndexOf('/') + 1)
	def microServiceName=microServiceNameAndVersion.split(':')[0]
	def version=microServiceNameAndVersion.split(':')[1]
	return [microServiceName.trim(), version.trim()]
}


def renameFile(def basePath, def sourceName, def targetName)
{
   try {
         println sh(script:"mv ${basePath}/${sourceName} ${basePath}/${targetName}", returnStdout:true).trim()
       } catch (Exception e) {
	 echo "Failed to rename file ${basePath}/${sourceName} to ${basePath}/${targetName} " e.toString()
     }
}

def updateFileNameChangeReferences(def sourcePath, def fileName, def oldReference, def newReference)
{
   try {
	   def cmd="sed -i " + "s/" + oldReference + "/" + newReference + "/g " + sourcePath + "/" + fileName
	   println "cmd=${cmd}"
           println  sh(script:cmd, returnStdout:true).trim()
       } catch (Exception e) {
	 echo "Failed to update reference text ${newReference} in file ${sourcePath}/${fileName} " + e.toString()
     }
}

def renameTwistlockResults(def sourcePath, def  microServiceName, def version)
{
     def fileExtension = [".metadata.csv", ".overview.csv", ".results.csv", ".json"]
     def nameStartsWith = "twistlock"
     for (int i = 0; i < fileExtension.size(); i++) {
         def reportFile=findFileWithExtension(sourcePath, nameStartsWith, fileExtension[i])
	 def dateStamp = getDateStampFromTwistlockFile(reportFile)
	 println "Date stamp on file name ${dateStamp}"
	 def shortName="twistlock-" + dateStamp + "-" + microServiceName + "-" + version + fileExtension[i]
	 renameFile(sourcePath, reportFile + fileExtension[i], shortName)
	 updateFileNameChangeReferences(sourcePath, shortName, reportFile, nameStartsWith + "-" + dateStamp + "-" + microServiceName + "-" + version)
	}
}

// Main starts here

call(msvc_variables)
