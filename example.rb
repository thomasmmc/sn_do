#gets sample data from service now demo enviroment
require_relative 'sn_do'

#this is the group that we are getting data from in ServiceNow
assign_group_id = '8a4dde73c6112278017a6a4baf547aa7'
assignment_group = 'Software'

# SN_DO::INC.new('instance_name','username','password')
SN_DO::INC.new('demo017','admin','admin')

#SN_DO::INC.retrieve('format','query_param','query_value')
httpresult = SN_DO::INC.retrieve('XML','assignment_group', assign_group_id)

#SN_DO::INC.parse_xml('xml')
incident_list = SN_DO::INC.parse_xml(httpresult)

#basic count of total incidents
total_incidents = incident_list.count
puts "Total incidents for #{assignment_group} are #{total_incidents}"

#how to filter out an incident_state from our above array
#SN_DO::INC.filter(array, type, query_param, query_value)
filtered_incidents = SN_DO::INC.filter(incident_list, 'out', 'incident_state', '1')
puts "Incidents initialized #{filtered_incidents.count}"

#how to get a count of incidents by datediff where the value opened is less then 1
#SN_DO::INC.count_datediff(array, query_param, operator, diff)
openedlast_24 = SN_DO::INC.count_datediff(incident_list,'opened','less',1)
puts "New incidents last 24hrs #{openedlast_24}"

#how to get a count of incidents by datediff and the value opened is more then 7
#SN_DO::INC.count_datediff(array, query_param, operator, diff)
olderthen7days = SN_DO::INC.count_datediff(incident_list,'opened','more',7)
puts "Total incidents older then 7 days #{olderthen7days}"

#how to get a count of incidents by datediff and the value updated is more then 7
#SN_DO::INC.count_datediff(array, query_param, operator, diff)
notupdated7days = SN_DO::INC.count_datediff(incident_list,'updated','more',7)
puts "Total incidents not updated in 7 days #{notupdated7days}"

#how to get the details of incidents by datediff and the value updated is more then 7
#SN_DO::INC.details_datediff(array, query_param, operator, diff)
notupdated7days_details = SN_DO::INC.details_datediff(incident_list,'updated','more',7)

#Now we are going to add a url to each hash based on sys_id within the details we just got
notupdated7days_details.each do |inc|
	#SN_DO::INC.gen_url(sys_id)
 	link = SN_DO::INC.gen_url(inc[:sys_id])
 	inc[:url] = link
 end

#building our a list of these untouched incidents if there is any and display it
if notupdated7days_details.any?
 	info = "<b>Details on Incidents not updated for 7 days</b>\n<br>"
 	notupdated7days_details.each do |inc|
 		info << %Q^Number: <a href="#{inc[:url]}">#{inc[:number]}</a> Priority: #{inc[:priority]} Updated_by: #{inc[:updated_by]} Desc: #{inc[:short_desc]}\n<br>^
 	end
 	puts info
end

