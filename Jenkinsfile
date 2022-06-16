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
	try {
		dirName = dirName.trim()
		sh "rm -rf wicked-cli-reports; mkdir wicked-cli-reports"
	} catch (e) {
		//sh "cat wicked_cli.log"
		echo "Error: There were issues while generating the wicked cli scan report."
		throw e
	}
	dir ("wicked-cli-reports") {
		sh "pwd; ls -al;"
		try {
			String jobName = "${env.JOB_NAME}/${currentBuild.displayName}"
			String imageName= "actions"
			jobName = jobName.trim().replaceAll(" ", "_")
	                sh "mkdir -p ${jobName};"
			sh "echo metadata > ${jobName}/twistlock-scan-results-20220607-131140-415469488-UTC-b95e0aaa.metadata.csv"
			sh "echo overview > ${jobName}/twistlock-scan-results-20220607-131140-415469488-UTC-b95e0aaa.overview.csv"
			sh "echo all-results > ${jobName}/twistlock-scan-results-20220607-131140-415469488-UTC-b95e0aaa.results.csv"
			sh "echo json-data > ${jobName}/twistlock-scan-results-20220607-131140-415469488-UTC-b95e0aaa.json"
			
			//publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "Test_scan-results", reportFiles: "**/*", reportName: "Wicked CLI Report"])
		        publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: "${jobName}", reportFiles: "**/*", reportName: "Twistlock Scan Report for ${imageName}"])
		} catch (e) {
			echo "Error: There was some issue while publishing the Wicked CLI HTML report."
			throw e
		}
	}
}
// Main starts here

call(msvc_variables)
