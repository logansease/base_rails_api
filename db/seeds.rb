# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

User.delete_all
user = User.create(:name => 'Logan Sease', :password => 'password', :password_confirmation => 'password', :email => 'testuser@gmail.com')
user.update_attribute("activated", true)
user.update_attribute("admin", true)