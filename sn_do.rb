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
	url = URI.parse("#{@sninstance_url}incident_list.do?#{format}&sysparm_query=#{query_param}=#{query_value}")
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

#create our incident list array to capture the data
incident_list = Array.new

#Running getincidents for the assignment group specified in the yaml
httpresult = getincidents('XML','assignment_group', assign_group_id)
xmldoc = Document.new(httpresult.body)
#Now we are going to reiderate over all the XML data and get some info into an array
xmldoc.elements.each("xml/incident") do |inc|
	#we are accesing each element we want and adding the text to a variable
	number = inc.elements['number'].text
	opened = inc.elements['opened_at'].text
	short_desc = inc.elements['short_description'].text
	category = inc.elements['category'].text
	priority = inc.elements['priority'].text
	incident_state = inc.elements['incident_state'].text
	updated = inc.elements['sys_updated_on'].text
	# we are now loding are variables into a hash
	details = {number: number, desc: short_desc, opened: opened, category: category, priority: priority, incident_state: incident_state, updated: updated}
	#finaly we are loding our hashes into our array
	incident_list << details
end


total_incidents = incident_list.count
openedlast_24 = count_incidents_by_datediff(incident_list,:opened,'less',1)
olderthen7days = count_incidents_by_datediff(incident_list,:opened,'less',7)
notupdated7days = count_incidents_by_datediff(incident_list,:updated,'more',7)

puts openedlast_24
puts olderthen7days
puts notupdated7days