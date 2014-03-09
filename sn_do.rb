require 'yaml'
require 'net/https'
require 'rexml/document'
include REXML


#Loading YAML variables
config = YAML.load_file("sn_do_config.yml")
instance_name = config["instance_name"]
@username = config["username"]
@password = config["password"]


xmlraw = "<?xml version='1.0' encoding='UTF-8'?>
<xml>
<incident>
<active>true</active>
<activity_due>2014-03-06 22:49:14</activity_due>
<approval>not requested</approval>
<approval_history/>
<approval_set/>
<assigned_to>681b365ec0a80164000fb0b05854a0cd</assigned_to>
<assignment_group>d625dccec0a8016700a222a0f7900d06</assignment_group>
<business_duration/>
<business_stc/>
<calendar_duration/>
<calendar_stc/>
<caller_id>46c1293aa9fe1981000dc753e75ebeee</caller_id>
<category>software</category>
<caused_by/>
<child_incidents/>
<close_code/>
<close_notes/>
<closed_at/>
<closed_by/>
<cmdb_ci>26e494480a0a0bb400ad175538708ad9</cmdb_ci>
<comments/>
<comments_and_work_notes/>
<company/>
<contact_type>phone</contact_type>
<correlation_display/>
<correlation_id/>
<delivery_plan/>
<delivery_task/>
<description/>
<due_date/>
<escalation>3</escalation>
<expected_start/>
<follow_up/>
<group_list/>
<impact>1</impact>
<incident_state>1</incident_state>
<knowledge>false</knowledge>
<location/>
<made_sla>true</made_sla>
<notify>1</notify>
<number>INC0000055</number>
<opened_at>2014-03-07 04:47:23</opened_at>
<opened_by>681b365ec0a80164000fb0b05854a0cd</opened_by>
<order/>
<parent/>
<parent_incident/>
<priority>1</priority>
<problem_id>d7296d02c0a801670085e737da016e70</problem_id>
<reassignment_count>0</reassignment_count>
<rejection_goto/>
<reopen_count/>
<resolved_at/>
<resolved_by/>
<rfc/>
<severity>3</severity>
<short_description>SAP Sales app is not accessible</short_description>
<sla_due>2014-03-06 12:47:23</sla_due>
<state>1</state>
<subcategory/>
<sys_class_name>incident</sys_class_name>
<sys_created_by>itil</sys_created_by>
<sys_created_on>2014-03-07 04:49:39</sys_created_on>
<sys_domain>global</sys_domain>
<sys_id>d71f7935c0a8016700802b64c67c11c6</sys_id>
<sys_mod_count>2</sys_mod_count>
<sys_updated_by>glide.maint</sys_updated_by>
<sys_updated_on>2014-03-06 20:49:14</sys_updated_on>
<time_worked/>
<upon_approval>proceed</upon_approval>
<upon_reject>cancel</upon_reject>
<urgency>1</urgency>
<user_input/>
<variables/>
<watch_list/>
<wf_activity/>
<work_end/>
<work_notes/>
<work_notes_list/>
<work_start/>
</incident>
<incident>
<active>true</active>
<activity_due>2014-03-06 22:49:08</activity_due>
<approval>not requested</approval>
<approval_history/>
<approval_set/>
<assigned_to>681b365ec0a80164000fb0b05854a0cd</assigned_to>
<assignment_group>d625dccec0a8016700a222a0f7900d06</assignment_group>
<business_duration/>
<business_stc/>
<calendar_duration/>
<calendar_stc/>
<caller_id>97000fcc0a0a0a6e0104ca999f619e5b</caller_id>
<category>software</category>
<caused_by/>
<child_incidents/>
<close_code/>
<close_notes/>
<closed_at/>
<closed_by/>
<cmdb_ci>26e44e8a0a0a0bb40095ff953f9ee520</cmdb_ci>
<comments/>
<comments_and_work_notes/>
<company/>
<contact_type>phone</contact_type>
<correlation_display/>
<correlation_id/>
<delivery_plan/>
<delivery_task/>
<description/>
<due_date/>
<escalation>3</escalation>
<expected_start/>
<follow_up/>
<group_list/>
<impact>1</impact>
<incident_state>1</incident_state>
<knowledge>false</knowledge>
<location>db9a923c0a0a0a6501068d6eaec25ee0</location>
<made_sla>true</made_sla>
<notify>1</notify>
<number>INC0000054</number>
<opened_at>2014-03-06 20:49:08</opened_at>
<opened_by>681b365ec0a80164000fb0b05854a0cd</opened_by>
<order/>
<parent/>
<parent_incident/>
<priority>1</priority>
<problem_id>d7296d02c0a801670085e737da016e70</problem_id>
<reassignment_count>0</reassignment_count>
<rejection_goto/>
<reopen_count/>
<resolved_at/>
<resolved_by/>
<rfc/>
<severity>3</severity>
<short_description>There seems to be some slowness or an out to SAP Materials Management</short_description>
<sla_due>2014-03-06 12:45:24</sla_due>
<state>1</state>
<subcategory/>
<sys_class_name>incident</sys_class_name>
<sys_created_by>itil</sys_created_by>
<sys_created_on>2014-03-06 20:49:08</sys_created_on>
<sys_domain>global</sys_domain>
<sys_id>d71da88ac0a801670061eabfe4b28f77</sys_id>
<sys_mod_count>2</sys_mod_count>
<sys_updated_by>glide.maint</sys_updated_by>
<sys_updated_on>2014-03-06 20:49:08</sys_updated_on>
<time_worked/>
<upon_approval>proceed</upon_approval>
<upon_reject>cancel</upon_reject>
<urgency>1</urgency>
<user_input/>
<variables/>
<watch_list/>
<wf_activity/>
<work_end/>
<work_notes/>
<work_notes_list/>
<work_start/>
</incident>
</xml>"

#set service now instance name
@sninstance_url = "https://#{instance_name}.service-now.com/"

#this method is for getting incidents by query_param and query value, we also need to specify the format
def getincidents(format, query_param, query_value)
	url = URI.parse("#{@sninstance_url}incident_list.do?#{format}&sysparm_query=#{query_param}=#{group_id}")
	http = Net::HTTP.new(url.host, url.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	req = Net::HTTP::Get.new(url.request_uri)
	req.basic_auth(@username, @password)
  	http.request(req)
end


#create our incident list array to capture the data
incident_list = Array.new

#httpresult = getincidents('XML','assignment_group','d625dccec0a8016700a222a0f7900d06')
#xmldoc = Document.new(httpresult.body)
xmldoc = Document.new(xmlraw)
#Now we are going to reiderate over all the XML data and get some data into an array
xmldoc.elements.each("xml/incident") do |inc| 
number = inc.elements['number'].text
opened = inc.elements['opened_at'].text
short_desc = inc.elements['short_description'].text
category = inc.elements['category'].text
priority = inc.elements['priority'].text

details = {number: number, desc: short_desc, opened: opened, category: category, priority: priority}
incident_list.push(details)
end

