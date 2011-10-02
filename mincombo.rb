#DESCRIPTION: 
# Given a list of restaurant menus and desired items, finds
# the restaurant with the cheapest combination as well as the associated price.
#
#NOTES:
# - Assumes that the user will only request one of a given item, although they may
# get more than one of that item (or additional unrequested items).
# - Assumes that restaurant menus are listed in order, i.e. all menu items or combinations for a
# restaurant will appear together.
# - Run-time is O(n*m*x) where n is the number of restaurants, m is the number of items on a
# restaurant menu (n * m ~ length of the file) and x is the number of items requested
# - Memory requirement is O(n*m)
#
#USAGE: 
# mincombo <input file name> <list of items>
# e.g.: mincombo menu1.txt coffee apples bananas
#

#Description:
# Given an input menu and list of desired items, returns a reduced menu that
# only contains combos that has one or more of those items, with each item
# appearing at least once
#Inputs:
# menu - Nested list of form [[cost, item1, item2, item3, ...], [cost, item1, item2, item 3, ...], ...]
# items - List of desired menu items [item1, item2, item3, ...]
#Returns:
# Reduced menu with same structure as input menu
def reduce_menu(menu, items)
	reduced_menu = []
	menu.each do |combo|
		#Find intersection between combo and input items
		#Only keep combos that have at least one desired input
		if ((combo & items).length > 0) 
			reduced_menu.push(combo)
		end
	end
	flat_menu = reduced_menu.flatten
	#Check if any input items are missing from final menu
	if ((flat_menu & items).length != items.length) 
		return nil
	end
	return reduced_menu
end

#Description:
# Gets the price of a given combination of items from a restaurant's menu
#Inputs:
# menu - Nested list of form [[cost, item1, item2, item3, ...], [cost, item1, item2, item 3, ...], ...]
# item_combo - A possible combination of menu items, e.g. [0, 1, 1]
#Returns:
# The price as a float
def get_price(menu, item_combo)
	price = 0.0
	if menu.length != item_combo.length 
		raise "Menu length doesn't match item combination length"
	end
	for i in (0..item_combo.length)
		price += (menu[i].to_a[0]).to_f * item_combo[i].to_f
	end
	return price
end

#Description:
# Generate a list of binary values of length n with 1 to n bits set
#Inputs:
# Length of list
#Returns:
# An array of arrays containing all possible lists, e.g. for an input of 2: [[0, 1], [1, 0], [1, 1]]
# List will be of length 2^n - 1
def get_item_combos(n)
	result = []
	(0..n).each do |k|		
		(0..n-1).to_a.combination(k + 1).each do |bits|
			s = [0] * n
			bits.each do |bit|
				s[bit] = 1
			end
			result.push(s)
		end
	end
	return result
end

#Description:
# Determines whether the given menu combination is valid based on a
# restaurant's menu and the items the user wants.
#Inputs:
# menu - Nested list of form [[cost, item1, item2, item3, ...], [cost, item1, item2, item 3, ...], ...]
# item_combo - A possible combination of menu items, e.g. [0, 1, 1]
# items - List of desired items [item1, item2, item3, ...]
#Returns:
# True if it is a valid combination (i.e. the combination contains at least one of each item).
# False otherwise.
def is_valid_combo?(menu, item_combo, items)
	if menu.length != item_combo.length 
		raise "Menu length doesn't match item combination length"
	end
	has_items = {}
	items.each do |item|
		has_items[item] = false
	end
	#For each menu item in the item combo, mark the item(s)
	#it contains in the has_items hash
	(0..item_combo.length).each do |x|
		if (item_combo[x] != nil) and (item_combo[x] > 0) 
			(0..(menu[x].length - 1)).each do |y|
				has_items[menu[x][y + 1]] = true
			end
		end
	end
	#Make sure all necessary items are accounted for
	items.each do |item|
		if (not has_items[item]) 
			return false
		end
	end
	return true
end

#Description: 
# Given a restaurant's menu, finds the cheapest price for a set of items
#Inputs:
# menu - Nested list of form [[cost, item1, item2, item3, ...], [cost, item1, item2, item 3, ...], ...]
# items - A list of desired items [item1, item2, item3, ...]
#Returns: 
# The lowest cost, or None if the combination isn't found
def get_min_cost(menu, items)
	if (menu.length == 0) 
		return nil
	elsif (menu.length == 1)
		return menu[0].to_a[0]
	else
		min_price = (1.0/0.0)
		#Because prices are never non-negative and we assume that only one of any item is
		#desired, we can check only the limited number of combinations generated below
		item_combos = get_item_combos(menu.length)
		item_combos.each do |item_combo|
			#Check if the given combination will satisfy the constraints
			if is_valid_combo?(menu, item_combo, items) 
				#If so, check the price
				combo_price = get_price(menu, item_combo)
				if combo_price < min_price 
					min_price = combo_price
				end
			end
		end
		return min_price
	end
end
	
#Entry point
def main
	#Setup file I/O, input parameters, etc.
	if (ARGV.length < 1) 
		puts("Invalid arguments: Specify an input file")
		return
	elsif (ARGV.length == 1)
		puts("Invalid parameters: No items provided")
		return
	end
	
	items = ARGV[1..ARGV.length]
	
	f = nil
	begin
		f = File.open(ARGV[0], "r")
	rescue
		puts("Could not open input file: #{ARGV[0]}")
		return
	end

	#Initialize tracking variables
	min_cost = (1.0/0.0)
	min_restaurant = nil
	
	curr_restaurant = nil
	
	reduced_menu = {}
	menu = []

	#Generate menu for each restaurant from file and get min cost
	while (line = f.gets)
		#Format each line
		line = line.strip.split(',')
		line = line.collect{|x| x.strip}
		if (curr_restaurant != line[0]) 
			#Before moving to new restaurant, check the lowest price of the
			#current restaurant and see if it's cheaper than what have
			if (menu.length > 0) 
				reduced_menu = reduce_menu(menu, items)
				if (not reduced_menu.nil?)
					curr_min_cost = get_min_cost(reduced_menu, items)					
					if ((not curr_min_cost.nil?) and ((curr_min_cost.to_f) < (min_cost.to_f)))
						min_cost = curr_min_cost
						min_restaurant = curr_restaurant
					end
				end
			end
			curr_restaurant = line[0]
			menu.clear
		end
		#Add line to current restaurant's menu
		menu.push(line[1..line.length])
	end
	#Check one more time to since the last
	#line is not calculated in the above loop
	if (menu.length > 0) 
		reduced_menu = reduce_menu(menu, items)
		if (not reduced_menu.nil?) 
			curr_min_cost = get_min_cost(reduced_menu, items)
			if ((not curr_min_cost.nil?) and ((curr_min_cost.to_f) < (min_cost.to_f))) 
				min_cost = curr_min_cost
				min_restaurant = curr_restaurant
			end
		end
	end
	
	#Print out results
	if (min_restaurant.nil?) 
		puts(nil)
	else
		puts("#{min_restaurant}, #{min_cost}")
	end
end

if __FILE__ == $PROGRAM_NAME 
	main
end