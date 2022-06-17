import com.cloudbees.groovy.cps.NonCPS
import hudson.tasks.test.AbstractTestResultAction
import hudson.model.*

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
	
	String jobName = "Dev_19"
	String imageName= "actions"
	String gitWorkspace= "/var/jenkins_home/workspace/TestPipelinesJob@script"
	dirName = dirName.trim()
	jobName = jobName.trim().replaceAll(" ", "_")
	String resultsWorkspace= "/tmp/fedramp-compliance-scans/fedramp_compliance_scans"
	
	try {
		sh "env"
		sh "pwd"
		sh "rm -rf ${WORKSPACE}; mkdir -p ${WORKSPACE}"
		sh "ls ${gitWorkspace}/*/"
		
		sh "cp -r ${gitWorkspace}/*/* ${WORKSPACE}/" 
		sh "rm -rf ${resultsWorkspace}; mkdir -p ${resultsWorkspace}/${jobName}"
		sh "ls ${WORKSPACE}"
		sh "cp -r ${WORKSPACE}/output_files/* ${resultsWorkspace}/${jobName}/"
		sh "cd ${resultsWorkspace}"
		sh "pwd; ls -al; ls ${jobName}"
		
		publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "${jobName}", reportFiles: "**/*", reportName: "TwistlockScanReport-${imageName}"])
		
	} catch (e) {
		//sh "cat wicked_cli.log"
		echo "Error: There were issues while generating the wicked cli scan report."
		throw e
	}

}
// Main starts here

call(msvc_variables)
