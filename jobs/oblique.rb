require 'oblique_strategies'

SCHEDULER.every '1d', :first_in => 0 do |job|
	card = ObliqueStrategies.card
	
	# Update the dashboard
	send_event("oblique", { text: card, title: "Today's Oblique Strategy" })
	
end