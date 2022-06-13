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
	    echo param
        }
    }

}


// Main starts here

call(msvc_variables)
