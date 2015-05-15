class GrubstersController < ApplicationController
	skip_before_action :verify_authenticity_token		#needed for twilio api to work in rails

	def index
	end

	def send_msg
		phone_num = params['phone_num']		#assign user phone number
		
		#******************Whitepages Setup**********************
		api_key = "xxxx"
		api_url = "https://proapi.whitepages.com/2.1/phone.json?api_key=#{api_key}&phone_number=#{phone_num}"
		response = HTTParty.get(api_url).parsed_response
		first_name = response['results'][0]['belongs_to'][0]['names'][0]['first_name']
		whitepages = response['results'][0]['best_location']['standard_address_location']		#get zip code info
		temp = whitepages.split.last 		#split string to get zip code
		zipcode = temp[0..4]
		puts "first name: #{first_name}"
		puts "white zip: #{zipcode}"

		#*********************Yelp Setup*************************
		current_time = Time.now.hour		#returns 0-23
		puts "current time #{current_time}"
		#loop to figure out if it's: breakfast, lunch or dinner
		if current_time >= 5 || current_time <= 11 		#breakfast
			eat_time = "breakfast"
		elsif current_time >= 12 || current_time <= 15 		#lunch
			eat_time = "lunch"
		elsif current_time >= 16 || current_time <= 21 		#dinner
			eat_time = "dinner"
		else
			eat_time = "food"
		end 

		random_choice = rand(0..15)		#random number for yelp results
		puts "random choice: #{random_choice}"
		filters = { term: eat_time,
								sort: 2
           	    #limit: 1
         	    }
		yelps = Yelp.client.search(zipcode, filters)
		base_url = yelps.businesses[random_choice]
		@image_url = base_url.image_url		#grab result image
		@name = base_url.name.to_s		#grab result name
		@mobile_url = base_url.mobile_url		#grab mobile url
		postal_code = base_url.location.postal_code		#grab result postal code
		puts "yelp zip: #{postal_code}"

		#*******************ZipCodeApi Setup*********************
		app_key = "nHLVXNuDkkjqsOBh115cfrYBhooiKdv7Vh3S5xvpSPPkDqCFsHRI9QjqfIIZVe7Q"
		app_url = "https://www.zipcodeapi.com/rest/#{app_key}/distance.json/#{zipcode}/#{postal_code}/mile"
		distance = HTTParty.get(app_url).parsed_response
		@miles = distance['distance'].round
		puts "miles: #{@miles}"

		#*******************Twilio Setup*************************
		account_sid = "ACf155d8e33ae41b4b103318fdafc2b93d"
		auth_token = "b1bf4ecc85b18ffaf0ad9edea9f2f35b"
		@from = "+19493976328"		#my Twilio number
		@friends = { "+1#{phone_num}" => "#{first_name}",		#array to store user number and my number		
								 "+17142359516" => "Jerry"
							 }
		@client = Twilio::REST::Client.new account_sid, auth_token
	end
end