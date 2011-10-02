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

import sys
import itertools

#Description:
# Given an input menu and list of desired items, returns a reduced menu that
# only contains combos that has one or more of those items, with each item
# appearing at least once
#Inputs:
# menu - Nested list of form [[cost, item1, item2, item3, ...], [cost, item1, item2, item 3, ...], ...]
# items - List of desired menu items [item1, item2, item3, ...]
#Returns:
# Reduced menu with same structure as input menu
def reduce_menu(menu, items):
	reduced_menu = []
	flat_menu = []
	for combo in menu:		
		#Find intersection between combo and input items
		#Only keep combos that have at least one desired input
		if (len(list(set(combo[1:]) & set(items))) > 0):
			flat_menu.extend(combo[1:])
			reduced_menu.append(combo)
	#Check if any input items are missing from final menu
	if (len(list(set(flat_menu) & set(items))) != len(list(items))):
		return None
	return reduced_menu

#Description:
# Gets the price of a given combination of items from a restaurant's menu
#Inputs:
# menu - Nested list of form [[cost, item1, item2, item3, ...], [cost, item1, item2, item 3, ...], ...]
# item_combo - A possible combination of menu items, e.g. [0, 1, 1]
#Returns:
# The price as a float
def get_price(menu, item_combo):
	price = 0.0
	if (menu.length != item_combo.length):
		raise
	for i in range(len(item_combo)):
		price += float(menu[i][0]) * item_combo[i]
	return price

#Description:
# Generate a list of binary values of length n with 1 to n bits set
#Inputs:
# Length of list
#Returns:
# An array of arrays containing all possible lists, e.g. for an input of 2: [[0, 1], [1, 0], [1, 1]]
# List will be of length 2^n - 1
def get_item_combos(n):
	result = [] 
	for k in range(n):		
		for bits in itertools.combinations(range(n), k + 1):
			s = [0] * n
			for bit in bits:
				s[bit] = 1
			result.append(s)
	return result

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
def is_valid_combo(menu, item_combo, items):	
	if (menu.length != item_combo.length):
		raise
	has_items = {}
	for item in items:
		has_items[item] = False
	#For each menu item in the item combo, mark the item(s)
	#it contains in the has_items hash
	for x in range(len(item_combo)):
		if (item_combo[x] > 0):
			for y in range(len(menu[x]) - 1):
				has_items[menu[x][y + 1]] = True
	#Make sure all necessary items are accounted for
	for item in items:
		if (not has_items[item]):
			return False
	return True

#Description: 
# Given a restaurant's menu, finds the cheapest price for a set of items
#Inputs:
# menu - Nested list of form [[cost, item1, item2, item3, ...], [cost, item1, item2, item 3, ...], ...]
# items - A list of desired items [item1, item2, item3, ...]
#Returns: 
# The lowest cost, or None if the combination isn't found
def get_min_cost(menu, items):
	if (len(menu) == 0):
		return None
	elif (len(menu) == 1):
		return menu[0][0]
	else:
		min_price = float('inf')
		#Because prices are never non-negative and we assume that only one of any item is
		#desired, we can check only the limited number of combinations generated below
		item_combos = get_item_combos(len(menu))
		for item_combo in item_combos:
			#Check if the given combination will satisfy the constraints
			if is_valid_combo(menu, item_combo, items):
				#If so, check the price
				combo_price = get_price(menu, item_combo)
				if combo_price < min_price:
					min_price = combo_price
		return min_price
	
#Entry point
def main():
	#Setup file I/O, input parameters, etc.
	f = None
	try:
		f = open(sys.argv[1], 'r')
	except:
		print "Could not open input file: " + sys.argv[1]
		return

	items = sys.argv[2:]
	if (len(items) == 0): 
		print "Invalid parameters: No items provided"
		return

	#Initialize tracking variables
	min_cost = float('inf')
	min_restaurant = None
	
	curr_restaurant = None
	
	menu = []
	reduced_menu = []

	#Generate menu for each restaurant from file and get min cost
	for line in f:		
		#Format each line
		line = line.strip('\r\n').split(',')
		line = [x.strip() for x in line]
		if (curr_restaurant != line[0]):
			#Before moving to new restaurant, check the lowest price of the
			#current restaurant and see if it's cheaper than what have
			if (len(menu) > 0):
				reduced_menu = reduce_menu(menu, items)
				if reduced_menu is not None:
					curr_min_cost = get_min_cost(reduced_menu, items)
					if ((curr_min_cost is not None) and (float(curr_min_cost) < float(min_cost))):
						min_cost = curr_min_cost
						min_restaurant = curr_restaurant
			curr_restaurant = line[0]
			menu = []
		#Add line to current restaurant's menu
		menu.append(line[1:])

	#Check one more time to since the last
	#line is not calculated in the above loop
	if (len(menu) > 0):
		reduced_menu = reduce_menu(menu, items)
		if reduced_menu is not None:
			curr_min_cost = get_min_cost(reduced_menu, items)
			if ((curr_min_cost is not None) and (float(curr_min_cost) < float(min_cost))):
				min_cost = curr_min_cost
				min_restaurant = curr_restaurant
	
	#Print out results
	if (min_restaurant is None):
		print None
	else:
		print str(min_restaurant) + ", " + str(min_cost)

if __name__ == "__main__":
    main()