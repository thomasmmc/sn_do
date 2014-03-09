require 'yaml'
require 'net/https'
require 'rexml/document'
include REXML

#Loading YAML variables
config = YAML.load_file("sn_do_config.yml")
instance_name = config["instance_name"]
@username = config["username"]
@password = config["password"]
assign_group_id = config["assign_group_id"]

#set service now instance name
@sninstance_url = "https://#{instance_name}.service-now.com/"

#this method is for getting incidents by query_param and query value, we also need to specify the format
def getincidents(format, query_param, query_value)
	url = URI.parse("#{@sninstance_url}incident_list.do?#{format}&sysparm_query=active=true%5E#{query_param}=#{query_value}")
	http = Net::HTTP.new(url.host, url.port)
	http.use_ssl = true
	http.verify_mode = OpenSSL::SSL::VERIFY_NONE
	req = Net::HTTP::Get.new(url.request_uri)
	req.basic_auth(@username, @password)
  	http.request(req)
end

# count incidents by diffrence in date value
def count_incidents_by_datediff(array, hash, operator, diff)
	count = 0
	today = Date.today
	array.each do |inc|
		#comparing each opened date with today via MonthJulianDay (mjd) and couting any that are <= value
		if operator == 'less'
			count = count + 1  if (today.mjd - Date.parse(inc[hash]).mjd) <= diff 
		elsif operator == 'more'
			count = count + 1  if (today.mjd - Date.parse(inc[hash]).mjd) >= diff
		elsif operator == 'eq'
			count = count + 1  if (today.mjd - Date.parse(inc[hash]).mjd) == diff
		else
			return 'not a valid operator'
		end
	end
	count
end

# get incident number by diffrence in date value
def incidentdetails_by_datediff(array, hash, operator, diff)
	today = Date.today
	results = Array.new
	array.each do |inc|
		#comparing each opened date with today via MonthJulianDay (mjd) and couting any that are <= value
		if operator == 'less'
			results << inc if (today.mjd - Date.parse(inc[hash]).mjd) <= diff
		elsif operator == 'more'
			results << inc if (today.mjd - Date.parse(inc[hash]).mjd) >= diff
		elsif operator == 'eq'
			results << inc if (today.mjd - Date.parse(inc[hash]).mjd) == diff
		else
			return 'not a valid operator'
		end
	end
	results
end

#Generates a indicent url based on instance and sys_id, this is used to quickly access an incident
def generate_incident_url(instance, sys_id)
	url = "https://#{instance}.service-now.com/nav_to.do?uri=incident.do?sys_id=#{sys_id}"
	url
end

#get incident details
def get_incident_details(array, number)
	results = array.select do |inc|
		inc[:number] == number
	end
	results
end

#create our incident list array to capture the data
incident_list = Array.new

#Running getincidents for the assignment group specified in the yaml
httpresult = getincidents('XML','assignment_group', assign_group_id)
xmldoc = Document.new(httpresult.body)
#xmldoc = Document.new(xmlraw)
#Now we are going to reiderate over all the XML data and get some info into an array
xmldoc.elements.each("xml/incident") do |inc|
	details = Hash.new
	#we are accesing each element we want and adding the text our hash
	details[:number] = inc.elements['number'].text
	details[:sys_id] = inc.elements['sys_id'].text
	details[:opened] = inc.elements['opened_at'].text
	details[:short_desc] = inc.elements['short_description'].text
	details[:category] = inc.elements['category'].text
	details[:priority] = inc.elements['priority'].text
	details[:incident_state] = inc.elements['incident_state'].text
	details[:updated] = inc.elements['sys_updated_on'].text
	details[:updated_by] = inc.elements['sys_updated_by'].text
	#finaly we are loding our hash into our array
	incident_list << details
end

total_incidents = incident_list.count
openedlast_24 = count_incidents_by_datediff(incident_list,:opened,'less',1)
olderthen7days = count_incidents_by_datediff(incident_list,:opened,'more',7)
notupdated7days = count_incidents_by_datediff(incident_list,:updated,'more',7)
notupdated7days_details = incidentdetails_by_datediff(incident_list,:updated,'more',7)

#Now we are going to add a url to each hash based on sys_id and instance
notupdated7days_details.each do |inc|
	link = generate_incident_url(instance_name, inc[:sys_id])
	inc[:url] = link
end

puts "Total Incidents in queue #{total_incidents}"
puts "Total Incidents last day #{openedlast_24}"
puts "Total Incidents older the 7 days #{olderthen7days}"
puts "Total Incidents not updated 7 days #{notupdated7days}" 
if notupdated7days_details.any?
	info = "<b>Details on Incidents not updated for 7 days</b>\n"
	notupdated7days_details.each do |inc|
		info << %Q^Number: <a href="#{inc[:url]}">#{inc[:number]}</a> Priority: #{inc[:priority]} Updated_by: #{inc[:updated_by]} Desc: #{inc[:short_desc]}\n^
	end
end
puts info



